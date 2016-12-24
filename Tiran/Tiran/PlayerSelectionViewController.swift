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

    var playerIcons = ["Player_1", "Player_2", "Player_3", "Player_4"]
    var currentSelection = 0 {
        didSet {
            self.playerImage.image = UIImage(named: playerIcons[currentSelection])
        }
    }
    var currentMatch: GKMatch? = nil
    let localGKPlayer = GKLocalPlayer.localPlayer()
    
    var otherPlayers = [String: Player]()
    
    @IBOutlet weak var playersTable: UITableView!
    @IBOutlet weak var playerImage: UIImageView!
    @IBOutlet weak var localPlayer: UILabel!
    @IBOutlet weak var nextImage: UIButton!
    @IBOutlet weak var previousImage: UIButton!
    @IBOutlet weak var lockIn: UIButton!
    @IBOutlet weak var errorSelecting: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentMatch?.delegate = self
        self.localPlayer.text = localGKPlayer.displayName
        if currentMatch != nil {
            populateOtherPlayers()
        }
    }
    
    func populateOtherPlayers() {
        for player in currentMatch!.players {
            let newPlayer = Player(playerID: player.playerID!, playerName: player.alias!, playerNumber: "None", playerLockedIn: false)
            otherPlayers[newPlayer.playerID] = newPlayer
        }
        playersTable.reloadData()
    }
    
    @IBAction func previous(_ sender: Any) {
        errorSelecting.isHidden = true
        if currentSelection > 0 {
            currentSelection -= 1
        } else {
            currentSelection = playerIcons.count - 1
        }
    }
    
    @IBAction func next(_ sender: UIButton) {
        errorSelecting.isHidden = true
        if currentSelection < 3 {
            currentSelection += 1
        } else {
            currentSelection = 0
        }
    }
    
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
    
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        let dictionary: Dictionary? = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : String]
        let playerID = dictionary?["playerID"]
        let playerSelected = dictionary?["playerSelected"]
        updateOtherPlayerSelections(playerID: playerID!, playerSelected: playerSelected!)
    }
    
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
    
    func transitionToField() {
        if checkIfAllLockedIn() {
            indicateBattleStarting()
            self.performSegue(withIdentifier: "Start_Match", sender: self)
        }
    }
    
    func indicateBattleStarting() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            sleep(3)
            //Indicate game starting
        }
    }
    
    private func checkIfAllLockedIn() -> Bool {
        for player in otherPlayers.values {
            if player.playerLockedIn == false {
                return false
            }
        }
        return !self.lockIn.isEnabled
    }
    
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
