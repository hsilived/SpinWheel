//
//  SpinWheel.swift
//  SpinWheel
//
//  Created by Ron Myschuk on 2016-05-27.
//  Copyright © 2016 Orange Think Box. All rights reserved.
//

import Foundation
import SpriteKit

enum WheelState : Int {
    case stopped
    case ready
    case spinning
    case waiting
}

//protocol SpinSceneDelegate {
    
//}

class SpinWheel: SKSpriteNode {
    
    //var spinSceneDelegate: SpinSceneDelegate

    //MARK: - Local variables
    var wheel: SKSpriteNode!
    var flapper: SKSpriteNode!
    var pivotPin: SKSpriteNode!
    var springPin: SKSpriteNode!
    
    var wheelState: WheelState = .waiting
    var slots = [[String]]()
    var images = [SKSpriteNode]()
    var tickSound: SKAction!
    var errorSound: SKAction!
    var wonSound: SKAction!
    var wooshSound: SKAction!
    var startPos: CGFloat = 0
    
    var exitButton: PushButton!
    var wheelHub: PushButton!
    var dialogTitleLabel: SKLabelNode = SKLabelNode()
    var labelColor: SKColor = SKColor()
    var labelDarkColor: SKColor = SKColor()
    
    init(size: CGSize) {
        
        super.init(texture: nil, color: .clear, size: size)
        
        name = "spinWheel"
        
        self.size = size
        isUserInteractionEnabled = true
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        setupSounds()
        
        let background = SKSpriteNode(color: .blue, size: self.size)
        background.zPosition = -1
        addChild(background)
        
        // Note how prize end angle is 1 less than start angle of next prize so no overlap.
        //[title that displays when won, icon image, value of items won in String format, start angle (do not change), end angle (do not change)]
        slots = [
            ["40 coins", "wheel_prize_coin", "40", "0", "44"],
            ["100 coins", "wheel_prize_coin", "100", "45", "89"],
            ["200 coins", "wheel_prize_coin", "200", "90", "134"],
            ["40 coins", "wheel_prize_coin", "40", "135", "179"],
            ["400 coins", "wheel_prize_coin", "400", "180", "224"],
            ["100 coins", "wheel_prize_coin", "100", "225", "269"],
            ["40 coins", "wheel_prize_coin", "40", "270", "314"],
            ["a present", "wheel_prize_present", "", "315", "360"]
        ]
        
        labelColor = SKColor(white: 0.9, alpha:1.0)
        labelDarkColor = SKColor(white:0.2, alpha:1.0)

        createWheel()
        createFlapper()

        exitButton = PushButton(upImage: "button_blank_up", downImage: "button_blank_down")
        exitButton.name = "exitButton"
        exitButton.setButtonAction(target: self, event: .touchUpInside, function: closeSpinWheel, parent: self)
        exitButton.position = CGPoint(x: 0 - self.size.width / 2 + exitButton.size.width / 1.5, y: 0 - self.size.height / 2 + exitButton.size.height / 1.5)
        exitButton.createButtonText(buttonText: "done")
        exitButton.zPosition = self.zPosition + 100
        background.addChild(exitButton)
    }
    
    func setupSounds() {
        
        tickSound = SKAction.playSoundFileNamed("bubble_pop.aac", waitForCompletion: false)
        errorSound = SKAction.playSoundFileNamed("error.aac", waitForCompletion: false)
        wonSound = SKAction.playSoundFileNamed("victory.aac", waitForCompletion: false)
        wooshSound = SKAction.playSoundFileNamed("woosh.aac", waitForCompletion: false)
    }
    
    //MARK: - Create Prize Wheel Objects
    
