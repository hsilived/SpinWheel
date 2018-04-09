import SpriteKit

enum ButtonActionType: Int {
    
    case touchUpInside = 1
    case touchDown = 2
    case touchUp = 3
}

class PushButton: SKSpriteNode {
    
    //let gameModel: GameModel = GameModel()
    
    let kButtonFontColor = SKColor(white: 0.9, alpha: 1.0)//SKColorWithRGB(38, g: 163, b: 222)
    
    var turbo: Bool = false
    private var isPressed: Bool?
    var toggle: Bool = false
    var bounce: Bool = true
    private var priorToggle: Bool = false
    var image: SKSpriteNode?
    var toggleImage: String?
    //var buttonImage: String?
    var sendTouchEventToParent: Bool = true
    
    private var upTexture: SKTexture?
    private var downTexture: SKTexture?
    private var disabledTexture: SKTexture?
    private var selectedTexture: SKTexture?
    private var initialPos: CGPoint = CGPoint.zero
    private var initialXScale: CGFloat = 1
    private var initialYScale: CGFloat = 1
    
    weak var buttonParent: SKNode?
    
    var stringAction: (() -> ())? = nil
    var actionType: ButtonActionType?
    var objectTouchUpInside: String?
    var hasText = false
    
    //MARK: custom properties
    
    var highlighted: Bool = false {
        
        didSet {
            
            //if highlighting grow the button
            //runAction(SKAction.scaleTo(highlighted ? 1.2 : 1.0, duration: 0.15))
            if downTexture == nil {
                run(SKAction.scaleX(to: highlighted ? xScale * 1.2 : initialXScale, y: highlighted ? yScale * 1.2 : initialYScale, duration: 0.15))
            }
            //runAction(SKAction.colorizeWithColor(highlighted ? .yellowColor() : .redColor(), colorBlendFactor: 1.0, duration: 0.15))
            
            if highlighted {
                
                guard isEnabled else { return }
                
                if !bounce {return }
                
                if downTexture != nil {
                    texture = downTexture
                }
                
                run(jiggleAction())
            }
            else {
                
                if downTexture != nil {
                    self.texture = upTexture
                }
                
                let wait: SKAction = SKAction.wait(forDuration: 0.15)
                let removeAllActions: SKAction = SKAction.run(self.removeAllActions)
                let seq: SKAction = SKAction.sequence([wait, removeAllActions])
                
                run(seq)
            }
        }
    }
    
    var isDepressed: Bool = false {
        
        didSet {
            
            guard isEnabled, selectedTexture == nil, downTexture == nil, !toggle else { return }
            
            run(SKAction.scaleX(to: isDepressed ? initialXScale * 0.8 : initialXScale * 1.0, y: isDepressed ? initialYScale * 0.8 : initialYScale * 1.0, duration: 0.15))
        }
    }
    
    var isToggled: Bool = false {
        
        didSet {
            
            guard toggle, toggleImage != nil, buttonImage != nil else { return }
            
            self.texture = SKTexture(imageNamed: isToggled ? toggleImage! : buttonImage!)
        }
    }
    
    var isSelected: Bool = false {
        
        didSet {
            
            guard isEnabled else { return }
            
            if selectedTexture != nil {
                self.texture = isSelected ? selectedTexture : upTexture
            }
            else {
                
                if downTexture != nil {// && !self.highlighted {
                    
                    self.texture = isSelected ? downTexture : upTexture
                    if hasText {
                        titleTextLabel.position = CGPoint(x: self.titleTextLabel.position.x, y: isSelected ? -2 : 0)
                    }
                }
            }
        }
    }
    
