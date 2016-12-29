//
//  JoystickViewController.swift
//  Tiran
//
//  Created by Kadhir M on 12/19/16.
//  Copyright © 2016 Manickam. All rights reserved.
//

import UIKit

precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ^^ : PowerPrecedence
func ^^ (radix: Double, power: Double) -> Double {
    return pow(radix, power)
}

class JoystickViewController: UIViewController, UIGestureRecognizerDelegate{

    /** The background view of this joystick. */
    @IBOutlet weak var backgroundView: UIView!
    /** The joystick controller itself. */
    @IBOutlet weak var joyStick: UIView!
    /** The delegate method for handling all joystick controller movement.*/
    var delegate: JoyStickViewControllerDelegate? = nil
    /** The current vector the user is moving the character in.*/
    var currentUnitVector: (CGFloat, CGFloat)?
    /** Is the joystick current updating its location.*/
    var updating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.cornerRadius = backgroundView.layer.frame.width / 2
        joyStick.layer.cornerRadius = joyStick.layer.frame.width / 2
        backgroundView.layer.borderColor = UIColor.white.cgColor
        backgroundView.layer.borderWidth = 3.0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{ update_joystick(touch: touch) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{ update_joystick(touch: touch) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.25) { 
            self.joyStick.center = self.backgroundView.center
        }
        self.currentUnitVector = nil
        self.updating = false
        self.delegate?.didStop()
    }
    
    /** Updates the unit vectors for which direction the character is moving in.*/
    func update_joystick(touch: UITouch) {
        let unitVector = determineUnitVector(newPoint: touch.location(in: backgroundView))
        self.currentUnitVector = unitVector
        let joystickRadius = self.backgroundView.frame.width / 2 - self.joyStick.frame.width / 2
        self.joyStick.center = CGPoint(x: self.backgroundView.center.x + joystickRadius * unitVector.0, y: self.backgroundView.center.y + joystickRadius * unitVector.1)
        if updating == false {
            self.updating = true
            sendDelegateMovements()
        }
    }
    
    /** In a background thread, sends the unit vector to the delegate methods to move the character around.*/
    func sendDelegateMovements() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            while self.currentUnitVector != nil {
                DispatchQueue.main.async {
                    //wait in here
                    if self.currentUnitVector != nil {
                        if fabs((self.currentUnitVector?.0)!) < CGFloat(0.2) {
                            if (self.currentUnitVector?.1)! > CGFloat(0.8) {
                                self.delegate?.didDuck()
                            } else if (self.currentUnitVector?.1)! < CGFloat(-0.8) {
                                self.delegate?.didJump()
                            }
                        } else {
                            self.delegate?.didMove(x: (self.currentUnitVector?.0)!)
                        }
                    }
                }
            }
        }
    }
    
    /** Given the current location of the joystick, returns the vector pointing from the center to the position.*/
    private func determineUnitVector(newPoint: CGPoint) -> (CGFloat, CGFloat) {
        let dx = newPoint.x - backgroundView.center.x
        let dy = newPoint.y - backgroundView.center.y
        let magnitude = (Double(dx) ^^ 2.0 + Double(dy) ^^ 2.0) ^^ (0.5)
        return (dx/CGFloat(magnitude), dy/CGFloat(magnitude))
    }
}

protocol JoyStickViewControllerDelegate {
    /** If the character moved.*/
    func didMove(x: CGFloat)
    /** Character ducked.*/
    func didDuck()
    /** Character jumped.*/
    func didJump()
    /** Joystick stopped moving.*/
    func didStop()
}

extension DispatchQueue {
    func delay(_ timeInterval: TimeInterval, execute work: @escaping () -> Void) {
        let milliseconds = Int(timeInterval * Double(1000))
        asyncAfter(deadline: .now() + .milliseconds(milliseconds)) { 
            work()
        }
    }
}