    func createWheel() {
        
        wheel = SKSpriteNode(imageNamed: "wheel.png")
        wheel.position = CGPoint(x: 0, y: -110)
        wheel.name = "wheel"
        wheel.zPosition = 50
        
        let circleSize: CGFloat = 29
        let angleLength: CGFloat = cos(CGFloat.degreesToRadians(45)()) * (wheel.size.width / 2 - circleSize / 2)
        
        //the circles are the outer pegs of the wheel that interact with the flapper
        let circle1 = SKPhysicsBody(circleOfRadius: circleSize / 2, center: CGPoint(x: 0, y: wheel.size.height / 2 - circleSize / 2))
        let circle2 = SKPhysicsBody(circleOfRadius: circleSize / 2, center: CGPoint(x: (0 - wheel.size.width / 2) + circleSize / 2, y: 0))
        let circle3 = SKPhysicsBody(circleOfRadius: circleSize / 2, center: CGPoint(x: wheel.size.width / 2 - circleSize / 2, y: 0))
        let circle4 = SKPhysicsBody(circleOfRadius: circleSize / 2, center: CGPoint(x: 0, y: (0 - wheel.size.width / 2) + circleSize / 2))
        let circle5 = SKPhysicsBody(circleOfRadius: circleSize / 2, center: CGPoint(x: angleLength, y: angleLength))
        let circle6 = SKPhysicsBody(circleOfRadius: circleSize / 2, center: CGPoint(x: 0 - angleLength, y: 0 - angleLength))
        let circle7 = SKPhysicsBody(circleOfRadius: circleSize / 2, center: CGPoint(x: angleLength, y: 0 - angleLength))
        let circle8 = SKPhysicsBody(circleOfRadius: circleSize / 2, center: CGPoint(x: 0 - angleLength, y: angleLength))
        let center = SKPhysicsBody(circleOfRadius: 40)
        
        wheel.physicsBody = SKPhysicsBody(bodies: [center, circle1, circle2, circle3, circle4, circle5, circle6, circle7, circle8])
        wheel.physicsBody!.categoryBitMask = pegCategory
        wheel.physicsBody!.collisionBitMask = flapperCategory
        wheel.physicsBody!.contactTestBitMask = flapperCategory
        wheel.physicsBody!.isDynamic = true
        wheel.physicsBody!.affectedByGravity = false
        wheel.physicsBody!.mass = 200
        addChild(wheel)
        
        wheelHub = PushButton(upImage: "wheel_hub", downImage: "wheel_hub")
        wheelHub.setButtonAction(target: self, event: .touchUpInside, function: spinWheel, parent: self)
        wheelHub.zPosition = 500
        wheelHub.position = wheel.position
        wheelHub.bounce = false
        wheelHub.physicsBody = SKPhysicsBody(circleOfRadius: wheelHub.size.width / 2)
        wheelHub.physicsBody!.isDynamic = false
        addChild(wheelHub)

        loadSlotImages()
        
        wheel.zRotation = CGFloat.degreesToRadians(22.25)()
    }
    
    func createFlapper() {
        
        pivotPin = SKSpriteNode(imageNamed: "flapperDot.png")
        pivotPin.name = "flapperDot"
        pivotPin.position = CGPoint(x: 0, y: wheel.position.y + wheel.size.height / 2 + 63)
        pivotPin.zPosition = 0
        pivotPin.physicsBody = SKPhysicsBody(circleOfRadius: pivotPin.size.width / 2)
        pivotPin.physicsBody!.isDynamic = false
        addChild(pivotPin)
        
        flapper = SKSpriteNode(imageNamed: "flapper.png")
        flapper.position = CGPoint(x: 0, y: wheel.position.y + wheel.size.height / 2 + flapper.size.height / 3 + 10)
        flapper.zPosition = 500
        flapper.name = "flapper"
        flapper.physicsBody = SKPhysicsBody(texture: flapper.texture!, size: flapper.texture!.size())
        flapper.physicsBody!.isDynamic = true
        flapper.physicsBody!.allowsRotation = true
        flapper.physicsBody!.affectedByGravity = false
        flapper.physicsBody!.friction = 100.0
        flapper.physicsBody!.categoryBitMask = flapperCategory
        flapper.physicsBody!.collisionBitMask = pegCategory
        flapper.physicsBody!.contactTestBitMask = pegCategory
        flapper.physicsBody!.usesPreciseCollisionDetection = true
        addChild(flapper)
        
        springPin = SKSpriteNode(imageNamed: "flapperDot.png")
        springPin.name = "flapperDot"
        springPin.position = CGPoint(x: 0, y: flapper.position.y - flapper.size.height / 2 + 30)
        springPin.zPosition = 0
        springPin.physicsBody = SKPhysicsBody(circleOfRadius: springPin.size.width / 2)
        springPin.physicsBody!.isDynamic = false
        springPin.physicsBody!.categoryBitMask = 0
        springPin.physicsBody!.collisionBitMask = 0
        springPin.physicsBody!.contactTestBitMask = 0
//        springPin.physicsBody!.pinned = true
        addChild(springPin)
    }
    
    func initPhysicsJoints() {

        let wheelHubPositionConverted: CGPoint = self.convert(self.convert(self.wheelHub.position, from: self), to: self.scene!)
        self.scene?.physicsWorld.add(SKPhysicsJointPin.joint(withBodyA: self.wheelHub.physicsBody!, bodyB: self.wheel.physicsBody!, anchor: wheelHubPositionConverted))

//        //add spring to flapper so that it springs back after contact with wheel
        let flapperPositionConverted: CGPoint = self.convert(self.convert(self.flapper.position, from: self), to: self.scene!)
        let springPinPositionConverted: CGPoint = self.convert(self.convert(self.springPin.position, from: self), to: self.scene!)
        let pivotPinPositionConverted: CGPoint = self.convert(self.convert(self.pivotPin.position, from: self), to: self.scene!)
        self.scene?.physicsWorld.add(SKPhysicsJointSpring.joint(withBodyA: springPin.physicsBody!, bodyB: flapper.physicsBody!, anchorA: CGPoint(x: flapperPositionConverted.x, y: flapperPositionConverted.y - flapper.size.height / 2), anchorB: springPinPositionConverted))
        self.scene?.physicsWorld.add(SKPhysicsJointPin.joint(withBodyA: flapper.physicsBody!, bodyB: pivotPin.physicsBody!, anchor: pivotPinPositionConverted))
    }
    
