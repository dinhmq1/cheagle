//
//  GameScene.swift
//  Cheagle
//
//  Created by Mike Dinh on 7/27/15.
//  Copyright (c) 2015 Mike Dinh. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let playButton = SKSpriteNode(imageNamed: "play")
    
    override func didMoveToView(view: SKView) {
        
        self.playButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 200)
        self.playButton.size = CGSizeMake(55, 55)
        
        self.addChild(self.playButton)
        
        self.backgroundColor = UIColor(hex: 0x80D9FF)
        
    }
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch in (touches as! Set<UITouch>) {
            
            let location = touch.locationInNode(self)
            if self.nodeAtPoint(location) == self.playButton {
                var scene = PlayScene(size: self.size)
                let skView = self.view as SKView!
                skView.ignoresSiblingOrder = true
                scene.scaleMode = .AspectFill
                scene.size = skView.bounds.size
                skView.presentScene(scene)
                
            }
            
        }
        
    }
}
