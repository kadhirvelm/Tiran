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

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var joyStick: UIView!
    
    var delegate: JoyStickViewControllerDelegate? = nil
    
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
        self.delegate?.didStop()
    }
    
    func update_joystick(touch: UITouch) {
        let unitVector = determineUnitVector(newPoint: touch.location(in: backgroundView))
        let joystickRadius = self.backgroundView.frame.width / 2 - self.joyStick.frame.width / 2
        self.joyStick.center = CGPoint(x: self.backgroundView.center.x + joystickRadius * unitVector.0, y: self.backgroundView.center.y + joystickRadius * unitVector.1)
        self.delegate?.didMove(x: unitVector.0)
        if unitVector.0 < 0.1 {
            if unitVector.1 > 0.8 {
                self.delegate?.didDuck()
            } else if unitVector.1 < -0.8 {
                self.delegate?.didJump()
            }
        }
    }
    
    private func determineUnitVector(newPoint: CGPoint) -> (CGFloat, CGFloat) {
        let dx = newPoint.x - backgroundView.center.x
        let dy = newPoint.y - backgroundView.center.y
        let magnitude = (Double(dx) ^^ 2.0 + Double(dy) ^^ 2.0) ^^ (0.5)
        return (dx/CGFloat(magnitude), dy/CGFloat(magnitude))
    }
}

protocol JoyStickViewControllerDelegate {
    func didMove(x: CGFloat)
    func didDuck()
    func didJump()
    func didStop()
}
