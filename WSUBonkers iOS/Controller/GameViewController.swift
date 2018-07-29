//
//  GameViewController.swift
//  WSUBonkers iOS
//
//  Created by Erik Buck on 7/11/18.
//  Copyright © 2018 WSU. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, SKPhysicsContactDelegate {
   
   var _selectedNode : SKNode?
   var _score : Int = 0
   var _turnsRemaining : Int = 3
   var _lastNewTurnScore : Int = 0;
   
   @IBOutlet var turnsLabel : UILabel?   
   @IBOutlet var scoreLabel : UILabel?
   @IBOutlet var gameOverLabel : UILabel?
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      self.updateInfo()
      
      guard let scene = SKScene(fileNamed: "GameScene") else {
         print("Failed to load GameScene.sks")
         abort()
      }
      
      // Present the scene
      let skView = self.view as! SKView
      skView.presentScene(scene)
      scene.physicsBody = SKPhysicsBody(edgeLoopFrom: scene.frame)
      scene.physicsWorld.contactDelegate = self
      
      skView.ignoresSiblingOrder = true
      skView.showsFPS = true
      skView.showsNodeCount = true
      
      UIDevice.current.beginGeneratingDeviceOrientationNotifications()
      NotificationCenter.default.addObserver(
         forName: .UIDeviceOrientationDidChange, 
         object: nil, 
         queue: nil, 
         using: 
         { (note) in
            scene.physicsBody = SKPhysicsBody(edgeLoopFrom: scene.frame)
            scene.physicsBody?.contactTestBitMask = 4
      })  
   }
   
   func orientationDidChange(_ notification : Notification)
   {
   }
   
   override var shouldAutorotate: Bool {
      return true
   }
   
   override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
      if UIDevice.current.userInterfaceIdiom == .phone {
         return .allButUpsideDown
      } else {
         return .all
      }
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Release any cached data, images, etc that aren't in use.
   }
   
   override var prefersStatusBarHidden: Bool {
      return true
   }
   
   func stopChecker(_ touchLocation : CGPoint, in skView : SKView!) -> Bool
   {
      let localTouchLocation = 
         skView.scene!.convertPoint(fromView: touchLocation)
      
      let nodes = skView.scene!.nodes(at: localTouchLocation) 
      if 0 < (nodes.count) && 0 <= _turnsRemaining {
         self._selectedNode = nodes[0];
         if(skView.scene == self._selectedNode)
         {
            self._selectedNode = nil;
         }
         else if 3 != self._selectedNode?.physicsBody?.contactTestBitMask
         {
            self._selectedNode = nil;
         }
         else if 0 > _turnsRemaining
         {
            self._selectedNode = nil;
         }
         else
         {
            self._selectedNode?.physicsBody?.velocity = CGVector(dx:0, dy:0)
            self._selectedNode?.physicsBody?.angularVelocity = 0.0;
         }
      }
      
      return nil == self._selectedNode
   }
   
   @IBAction func tapChecker(recognizer : UITapGestureRecognizer) 
   {
      let skView = recognizer.view as! SKView
      let touchLocation = recognizer.location(in:recognizer.view)
      if(stopChecker(touchLocation, in: skView))
      {
         recognizer.isEnabled = false
         recognizer.isEnabled = true
      }
   }
   
   ///////////////////////////////////////////////////////////////////////////
   ///
   @IBAction func moveChecker(recognizer : UIPanGestureRecognizer) 
   {
      if recognizer.state == UIGestureRecognizerState.began
      {
         let skView = recognizer.view as! SKView
         let touchLocation = recognizer.location(in:recognizer.view)
         
         if(stopChecker(touchLocation, in: skView))
         {
            recognizer.isEnabled = false
            recognizer.isEnabled = true
         }
      }
      else if recognizer.state == UIGestureRecognizerState.changed
      {
         if 0 > _turnsRemaining 
         {
            recognizer.isEnabled = false
            recognizer.isEnabled = true
         }
         else if let node = self._selectedNode
         {
            let skView = recognizer.view as! SKView
            let translation = recognizer.translation(in:recognizer.view)
            recognizer.setTranslation(CGPoint(), in: recognizer.view)
            let xRatio = (skView.scene!.frame.size.width) / (recognizer.view!.bounds.size.width)
            let yRatio = (skView.scene!.frame.size.height) / (recognizer.view!.bounds.size.height)
            node.position = CGPoint(
               x:node.position.x + (xRatio * translation.x),
               y:node.position.y + (yRatio * -translation.y))
            node.physicsBody?.velocity = CGVector(dx:0, dy:0)
            node.physicsBody?.angularVelocity = 0.0;
         }
      }
      else if recognizer.state == UIGestureRecognizerState.ended
      {
         let velocity = recognizer.velocity(in:recognizer.view)
         let velocityVector = CGVector(dx: velocity.x, dy: -velocity.y)
         self._selectedNode?.physicsBody?.velocity = velocityVector
         if nil != self._selectedNode
         {
            self._selectedNode = nil
            self._turnsRemaining -= 1
            self.updateInfo()
            print("end")
         }
      }     
   }
   
   @IBAction func scalePiece(_ gestureRecognizer : UIPinchGestureRecognizer) {   guard gestureRecognizer.view != nil else { return }
      
      if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
         gestureRecognizer.view?.transform = (gestureRecognizer.view?.transform.scaledBy(
            x: gestureRecognizer.scale, 
            y: gestureRecognizer.scale))!
         gestureRecognizer.scale = 1.0
      }
   }
   
   func updateInfo() 
   {
         self.gameOverLabel?.alpha = (0 > self._turnsRemaining) ? 1.0 : 0.0
         self.scoreLabel?.text = String(format: "%04d", self._score)
         self.turnsLabel?.text = String(format: "%01d", 
            (0 > self._turnsRemaining) ? 0 : self._turnsRemaining + 1)
   }
   
   override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) 
   {
      if motion == .motionShake 
      {
         self._turnsRemaining = 3
         self._score = 0
         self.updateInfo()
      }
   }   
   
   ///////////////////////////////////////////////////////////////////////////
   ///
   func didBegin(_ contact: SKPhysicsContact) 
   {      
      if (contact.bodyA.contactTestBitMask == 3 || 
         contact.bodyB.contactTestBitMask == 3) &&
         contact.bodyA.contactTestBitMask != 4 && 
         contact.bodyB.contactTestBitMask != 4
      {
         if nil != self._selectedNode
         {
            self._turnsRemaining -= 1
            self._selectedNode = nil
            print("contact")
         }
         else
         {
            self._score += 1
            if self._score >= (20 + self._lastNewTurnScore) &&
               0 < self._turnsRemaining            
            {
               self._lastNewTurnScore = self._score
            }
         }
         self.updateInfo()
      }
   }   
}
