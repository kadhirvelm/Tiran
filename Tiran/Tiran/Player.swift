//
//  Player.swift
//  Tiran
//
//  Created by Kadhir M on 12/22/16.
//  Copyright © 2016 Manickam. All rights reserved.
//

import GameKit

class Player {
    //MARK: Initialization of Player
    /** Player alias name from Game Center.*/
    var playerName: String
    /** Player ID from Game Center.*/
    var playerID: String
    
    //MARK: Created at Character selection screen
    /** Chosen player weapon, currently defaulted to Sword_Basic.*/
    var playerWeapon: String
    /** Selected player number (eg. Player_1).*/
    var playerNumber: String
    /** .*/
    var playerLockedIn: Bool
    
    /** Initialization of battle field. */
    var playerSprite: SKSpriteNode?
    var playerWeaponSprite: SKSpriteNode?
    var playerNameSprite: SKLabelNode?
    private var playerMaxHPSprite: SKSpriteNode?
    private var playerCurrentDamageSprite: SKSpriteNode?
    private var playerMaxVelSprite: SKSpriteNode?
    private var playerCurrentVelConsumedSprite: SKSpriteNode?
    
    /** Attributes of character. */
    var playerMaxHP: Int?
    var playerCurrentHP: Int? {
        didSet {
            let newWidth = ((self.playerCurrentDamageSprite?.position.x)! * 2) * CGFloat((playerMaxHP! - playerCurrentHP!)) / CGFloat(playerMaxHP!)
            self.playerCurrentDamageSprite?.run(SKAction.resize(toWidth: newWidth, duration: 0.15))
        }
    }
    var playerMaxVel: Int?
    var playerCurrentVel: Int? {
        didSet {
            let newWidth = ((self.playerCurrentVelConsumedSprite?.position.x)! * 2) * CGFloat((playerMaxVel! - playerCurrentVel!)) / CGFloat(playerMaxVel!)
            self.playerCurrentVelConsumedSprite?.run(SKAction.resize(toWidth: newWidth, duration: 0.15))
        }
    }
    
    init(playerID: String, playerName: String, playerNumber: String, playerLockedIn: Bool, playerWeapon: String = "Sword_Basic") {
        self.playerName = playerName
        self.playerNumber = playerNumber
        self.playerLockedIn = playerLockedIn
        self.playerID = playerID
        self.playerWeapon = playerWeapon
    }
    
    func setSprites(playerSprite: SKSpriteNode, playerWeaponSprite: SKSpriteNode, playerNameSprite: SKLabelNode, playerMaxHPSprite: SKSpriteNode, playerCurrentDamageSprite: SKSpriteNode, playerMaxVelSprite: SKSpriteNode, playerCurrentVelConsumedSprite: SKSpriteNode) {
        self.playerSprite = playerSprite
        self.playerWeaponSprite = playerWeaponSprite
        self.playerNameSprite = playerNameSprite
        self.playerMaxHPSprite = playerMaxHPSprite
        self.playerCurrentDamageSprite = playerCurrentDamageSprite
        self.playerMaxVelSprite = playerMaxVelSprite
        self.playerCurrentVelConsumedSprite = playerCurrentVelConsumedSprite
    }
}

struct PlayerWeapon {
    static let swordBasic = "Sword_Basic"
}
