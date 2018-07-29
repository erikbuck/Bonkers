//
//  GameViewController.swift
//  WSUBonkers macOS
//
//  Created by Erik Buck on 7/11/18.
//  Copyright © 2018 WSU. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class GameViewController: NSViewController {

   override func viewDidLoad() {
      super.viewDidLoad()

      guard let scene = SKScene(fileNamed: "GameScene") else {
         print("Failed to load GameScene.sks")
         abort()
      }

      // Present the scene
      let skView = self.view as! SKView
      skView.presentScene(scene)
      skView.ignoresSiblingOrder = true
      skView.showsFPS = true
      skView.showsNodeCount = true
   }

}

