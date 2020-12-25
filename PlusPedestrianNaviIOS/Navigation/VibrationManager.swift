//
//  VibrationManager.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 2020/12/24.
//  Copyright © 2020 박정규. All rights reserved.
//

import CoreHaptics

class VibrationManager {
    
    static let sharedInstance = VibrationManager()
    
    var engine: CHHapticEngine?
    
    let short1 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0)
    let short2 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.2)
    let short3 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.4)
    let long1 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 0.6, duration: 0.5)
    let long2 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 1.2, duration: 0.5)
    let long3 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 1.8, duration: 0.5)
    let short4 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.4)
    let short5 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.6)
    let short6 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.8)
    
    
    private init() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return
        }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
        
    }
    
    
    public func runVibration(text: String) {
        if (UserDefaultManager.isUseVibration()) {
            return
        }
        
        if (text.isEmpty) {
            return
        }
        
        guard engine != nil else {
            return
        }
        
        
        do {
            let events = getPattern(text: text)
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let engine = try CHHapticEngine()
            
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
        
        
    }
  
    
    private func getPattern(text: String) -> [CHHapticEvent] {
        var events: [CHHapticEvent] = [CHHapticEvent]()
        if (text.contains(LanguageManager.getString(key: "you_have_arrived"))) {
            events = [long1, short2,long1, short2,long1, short2,long1, short2,long1, short2,long1, short2,long1, short2,long1, short2]
        } else if (text.contains(LanguageManager.getString(key: "six_oclock"))) {
            events = [long1, short2, long1, short2,long1, short2,long1, short2]
        } else if (text.contains(LanguageManager.getString(key:"turn_left"))) {
            events = [long1, short2, long1, short2]
        } else if (text.contains(LanguageManager.getString(key:"turn_right"))) {
            events = [long1, short2,long1, short2,long1, short2]
        } else {
            events = [long1, short2]
        }
        
        return events
    }
    
    
}
