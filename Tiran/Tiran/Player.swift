//
//  Player.swift
//  Tiran
//
//  Created by Kadhir M on 12/22/16.
//  Copyright © 2016 Manickam. All rights reserved.
//

import GameKit

/** Use to interact the player, should not touch sprites associated with the player outside of this class.*/
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
    /** True if the player has locked in on the selection screen.*/
    var playerLockedIn: Bool
    
    //MARK: Initialization of battle field
    
    /** The sprite associated with the main player character. */
    var playerSprite: SKSpriteNode?
    /** The sprite associated with the player's weapon. */
    var playerWeaponSprite: SKSpriteNode?
    /** The label of the player (Player Name). */
    var playerNameSprite: SKLabelNode?
    /** Maximum HP bar of the player. */
    private var playerMaxHPSprite: SKSpriteNode?
    /** Overlays the Maximum HP bar indicating current health. */
    private var playerCurrentDamageSprite: SKSpriteNode?
    /** Maximum Vel sprite of the player. */
    private var playerMaxVelSprite: SKSpriteNode?
    /** Consumed Vel overlayed over the maxVelSprite. */
    private var playerCurrentVelConsumedSprite: SKSpriteNode?
    
    //MARK: Attributes of character.
    
    /** Maximum health of the player.*/
    var playerMaxHP: Int?
    /** The current health of the player, when set updates the currentDamage sprite to reflect accordingly.*/
    var playerCurrentHP: Int? {
        didSet {
            let newWidth = ((self.playerCurrentDamageSprite?.position.x)! * 2) * CGFloat((playerMaxHP! - playerCurrentHP!)) / CGFloat(playerMaxHP!)
            self.playerCurrentDamageSprite?.run(SKAction.resize(toWidth: newWidth, duration: 0.15))
            if playerCurrentHP! <= 0 {
                //Player died, handle death
            }
        }
    }
    /** The maximum vel of the player.*/
    var playerMaxVel: Int?
    /** The current vel of the player, when set updates the current vel consumed to reflect accordingly.*/
    var playerCurrentVel: Int? {
        didSet {
            let newWidth = ((self.playerCurrentVelConsumedSprite?.position.x)! * 2) * CGFloat((playerMaxVel! - playerCurrentVel!)) / CGFloat(playerMaxVel!)
            self.playerCurrentVelConsumedSprite?.run(SKAction.resize(toWidth: newWidth, duration: 0.15))
        }
    }
    
    /** Initializes a new player, which keeps track of everything involving a player.
     - parameters:
        - playerID: ID of player
        - playerName: name of player (Game Center alias)
        - playerLockedIn: Is locked in
        - playerWeapon: The weapon of the player
     */
    init(playerID: String, playerName: String, playerNumber: String, playerLockedIn: Bool, playerWeapon: String = "Sword_Basic") {
        self.playerName = playerName
        self.playerNumber = playerNumber
        self.playerLockedIn = playerLockedIn
        self.playerID = playerID
        self.playerWeapon = playerWeapon
    }
    
    /** Sets all the sprites associated with this character.*/
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
