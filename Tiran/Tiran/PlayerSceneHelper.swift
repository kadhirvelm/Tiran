//
//  PlayerSceneHelper.swift
//  Tiran
//
//  Created by Kadhir M on 12/26/16.
//  Copyright © 2016 Manickam. All rights reserved.
//

import GameKit

class PlayerSceneHelper {
    
    /** Maximum health of the player.*/
    let PLAYER_MAX_HEALTH = 100
    /** The maximum vel of a player.*/
    let PLAYER_MAX_VEL = 100
    /** The scene which this helper is acting on.*/
    var scene: SKScene
    /** All players in this current scene.*/
    var allPlayers: [String: Player]
    
    /** Initialize to access helper methods within this class for the PlayerScene.*/
    init(scene: SKScene, allPlayers: [String: Player]) {
        self.scene = scene
        self.allPlayers = allPlayers
    }
    
    /** Removes all players currently not owned by a user.*/
    func removeNonPlayers() {
        for index in 1...4 {
            let playerNum = "Player_\(index)"
            
            if !(allPlayers.contains(where: { (_: String, value: Player) -> Bool in
                return value.playerNumber == playerNum
            })) {
                self.scene.childNode(withName: playerNum)?.removeFromParent()
                self.scene.childNode(withName: "\(playerNum) Weapon")?.removeFromParent()
            }
        }
    }
    
    /** Sets all the sprites associated with a player in the Player class.*/
    func setPlayerSprites() {
        for (_, player) in self.allPlayers {
            let sprite = self.scene.childNode(withName: player.playerNumber) as? SKSpriteNode
            let weaponSprite = self.scene.childNode(withName: "\(player.playerNumber) Weapon") as? SKSpriteNode
            let nameSprite = sprite?.childNode(withName: "Name") as? SKLabelNode
            let maxHPSprite = sprite?.childNode(withName: "HP") as? SKSpriteNode
            let currentDamageSprite = maxHPSprite?.childNode(withName: "Damage") as? SKSpriteNode
            let maxVelSprite = sprite?.childNode(withName: "Vel") as? SKSpriteNode
            let currentVelConsumed = maxVelSprite?.childNode(withName: "VP") as? SKSpriteNode
            
            player.setSprites(playerSprite: sprite!,
                              playerWeaponSprite: weaponSprite!,
                              playerNameSprite: nameSprite!,
                              playerMaxHPSprite: maxHPSprite!,
                              playerCurrentDamageSprite: currentDamageSprite!,
                              playerMaxVelSprite: maxVelSprite!,
                              playerCurrentVelConsumedSprite: currentVelConsumed!)
            player.playerMaxHP = PLAYER_MAX_HEALTH
            player.playerMaxVel = PLAYER_MAX_VEL
        }
    }
    
    /** Adjusts the labels, health bars, and weapon of each player's associated sprites.*/
    func adjustPlayerSprites() {
        for (_, player) in self.allPlayers {
            player.playerNameSprite?.text = player.playerName
            let weaponIdle = SKAction.repeatForever(animate(frame_name: "Idle", atlasName: player.playerWeapon, duration: 0.15))
            player.playerWeaponSprite?.run(weaponIdle)
            
            resetPlayerWeapon(playerID: player.playerID)
            
            player.playerCurrentHP = player.playerMaxHP!
            player.playerCurrentVel = player.playerMaxVel!
        }
    }
    
    /** Resets the weapon to come to follow the player.*/
    func resetPlayerWeapon(playerID: String) {
        let player = allPlayers[playerID]
        let weaponConstraint = SKConstraint.distance(SKRange(lowerLimit: 25, upperLimit: 40), to: (player?.playerNameSprite)!)
        let weaponConstraint2 = SKConstraint.distance(SKRange(lowerLimit: 35, upperLimit: 40), to: (player?.playerSprite)!)
        player?.playerWeaponSprite?.constraints = [weaponConstraint, weaponConstraint2]
    }
    
    /** Given a frame_name to look for, and an atlas to look in, returns an SKAction with all the frames, each lasting duration.*/
    func animate(frame_name: String, atlasName: String, duration: Double) -> SKAction {
        let atlas = SKTextureAtlas(named: atlasName)
        var frames = [SKTexture]()
        
        for name in atlas.textureNames.sorted() {
            if name.contains(frame_name) {
                frames.append(atlas.textureNamed(name))
            }
        }
        return SKAction.animate(with: frames, timePerFrame: duration)
    }
}
