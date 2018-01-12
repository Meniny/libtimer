//
//  GCDTimer.swift
//  libtimer
//
//  Blog  : https://meniny.cn
//  Github: https://github.com/Meniny
//
//  No more shall we pray for peace
//  Never ever ask them why
//  No more shall we stop their visions
//  Of selfdestructing genocide
//  Dogs on leads march to war
//  Go ahead end it all...
//
//  Blow up the world
//  The final silence
//  Blow up the world
//  I don't give a damn!
//
//  Screams of terror, panic spreads
//  Bombs are raining from the sky
//  Bodies burning, all is dead
//  There's no place left to hide
//  Dogs on leads march to war
//  Go ahead end it all...
//
//  Blow up the world
//  The final silence
//  Blow up the world
//  I don't give a damn!
//
//  (A voice was heard from the battle field)
//
//  "Couldn't care less for a last goodbye
//  For as I die, so do all my enemies
//  There's no tomorrow, and no more today
//  So let us all fade away..."
//
//  Upon this ball of dirt we lived
//  Darkened clouds now to dwell
//  Wasted years of man's creation
//  The final silence now can tell
//  Dogs on leads march to war
//  Go ahead end it all...
//
//  Blow up the world
//  The final silence
//  Blow up the world
//  I don't give a damn!
//
//  When I wrote this code, only I and God knew what it was.
//  Now, only God knows!
//
//  So if you're done trying 'optimize' this routine (and failed),
//  please increment the following counter
//  as a warning to the next guy:
//
//  total_hours_wasted_here = 0
//
//  Created by Elias Abel on 2017/8/09.
//  Copyright © 2017 Meniny Lab. All rights reserved.
//

import Foundation

open class GCDTimer {
    
    private let internalTimer: DispatchSourceTimer
    
    private var isRunning = false
    
    open let repeats: Bool
    
    public typealias ActionClosure = (_ timer: GCDTimer) -> Swift.Void
    
    open var actionClosure: GCDTimer.ActionClosure
    
    public init(_ interval: DispatchTimeInterval, repeats: Bool, queue: DispatchQueue = .main, action: @escaping GCDTimer.ActionClosure) {
        
        self.actionClosure = action
        self.repeats = repeats
        internalTimer = DispatchSource.makeTimerSource(queue: queue)
        internalTimer.setEventHandler { [weak self] in
            if let strongSelf = self {
                action(strongSelf)
            }
        }
        
        if repeats {
            internalTimer.schedule(deadline: .now() + interval, repeating: interval)
        } else {
            internalTimer.schedule(deadline: .now() + interval)
        }
    }
    
    open static func repeatic(_ interval: DispatchTimeInterval, queue: DispatchQueue = .main, action: @escaping GCDTimer.ActionClosure) -> GCDTimer {
        return GCDTimer(interval, repeats: true, queue: queue, action: action)
    }
    
    deinit {
        if !self.isRunning {
            internalTimer.resume()
        }
    }
    
    //You can use this method to fire a repeating timer without interrupting its regular firing schedule. If the timer is non-repeating, it is automatically invalidated after firing, even if its scheduled fire date has not arrived.
    open func fire() {
        if repeats {
            actionClosure(self)
        } else {
            actionClosure(self)
            internalTimer.cancel()
        }
    }
    
    open func start() {
        if !isRunning {
            internalTimer.resume()
            isRunning = true
        }
    }
    
    open func suspend() {
        if isRunning {
            internalTimer.suspend()
            isRunning = false
        }
    }
    
    open func rescheduleRepeating(_ interval: DispatchTimeInterval) {
        if repeats {
            internalTimer.schedule(deadline: .now() + interval, repeating: interval)
        }
    }
    
    open func rescheduleAction(_ action: @escaping GCDTimer.ActionClosure) {
        self.actionClosure = action
        internalTimer.setEventHandler { [weak self] in
            if let strongSelf = self {
                action(strongSelf)
            }
        }
        
    }
}

//MARK: Throttle
public extension GCDTimer {
    
    private static var timers: [String: DispatchSourceTimer] = [:]
    
    public static func throttle(_ interval: DispatchTimeInterval, identifier: String, queue: DispatchQueue = .main, action: @escaping () -> Void ) {
        
        if let previousTimer = timers[identifier] {
            previousTimer.cancel()
            timers.removeValue(forKey: identifier)
        }
        
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timers[identifier] = timer
        timer.schedule(deadline: .now() + interval)
        timer.setEventHandler {
            action()
            timer.cancel()
            timers.removeValue(forKey: identifier)
        }
        timer.resume()
    }
    
    public static func cancelThrottlingTimer(identifier: String) {
        if let previousTimer = timers[identifier] {
            previousTimer.cancel()
            timers.removeValue(forKey: identifier)
        }
    }
    
    
    
}

//MARK: Count Down
open class GCDCountDownTimer {
    
    private let internalTimer: GCDTimer
    
    private var leftTimes: Int
    
    private let originalTimes: Int
    
    public typealias ActionClosure = (_ timer: GCDCountDownTimer, _ leftTimes: Swift.Int) -> Swift.Void
    
    private let actionClosure: GCDCountDownTimer.ActionClosure
    
    public init(_ interval: DispatchTimeInterval, times: Int, queue: DispatchQueue = .main, action: @escaping GCDCountDownTimer.ActionClosure) {
        
        self.leftTimes = times
        self.originalTimes = times
        self.actionClosure = action
        self.internalTimer = GCDTimer.repeatic(interval, queue: queue, action: { _ in
            
        })
        self.internalTimer.rescheduleAction { [weak self]  swiftTimer in
            if let strongSelf = self {
                if strongSelf.leftTimes > 0 {
                    strongSelf.leftTimes = strongSelf.leftTimes - 1
                    strongSelf.actionClosure(strongSelf, strongSelf.leftTimes)
                } else {
                    strongSelf.internalTimer.suspend()
                }
            }
        }
    }
    
    open func start() {
        self.internalTimer.start()
    }
    
    open func suspend() {
        self.internalTimer.suspend()
    }
    
    open func reCountDown() {
        self.leftTimes = self.originalTimes
    }
    
}

public extension DispatchTimeInterval {
    
    public static func fromSeconds(_ seconds: Double) -> DispatchTimeInterval {
        return DispatchTimeInterval.milliseconds(Int(seconds * 1000))
    }
}

