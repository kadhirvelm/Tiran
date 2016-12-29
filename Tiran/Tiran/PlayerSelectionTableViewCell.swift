//
//  PlayerSelectionTableViewCell.swift
//  Tiran
//
//  Created by Kadhir M on 12/21/16.
//  Copyright © 2016 Manickam. All rights reserved.
//

import UIKit

class PlayerSelectionTableViewCell: UITableViewCell {

    /** Selected player's character selection image.*/
    @IBOutlet weak var selectedPlayerImage: UIImageView!
    /** Player's name (Game Center Alias).*/
    @IBOutlet weak var playerName: UILabel!
    /** "Locked In" if the player has locked in their selection*/
    @IBOutlet weak var lockedIn: UILabel!
    
    /** Which number or player the user has selected, sets the selectedPlayerImage image.*/
    var didSelectPlayerNumber: String? {
        didSet {
            if didSelectPlayerNumber != "None" {
                selectedPlayerImage.image = UIImage(named: didSelectPlayerNumber!)
            }
        }
    }
    /** Player's Game Center Alias name, sets the playerName label text.*/
    var didSelectPlayerName: String? {
        didSet {
            playerName?.text = didSelectPlayerName
        }
    }
    /** True if the player has locked in, sets the lockedIn label text.*/
    var didLockIn: Bool? {
        didSet {
            if didLockIn != nil {
                if didLockIn! {
                    lockedIn.text = "Locked In!"
                }
            }
        }
    }

}