    func findImagePlacement(_ slot: Int, shortLength: CGFloat, longLength: CGFloat) -> CGPoint {
        
        switch slot {
            
            case 1:
                return CGPoint(x: shortLength, y: longLength)
            case 2:
                return CGPoint(x: longLength, y: shortLength)
            case 3:
                return CGPoint(x: longLength, y: -shortLength)
            case 4:
                return CGPoint(x: shortLength, y: -longLength)
            case 5:
                return CGPoint(x: -shortLength, y: -longLength)
            case 6:
                return CGPoint(x: -longLength, y: -shortLength)
            case 7:
                return CGPoint(x: -longLength, y: shortLength)
            case 8:
                return CGPoint(x: -shortLength, y: longLength)
            default:
                return CGPoint.zero
        }
    }
    
    func loadSlotImages() {
        
        let interval = CGFloat(360 / slots.count)
        let offset: CGFloat = interval / CGFloat(2)
        let length: CGFloat = wheel.size.width / 3 + 10
        let shortLength: CGFloat = sin(CGFloat.degreesToRadians(22.5)()) * length
        let longLength: CGFloat = cos(CGFloat.degreesToRadians(22.5)()) * length
        
        for x in 0..<slots.count {
            
            let degree: CGFloat = offset + (interval * CGFloat(x))
            //print("image degree \(degree)")
            let prizeImage: SKSpriteNode = SKSpriteNode(imageNamed: slots[x][1] )
            prizeImage.position = findImagePlacement(x + 1, shortLength: shortLength, longLength: longLength)
            prizeImage.zRotation = CGFloat.degreesToRadians(-degree)()
            prizeImage.name = "prize"
            prizeImage.zPosition = 500
            wheel.addChild(prizeImage)
            
            let prizeText: SKLabelNode = SKLabelNode(fontNamed: kGameFont)
            prizeText.text = slots[x][2]
            prizeText.fontSize = 38.0
            prizeText.fontColor = SKColor(white: 0.125, alpha: 1.0)
            prizeText.position = CGPoint(x: 0, y: -110)
            prizeImage.addChild(prizeText)
            images.append(prizeImage)
        }
    }
    
    //MARK: - Game Loop
    
    func updateWheel(_ currentTime: TimeInterval) {
        
        if wheel.physicsBody!.isResting && wheelState == .spinning {
            
            wheelState = .stopped
            var degree = CGFloat.radiansToDegrees(wheel.zRotation)()
            //print("resting rad? \(wheel.zRotation)")
            //print("resting degree ? \(degree)")
            
            if degree < 0 {
                degree = 360 + degree
            }
            
            for x in 0..<slots.count {
                
                if (degree >= CGFloat(Int(slots[x][3])!)) && (degree <= CGFloat(Int(slots[x][4])!)) {
                    print("You landed on \(slots[x][0]) slot and won \(slots[x][1])")
                    
                    won(prizeTitle: String(describing: slots[x][0]))
                    
                    highlightWin(x)
                    break
                }
            }
        }
    }
    
