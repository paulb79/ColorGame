//
//  GameScene.swift
//  ColorGame
//
//  Created by Paul Brown on 03/05/2019.
//  Copyright © 2019 Paul Brown. All rights reserved.
//

import SpriteKit
import GameplayKit

enum Enemies {
    case small
    case medium
    case large
}

class GameScene: SKScene {
    
    var tracksArray:[SKSpriteNode]? = [SKSpriteNode]()
    var player:SKSpriteNode?
    
    var currentTrack = 0
    var movingToTrack = false
    
    let moveSound = SKAction.playSoundFileNamed("move.wav", waitForCompletion: false)
    
    let trackVelocities = [180, 200, 250]
    var directionArray = [Bool]()
    var velocityArray = [Int]()
    
    
    func setupTracks() {
        for i in 0 ... 8 {
            if let track = self.childNode(withName: "\(i)") as? SKSpriteNode {
                tracksArray?.append(track)
            }
        }
    }
    
    override func didMove(to view: SKView) {
        setupTracks()
        createPlayer()
        
        tracksArray?.first?.color = UIColor.green
        
//        self.addChild(createEnemy(type: .large, forTrack: 2)!)
        
        if let numofTracks = tracksArray?.count {
            for _ in 0...numofTracks {
                let randomNumberForVelocity = GKRandomSource.sharedRandom().nextInt(upperBound: 3)
                velocityArray.append(trackVelocities[randomNumberForVelocity])
                
                directionArray.append(GKRandomSource.sharedRandom().nextBool())
            }
        }
    }
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        
        guard let playerPostion = tracksArray?.first?.position.x else {return}
        player?.position = CGPoint(x: playerPostion, y: self.size.height / 2)
        
        self.addChild(player!)
        
        let pulse = SKEmitterNode(fileNamed: "spark")!
        player?.addChild(pulse)
        pulse.position = CGPoint(x: 0, y: 0)
    }
    
    func createEnemy(type:Enemies, forTrack track:Int) -> SKShapeNode? {
        let enemySprite = SKShapeNode()
        
        switch type {
        case .small:
            enemySprite.path = CGPath(roundedRect: CGRect(x: -10, y: 0, width: 20, height: 70), cornerWidth: 8, cornerHeight: 8, transform: nil)
            enemySprite.fillColor = UIColor(red: 0.4432, green: 0.5528, blue: 0.7451, alpha: 1)
        case .medium:
            enemySprite.path = CGPath(roundedRect: CGRect(x: -10, y: 0, width: 20, height: 100), cornerWidth: 8, cornerHeight: 8, transform: nil)
            enemySprite.fillColor = UIColor(red: 0.7804, green: 0.4039, blue: 0.4039, alpha: 1)
        case .large:
            enemySprite.path = CGPath(roundedRect: CGRect(x: -10, y: 0, width: 20, height: 130), cornerWidth: 8, cornerHeight: 8, transform: nil)
            enemySprite.fillColor = UIColor(red: 0.7804, green: 0.6392, blue: 0.4039, alpha: 1)
        }
        
        guard let enemyPosition = tracksArray?[track].position else { return nil }
        
        enemySprite.position.x = enemyPosition.x
        enemySprite.position.y = 50
        
        return enemySprite
    }
    
    func moveVertically(up:Bool) {
        if up {
            let moveAction = SKAction.moveBy(x: 0, y: 3, duration: 0.01)
            let repeatAction = SKAction.repeatForever(moveAction)
            player?.run(repeatAction)
        } else {
            let moveAction = SKAction.moveBy(x: 0, y: -3, duration: 0.01)
            let repeatAction = SKAction.repeatForever(moveAction)
            player?.run(repeatAction)
        }
    }
    
    func moveToNextTrack() {
        player?.removeAllActions()
        
        movingToTrack = true
        guard let nextTrack = tracksArray?[currentTrack + 1].position else {return}
        
        if let player = self.player {
            let moveAction = SKAction.move(to: CGPoint(x: nextTrack.x, y:player.position.y), duration: 0.2)
            
            player.run(moveAction, completion: {
                self.movingToTrack = false})
            currentTrack += 1
            
            self.run(moveSound)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.previousLocation(in: self)
            let node = self.nodes(at: location).first
            
            if node?.name == "right" {
                print("right")
                moveToNextTrack()
            } else if node?.name == "up" {
                print("up")
                moveVertically(up: true)
            } else if node?.name == "down" {
                print("down")
                moveVertically(up: false)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !movingToTrack {
            player?.removeAllActions()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !movingToTrack {
            player?.removeAllActions()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
