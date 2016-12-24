//
//  NetworkingViewController.swift
//  Tiran
//
//  Created by Kadhir M on 12/20/16.
//  Copyright © 2016 Manickam. All rights reserved.
//

import UIKit
import GameKit

class NetworkingViewController: UIViewController, GKGameCenterControllerDelegate, GKMatchmakerViewControllerDelegate, GKMatchDelegate {
    
    var gameCenterAvailable = true
    var userAuthenticated = false
    var matchTiran: GKMatch? = nil
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.authenticateLocalPlayer()
    }
    
    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = { (ViewController, error) -> Void in
            if ViewController != nil {
                self.present(ViewController!, animated: true, completion: nil)
            } else if localPlayer.isAuthenticated {
                self.userAuthenticated = true
            } else {
                self.gameCenterAvailable = false
                print("Error getting gameCenter --> \(error)")
            }
        }
    }
    
    @IBOutlet weak var match: UIButton!
    
    @IBAction func match(_ sender: UIButton) {
        if self.userAuthenticated {
            for controller in self.childViewControllers {
                controller.dismiss(animated: true, completion: nil)
            }
            createMatch()
        } else {
            self.authenticateLocalPlayer()
        }
    }
    
    @IBAction func practice(_ sender: UIButton) {
        if self.userAuthenticated {
            self.performSegue(withIdentifier: "Practice", sender: self)
        } else {
            authenticateLocalPlayer()
        }
    }
    
    
    func createMatch() {
        let request = GKMatchRequest.init()
        request.maxPlayers = 4
        
        let matchController = GKMatchmakerViewController(matchRequest: request)
        matchController?.matchmakerDelegate = self
        self.present(matchController!, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        viewController.dismiss(animated: true) { 
            self.match.setTitle("Matched", for: UIControlState.normal)
            self.matchTiran = match
            self.performSegue(withIdentifier: "Player Selection", sender: self)
        }
    }
    
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(animated: true)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, hostedPlayerDidAccept player: GKPlayer) {
        print(player)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        print(error)
    }
    
    func match(_ match: GKMatch, didReceive data: Data, forRecipient recipient: GKPlayer, fromRemotePlayer player: GKPlayer) {
        let string = String.init(data: data, encoding: String.Encoding.utf8)
        print("\(player) --> \(string)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ControllerViewController {
            let destinationController = segue.destination as! ControllerViewController
            let localPlayer = GKLocalPlayer.localPlayer()
            destinationController.currPlayer = Player(playerID: localPlayer.playerID!, playerName: localPlayer.displayName!, playerNumber: "Player_1", playerLockedIn: true)
        } else if segue.destination is PlayerSelectionViewController {
            let destinationController = segue.destination as! PlayerSelectionViewController
            destinationController.currentMatch = self.matchTiran
        }
    }

}

