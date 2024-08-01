//
//  touch.swift
//  CrashyPlane
//
//  Created by Shubham Nanda on 31/07/24.
//

import Foundation
import SpriteKit
import FirebaseDatabase
import FirebaseAuth
class touch {
    
    func glow(button: SKSpriteNode){
        let glowAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 1.0, duration: 1.0),
            SKAction.fadeAlpha(to: 0.8, duration: 1.0)
            
        ])
        button.run(SKAction.repeatForever(glowAction))}
    func ui(button: SKSpriteNode){
        button.run(SKAction.sequence([
            SKAction.scale(to: 0.9, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
    }
    func fetchPremiumStatus(completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let ref = Database.database().reference().child("users").child(userID)
        ref.observeSingleEvent(of: .value) { snapshot in
            if let data = snapshot.value as? [String: Any],
               let isPremium = data["isPremiumUser"] as? Bool {
                completion(isPremium)
            } else {
                completion(false)
            }
        } withCancel: { error in
            print("Failed to fetch premium status: \(error.localizedDescription)")
            completion(false)
        }
    }
}
