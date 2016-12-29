//
//  NetworkingViewController.swift
//  Tiran
//
//  Created by Kadhir M on 12/20/16.
//  Copyright © 2016 Manickam. All rights reserved.
//

import UIKit
import GameKit

class NetworkingViewController: UIViewController, GKGameCenterControllerDelegate, GKMatchmakerViewControllerDelegate {
    
    /** True if the game center is available.*/
    var gameCenterAvailable = true
    /** True if the user is authenticated by Game Center.*/
    var userAuthenticated = false
    /** The current GKMatch from Game Center.*/
    var matchTiran: GKMatch? = nil
    /** Match Button outlet.*/
    @IBOutlet weak var match: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.authenticateLocalPlayer()
    }
    
    /** Authenticates the local player with Game Center.*/
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
    
    /** If the user is authenticated, presents the matching view controller.*/
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
    
    /** Practice segue instead of match.*/
    @IBAction func practice(_ sender: UIButton) {
        if self.userAuthenticated {
            self.performSegue(withIdentifier: "Practice", sender: self)
        } else {
            authenticateLocalPlayer()
        }
    }
    
    /** Creates a match request, with a max of 4 players.*/
    func createMatch() {
        let request = GKMatchRequest.init()
        request.maxPlayers = 4
        
        let matchController = GKMatchmakerViewController(matchRequest: request)
        matchController?.matchmakerDelegate = self
        self.present(matchController!, animated: true, completion: nil)
    }
    
    //MARK: Game Center Delegate Methods
    
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

