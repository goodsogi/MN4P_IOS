//
//  VibrationManager.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 2020/12/24.
//  Copyright © 2020 박정규. All rights reserved.
//

import CoreHaptics

class VibrationManager {


let short1 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0)
    let short2 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.2)
    let short3 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.4)
    let long1 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 0.6, duration: 0.5)
    let long2 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 1.2, duration: 0.5)
    let long3 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 1.8, duration: 0.5)
    let short4 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.4)
    let short5 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.6)
    let short6 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.8)

    
    public static func runVibration(message: String) {
            if (UserDefaultManager.isUseVibration()) {
                return
            }

            if (message.isEmpty) {
                return
            }
        
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        
        
        do {
                let pattern = try CHHapticPattern(events: [short1, short2, short3, long1, long2, long3, short4, short5, short6], parameters: [])
            let engine = try CHHapticEngine()
                let player = try engine?.makePlayer(with: pattern)
                try player?.start(atTime: 0)
            } catch {
                print("Failed to play pattern: \(error.localizedDescription).")
                   }

        
        

            if (message.contains(context.getString(R.string.you_have_arrived))) {
                selectedPattern = VIBRATION_PATTERN_ARRIVE;
            } else if (message.toLowerCase().contains(context.getString(R.string.six_oclock))) {
                selectedPattern = VIBRATION_PATTERN_BACK;
            } else if (message.toLowerCase().contains(context.getString(R.string.turn_left))) {
                selectedPattern = VIBRATION_PATTERN_LEFT;
            } else if (message.toLowerCase().contains(context.getString(R.string.turn_right))) {
                selectedPattern = VIBRATION_PATTERN_RIGHT;
            } else {
                selectedPattern = VIBRATION_PATTERN_STRAIGHT;
            }

            vibrator.vibrate(selectedPattern, -1);
        }
    
    
    
    
    
}