    var isEnabled: Bool = true {
        
        didSet {
            
            if isEnabled {
                
                let returnColor: SKAction = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.5)
                
                //if button has pending actions wait .5 seconds then reset it
                run(.wait(forDuration: self.hasActions() ? 0.5 : 0), completion: { [weak self] in self?.run(returnColor) })
                
                alpha = 1.0
            }
            else {
                
                //self.run(SKAction.colorizeWithColor(SKColor(white: 0.25, alpha: 0.8), colorBlendFactor: 0.5, duration: 0.0))
                //removeAllActions()
                run(.wait(forDuration: self.hasActions() ? 0.5 : 0)) { [weak self] in self?.run(.colorize(with: .black, colorBlendFactor: 0.3, duration: 0.2))
                }
            }
            
            if disabledTexture != nil {
                texture = isEnabled ? upTexture : disabledTexture
            }
        }
    }
    
    //MARK: button attributes
    
    var buttonImage: String? {

        didSet {

            image = SKSpriteNode(imageNamed: buttonImage!)
            image!.position = CGPoint(x: 0, y: 0)
            image?.zPosition = 10
            addChild(image!)
        }
    }
    
    func setButtonAction(target: AnyObject, event: ButtonActionType, function: Optional<() -> ()>, parent: SKNode!) {
        
        //let newAction: nil //Selector = Selector(action().description)
        stringAction = function
        actionType = event
        buttonParent = parent
    }
    
    lazy var titleTextLabel: SKLabelNode = {
        
        let titleLabel = SKLabelNode(fontNamed: kGameFont)
        titleLabel.fontColor = self.kButtonFontColor
        titleLabel.fontSize = 68
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        //titleLabel.setScale(self.upTexture!.size().width / self.size.width)
        titleLabel.position = CGPoint(x: 0, y: 0)
        titleLabel.zPosition = 10
        self.addChild(titleLabel)
        
        self.hasText = true
        
        return titleLabel
    }()
    
    func createButtonText(buttonText: String, fontSize: CGFloat = 68, fontColor: SKColor? = nil) {
        
        titleTextLabel.text = buttonText
        titleTextLabel.fontSize = fontSize
        titleTextLabel.fontColor = fontColor ?? self.kButtonFontColor
    }
    
    //    func setTextRight(buttonText: String) {
    //
    //        //         self.titleLabel! = gameModel.makeDropShadowString(buttonText, fontSize: 25.0, alignment: .Center, textColor: SKColor.colorWithWhite(0.4, alpha: 0.4), shadowColor: SKColor.whiteColor(), offsetY: 3)
    //        //         self.titleLabel!.xScale = self.upTexture.size.width / self.size.width
    //        //         self.titleLabel!.position = CGPoint(x: 0.5 * self.size.width / 2, -5)
    //        //        self.addChild( self.titleLabel!)
    //    }
    
    //MARK: initilizers
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        isUserInteractionEnabled = true
    }
    
    func quickSetUpWith(imageBaseName: String? = "", action: (() -> ())?) {
        
        upTexture = self.texture
        
        if imageBaseName != nil && imageBaseName != "" {
            
            let downTextureName = imageBaseName! + "_down.png"
            if SKTextureAtlas(named: "Sprites").textureNames.contains(downTextureName) {
                self.downTexture = SKTexture(imageNamed: downTextureName)
            }
            else {
                downTexture = nil
            }
        }
        
        actionType = .touchUpInside
        buttonParent = self.parent!
        stringAction = action
        initialXScale = xScale
        initialYScale = yScale
    }
    
    func quickSetUpTextureAndAction(imageTexture: SKTexture, action: (() -> ())?) {
        
        upTexture = imageTexture
        downTexture = nil
        actionType = .touchUpInside
        buttonParent = parent
        stringAction = action
        initialXScale = xScale
        initialYScale = yScale
    }
    
    func quickSetUpImageAndAction(imageBaseName: String? = "", action: (() -> ())?) {
        
        if imageBaseName != nil && imageBaseName != "" {
            upTexture = SKTexture(imageNamed: imageBaseName! + "_up")
        }
        else {
            upTexture = self.texture
        }
        downTexture = nil
        actionType = .touchUpInside
        buttonParent = parent
        stringAction = action
        initialXScale = xScale
        initialYScale = yScale
    }
    
    func quickSetUpAndDownTexturesAndAction(imageBaseName: String, action: (() -> ())?, parent: SKNode!) {
        
        upTexture = SKTexture(imageNamed: imageBaseName + "_up")
        downTexture = SKTexture(imageNamed: imageBaseName + "_down")
        actionType = .touchUpInside
        buttonParent = parent
        stringAction = action
        initialXScale = xScale
        initialYScale = yScale
    }
    
    convenience init(upImage: String? = nil, downImage: String? = nil, inset: CGPoint = CGPoint.zero, size: CGSize = CGSize.zero) {
        
        let upTexture: SKTexture? = (upImage != nil) ? SKTexture(imageNamed: upImage!) : nil
        let downTexture: SKTexture? = (downImage != nil) ? SKTexture(imageNamed: downImage!) : nil
        
        self.init(upTexture: upTexture, downTexture: downTexture, inset: inset, size: size)
    }
    
    //up and down textures, x inset , y inset and size
    init(upTexture: SKTexture?, downTexture: SKTexture? = nil, inset: CGPoint = CGPoint.zero, size: CGSize = CGSize.zero) {
        
        var localSize = size
        
        if localSize == CGSize.zero {
            localSize = (upTexture?.size())!
        }
        
        super.init(texture: upTexture, color: UIColor.white, size: localSize)
        
        self.size = localSize
        self.upTexture = upTexture
        self.downTexture = downTexture
        
        if inset.x > 0 {
            centerRect = CGRect(x: inset.x / (upTexture?.size().width)!, y: inset.y / (upTexture?.size().height)!, width: ((upTexture?.size().width)! - inset.x * 2) / (upTexture?.size().width)!, height: ((upTexture?.size().height)! - inset.y * 2) / (upTexture?.size().height)!)
            xScale = size.width / (upTexture?.size().width)!
            yScale = size.height / (upTexture?.size().height)!
            
            initialXScale = xScale
            initialYScale = yScale
        }
        
        self.highlighted = false
        self.isSelected = false
        self.isEnabled = true
        isUserInteractionEnabled = true
    }
    
    //MARK: Touches Methods
    
    //This method only occurs, if the touch was inside this node. Furthermore if the Button is enabled, the texture should change to "selectedTexture".
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent!)  {
        
        guard isEnabled else {  return }
        
        priorToggle = isToggled
        isToggled = !isToggled
        isSelected = true
        isDepressed = true
        //highlighted = true
        
        isPressed = turbo ? true : false;
        
        if turbo {  return }
        
        if sendTouchEventToParent {
            parent!.touchesBegan(touches, with: event)
        }
        
        //TODO: fix sound
        //self.run(sound.playSound(sound: .button))
        
        guard actionType == .touchDown, buttonParent != nil else {  return }

        buttonParent?.run(SKAction.run(stringAction!))
    }
    
    //If the Button is enabled: This method looks, where the touch was moved to. If the touch moves outside of the button, the isSelected property is restored to NO and the texture changes to "normalTexture".
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent!)  {
        
        guard isEnabled else { return }
        
        if let touch = touches.first as UITouch? {
            
            let touchLocation = touch.location(in: parent!)
            
            if !frame.contains(touchLocation) {
                isDepressed = false
                isSelected = false
                isPressed = false
                isToggled = priorToggle
            }
        }
        
        if sendTouchEventToParent {
            parent!.touchesMoved(touches, with: event)
        }
    }
    
    //If the Button is enabled AND the touch ended in the buttons frame, the selector of the target is run.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent!) {
        
        guard isEnabled, actionType == .touchUpInside else { return }
        
        if let touch = touches.first as UITouch? {
            
            let touchLocation = touch.location(in: parent!)
            
            if frame.contains(touchLocation) {
                
                if actionType == .touchUpInside {
                    buttonParent?.run(SKAction.run(stringAction!))
                }
            }
        }
        
        isPressed = false
        isDepressed = false
        //highlighted = false
        if !toggle {
            isSelected = false
        }
        
        if sendTouchEventToParent {
            parent!.touchesEnded(touches, with: event)
        }
    }
    
    func jiggleAction() -> SKAction {
        
        let timing: SKActionTimingMode = .easeIn
        
        let moveDownHalf: SKAction = SKAction.moveBy(x: 0.0, y: -5, duration: 0.05)
        moveDownHalf.timingMode = timing
        
        let moveUp: SKAction = SKAction.moveBy(x: 0.0, y: 10, duration: 0.05)
        moveUp.timingMode = timing
        
        let moveDown: SKAction = SKAction.moveBy(x: 0.0, y: -10, duration: 0.05)
        moveDown.timingMode = timing
        
        let moveUpHalf: SKAction = SKAction.moveBy(x: 0.0, y: 5, duration: 0.05)
        moveUpHalf.timingMode = timing
        
        let wait: SKAction = SKAction.wait(forDuration: 4.0)
        
        let sequence: SKAction = SKAction.sequence([wait, moveDownHalf, moveUp, moveDown, moveUpHalf])
        let group: SKAction = SKAction.repeatForever(sequence)
        
        return group
    }
}
