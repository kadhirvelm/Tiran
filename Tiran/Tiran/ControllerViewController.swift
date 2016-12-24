//
//  ControllerViewController.swift
//  Tiran
//
//  Created by Kadhir M on 12/19/16.
//  Copyright © 2016 Manickam. All rights reserved.
//

import UIKit
import GameKit
import SpriteKit

class ControllerViewController: UIViewController, JoyStickViewControllerDelegate, GKMatchDelegate, syncMovementsDelegate {
    
    /** Needs to be set. */
    var match: GKMatch? = nil
    /** Needs to be set. */
    var currPlayer: Player? = nil
    /** Needs to be set. */
    var otherPlayers = [String: Player]()
    
    var playerField: PlayerScene? = nil
    var countSinceSync = 0 {
        didSet {
            if countSinceSync == 6 {
                updatePosition()
                countSinceSync = 0
            }
        }
    }
    
    var dataSender: [String: Any?]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (match != nil) {
            match?.delegate = self
        }
    
        if let fieldScene = PlayerScene.unarchiveFromFile(file: "PlayerScene") as? PlayerScene {
            self.playerField = fieldScene
            self.playerField?.localPlayer = self.currPlayer
            self.playerField?.syncMovementsDelegate = self
            self.otherPlayers[(self.currPlayer?.playerID)!] = self.currPlayer
            self.playerField?.allPlayers = self.otherPlayers
            let skView = self.view as! SKView
            skView.ignoresSiblingOrder = true
            fieldScene.scaleMode = .aspectFill
            skView.presentScene(fieldScene)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? JoystickViewController {
            destination.delegate = self
        } else {
            if (match != nil) {
                match?.disconnect()
            }
        }
    }
    
    func didMove(x: CGFloat) {
        self.playerField?.movePlayer(dx: x)
    }
    
    func didDuck() { }
    
    func didJump() {
        self.playerField?.jumpPlayer()
        countSinceSync = 0
    }
    
    func didStop() {
        self.playerField?.stopPlayer()
    }
    
    func updateVelocity() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            if self.match != nil {
                let currVelocity = self.playerField?.localPlayer?.playerSprite!.physicsBody?.velocity
                self.dataSender = ["dx": currVelocity?.dx, "dy": currVelocity?.dy, "action": self.playerField?.playerCurrAction, "direction": self.playerField?.localPlayer?.playerSprite!.xScale]
                let dataExample = NSKeyedArchiver.archivedData(withRootObject: self.dataSender!)
                do {
                    try self.match!.sendData(toAllPlayers: dataExample, with: GKMatchSendDataMode.unreliable)
                    DispatchQueue.main.sync {
                        self.countSinceSync += 1
                    }
                } catch {
                    print("Error sending data")
                }
            }
        }
    }
    
    func updatePosition() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            if self.match != nil {
                let position = (self.playerField?.localPlayer?.playerSprite!.position)!
                self.dataSender = ["x": position.x, "y": position.y]
                let dataExample = NSKeyedArchiver.archivedData(withRootObject: self.dataSender!)
                do {
                    try self.match!.sendData(toAllPlayers: dataExample, with: GKMatchSendDataMode.unreliable)
                } catch {
                    print("Error sending data")
                }
            }
        }
    }
    
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
            let dictionary: Dictionary? = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : Any]
            if dictionary?["dx"] != nil {
                let velocity = CGVector(dx: dictionary?["dx"] as! CGFloat, dy: dictionary?["dy"] as! CGFloat)
                self.playerField?.updateOtherPlayerVelocity(playerID: player.playerID!, velocity: velocity)
                self.playerField?.updateOtherPlayerAction(playerID: player.playerID!, action: dictionary?["action"] as! String, direction: dictionary?["direction"] as! CGFloat)
            } else if dictionary?["x"] != nil {
                self.playerField?.syncOtherPlayerPosition(playerID: player.playerID!, x: dictionary?["x"] as! CGFloat, y: dictionary?["y"] as! CGFloat)
            }
        }
    }
}


extension SKNode {
    
    class func unarchiveFromFile(file : String) -> SKNode? {
        if let path = Bundle.main.path(forResource: file, ofType: "sks") {
            let sceneData = try! NSData(contentsOfFile: path, options: .mappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWith: sceneData as Data)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! PlayerScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
    
}
