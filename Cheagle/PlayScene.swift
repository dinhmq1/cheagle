//
//  PlayScene.swift
//  Cheagle
//
//  Created by Mike Dinh on 7/27/15.
//  Copyright (c) 2015 Mike Dinh. All rights reserved.
//

import SpriteKit
import Foundation
import UIKit


// MARK: - PlayScene

class PlayScene: SKScene, SKPhysicsContactDelegate {
    
    var eagle : SKSpriteNode!
    var eagleFlyingFrames : [SKTexture]!
    var moving:SKNode!
    
    var enemyFlyingBomb : SKSpriteNode!
    var enemyFlyingBombFrames : [SKTexture]!
    var lastFlyingBombAdded : NSTimeInterval = 0.0
    var gravity : CGVector!
    
    var enemyFlyingTheDark : SKSpriteNode!
    var enemyFlyingTheDarkFrames : [SKTexture]!
    
    let flyingBombVelocity : CGFloat = 10.0
    let flyingTheDarkVelocity : CGFloat = 10.0
    var lastTheDarkNodeAdded : NSTimeInterval = 0.0
    
    let backgroundVelocity : CGFloat = 0.25
    let cloudVelocity : CGFloat = 0.25
    
    let eagleCategory: UInt32 = 1 << 1
    let worldCategory: UInt32 = 1 << 2
    let flyingBombCategory: UInt32 = 1 << 3
    let scoreCategory: UInt32 = 1 << 4
    let collisionCategoryTheDark : UInt32 = 1 << 5
    let collisionCategoryCoins : UInt32 = 1 << 6
    
    var coinNode : SKSpriteNode!
    var coinFlyingFrames : [SKTexture]!
    let flyingCoinNodeVelocity : CGFloat = 10.0
    var lastCoinNodeAdded : NSTimeInterval = 0.0
    var score = 0
    var scoreLabel : SKLabelNode!
    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.gravity = CGVectorMake(0.0, -5.0)
        physicsWorld.contactDelegate = self
        self.backgroundColor = UIColor(hex: 0x80D9FF)
        
        
        self.initializingScrollingBackground()
        self.initializingScrollingClouds()
        
        moving = SKNode()
        self.addChild(moving)
        
        
        createMountainB()
        createMountainA()
        spawnEagle()
        //        initializeCoinNode()
        //        collisionCategoryCoin()
        
