//
//  GameScene.swift
//  SpinWheel
//
//  Created by Ron Myschuk on 2018-04-07.
//  Copyright © 2018 Orange Think Box. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var spinWheelOpen = false
    private var spinWheel: SpinWheel!
    
    override func didMove(to view: SKView) {
        
       setup()
    }
    
    func setup() {
        
        self.physicsWorld.contactDelegate = self
        
        if let spinButton = self.childNode(withName: "//spinButton") as? PushButton {
            spinButton.quickSetUpWith(action: { self.displaySpinWheel() })
            spinButton.buttonImage = "spin_icon"
        }
        
    }
    
    func displaySpinWheel() {
        
        print("spin wheel")
        spinWheel = SpinWheel(size: self.size)
        spinWheel.zPosition = 500
        addChild(spinWheel)
        
        spinWheel.initPhysicsJoints()
        
        spinWheelOpen = true
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if spinWheelOpen {
            spinWheel.didBegin(contact)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if spinWheelOpen {
            spinWheel.updateWheel(currentTime)
        }
    }
}
