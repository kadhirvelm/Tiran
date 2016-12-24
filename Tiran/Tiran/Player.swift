//
//  Player.swift
//  Tiran
//
//  Created by Kadhir M on 12/22/16.
//  Copyright © 2016 Manickam. All rights reserved.
//

import GameKit

class Player {
    /** Initialization of Player. */
    var playerName: String
    var playerID: String
    
    /** Character selection screen. */
    var playerWeapon: String
    var playerNumber: String
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
            let newWidth = (self.playerMaxHPSprite?.size.width)! * CGFloat((playerMaxHP! - playerCurrentHP!)/playerMaxHP!)
            self.playerCurrentDamageSprite?.run(SKAction.resize(toWidth: newWidth, duration: 0.15))
        }
    }
    var playerMaxVel: Int?
    var playerCurrentVel: Int? {
        didSet {
            let newWidth = (self.playerMaxVelSprite?.size.width)! * CGFloat((playerMaxVel! - playerCurrentVel!)/playerMaxVel!)
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