        eagle.physicsBody?.affectedByGravity = false
        //        spawnFlyingBombs()
        createGround()
        createScoreLabel()
        
    }
    
    // MARK: - createScoreLabel
    
    func createScoreLabel() {
        
        scoreLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        scoreLabel.text = "\(score)"
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = SKColor.whiteColor()
        scoreLabel.zPosition = -15
        scoreLabel.position = CGPoint(x: size.width / 2.0, y: frame.height - scoreLabel.frame.height)
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        
        addChild(scoreLabel)
        
    }
    
    // MARK: - collisionCategoryCoin
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        var nodeB = contact.bodyB!.node!
        if nodeB.name == "COIN_UP" {
            self.score++
            self.scoreLabel.text = "\(score)"
            scoreLabel.fontColor = SKColor.whiteColor()
            nodeB.removeFromParent()
        }
        var nodeC = contact.bodyB!.node!
        var nodeD = contact.bodyA!.node!
        if nodeC.name == "THE_DARK_HIT"{
            if score > 0 {
                self.score--
                self.scoreLabel.text = "\(score)"
                scoreLabel.fontColor = SKColor.redColor()
                nodeC.removeFromParent()
            }
        }
    }
    
    func collisionCategoryCoin() {
        
        coinNode.physicsBody!.categoryBitMask = collisionCategoryCoins
        coinNode.physicsBody!.collisionBitMask = 0
        
    }
    
    func collisionCategoryFlyingBomb() {
        enemyFlyingBomb.physicsBody!.categoryBitMask = flyingBombCategory
        enemyFlyingBomb.physicsBody!.collisionBitMask = 0
    }
    
    // MARK: - createGround
    
    func createGround() {
        let groundTexture = SKTexture(imageNamed: "landGrass")
        groundTexture.filteringMode = .Nearest // shorter form for SKTextureFilteringMode.Nearest
        
        let moveGroundSprite = SKAction.moveByX(-groundTexture.size().width * 2.0, y: 0, duration: NSTimeInterval(0.003 * groundTexture.size().width * 2.0))
        let resetGroundSprite = SKAction.moveByX(groundTexture.size().width * 2.0, y: 0, duration: 0.0)
        let moveGroundSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveGroundSprite,resetGroundSprite]))
        
        for var i:CGFloat = 0; i < 2.0 + self.frame.size.width / ( groundTexture.size().width * 2.0 ); ++i {
            let sprite = SKSpriteNode(texture: groundTexture)
            sprite.setScale(2.0)
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2.0)
            sprite.runAction(moveGroundSpritesForever)
            moving.addChild(sprite)
        }
        
        // create the ground
        var ground = SKNode()
        // Ground and eagle collision
        ground.position = CGPointMake(ground.position.x, (eagle.position.y - 180.0)/12)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, groundTexture.size().height * 2.0))
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = worldCategory
        self.addChild(ground)
    }
    
    // MARK: - createCeiling
    
    // MARK: - initializingScrollingBackground
    
    func initializingScrollingBackground() {
        for var index = 0; index < 2; ++index {
            let bg = SKSpriteNode(imageNamed: "bg")
            bg.zPosition = -13
            bg.position = CGPoint(x: index * Int(bg.size.width), y: 200)
            bg.anchorPoint = CGPointZero
            bg.name = "background"
            self.addChild(bg)
        }
    }
    
    // MARK: - moveBackground
    
    func moveBackground() {
        self.enumerateChildNodesWithName("background", usingBlock: { (node, stop) -> Void in
            if let bg = node as? SKSpriteNode {
                bg.position = CGPoint(x: bg.position.x - self.backgroundVelocity, y: bg.position.y)
                
                // Checks if bg node is completely scrolled off the screen, if yes, then puts it at the end of the other node.
                if bg.position.x <= -bg.size.width {
                    bg.position = CGPointMake(bg.position.x + bg.size.width * 2, bg.position.y)
                }
            }
        })
    }
    
    // MARK: - initializingScrollingClouds
    
    func initializingScrollingClouds() {
        for var index = 0; index < 2; ++index {
            let sky = SKSpriteNode(imageNamed: "clouds")
            sky.zPosition = -12
            sky.position = CGPoint(x: index * Int(sky.size.width), y: 400)
            sky.anchorPoint = CGPointZero
            sky.name = "cloud"
            self.addChild(sky)
        }
    }
    
    // MARK: - moveClouds
    
    func moveClouds() {
        self.enumerateChildNodesWithName("cloud", usingBlock: {( node, stop) -> Void in
            if let sky = node as? SKSpriteNode{
                sky.position = CGPoint(x: sky.position.x - self.cloudVelocity, y: sky.position.y)
                
                if sky.position.x <= -sky.size.width {
                    sky.position = CGPointMake(sky.position.x + sky.size.width * 2, sky.position.y)
                }
                
            }
        })
    }
    
    // MARK: - initializeCoinNode
    
    func initializeCoinNode() {
        
        var coinNodePosition = CGPoint(x: frame.size.width + eagle.size.width/2, y: eagle.size.height * random(min:0.0, max:5.0))
        
        coinNode = SKSpriteNode(imageNamed: "coin")
        
        coinNodePosition.y += 140
        coinNode.size = CGSizeMake(30, 30)
        coinNode.position = coinNodePosition
        coinNode!.physicsBody = SKPhysicsBody(circleOfRadius: coinNode!.size.width / 2)
        coinNode!.physicsBody!.dynamic = false
        coinNode.physicsBody?.categoryBitMask = collisionCategoryCoins
        coinNode.physicsBody?.collisionBitMask = 0
        coinNode!.name = "COIN_UP"
        
        let coinAction = SKAction.moveByX(-size.width - coinNode.size.width, y: 0.0, duration: NSTimeInterval(random(min:1, max: 3)))
        
        coinNode.runAction(SKAction.repeatActionForever(coinAction))
        addChild(coinNode!)
        
    }
    
    // MARK: - initializeTheDarkNode
    
    func initializeTheDarkNode() {
        
        var theDarkNodePosition = CGPoint(x: frame.size.width + eagle.size.width/2, y: eagle.size.height * random(min:0.3, max:5.0))
        
        let enemyTheDarkAnimationAtlas : SKTextureAtlas = SKTextureAtlas(named: "EnemyTheDarkImages")
        
        var flyingTheDarkFrames = [SKTexture]()
        let numberFlyingTheDarkImages : Int = enemyTheDarkAnimationAtlas.textureNames.count
        for var i=1; i<=numberFlyingTheDarkImages/2; i++ {
            let flyingTheDarkTextureName = "td\(i)"
            flyingTheDarkFrames.append(enemyTheDarkAnimationAtlas.textureNamed(flyingTheDarkTextureName))
        }
        
        enemyFlyingTheDarkFrames = flyingTheDarkFrames
        
        // TheDark img size in pixels 16970.078740157 x 14929.133858268
        
        let tempFlyingTheDark : SKTexture = enemyFlyingTheDarkFrames[0]
        enemyFlyingTheDark = SKSpriteNode(texture: tempFlyingTheDark)
        enemyFlyingTheDark.size = CGSizeMake(66.289371, 58.3169295)
        
        enemyFlyingTheDark.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(enemyFlyingTheDarkFrames, timePerFrame: 0.1, resize: false, restore: true)), withKey:"flyingInPlaceTheDark")
        
        theDarkNodePosition.y += 140
        enemyFlyingTheDark.position = theDarkNodePosition
        
        //Change random(min) to increase speed of flyingbomb
        enemyFlyingTheDark.runAction(SKAction.moveByX(-size.width - enemyFlyingTheDark.size.width, y: 0.0, duration: NSTimeInterval(random(min:3, max: 4))))
        enemyFlyingTheDark.physicsBody = SKPhysicsBody(circleOfRadius: enemyFlyingTheDark.frame.size.width / 2.0)
        enemyFlyingTheDark.physicsBody?.dynamic = false
        enemyFlyingTheDark.physicsBody?.categoryBitMask = collisionCategoryTheDark
        enemyFlyingTheDark.physicsBody?.collisionBitMask = 0
        enemyFlyingTheDark.name = "THE_DARK_HIT"
        
        let theDarkAction = SKAction.moveByX(-size.width - enemyFlyingTheDark.size.width, y: 0.0, duration: NSTimeInterval(random(min:1, max: 3)))
        enemyFlyingTheDark.runAction(SKAction.repeatActionForever(theDarkAction))
        addChild(enemyFlyingTheDark)
        
        
    }
    
    // MARK: - createMountainB
    
    func createMountainB(){
        //Build mountainB
        let mountainBTexture = SKTexture(imageNamed: "mountainB")
        mountainBTexture.filteringMode = .Nearest
        
        let moveMountainBSprite = SKAction.moveByX(-mountainBTexture.size().width * 2.0, y: 0, duration: NSTimeInterval(0.003 * mountainBTexture.size().width * 2.0))
        let resetMountainBSprite = SKAction.moveByX(mountainBTexture.size().width * 2.0, y: 0, duration: 0.0)
        let moveMountainBSpriteForever = SKAction.repeatActionForever(SKAction.sequence([moveMountainBSprite, resetMountainBSprite]))
        
        for var i:CGFloat = 0; i < 2.0 + self.frame.size.width / (mountainBTexture.size().width * 2.0); i++ {
            let sprite = SKSpriteNode(texture: mountainBTexture)
            sprite.setScale(2.0)
            sprite.zPosition = -10
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height + 10.0)
            sprite.runAction(moveMountainBSpriteForever)
            moving.addChild(sprite)
        }
        
    }
    
    // MARK: - createMountainA
    
    func createMountainA(){
        //Build MountainA
        let mountainATexture = SKTexture(imageNamed: "mountainA")
        mountainATexture.filteringMode = .Nearest
        
        let moveMountainASprite = SKAction.moveByX(-mountainATexture.size().width * 2.0, y: 0, duration: NSTimeInterval(0.04 * mountainATexture.size().width * 2.0))
        let resetMountainASprite = SKAction.moveByX(mountainATexture.size().width * 2.0, y: 0, duration: 0.0)
        let moveMountainASpriteForever = SKAction.repeatActionForever(SKAction.sequence([moveMountainASprite, resetMountainASprite]))
        
        for var i:CGFloat = 0; i < 2.0 + self.frame.size.width / (mountainATexture.size().width * 2.0); i++ {
            let sprite = SKSpriteNode(texture: mountainATexture)
            sprite.setScale(2.0)
            sprite.zPosition = -11
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height - 25.0)
            sprite.runAction(moveMountainASpriteForever)
            moving.addChild(sprite)
        }
        
    }
    
    // MARK: - spawnEagle
    
    func spawnEagle(){
        
        //Begin EagleFlying Animation
        let eagleFlyingAnimatedAtlas : SKTextureAtlas = SKTextureAtlas(named: "EagleFlyingImages")
        
        var flyingFrames = [SKTexture]()
        let numberFlyingImages : Int = eagleFlyingAnimatedAtlas.textureNames.count
        for var i=1; i<=numberFlyingImages/2; i++ {
            let eagleTextureName = "a\(i)"
            flyingFrames.append(eagleFlyingAnimatedAtlas.textureNamed(eagleTextureName))
        }
        
        eagleFlyingFrames = flyingFrames
        
        let tempEagleFlying : SKTexture = eagleFlyingFrames[0]
        tempEagleFlying.filteringMode = .Nearest
        
        eagle = SKSpriteNode(texture: tempEagleFlying)
        //eagle dimensions in pixels : 22639.37007874 x 15382.677165354
        eagle.size = CGSizeMake(88.4350395, 60.088583)
        
        eagle.position = CGPoint(x: self.frame.size.width * 0.35, y: self.frame.size.height * 0.6)
        eagle.physicsBody = SKPhysicsBody(circleOfRadius: eagle.size.height / 2.0)
        eagle.physicsBody?.dynamic = true
        eagle.physicsBody?.mass = 0.1
        eagle.physicsBody?.allowsRotation = false
        eagle.physicsBody?.collisionBitMask = worldCategory | flyingBombCategory
        eagle.physicsBody?.contactTestBitMask = worldCategory | flyingBombCategory | collisionCategoryCoins | collisionCategoryTheDark
        eagle.physicsBody?.categoryBitMask = 0
        eagle.name = "THE_DARK"
        
        
        addChild(eagle)
        flyingEagle()
    }
    
    // MARK: - flyingEagle
    
    func flyingEagle() {
        eagle.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(eagleFlyingFrames, timePerFrame: 0.1, resize: false, restore: true))
            , withKey:"flyingInPlaceEagle")
    }
    
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(#min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    // MARK: - spawnFlyingBombs
    
    func spawnFlyingBombs() {
        
        //Begin EnemyFlyingBomb Animation
        let enemyFlyingBombAnimationAtlas : SKTextureAtlas = SKTextureAtlas(named: "EnemyFlyingBombImages")
        
        var flyingBombFrames = [SKTexture]()
        let numberFlyingBombImages : Int = enemyFlyingBombAnimationAtlas.textureNames.count
        for var i=1; i<=numberFlyingBombImages/2; i++ {
            let flyingBombTextureName = "efb\(i)"
            flyingBombFrames.append(enemyFlyingBombAnimationAtlas.textureNamed(flyingBombTextureName))
        }
        
        enemyFlyingBombFrames = flyingBombFrames
        
        let tempFlyingBomb : SKTexture = enemyFlyingBombFrames[0]
        enemyFlyingBomb = SKSpriteNode(texture: tempFlyingBomb)
        enemyFlyingBomb.size = CGSizeMake(41.9257813, 59.6456695)
        
        //Change timePerFrame to increase wings flap
        enemyFlyingBomb.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(enemyFlyingBombFrames, timePerFrame: 0.1, resize: false, restore: true)), withKey:"flyingInPlaceBomb")
        
        
        enemyFlyingBomb.position = CGPoint(x: frame.size.width + enemyFlyingBomb.size.width/2, y: frame.size.height * random(min:0.4, max:0.7))
        addChild(enemyFlyingBomb)
        
        //Change random(min) to increase speed of flyingbomb
        enemyFlyingBomb.runAction(SKAction.moveByX(-size.width - enemyFlyingBomb.size.width, y: 0.0, duration: NSTimeInterval(random(min:1, max: 2))))
        enemyFlyingBomb.physicsBody = SKPhysicsBody(circleOfRadius: enemyFlyingBomb.frame.size.width / 2.0)
        enemyFlyingBomb.physicsBody?.affectedByGravity = false
        enemyFlyingBomb.physicsBody?.dynamic = false
        enemyFlyingBomb.physicsBody?.categoryBitMask = flyingBombCategory
        //        enemyFlyingBomb.physicsBody?.contactTestBitMask = worldCategory | eagleCategory
        enemyFlyingBomb.physicsBody?.collisionBitMask = 0
        
        enemyFlyingBomb.name = "enemyFlyingBomb"
        collisionCategoryFlyingBomb()
        
    }
    
    // MARK: - moveFlyingBomb
    
    func moveFlyingBomb() {
        self.enumerateChildNodesWithName("enemyFlyingBomb", usingBlock: {(node, stop) -> Void in
            
            if let obstacle = node as? SKSpriteNode {
                obstacle.position = CGPoint(x: obstacle.position.x + self.flyingBombVelocity, y: obstacle.position.y)
                if obstacle.position.x < 0 {
                    obstacle.removeFromParent()
                }
            }
            
        })
    }
    
    // MARK: - moveCoinNode
    
    func moveCoinNode() {
        self.enumerateChildNodesWithName("COIN_UP", usingBlock: {(node, stop) -> Void in
            if let obstacle = node as? SKSpriteNode {
                obstacle.position = CGPoint(x: obstacle.position.x + self.flyingBombVelocity, y: obstacle.position.y)
                if obstacle.position.x < 0 {
                    obstacle.removeFromParent()
                }
            }})
    }
    
    // MARK: - moveTheDarkNode
    
    func moveTheDarkNode() {
        
        self.enumerateChildNodesWithName("THE_DARK_HIT", usingBlock: {(node, stop) -> Void in
            if let obstacle = node as? SKSpriteNode {
                obstacle.position = CGPoint(x: obstacle.position.x + self.flyingBombVelocity, y: obstacle.position.y)
                if obstacle.position.x < 0 {
                    obstacle.removeFromParent()
                }
            }})
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            eagle.physicsBody?.affectedByGravity = true
            eagle.physicsBody?.velocity = CGVectorMake(0, 0)
            eagle.physicsBody?.applyImpulse(CGVectorMake(0, 30))
            
        }
        //            self.spawnFlyingBombs()
    }
    
    
    //        override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
    //            self.spawnFlyingBombs()
    //        }
    
    func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
        if( value > max ) {
            return max
        } else if( value < min ) {
            return min
        } else {
            return value
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        
        eagle.zRotation = self.clamp( -1, max: 0.5, value: eagle.physicsBody!.velocity.dy * ( eagle.physicsBody!.velocity.dy < 0 ? 0.003 : 0.001 ) )
        
        if currentTime - self.lastFlyingBombAdded > 1 {
            self.lastFlyingBombAdded = currentTime + 1
            //            self.spawnFlyingBombs()
        }
        
        if currentTime - self.lastCoinNodeAdded > 1 {
            self.lastCoinNodeAdded = currentTime + 1
            self.initializeCoinNode()
        }
        
        if currentTime - self.lastTheDarkNodeAdded > 1 {
            self.lastTheDarkNodeAdded = currentTime + 1
            self.initializeTheDarkNode()
        }
        self.moveBackground()
        self.moveClouds()
        
    }
    
}














































