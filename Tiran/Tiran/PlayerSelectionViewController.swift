//
//  PlayerSelectionViewController.swift
//  Tiran
//
//  Created by Kadhir M on 12/21/16.
//  Copyright © 2016 Manickam. All rights reserved.
//

import UIKit
import GameKit

class PlayerSelectionViewController: UIViewController, GKMatchDelegate, UITableViewDataSource, UITableViewDelegate {

    /** All available icons for the player to pick from.*/
    var playerIcons = ["Player_1", "Player_2", "Player_3", "Player_4"]
    /** The current selection of the player.*/
    var currentSelection = 0 {
        didSet {
            self.playerImage.image = UIImage(named: playerIcons[currentSelection])
        }
    }
    /** The current match (Game Center).*/
    var currentMatch: GKMatch? = nil
    /** The local player GKLocalPlayer (Game Center).*/
    let localGKPlayer = GKLocalPlayer.localPlayer()
    /** All other players, with the playerID as the key, and associated Player (class) as the value.*/
    var otherPlayers = [String: Player]()
    
    /** All other players UITableView to see what everyone else has selected.*/
    @IBOutlet weak var playersTable: UITableView!
    /** The player's current selection image.*/
    @IBOutlet weak var playerImage: UIImageView!
    /** The local player name label.*/
    @IBOutlet weak var localPlayer: UILabel!
    /** The next player selection button.*/
    @IBOutlet weak var nextImage: UIButton!
    /** The previous player selection button.*/
    @IBOutlet weak var previousImage: UIButton!
    /** Lock in button.*/
    @IBOutlet weak var lockIn: UIButton!
    /** Error selecting the current player.*/
    @IBOutlet weak var errorSelecting: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentMatch?.delegate = self
        self.localPlayer.text = localGKPlayer.displayName
        if currentMatch != nil {
            populateOtherPlayers()
        }
    }
    
    /** Populates the otherPlayers array with player, using the playerID as the key, and the player class as the value.*/
    func populateOtherPlayers() {
        for player in currentMatch!.players {
            let newPlayer = Player(playerID: player.playerID!, playerName: player.alias!, playerNumber: "None", playerLockedIn: false)
            otherPlayers[newPlayer.playerID] = newPlayer
        }
        playersTable.reloadData()
    }
    
    /** Previous character selection.*/
    @IBAction func previous(_ sender: Any) {
        errorSelecting.isHidden = true
        if currentSelection > 0 {
            currentSelection -= 1
        } else {
            currentSelection = playerIcons.count - 1
        }
    }
    
    /** Next character selection.*/
    @IBAction func next(_ sender: UIButton) {
        errorSelecting.isHidden = true
        if currentSelection < 3 {
            currentSelection += 1
        } else {
            currentSelection = 0
        }
    }
    
    /** Locks in the current players selection and updates all other players if the selection is legal.*/
    @IBAction func lockIn(_ sender: UIButton) {
        if checkIfCanLockIn() == nil {
            errorSelecting.isHidden = true
            self.lockIn.isEnabled = false
            self.lockIn.setTitle("Waiting...", for: UIControlState.disabled)
            self.lockIn.setTitleColor(UIColor.gray, for: UIControlState.disabled)
            self.previousImage.isEnabled = false
            self.previousImage.setTitleColor(UIColor.gray, for: UIControlState.disabled)
            self.nextImage.isEnabled = false
            self.nextImage.setTitleColor(UIColor.gray, for: UIControlState.disabled)
            updateLockIn()
        } else {
            errorSelecting.isHidden = false
        }
    }
    
    /** Checks to make sure all other players have not selected the current character, and if someone has, returns that user's playername (Game Center alias).*/
    func checkIfCanLockIn() -> String? {
        for player in self.otherPlayers.values {
            if player.playerLockedIn {
                if player.playerNumber == playerIcons[currentSelection] {
                    return player.playerName
                }
            }
        }
        return nil
    }
    
    /** Using the currentMatch, sends the selection data to all other players reliably.*/
    func updateLockIn() {
        let dataSender = ["playerID": self.localGKPlayer.playerID, "playerSelected": playerIcons[currentSelection]]
        let selectionData = NSKeyedArchiver.archivedData(withRootObject: dataSender)
        do {
            try currentMatch!.sendData(toAllPlayers: selectionData, with: GKMatchSendDataMode.reliable)
            transitionToField()
        } catch {
            print("Error sending data")
        }
    }
    
    //MARK: GKMatchDelegate Methods
    
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        let dictionary: Dictionary? = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : String]
        let playerID = dictionary?["playerID"]
        let playerSelected = dictionary?["playerSelected"]
        updateOtherPlayerSelections(playerID: playerID!, playerSelected: playerSelected!)
    }
    
    /** Updates all other player selections in the table view.*/
    func updateOtherPlayerSelections(playerID: String, playerSelected: String) {
        for player in self.otherPlayers.values {
            if player.playerID == playerID {
                player.playerLockedIn = true
                player.playerNumber = playerSelected
            }
        }
        self.playersTable.reloadData()
        transitionToField()
    }
    
    /** If everyone has locked in, indicates the battle is starting and segues to the battle view.*/
    func transitionToField() {
        if checkIfAllLockedIn() {
            indicateBattleStarting()
            self.performSegue(withIdentifier: "Start_Match", sender: self)
        }
    }
    
    /** Indicates the battle is starting. NEEDS TO BE IMPLEMENTED.*/
    func indicateBattleStarting() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            sleep(3)
            //Indicate game starting
        }
    }
    
    /** Loops through all players and returns true if all players have checked in, including local player.*/
    private func checkIfAllLockedIn() -> Bool {
        for player in otherPlayers.values {
            if player.playerLockedIn == false {
                return false
            }
        }
        return !self.lockIn.isEnabled
    }
    
    //MARK: UITableView Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return otherPlayers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath) as? PlayerSelectionTableViewCell
        let tempPlayer = (otherPlayers[otherPlayers.keys.sorted()[indexPath.row]])!
        cell?.didSelectPlayerName = tempPlayer.playerName
        cell?.didSelectPlayerNumber = tempPlayer.playerNumber
        cell?.didLockIn = tempPlayer.playerLockedIn
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ControllerViewController {
            let destinationController = segue.destination as! ControllerViewController
            destinationController.currPlayer = Player(playerID: self.localGKPlayer.playerID!, playerName: self.localGKPlayer.alias!, playerNumber: self.playerIcons[self.currentSelection], playerLockedIn: true)
            destinationController.otherPlayers = self.otherPlayers
            destinationController.match = self.currentMatch
        }
    }

}
