import SpriteKit

class PlayerScene: SKScene, SKPhysicsContactDelegate {
    
    /** The maximum speed of the player.*/
    let PLAYER_MAX_SPEED: CGFloat = 200
    /** The camera Y-offset from the player.*/
    let CAMERA_Y_ADJUSTMENT: CGFloat = 50
    /** Local player for easier access.*/
    var localPlayer: Player?
    /** All players, including the local player.*/
    var allPlayers = [String: Player]()
    /** The current player action.*/
    var playerCurrAction = ""
    /** True if the player's physics body is currently moving.*/
    var isMoving = false
    /** True if the player is currently jumping.*/
    var isJumping = false
    /** The synchronizing movements with all other players in the game delegate.*/
    var syncMovementsDelegate: syncMovementsDelegate?
    /** Helper methods for this class.*/
    var playerSceneHelper: PlayerSceneHelper?
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        self.playerSceneHelper = PlayerSceneHelper(scene: self.scene!, allPlayers: allPlayers)
        
        playerSceneHelper!.removeNonPlayers()
        playerSceneHelper!.setPlayerSprites()
        playerSceneHelper!.adjustPlayerSprites()
        
        zoomCamera()
        updateCamera()
    }
    
    /** Zooms the camera in after 2 seconds to center on the player.*/
    func zoomCamera() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            sleep(2)
            DispatchQueue.main.sync {
                self.camera?.run(SKAction.scale(to: 0.5, duration: 0.75)) {
                }
            }
        }
    }
    
    override func didSimulatePhysics() {
        updateCamera()
    }
    
    /** Moves the player by the dx scale and turns the player to face that direction accordingly, moves by giving the player an impulse in the x-exclusive direction.*/
    func movePlayer(dx: CGFloat) {
        if self.isJumping == false {
            if self.isMoving == false{
                self.isMoving = true
                localPlayer!.playerSprite!.removeAllActions()
                self.localPlayer!.playerSprite!.run(start_run(atlasName: localPlayer!.playerNumber)) {
                    let groupMovement = SKAction.repeatForever(self.run(atlasName: self.localPlayer!.playerNumber))
                    self.localPlayer?.playerSprite!.run(groupMovement)
                }
            }
            if dx != 0 {
                let newScale = dx/fabs(dx)
                self.localPlayer?.playerSprite!.xScale = newScale
            }
            if fabs((self.localPlayer?.playerSprite!.physicsBody?.velocity.dx)!) < self.PLAYER_MAX_SPEED {
                self.localPlayer?.playerSprite!.physicsBody?.applyImpulse(CGVector(dx: 750 * dx, dy: 0.0))
                self.syncMovementsDelegate?.updateVelocity()
            }
        }
    }
    
    /** Makes the player jump by giving it an upwards impulse.*/
    func jumpPlayer() {
        if self.isJumping == false {
            localPlayer?.playerSprite!.removeAllActions()
            self.isMoving = false
            self.isJumping = true
            localPlayer?.playerSprite!.run(start_jump(atlasName: localPlayer!.playerNumber)) {
                self.localPlayer?.playerSprite!.physicsBody?.applyImpulse(CGVector(dx: 5, dy: 20000))
                self.syncMovementsDelegate?.updateVelocity()
                let groupMovement = SKAction.repeatForever(self.fall(atlasName: self.localPlayer!.playerNumber))
                self.localPlayer?.playerSprite!.run(groupMovement)
            }
        }
    }
    
    /** Stops the player's physics body all together.*/
    func stopPlayer() {
        self.isMoving = false
        self.isJumping = false
        localPlayer?.playerSprite!.removeAllActions()
        localPlayer?.playerSprite!.physicsBody?.isResting = true
        localPlayer?.playerSprite!.run(idle(atlasName: (localPlayer?.playerNumber)!))
        self.syncMovementsDelegate?.updateVelocity()
    }
    
    /** Causes the player's weapon to attack for Sword Basic.*/
    func attack(vector: CGVector, angle: CGFloat, force: Double) {
        let startAttack = self.playerSceneHelper?.animate(frame_name: "Start", atlasName: (localPlayer?.playerWeapon)!, duration: 0.10)
        let attack = (self.playerSceneHelper?.animate(frame_name: "Attacking", atlasName: (localPlayer?.playerWeapon)!, duration: force))!
        let movement = SKAction.move(by: vector, duration: force)
        let rotate = SKAction.rotate(toAngle: angle, duration: 0.10)
        let stopAnimation = SKAction.reversed(startAttack!)
        localPlayer?.playerWeaponSprite?.run(SKAction.group([startAttack!, rotate])) {
            self.localPlayer?.playerWeaponSprite?.constraints?.removeAll()
            self.localPlayer?.playerWeaponSprite?.run(SKAction.group([attack, movement])) {
                self.localPlayer?.playerWeaponSprite?.run(SKAction.group([stopAnimation()]))
                self.playerSceneHelper?.resetPlayerWeapon(playerID: (self.localPlayer?.playerID)!)
            }
        }
    }
    
    /** Returns an idle animation for the player.*/
    private func idle(atlasName: String) -> SKAction {
        self.playerCurrAction = "idle"
        return SKAction.repeatForever(self.playerSceneHelper!.animate(frame_name: "Idle", atlasName: atlasName, duration: 0.30))
    }
    
    /** Returns a start running animation for the player.*/
    private func start_run(atlasName: String) -> SKAction {
        self.playerCurrAction = "start_run"
        return SKAction.repeat(self.playerSceneHelper!.animate(frame_name: "Start", atlasName: atlasName, duration: 0.05), count: 1)
    }
    
    /** Returns a running animation for the player.*/
    private func run(atlasName: String) -> SKAction {
        self.playerCurrAction = "run"
        return SKAction.repeat(self.playerSceneHelper!.animate(frame_name: "Run", atlasName: atlasName, duration: 0.085), count: 1)
    }
    
    /** Returns a stop running animation for the player.*/
    private func stop_run(atlasName: String) -> SKAction {
        self.playerCurrAction = "stop_run"
        return SKAction.reversed(start_run(atlasName: atlasName))()
    }
    
    /** Returns a start jumping animation for the player.*/
    private func start_jump(atlasName: String) -> SKAction {
        self.playerCurrAction = "start_jump"
        return SKAction.repeat(self.playerSceneHelper!.animate(frame_name: "Jump", atlasName: atlasName, duration: 0.06), count: 1)
    }
    
    /** Returns a continuous falling animation for the player.*/
    private func fall(atlasName: String) -> SKAction {
        self.playerCurrAction = "fall"
        return SKAction.repeatForever(self.playerSceneHelper!.animate(frame_name: "Fall", atlasName: atlasName, duration: 0.15))
    }
    
    /** Updates the camera to center on the player with a movement animation.*/
    private func updateCamera() {
        if let camera = camera{
            if self.localPlayer?.playerSprite != nil {
                camera.run(SKAction.move(to: CGPoint(x: (self.localPlayer?.playerSprite!.position.x)!, y: (self.localPlayer?.playerSprite!.position.y)! + CAMERA_Y_ADJUSTMENT), duration: 0.15))
            }
        }
    }
    
    /** When two objects collide delegate method.*/
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.collisionBitMask == 0) && (contact.bodyB.collisionBitMask == 1) {
            print("Player and weapon collided")
        }
    }
    
    //MARK: UPDATE OTHER PLAYERS METHODS
    
    /** Updates all other player's physics bodies.*/
    func updateOtherPlayerVelocity(playerID: String, velocity: CGVector?) {
        if velocity != nil {
            DispatchQueue.main.async {
                self.allPlayers[playerID]?.playerSprite!.physicsBody?.velocity = velocity!
            }
        }
    }
    
    /** Synchronizes all other player positions on the map.*/
    func syncOtherPlayerPosition(playerID: String, x: CGFloat, y: CGFloat) {
        let otherPlayer = allPlayers[playerID]?.playerSprite!
        let syncPosition = CGPoint(x: x, y: y)
        let distance = CGPointDistance(from: (otherPlayer?.position)!, to: syncPosition)
        if distance >= 30 {
            DispatchQueue.main.async {
                otherPlayer?.position = syncPosition
            }
        }
    }
    
    /** Returns the distance between the CGPoint from and to.*/
    private func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: from, to: to));
    }
    
    /** Squares and returns the distance between the from and to points.*/
    private func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y);
    }
    
    /** Given a playerID, current action, and facing direction, updates the player accordingly with the correct actions.*/
    func updateOtherPlayerAction(playerID: String, action: String, direction: CGFloat) {
        let finalAction: SKAction?
        
        switch action {
        case "idle":
            finalAction = idle(atlasName: allPlayers[playerID]!.playerNumber)
        case "start_run":
            finalAction = start_run(atlasName: allPlayers[playerID]!.playerNumber)
        case "run":
            finalAction = run(atlasName: allPlayers[playerID]!.playerNumber)
        case "stop_run":
            finalAction = stop_run(atlasName: allPlayers[playerID]!.playerNumber)
        case "start_jump":
            finalAction = start_jump(atlasName: allPlayers[playerID]!.playerNumber)
        case "fall":
            finalAction = fall(atlasName: allPlayers[playerID]!.playerNumber)
        default:
            finalAction = nil
        }
        
        if finalAction != nil {
            DispatchQueue.main.async {
                self.allPlayers[playerID]?.playerSprite!.xScale = direction
                self.allPlayers[playerID]?.playerSprite!.removeAllActions()
                self.allPlayers[playerID]?.playerSprite!.run(SKAction.repeatForever(finalAction!))
            }
        }
    }
}

/** Synchronizes the player's velocity with all other players.*/
protocol syncMovementsDelegate {
    /** Updates the player's current velocity to all other players.*/
    func updateVelocity()
}
