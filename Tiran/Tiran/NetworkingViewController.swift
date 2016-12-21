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
            print("Creating match")
            createMatch()
        }
    }
    
    @IBAction func practice(_ sender: UIButton) {
        self.performSegue(withIdentifier: "Start_Match", sender: self)
    }
    
    
    func createMatch() {
        let request = GKMatchRequest.init()
        request.maxPlayers = 2
        
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
            self.performSegue(withIdentifier: "Start_Match", sender: self)
        }
    }
    
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        print("Cancelled")
        viewController.dismiss(animated: true) { 
            print("And dismissed")
        }
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
            destinationController.match = self.matchTiran
        }
    }

}

