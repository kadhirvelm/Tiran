import SpriteKit

class PlayerScene: SKScene, SKPhysicsContactDelegate {
    
    let playerMaxSpeed: CGFloat = 200
    var player: SKSpriteNode?
    var lastTouch: CGPoint?
    
    var isMoving = false
    var isJumping = false
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        self.player = self.childNode(withName: "Player_1") as! SKSpriteNode?
    }
    
    override func didSimulatePhysics() {
        updateCamera()
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
        return SKAction.repeatForever(animate(frame_name: "Idle", sprite: player!, duration: 0.30))
    }
    
    private func start_run() -> SKAction {
        return SKAction.repeat(animate(frame_name: "Start", sprite: player!, duration: 0.08), count: 1)
    }
    
    private func run() -> SKAction {
        return SKAction.repeat(animate(frame_name: "Run", sprite: player!, duration: 0.085), count: 1)
    }
    
    private func stop_run() -> SKAction {
        return SKAction.repeat(animate(frame_name: "Start", sprite: player!, duration: 0.15), count: 1)
    }
    
    private func start_jump() -> SKAction {
        return SKAction.repeat(animate(frame_name: "Jump", sprite: player!, duration: 0.06), count: 1)
    }
    
    private func fall() -> SKAction {
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
