import SpriteKit

class PlayerScene: SKScene, SKPhysicsContactDelegate {
    
    let PLAYER_MAX_SPEED: CGFloat = 200
    let CAMERA_Y_ADJUSTMENT: CGFloat = 50
    
    var localPlayer: Player?
    var allPlayers = [String: Player]()
    
    var playerCurrAction = ""
    var isMoving = false
    var isJumping = false
    
    var syncMovementsDelegate: syncMovementsDelegate?
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        removeNonPlayers()
        setPlayerSprites()
        adjustPlayerSprites()
        
        zoomCamera()
        updateCamera()
    }
    
    func removeNonPlayers() {
        for index in 1...4 {
            let playerNum = "Player_\(index)"
            
            if !(allPlayers.contains(where: { (_: String, value: Player) -> Bool in
                return value.playerNumber == playerNum
            })) {
                self.childNode(withName: playerNum)?.removeFromParent()
                self.childNode(withName: "\(playerNum) Weapon")?.removeFromParent()
            }
        }
    }
    
    func setPlayerSprites() {
        for (_, player) in self.allPlayers {
            let sprite = self.childNode(withName: player.playerNumber) as? SKSpriteNode
            let weaponSprite = self.childNode(withName: "\(player.playerNumber) Weapon") as? SKSpriteNode
            let nameSprite = sprite?.childNode(withName: "Name") as? SKLabelNode
            let maxHPSprite = sprite?.childNode(withName: "HP") as? SKSpriteNode
            let currentDamageSprite = maxHPSprite?.childNode(withName: "Damage") as? SKSpriteNode
            let maxVelSprite = sprite?.childNode(withName: "Vel") as? SKSpriteNode
            let currentVelConsumed = maxVelSprite?.childNode(withName: "VP") as? SKSpriteNode
            
            player.setSprites(playerSprite: sprite!,
                              playerWeaponSprite: weaponSprite!,
                              playerNameSprite: nameSprite!,
                              playerMaxHPSprite: maxHPSprite!,
                              playerCurrentDamageSprite: currentDamageSprite!,
                              playerMaxVelSprite: maxVelSprite!,
                              playerCurrentVelConsumedSprite: currentVelConsumed!)
            player.playerMaxHP = 100
            player.playerMaxVel = 100
        }
    }
    
    func adjustPlayerSprites() {
        for (_, player) in self.allPlayers {
            player.playerNameSprite?.text = player.playerName
            let weaponIdle = SKAction.repeatForever(animate(frame_name: "Idle", atlasName: player.playerWeapon, duration: 0.15))
            player.playerWeaponSprite?.run(weaponIdle)
            
            resetPlayerWeapon(playerID: player.playerID)
            
            player.playerCurrentHP = player.playerMaxHP
            player.playerCurrentVel = player.playerMaxVel
        }
    }
    
    func resetPlayerWeapon(playerID: String) {
        let player = allPlayers[playerID]
        let weaponConstraint = SKConstraint.distance(SKRange(lowerLimit: 25, upperLimit: 40), to: (player?.playerNameSprite)!)
        let weaponConstraint2 = SKConstraint.distance(SKRange(lowerLimit: 35, upperLimit: 40), to: (player?.playerSprite)!)
        player?.playerWeaponSprite?.constraints = [weaponConstraint, weaponConstraint2]
        
    }
    
    func zoomCamera() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            sleep(3)
            DispatchQueue.main.sync {
                self.camera?.run(SKAction.scale(to: 0.5, duration: 0.75)) {
                }
            }
        }
    }
    
    override func didSimulatePhysics() {
        updateCamera()
    }
    
    func updateOtherPlayerVelocity(playerID: String, velocity: CGVector?) {
        if velocity != nil {
            DispatchQueue.main.async {
                self.allPlayers[playerID]?.playerSprite!.physicsBody?.velocity = velocity!
            }
        }
    }
    
    func syncOtherPlayerPosition(playerID: String, x: CGFloat, y: CGFloat) {
        let otherPlayer = allPlayers[playerID]?.playerSprite!
        let syncPosition = CGPoint(x: x, y: y)
        let distance = CGPointDistance(from: (otherPlayer?.position)!, to: syncPosition)
        if distance >= 10 {
            DispatchQueue.main.async {
                otherPlayer?.position = syncPosition
            }
        }
    }
    
    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: from, to: to));
    }
    
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y);
    }
    
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
            DispatchQueue.main.sync {
                self.allPlayers[playerID]?.playerSprite!.xScale = direction
                self.allPlayers[playerID]?.playerSprite!.removeAllActions()
                self.allPlayers[playerID]?.playerSprite!.run(SKAction.repeatForever(finalAction!))
            }
        }
    }
    
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
    
    func stopPlayer() {
        self.isMoving = false
        self.isJumping = false
        localPlayer?.playerSprite!.removeAllActions()
        localPlayer?.playerSprite!.physicsBody?.isResting = true
        localPlayer?.playerSprite!.run(idle(atlasName: (localPlayer?.playerNumber)!))
        self.syncMovementsDelegate?.updateVelocity()
    }
    
    private func idle(atlasName: String) -> SKAction {
        self.playerCurrAction = "idle"
        return SKAction.repeatForever(animate(frame_name: "Idle", atlasName: atlasName, duration: 0.30))
    }
    
    private func start_run(atlasName: String) -> SKAction {
        self.playerCurrAction = "start_run"
        return SKAction.repeat(animate(frame_name: "Start", atlasName: atlasName, duration: 0.05), count: 1)
    }
    
    private func run(atlasName: String) -> SKAction {
        self.playerCurrAction = "run"
        return SKAction.repeat(animate(frame_name: "Run", atlasName: atlasName, duration: 0.085), count: 1)
    }
    
    private func stop_run(atlasName: String) -> SKAction {
        self.playerCurrAction = "stop_run"
        return SKAction.repeat(animate(frame_name: "Start", atlasName: atlasName, duration: 0.15), count: 1)
    }
    
    private func start_jump(atlasName: String) -> SKAction {
        self.playerCurrAction = "start_jump"
        return SKAction.repeat(animate(frame_name: "Jump", atlasName: atlasName, duration: 0.06), count: 1)
    }
    
    private func fall(atlasName: String) -> SKAction {
        self.playerCurrAction = "fall"
        return SKAction.repeatForever(animate(frame_name: "Fall", atlasName: atlasName, duration: 0.15))
    }
    
    private func animate(frame_name: String, atlasName: String, duration: Double) -> SKAction {
        let atlas = SKTextureAtlas(named: atlasName)
        var frames = [SKTexture]()
        
        for name in atlas.textureNames.sorted() {
            if name.contains(frame_name) {
                frames.append(atlas.textureNamed(name))
            }
        }
        return SKAction.animate(with: frames, timePerFrame: duration)
    }
    
    private func updateCamera() {
        if let camera = camera{
            if self.localPlayer?.playerSprite != nil {
                camera.run(SKAction.move(to: CGPoint(x: (self.localPlayer?.playerSprite!.position.x)!, y: (self.localPlayer?.playerSprite!.position.y)! + CAMERA_Y_ADJUSTMENT), duration: 0.15))
            }
        }
    }
}

protocol syncMovementsDelegate {
    func updateVelocity()
}
