# SpriteKit Spinning Prize Wheel

![Orange Think Box presents: SpinWheel](Documentation/prize_wheel.gif)


SpriteKit Prize Wheel is a physics based spinning prize wheel with a real moving peg flapper to create an awesome looking effect. You can have your users drag on the wheel to control how to much to spin just like a real prize wheel or have your users push the spin button in the center of the wheel to spin the wheel. Use it to reward your users with daily prizes, trivia games, control chance situations or for gambling type games.

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/hsilived/SpinWheel/blob/master/Documentation/LICENSE)
[![Twitter](https://img.shields.io/badge/twitter-@OrangeThinkBox-55ACEE.svg)](http://twitter.com/orangethinkbox)

## SKControlSprite Install Instructions

copy the SpinWheel folder into your project

Your scene must conform to SKPhysicsContactDelegate

    class GameScene: SKScene, SKPhysicsContactDelegate {

        private var spinWheelOpen = false
        
        override func didMove(to view: SKView) {
            self.physicsWorld.contactDelegate = self
        }
    }

In your scene to open a copy of the SpinWheel 

    func displaySpinWheel() {
        let spinWheel = SpinWheel(size: self.size)
        spinWheel.zPosition = 500
        addChild(spinWheel)

        //must be after the addChild
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

## Settings.swift

Inside of Settings.swift you can change the font or how the Spin Wheel is interacted with. Settings also has the physics category declarations.

    let kGameFont: String = "Context Rounded Black SSi"

    //if you don't want the center hub to act like a spin button change this to false
    var kHubSpinsWheel = true

    //if you don't want the user to be able to swipe to spin the wheel change this to false
    var kCanSwipeToSpinWheel = true

## To Change values on the Spin Wheel

Inside of SpinWheel.swift change the first 3 values for each array in the slots array

    //[prizeTitle that displays when won, icon image, value of items one in String format, start angle (do not change), end angle (do not change)]
    slots = [
        ["40 coins", "wheel_prize_coin", "40", "0", "44"]
    ]
    
## To receive winnings
    
Inside of SpinWheel.swift check in won(prizeTitle: String) for the same prizeTitle as in the slots array and handle it accordingly

    func won(prizeTitle: String) {
    
        if prizeTitle == "a present" {
            //they've won a prize so do something with the it
        }
        else if prizeTitle.hasSuffix("coins")  {
            //they've won coins so do something with the coins
        }
    }

        
## Feedback
I am happy to provide the SpriteKit Prize Wheel, and example code free of charge without any warranty or guarantee (see license below for more info). If there is a feature missing or you would like added please email us at dev@orangethinkbox.com

If you use this code or get inspired by the idea give us a star ;) and let us know, I would love to hear about it.
    
## License
Copyright (c) 2017 Orange Think Box

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Happy Spinning!
