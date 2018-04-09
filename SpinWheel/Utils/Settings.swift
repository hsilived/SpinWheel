//
//  Settings.swift
//  SpinWheel
//
//  Created by Ron Myschuk on 2018-04-07.
//  Copyright © 2018 Orange Think Box. All rights reserved.
//

import Foundation
import SpriteKit

//MARK: - Physics Categories
let pegCategory: UInt32 = 0x1 << 1
let flapperCategory: UInt32 = 0x1 << 2

//MARK: - Global Variables
let kGameFont: String = "Context Rounded Black SSi"

//MARK: - Spin Wheel Settings

//if you don't want the center hub to act like a spin button change this to false
var kHubSpinsWheel = true

//if you don't want the user to be able to swipe to spin the wheel change this to false
var kCanSwipeToSpinWheel = true
