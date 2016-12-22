//
//  Player.swift
//  Tiran
//
//  Created by Kadhir M on 12/22/16.
//  Copyright © 2016 Manickam. All rights reserved.
//

class Player {
    var playerName: String
    var playerNumber: String
    var playerLockedIn: Bool
    var playerID: String
    
    var playerMaxHP = 100
    var playerCurrentHP = 100
    
    var playerMaxVel = 100
    var playerCurrentVel = 100
    
    init(playerID: String, playerName: String, playerNumber: String, playerLockedIn: Bool) {
        self.playerName = playerName
        self.playerNumber = playerNumber
        self.playerLockedIn = playerLockedIn
        self.playerID = playerID
    }
}
