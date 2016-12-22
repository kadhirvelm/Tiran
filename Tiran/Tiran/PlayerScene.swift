import SpriteKit

class PlayerScene: SKScene, SKPhysicsContactDelegate {
    
    let PLAYER_MAX_SPEED: CGFloat = 200
    let CAMERA_Y_ADJUSTMENT: CGFloat = 50
    
    
    var localPlayer: SKSpriteNode?
    var localPlayerInfo: Player?
    
    var otherPlayers = [Player]()
    var otherPlayerSprites = [String: SKSpriteNode]()
    
    var playerCurrAction = ""
    var isMoving = false
    var isJumping = false
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        self.localPlayer = self.childNode(withName: self.localPlayerInfo!.playerNumber) as! SKSpriteNode?
        createOtherPlayerSprites()
        
        updateDisplayedValues(node: self.localPlayer!)
        
        zoomCamera()
        updateCamera()
    }
    
    func createOtherPlayerSprites() {
        for player in otherPlayers {
            let tempSprite = self.childNode(withName: player.playerNumber)
            otherPlayerSprites[player.playerID] = tempSprite as? SKSpriteNode
        }
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
            otherPlayerSprites[playerID]?.physicsBody?.velocity = velocity!
        }
    }
    
    func syncOtherPlayerPosition(playerID: String, x: CGFloat, y: CGFloat) {
        
        let otherPlayer = otherPlayerSprites[playerID]
        let syncPosition = CGPoint(x: x, y: y)
        let distance = CGPointDistance(from: (otherPlayer?.position)!, to: syncPosition)
        if distance >= 10 {
            otherPlayer?.position = syncPosition
        }
    }
    
    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: from, to: to));
    }
    
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y);
    }
    
    func updateOtherPlayerAction(playerID: String, action: String, direction: CGFloat) {
        otherPlayerSprites[playerID]?.xScale = direction
        otherPlayerSprites[playerID]?.removeAllActions()
        
        let finalAction: SKAction?
        
        switch action {
        case "idle":
            finalAction = idle(sprite: otherPlayerSprites[playerID]!)
        case "start_run":
            finalAction = start_run(sprite: otherPlayerSprites[playerID]!)
        case "run":
            finalAction = run(sprite: otherPlayerSprites[playerID]!)
        case "stop_run":
            finalAction = stop_run(sprite: otherPlayerSprites[playerID]!)
        case "start_jump":
            finalAction = start_jump(sprite: otherPlayerSprites[playerID]!)
        case "fall":
            finalAction = fall(sprite: otherPlayerSprites[playerID]!)
        default:
            finalAction = nil
        }
        
        if finalAction != nil {
            otherPlayerSprites[playerID]?.run(SKAction.repeatForever(finalAction!))
        }
    }
    
    func updatePlayer(dx: CGFloat) {
        if self.isJumping == false {
            if self.isMoving == false{
                self.isMoving = true
                localPlayer!.removeAllActions()
                self.localPlayer!.run(start_run(sprite: localPlayer!)) {
                    let groupMovement = SKAction.repeatForever(self.run(sprite: self.localPlayer!))
                    self.localPlayer?.run(groupMovement)
                }
            }
            if dx != 0 {
                let newScale = dx/fabs(dx)
                self.localPlayer?.xScale = newScale
            }
            if ((self.localPlayer?.physicsBody?.velocity.dx)! * dx) < self.PLAYER_MAX_SPEED {
                self.localPlayer?.physicsBody?.applyImpulse(CGVector(dx: 750 * dx, dy: 0.0))
            }
        }
    }
    
    func jumpPlayer() {
        if self.isJumping == false {
            localPlayer!.removeAllActions()
            self.isMoving = false
            self.isJumping = true
            localPlayer!.run(start_jump(sprite: localPlayer!)) {
                self.localPlayer?.physicsBody?.applyImpulse(CGVector(dx: 5, dy: 20000))
                let groupMovement = SKAction.repeatForever(self.fall(sprite: self.localPlayer!))
                self.localPlayer!.run(groupMovement)
            }
        }
    }
    
    func stopPlayer() {
        self.isMoving = false
        self.isJumping = false
        localPlayer!.removeAllActions()
        localPlayer!.physicsBody?.isResting = true
        localPlayer!.run(idle(sprite: localPlayer!))
    }
    
    private func idle(sprite: SKSpriteNode) -> SKAction {
        self.playerCurrAction = "idle"
        return SKAction.repeatForever(animate(frame_name: "Idle", sprite: sprite, duration: 0.30))
    }
    
    private func start_run(sprite: SKSpriteNode) -> SKAction {
        self.playerCurrAction = "start_run"
        return SKAction.repeat(animate(frame_name: "Start", sprite: sprite, duration: 0.08), count: 1)
    }
    
    private func run(sprite: SKSpriteNode) -> SKAction {
        self.playerCurrAction = "run"
        return SKAction.repeat(animate(frame_name: "Run", sprite: sprite, duration: 0.085), count: 1)
    }
    
    private func stop_run(sprite: SKSpriteNode) -> SKAction {
        self.playerCurrAction = "stop_run"
        return SKAction.repeat(animate(frame_name: "Start", sprite: sprite, duration: 0.15), count: 1)
    }
    
    private func start_jump(sprite: SKSpriteNode) -> SKAction {
        self.playerCurrAction = "start_jump"
        return SKAction.repeat(animate(frame_name: "Jump", sprite: sprite, duration: 0.06), count: 1)
    }
    
    private func fall(sprite: SKSpriteNode) -> SKAction {
        self.playerCurrAction = "fall"
        return SKAction.repeatForever(animate(frame_name: "Fall", sprite: sprite, duration: 0.15))
    }
    
    private func animate(frame_name: String, sprite: SKSpriteNode, duration: Double) -> SKAction {
        let atlas = SKTextureAtlas(named: sprite.name!)
        var frames = [SKTexture]()
        
        for name in atlas.textureNames.sorted() {
            if name.contains(frame_name) {
                frames.append(atlas.textureNamed(name))
            }
        }
        return SKAction.animate(with: frames, timePerFrame: duration)
    }
    
    private func updateDisplayedValues(node: SKSpriteNode) {
        let nodeName = (node.name)!
        let playerStats = self.childNode(withName: "\(nodeName) Stats")
        
        playerStats?.constraints = [SKConstraint.distance(SKRange.init(constantValue: 100), to: node)]
    }
    
    private func updateCamera() {
        if let camera = camera {
            camera.run(SKAction.move(to: CGPoint(x: self.localPlayer!.position.x, y: self.localPlayer!.position.y + CAMERA_Y_ADJUSTMENT), duration: 0.15))
        }
    }
}
