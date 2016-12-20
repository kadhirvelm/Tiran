//
//  ControllerViewController.swift
//  Tiran
//
//  Created by Kadhir M on 12/19/16.
//  Copyright © 2016 Manickam. All rights reserved.
//

import UIKit
import SpriteKit

class ControllerViewController: UIViewController, JoyStickViewControllerDelegate {
    
    var player: PlayerScene? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let fieldScene = PlayerScene.unarchiveFromFile(file: "PlayerScene") as? PlayerScene {
            self.player = fieldScene
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
        }
    }
    
    func didMove(x: CGFloat) {
        self.player?.updatePlayer(dx: x)
    }
    
    func didDuck() { }
    
    func didJump() {
        self.player?.jumpPlayer()
    }
    
    func didStop() {
        self.player?.stopPlayer()
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
