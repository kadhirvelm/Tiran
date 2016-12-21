import SpriteKit

class PlayerScene: SKScene, SKPhysicsContactDelegate {
    
    let playerMaxSpeed: CGFloat = 200
    var player: SKSpriteNode?
    var playerCurrAction = ""
    var num_other_players = 0
    var other_players = [SKSpriteNode?]()
    var lastTouch: CGPoint?
    
    var isMoving = false
    var isJumping = false
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        self.player = self.childNode(withName: "Player_1") as! SKSpriteNode?
        if num_other_players > 0 {
            for player_num in 2...(2 + self.num_other_players) {
                let otherPlayer = self.childNode(withName: "Player_\(player_num)") as! SKSpriteNode?
                otherPlayer?.run(idle())
                print("Sprite added --> \(otherPlayer)")
                other_players.append(otherPlayer)
            }
        }
    }
    
    override func didSimulatePhysics() {
        updateCamera()
    }
    
    func updateOtherPlayerPosition(index: Int, body: SKPhysicsBody?, x: Int, y: Int) {
        if body != nil {
            other_players[index]?.physicsBody = body
        }
        other_players[index]?.position = CGPoint(x: x, y: y)
    }
    
    func updateOtherPlayerAction(index: Int, action: String, direction: CGFloat) {
        other_players[index]?.xScale = direction
        other_players[index]?.removeAllActions()
        
        let finalAction: SKAction?
        
        switch action {
        case "idle":
            finalAction = idle()
        case "start_run":
            finalAction = start_run()
        case "run":
            finalAction = run()
        case "stop_run":
            finalAction = stop_run()
        case "start_jump":
            finalAction = start_jump()
        case "fall":
            finalAction = fall()
        default:
            finalAction = nil
        }
        
        if finalAction != nil {
            other_players[index]?.run(SKAction.repeatForever(finalAction!))
        }
    }
    
    func updatePlayer(dx: CGFloat) {
        if self.isJumping == false {
            if self.isMoving == false{
                self.isMoving = true
                player!.removeAllActions()
                self.player!.run(start_run()) {
                    let groupMovement = SKAction.repeatForever(self.run())
                    self.player?.run(groupMovement)
                }
            }
            if dx != 0 {
                self.player?.xScale = dx/fabs(dx)
            }
            if ((self.player?.physicsBody?.velocity.dx)! * dx) < self.playerMaxSpeed {
                self.player?.physicsBody?.applyImpulse(CGVector(dx: 750 * dx, dy: 0.0))
            }
        }
    }
    
    func jumpPlayer() {
        if self.isJumping == false {
            player!.removeAllActions()
            self.isMoving = false
            self.isJumping = true
            player!.run(start_jump()) {
                self.player?.physicsBody?.applyImpulse(CGVector(dx: 5, dy: 20000))
                let groupMovement = SKAction.repeatForever(self.fall())
                self.player!.run(groupMovement)
            }
        }
    }
    
    func stopPlayer() {
        self.isMoving = false
        self.isJumping = false
        player!.removeAllActions()
        player!.physicsBody?.isResting = true
        player!.run(idle())
    }
    
    private func idle() -> SKAction {
        self.playerCurrAction = "idle"
        return SKAction.repeatForever(animate(frame_name: "Idle", sprite: player!, duration: 0.30))
    }
    
    private func start_run() -> SKAction {
        self.playerCurrAction = "start_run"
        return SKAction.repeat(animate(frame_name: "Start", sprite: player!, duration: 0.08), count: 1)
    }
    
    private func run() -> SKAction {
        self.playerCurrAction = "run"
        return SKAction.repeat(animate(frame_name: "Run", sprite: player!, duration: 0.085), count: 1)
    }
    
    private func stop_run() -> SKAction {
        self.playerCurrAction = "stop_run"
        return SKAction.repeat(animate(frame_name: "Start", sprite: player!, duration: 0.15), count: 1)
    }
    
    private func start_jump() -> SKAction {
        self.playerCurrAction = "start_jump"
        return SKAction.repeat(animate(frame_name: "Jump", sprite: player!, duration: 0.06), count: 1)
    }
    
    private func fall() -> SKAction {
        self.playerCurrAction = "fall"
        return SKAction.repeatForever(animate(frame_name: "Fall", sprite: player!, duration: 0.15))
    }
    
    private func animate(frame_name: String, sprite: SKSpriteNode, duration: Double) -> SKAction {
        let atlas = SKTextureAtlas(named: "Red_Figure")
        var frames = [SKTexture]()
        
        for name in atlas.textureNames.sorted() {
            if name.contains(frame_name) {
                frames.append(atlas.textureNamed(name))
            }
        }
        return SKAction.animate(with: frames, timePerFrame: duration)
    }
    
    private func updateCamera() {
        if let camera = camera {
            camera.run(SKAction.move(to: CGPoint(x: self.player!.position.x, y: self.player!.position.y), duration: 0.15))
        }
    }
}
