static int32_t __CFRunLoopRun(CFRunLoopRef rl, 
                              CFRunLoopModeRef rlm, 
                              CFTimeInterval seconds,
                              Boolean stopAfterHandle, 
                              CFRunLoopModeRef previousMode) {
    
    uint64_t startTSR = mach_absolute_time();
    
    // RunLoop结束了，没有timer/source/observer
    if (__CFRunLoopIsStopped(rl)) {
        __CFRunLoopUnsetStopped(rl);
        return kCFRunLoopRunStopped;
    } else if (rlm->_stopped) {// mode的stop被设成了true，还可能设回来
        rlm->_stopped = false;
        return kCFRunLoopRunStopped;
    }
    
    // 发消息的port，初始化为NULL
    mach_port_name_t dispatchPort_jieShouXiaoXi = MACH_PORT_NULL;
    
    // 判断是否在主线程
    Boolean libdispatchQSafe = pthread_main_np() && 
    ((HANDLE_DISPATCH_ON_BASE_INVOCATION_ONLY && NULL == previousMode) || 
     (!HANDLE_DISPATCH_ON_BASE_INVOCATION_ONLY && 0 == _CFGetTSD(__CFTSDKeyIsInGCDMainQ)));
    
    // 如果当前是主线程 && runloop是主线程的runloop && 现在要跑的mode是commonModes之一
    // 那么就把mainqueue的port赋值给dispacthPort用于接收消息
    if (libdispatchQSafe && 
        (CFRunLoopGetMain() == rl) && 
        CFSetContainsValue(rl->_commonModes, rlm->_name)) {
        dispatchPort_jieShouXiaoXi = _dispatch_get_main_queue_port_4CF();
    }
    
#if USE_DISPATCH_SOURCE_FOR_TIMERS
    mach_port_name_t modeQueuePort = MACH_PORT_NULL;
    // __CFRunLoopMode中dispatch_queue_t的_queue属性，暂时不知道该属性用来干啥
    if (rlm->_queue) {
        modeQueuePort = _dispatch_runloop_root_queue_get_port_4CF(rlm->_queue);
        if (!modeQueuePort) {
            CRASH("Unable to get port for run loop mode queue (%d)", -1);
        }
    }
#endif
    
    // typedef NSObject<OS_dispatch_source> *dispatch_source_t
    // dispatch_source_t是一个NSObject对象
    // 使用GCD timer实现Runloop的超时机制
    dispatch_source_t timeout_timer = NULL;
    struct __timeout_context *timeout_context = (struct __timeout_context *)malloc(sizeof(*timeout_context));
    
    // 处理timer三种情况：立即超时；有效的超时时间；永不超时；
    // 这里有个问题，这个定时器是在什么线程执行的，又是在哪个runloop中？还是这个定时器用其他技术实现的？
    if (seconds <= 0.0) { // instant timeout
        seconds = 0.0;
        timeout_context->termTSR = 0ULL;
    } else if (seconds <= TIMER_INTERVAL_LIMIT) {// 一个有效的超时时间
        // 是否是主线程，如果是主线程将timer加入到主线程中，否则加入到后台线程中
        dispatch_queue_t queue = pthread_main_np() ? __CFDispatchQueueGetGenericMatchingMain() : __CFDispatchQueueGetGenericBackground();
        timeout_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_retain(timeout_timer);
        
        timeout_context->ds = timeout_timer;
        timeout_context->rl = (CFRunLoopRef)CFRetain(rl);
        timeout_context->termTSR = startTSR + __CFTimeIntervalToTSR(seconds);
        
        dispatch_set_context(timeout_timer, timeout_context); // source gets ownership of context
        dispatch_source_set_event_handler_f(timeout_timer, __CFRunLoopTimeout);
        dispatch_source_set_cancel_handler_f(timeout_timer, __CFRunLoopTimeoutCancel);
        
        uint64_t ns_at = (uint64_t)((__CFTSRToTimeInterval(startTSR) + seconds) * 1000000000ULL);
        dispatch_source_set_timer(timeout_timer, dispatch_time(1, ns_at), DISPATCH_TIME_FOREVER, 1000ULL);
        // 定时器开始执行
        dispatch_resume(timeout_timer);
    } else { // infinite timeout
        seconds = 9999999999.0;
        timeout_context->termTSR = UINT64_MAX;
    }
    
    // 声明一个用户执行消息处理的标识，默认是YES
    Boolean didDispatchPortLastTime = true;
    
    // 方法返回值在此处声明
    int32_t retVal = 0;
    
    // do..while循环体，处理runloop逻辑
    do {
        voucher_mach_msg_state_t voucherState = VOUCHER_MACH_MSG_STATE_UNCHANGED;
        voucher_t voucherCopy = NULL;

        uint8_t msg_buffer[3 * 1024];
        mach_msg_header_t *msg = NULL;
        mach_port_t livePort = MACH_PORT_NULL;
        
        
        // 获取rlm的端口集合
        __CFPortSet waitSet = rlm->_portSet;
        // 将runloop设置为可被唤醒的状态
        __CFRunLoopUnsetIgnoreWakeUps(rl);
        
        // 2. kCFRunLoopBeforeTimers runloop通知observers即将处理Timers
        if (rlm->_observerMask & kCFRunLoopBeforeTimers)  {
            __CFRunLoopDoObservers(rl, rlm, kCFRunLoopBeforeTimers);
        }
        // 3. kCFRunLoopBeforeSources runloop通知observers即将处理sources
        if (rlm->_observerMask & kCFRunLoopBeforeSources) {
            __CFRunLoopDoObservers(rl, rlm, kCFRunLoopBeforeSources);  
        } 
        
        // 3.1 ?? 这里先处理了一把block
        // 这里的block是哪里的block？如何处理？
        // 这里的block是存在runloop的block链表中的
        __CFRunLoopDoBlocks(rl, rlm);
        
        // 4. runloop开始处理source0事件
        Boolean sourceHandledThisLoop = __CFRunLoopDoSources0(rl, rlm, stopAfterHandle);
        if (sourceHandledThisLoop) {
            // 处理完source0之后又处理block，难道这里的block是source0产生的？
            __CFRunLoopDoBlocks(rl, rlm);
        }
        
        // 处理了source0事件 或者 暂且认为定时器时间到了
        Boolean poll = sourceHandledThisLoop || (0ULL == timeout_context->termTSR);
        
        // 这里会判断是否调到后面去执行source1事件
        if (MACH_PORT_NULL != dispatchPort_jieShouXiaoXi && !didDispatchPortLastTime) {
            // 从消息缓冲区获取消息
            msg = (mach_msg_header_t *)msg_buffer;
            // 
            if (__CFRunLoopServiceMachPort(dispatchPort_jieShouXiaoXi, &msg, sizeof(msg_buffer), &livePort, 0, &voucherState, NULL)) {
                goto handle_msg;
            }
        }
        
        didDispatchPortLastTime = false;
        
        // poll == NO  时才会通知observer runloop将要休眠
        // poll == YES 时runloop还是会休眠，但是不会对observer发送将要休眠的通知
        if (!poll && (rlm->_observerMask & kCFRunLoopBeforeWaiting)) {
            __CFRunLoopDoObservers(rl, rlm, kCFRunLoopBeforeWaiting);
        } 
        __CFRunLoopSetSleeping(rl);
        
        // do not do any user callouts after this point (after notifying of sleeping)
        
        // Must push the local-to-this-activation ports in on every loop
        // iteration, as this mode could be run re-entrantly and we don't
        // want these ports to get serviced.
        
        __CFPortSetInsert(dispatchPort_jieShouXiaoXi, waitSet);
        
        __CFRunLoopModeUnlock(rlm);
        __CFRunLoopUnlock(rl);
        
        CFAbsoluteTime sleepStart = poll ? 0.0 : CFAbsoluteTimeGetCurrent();
        
        // 
        do {
            if (kCFUseCollectableAllocator) {
                // objc_clear_stack(0);
                // <rdar://problem/16393959>
                memset(msg_buffer, 0, sizeof(msg_buffer));
            }
            // 从消息缓冲区获取消息
            msg = (mach_msg_header_t *)msg_buffer;
            // 内部调用 mach_msg() 等待接收waitSet的消息
            __CFRunLoopServiceMachPort(waitSet, &msg, sizeof(msg_buffer), &livePort, poll ? 0 : TIMEOUT_INFINITY, &voucherState, &voucherCopy);
            
            if (modeQueuePort != MACH_PORT_NULL && livePort == modeQueuePort) {
                // Drain the internal queue. If one of the callout blocks sets the timerFired flag, break out and service the timer.
                while (_dispatch_runloop_root_queue_perform_4CF(rlm->_queue));
                if (rlm->_timerFired) {
                    // Leave livePort as the queue port, and service timers below
                    rlm->_timerFired = false;
                    break;
                } else {
                    if (msg && msg != (mach_msg_header_t *)msg_buffer) free(msg);
                }
            } else {
                // Go ahead and leave the inner loop.
                break;
            }
        } while (1);
        
        __CFRunLoopLock(rl);
        __CFRunLoopModeLock(rlm);
        
        rl->_sleepTime += (poll ? 0.0 : (CFAbsoluteTimeGetCurrent() - sleepStart));
        
        // Must remove the local-to-this-activation ports in on every loop
        // iteration, as this mode could be run re-entrantly and we don't
        // want these ports to get serviced. Also, we don't want them left
        // in there if this function returns.
        
        __CFPortSetRemove(dispatchPort_jieShouXiaoXi, waitSet);
        
        // 设置runloop不再等待唤醒
        __CFRunLoopSetIgnoreWakeUps(rl);
        
        // 唤醒runloop
        // user callouts now OK again
        __CFRunLoopUnsetSleeping(rl);
        
        // 8. 通知observes runloop已经被唤醒
        if (!poll && (rlm->_observerMask & kCFRunLoopAfterWaiting)) __CFRunLoopDoObservers(rl, rlm, kCFRunLoopAfterWaiting);
        
        // 9. 处理消息
    handle_msg:;
        // 设置runloop不再等待唤醒
        __CFRunLoopSetIgnoreWakeUps(rl);
        
        // 9.1 如果不存在
        if (MACH_PORT_NULL == livePort) {
            CFRUNLOOP_WAKEUP_FOR_NOTHING();
            // handle nothing
        } else if (livePort == rl->_wakeUpPort) {// 9.2 
            CFRUNLOOP_WAKEUP_FOR_WAKEUP();
            // do nothing on Mac OS
        } else if (modeQueuePort != MACH_PORT_NULL && livePort == modeQueuePort) { // 9.3 如果是定时器端口
            CFRUNLOOP_WAKEUP_FOR_TIMER();
            if (!__CFRunLoopDoTimers(rl, rlm, mach_absolute_time())) {
                // Re-arm the next timer, because we apparently fired early
                __CFArmNextTimerInMode(rlm, rl);
            }
        } else if (rlm->_timerPort != MACH_PORT_NULL && livePort == rlm->_timerPort) { // 9.4 
            CFRUNLOOP_WAKEUP_FOR_TIMER();
            // On Windows, we have observed an issue where the timer port is set before the time which we requested it to be set. For example, we set the fire time to be TSR 167646765860, but it is actually observed firing at TSR 167646764145, which is 1715 ticks early. The result is that, when __CFRunLoopDoTimers checks to see if any of the run loop timers should be firing, it appears to be 'too early' for the next timer, and no timers are handled.
            // In this case, the timer port has been automatically reset (since it was returned from MsgWaitForMultipleObjectsEx), and if we do not re-arm it, then no timers will ever be serviced again unless something adjusts the timer list (e.g. adding or removing timers). The fix for the issue is to reset the timer here if CFRunLoopDoTimers did not handle a timer itself. 9308754
            if (!__CFRunLoopDoTimers(rl, rlm, mach_absolute_time())) {
                // Re-arm the next timer
                __CFArmNextTimerInMode(rlm, rl);
            }
        } else if (livePort == dispatchPort_jieShouXiaoXi) {// 9.5 如果是主线程端口
            CFRUNLOOP_WAKEUP_FOR_DISPATCH();
            __CFRunLoopModeUnlock(rlm);
            __CFRunLoopUnlock(rl);
            _CFSetTSD(__CFTSDKeyIsInGCDMainQ, (void *)6, NULL);

            __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__(msg);
            _CFSetTSD(__CFTSDKeyIsInGCDMainQ, (void *)0, NULL);
            __CFRunLoopLock(rl);
            __CFRunLoopModeLock(rlm);
            sourceHandledThisLoop = true;
            didDispatchPortLastTime = true;
        } else { // 9.6 其他
            CFRUNLOOP_WAKEUP_FOR_SOURCE();
            
            // If we received a voucher from this mach_msg, then put a copy of the new voucher into TSD. CFMachPortBoost will look in the TSD for the voucher. By using the value in the TSD we tie the CFMachPortBoost to this received mach_msg explicitly without a chance for anything in between the two pieces of code to set the voucher again.
            voucher_t previousVoucher = _CFSetTSD(__CFTSDKeyMachMessageHasVoucher, (void *)voucherCopy, os_release);
            
            // Despite the name, this works for windows handles as well
            // 从端口收到的消失事件为source1事件
            CFRunLoopSourceRef rls = __CFRunLoopModeFindSourceForMachPort(rl, rlm, livePort);
            if (rls) {
#if DEPLOYMENT_TARGET_MACOSX || DEPLOYMENT_TARGET_EMBEDDED || DEPLOYMENT_TARGET_EMBEDDED_MINI
                mach_msg_header_t *reply = NULL;
                // 处理source1事件
                sourceHandledThisLoop = __CFRunLoopDoSource1(rl, rlm, rls, msg, msg->msgh_size, &reply) || sourceHandledThisLoop;
                if (NULL != reply) {
                    (void)mach_msg(reply, MACH_SEND_MSG, reply->msgh_size, 0, MACH_PORT_NULL, 0, MACH_PORT_NULL);
                    CFAllocatorDeallocate(kCFAllocatorSystemDefault, reply);
                }
            }
            // Restore the previous voucher
            _CFSetTSD(__CFTSDKeyMachMessageHasVoucher, previousVoucher, os_release);
            
        } 
#if DEPLOYMENT_TARGET_MACOSX || DEPLOYMENT_TARGET_EMBEDDED || DEPLOYMENT_TARGET_EMBEDDED_MINI
        if (msg && msg != (mach_msg_header_t *)msg_buffer) free(msg);
#endif
        __CFRunLoopDoBlocks(rl, rlm);
        
        // 10. 返回处理结果
        if (sourceHandledThisLoop && stopAfterHandle) {
            retVal = kCFRunLoopRunHandledSource;
        } else if (timeout_context->termTSR < mach_absolute_time()) {
            retVal = kCFRunLoopRunTimedOut;
        } else if (__CFRunLoopIsStopped(rl)) {
            __CFRunLoopUnsetStopped(rl);
            retVal = kCFRunLoopRunStopped;
        } else if (rlm->_stopped) {
            rlm->_stopped = false;
            retVal = kCFRunLoopRunStopped;
        } else if (__CFRunLoopModeIsEmpty(rl, rlm, previousMode)) {
            retVal = kCFRunLoopRunFinished;
        }
        
#if DEPLOYMENT_TARGET_MACOSX || DEPLOYMENT_TARGET_EMBEDDED || DEPLOYMENT_TARGET_EMBEDDED_MINI
        voucher_mach_msg_revert(voucherState);
        os_release(voucherCopy);
#endif
        
    } while (0 == retVal);
    
    if (timeout_timer) {
        dispatch_source_cancel(timeout_timer);
        dispatch_release(timeout_timer);
    } else {
        free(timeout_context);
    }
    
    return retVal;
}