    func won(prizeTitle: String) {
        
        if prizeTitle == "a present" {
            //they've won a prize so do something with the it
        }
        else if prizeTitle.hasSuffix("coins")  {
            //they've won coins so do something with the coins
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if let firstNode = contact.bodyA.node as? SKSpriteNode, let secondNode = contact.bodyB.node as? SKSpriteNode {
            
            let object1: String = firstNode.name!
            let object2: String = secondNode.name!
            
            if (object1 == "wheel") || (object2 == "wheel") {
                run(tickSound)
            }
        }
    }

    //MARK: - Touch functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard wheelState != .spinning, kCanSwipeToSpinWheel else { return }
        
        for touch: UITouch in touches {
            
            let touchPoint: String = atPoint(touch.location(in: self)).name ?? ""
            
            if (touchPoint == "wheelHub") {
                spinWheel()
                return
            }
            
            if (touchPoint == "wheel") || (touchPoint == "prize") {
                wheelState = .ready
                startPos = touch.previousLocation(in: self).y
                return
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard wheelState == .ready, kCanSwipeToSpinWheel else { return }
        
        let touch: UITouch = touches.first!
        let positionInScene: CGPoint = touch.location(in: self)
        let impulse: CGFloat = (startPos - positionInScene.y) / 100
        rotate(impulse)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard wheelState == .ready, kCanSwipeToSpinWheel else { return }
        
        let touch: UITouch = touches.first!
        let positionInScene: CGPoint = touch.location(in: self)
        //print("start \(startPos)");
        //print("end \(positionInScene.y)");
        let impulse: CGFloat = fabs(startPos - positionInScene.y)
        spin(impulse)
        
        if impulse > 100 {
            wheelState = .spinning
        }
        else {
            run(errorSound)
        }
    }
    
    //MARK: - Wheel Turn functions
    
    func rotate(_ impulse: CGFloat) {
        
        // print("velocity \(impulse)", impulse);
        wheel.zRotation = wheel.zRotation - CGFloat.degreesToRadians(impulse)()
    }
    
    func spinWheel() {

        if kHubSpinsWheel && wheelState != .spinning {
            
            let spinPower = CGFloat.random(min: 400, max: 600)
            spin(spinPower)
            wheelState = .spinning
        }
    }
    
    func spin(_ impulse: CGFloat) {
        
        //print("velocity \(impulse)");
        wheel.physicsBody!.applyAngularImpulse(-(impulse * 30.0))
        wheel.physicsBody!.angularDamping = 1
        let maxAngularVelocity: CGFloat = 100
        wheel.physicsBody!.angularVelocity = min(wheel.physicsBody!.angularVelocity, maxAngularVelocity)
        
        run(wooshSound)
    }
    
    //MARK: - Highlight win functions
    
    func highlightWin(_ index: Int) {
        
        let temp: SKSpriteNode = images[index]
        
        run(wonSound)
        
        createBackgroundBlocker(index)
        
        explodeImage(temp, duration: 1.5)
        
        wheel.run(SKAction.wait(forDuration: 0.5)) {
            self.explodeImage(temp, duration: 0.5)
        }
        
        let emitter = SKEmitterNode(fileNamed: "SparkleBlast")!
        emitter.position = temp.position
        emitter.particlePositionRange = CGVector(dx: temp.size.width * 2, dy: temp.size.height * 2)
        emitter.zPosition = 11
        wheel.addChild(emitter)
    }
    
    func explodeImage(_ image: SKSpriteNode, duration: TimeInterval) {
        
        let prizeImage: SKSpriteNode = image.copy() as! SKSpriteNode
        prizeImage.zPosition = 500
        let scale: SKAction = SKAction.scale(to: 4, duration: duration)
        let fade: SKAction = SKAction.fadeAlpha(to: 0.2, duration: duration)
        let group: SKAction = SKAction.group([scale, fade])
        wheel.addChild(prizeImage)
        
        prizeImage.run(group) {
            prizeImage.removeFromParent()
        }
    }
    
    func createBackgroundBlocker(_ winnningIndex: Int) {
        
        let prizeTitle: String = slots[winnningIndex][0] 
        let prizeImage: String = slots[winnningIndex][1]
        
        let backgroundBlocker = SKSpriteNode(color: UIColor(white: 0.2, alpha: 0.9), size: self.size)
        backgroundBlocker.zPosition = 1599
        backgroundBlocker.alpha = 0
        self.addChild(backgroundBlocker)
        
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 1.0)
        backgroundBlocker.run(fadeIn)
    
        var youWonLabel = SKLabelNode(fontNamed: kGameFont)
        youWonLabel.text = "you won"
        youWonLabel.fontSize = 44.0
        youWonLabel.fontColor = SKColor(white: 0.9, alpha: 1.0)
        youWonLabel.position = CGPoint(x: 0, y: 0.15 * self.size.height / 2)
        youWonLabel.zPosition = 1600
        backgroundBlocker.addChild(youWonLabel)
        
        youWonLabel = SKLabelNode(fontNamed: kGameFont)
        youWonLabel.text = prizeTitle
        youWonLabel.fontSize = 44.0
        youWonLabel.fontColor = SKColor(white: 0.9, alpha: 1.0)
        youWonLabel.position = CGPoint(x: 0, y: 0.1 * self.size.height / 2)
        youWonLabel.zPosition = 1600
        backgroundBlocker.addChild(youWonLabel)
        
        let prize: SKSpriteNode = SKSpriteNode(imageNamed: prizeImage)
        prize.position = CGPoint(x: 0, y: 0)
        prize.zPosition = 5
        backgroundBlocker.addChild(prize)
        
        let continueButton: PushButton = PushButton(upImage: "button_continue_up", downImage: "button_continue_down")
        continueButton.setButtonAction(target: self, event: .touchUpInside, function: closeSpinWheel, parent: self)
        continueButton.position = CGPoint(x: 0, y: 0 - 0.35 * self.size.height / 2)
        continueButton.zPosition = 5
        backgroundBlocker.addChild(continueButton)
    }
    
    func closeSpinWheel() {

        self.removeFromParent()
    }
}
