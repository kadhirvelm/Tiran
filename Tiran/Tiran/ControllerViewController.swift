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

class ControllerViewController: UIViewController, JoyStickViewControllerDelegate, GKMatchDelegate {
    
    var player: PlayerScene? = nil
    var match: GKMatch? = nil
    
    var dataSender: [String: Any?]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (match != nil) {
            match?.delegate = self
        }
    
        if let fieldScene = PlayerScene.unarchiveFromFile(file: "PlayerScene") as? PlayerScene {
            self.player = fieldScene
            
            self.player?.num_other_players = 1
            
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
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
        self.player?.updatePlayer(dx: x)
        updatePosition()
    }
    
    func didDuck() { }
    
    func didJump() {
        self.player?.jumpPlayer()
        updatePosition()
    }
    
    func didStop() {
        self.player?.stopPlayer()
        updatePosition()
    }
    
    func updatePosition() {
        let position = (self.player?.player?.position)!
        dataSender = ["body": nil, "x": position.x, "y": position.y, "action": self.player?.playerCurrAction, "direction": self.player?.player?.xScale]
        let dataExample = NSKeyedArchiver.archivedData(withRootObject: dataSender!)
        do {
            print("Data sent \(NSDate().timeIntervalSinceReferenceDate * 1000)")
            try match!.sendData(toAllPlayers: dataExample, with: GKMatchSendDataMode.unreliable)
            dataSender = nil
        } catch {
            print("Error sending data")
        }
    }
    
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        print("Data received \(NSDate().timeIntervalSinceReferenceDate * 1000)")
        let dictionary: Dictionary? = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : Any]
        self.player?.updateOtherPlayerPosition(index: 0, body: nil,
                                               x: dictionary?["x"] as! Int,
                                               y: dictionary?["y"] as! Int)
        self.player?.updateOtherPlayerAction(index: 0, action: dictionary?["action"] as! String, direction: dictionary?["direction"] as! CGFloat)
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
