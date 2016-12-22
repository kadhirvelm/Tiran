//
//  PlayerSelectionTableViewCell.swift
//  Tiran
//
//  Created by Kadhir M on 12/21/16.
//  Copyright © 2016 Manickam. All rights reserved.
//

import UIKit

class PlayerSelectionTableViewCell: UITableViewCell {

    @IBOutlet weak var selectedPlayerImage: UIImageView!
    @IBOutlet weak var playerName: UILabel!
    @IBOutlet weak var lockedIn: UILabel!
    
    var didSelectPlayerNumber: String? {
        didSet {
            if didSelectPlayerNumber != "None" {
                selectedPlayerImage.image = UIImage(named: didSelectPlayerNumber!)
            }
        }
    }
    
    var didSelectPlayerName: String? {
        didSet {
            playerName?.text = didSelectPlayerName
        }
    }
    
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
