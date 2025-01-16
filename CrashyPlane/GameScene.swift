//
//  GameScene.swift
//  CrashyPlane
//
//  Created by Shubham Nanda on 13/06/24.
//

import SpriteKit
import SceneKit
import GameplayKit
import GoogleMobileAds
import Firebase
import FirebaseAuth
import FirebaseDatabase
enum GameState {
    case showingLogo
    case playing
    case dead
    
}
class GameScene: SKScene , SKPhysicsContactDelegate{
    
    
    var instructionPanel: SKSpriteNode!
    var closeButton: SKSpriteNode!
    var tap: SKSpriteNode!
    var returnButton: SKSpriteNode!
    var speedFactor: CGFloat = 1.0
    let speedIncrement: CGFloat = 0.03
    var  playButtonLabel: SKLabelNode!
    let upPipeTextures = [
        SKTexture(imageNamed: "PipeDownBlue"),
        SKTexture(imageNamed: "PipeDown"),
        
    ]
    var lastPipeXPosition: CGFloat = 0
    let pipeScale: CGFloat = 4.0
    var pipeDistance: CGFloat = 120
    let downPipeTextures = [
        
        SKTexture(imageNamed: "PipeUpRED"),
        SKTexture(imageNamed: "PipeUp")
    ]
    
    
    let powerUps = [
        
        SKTexture(imageNamed: "chemical")
       
    ]
    
    var logo: SKSpriteNode!
    var gameOver: SKSpriteNode!
    var chemicalPowerUp:SKSpriteNode!
    var gameState = GameState.showingLogo
    var scoreLabel: SKLabelNode!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
            if score > highScore {
                highScore = score
            }
        }
    }
    var highScore: Int {
        get {
            return UserDefaults.standard.integer(forKey: "highScore")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "highScore")
            highScoreSave(value: newValue)
            UserDefaults.standard.synchronize()
        }
    }
    var player: SKSpriteNode!
    var gameOverLine: SKSpriteNode!
    
    
    override func didMove(to view: SKView) {
        
        
        
        
        
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
        physicsWorld.contactDelegate = self
        
        if UserDefaults.standard.bool(forKey: "isSoundOn") {
            BackgroundMusic.shared.play()
        }
        if let imageName = UserDefaults.standard.string(forKey: "selectedBackground") {
            let texture = SKTexture(imageNamed: imageName)
            createSky(skyTexture: texture)
        }
        
        if let selectedCharacterName = UserDefaults.standard.string(forKey: "selectedCharacter") {
            createPlayer(characterName: selectedCharacterName)
        }
        
        
        createReturnButton()
        endLine()
        createLogos()
        createScore()
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let playerName = UserDefaults.standard.string(forKey: "selectedCharacter")!
        for touch in touches {
            let location = touch.location(in: self)
            
            if returnButton.contains(location) {
                returnToTitleScene()
            }
            
            if gameState == .showingLogo {
                gameState = .playing
                let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                let remove = SKAction.removeFromParent()
                let wait = SKAction.wait(forDuration: 0.5)
                let activatePlayer = SKAction.run { [unowned self] in
                    self.player.physicsBody?.isDynamic = true
                    self.startPipes()
                    self.generatePowerup()
                    
                }
                let activatePlayer1 = SKAction.run { [unowned self] in
                    self.player.physicsBody?.isDynamic = true
                    
                }
                
                let sequence = SKAction.sequence([fadeOut, wait, activatePlayer, remove])
                let sequence1 = SKAction.sequence([fadeOut, wait, activatePlayer1, remove])
                logo.run(sequence)
                returnButton.run(sequence1)
                tap.run(sequence1)
                playButtonLabel.run(sequence1)
            } else if gameState == .playing {
                player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
              
                // Apply impulse based on gravity direction
                if physicsWorld.gravity.dy < 0 {
                    if playerName == "planeRed" || playerName == "planeGreen" || playerName == "bird" || playerName == "bat" {
                        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 35))}
                    else if playerName == "dragon" {
                        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 55))
                    }
//                    else if playerName == "bat" {
//                        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10))
//                    }
                    
                    else if playerName == "skeleton" {
                        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 30))
                    }
                } else {
                    if playerName == "planeRed" || playerName == "planeBlue" || playerName == "bird" || playerName == "bat"{
                        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -35))}
                    else if playerName == "dragon" {
                        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -55))
                    }
//                    else if playerName == "bat" {
//                        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -10))
//                    }
                    
                    else if playerName == "skeleton" {
                        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -30 ))
                    }
                }}
            else if gameState == .dead {
                returnToGameOverScene()
            }
        }
    }
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        guard player != nil else { return }
        let value = player.physicsBody!.velocity.dy * 0.001
        let rotate = SKAction.rotate(toAngle: value, duration: 0.1)
        
        player.run(rotate)
    }
    
    func createLogos() {
        logo = SKSpriteNode(imageNamed: "cranky")
        logo.size = CGSize(width: frame.size.width * 1.3, height: frame.size.width * 1.3)

        logo.position = CGPoint(x: frame.midX, y: frame.midY+60)
        addChild(logo)
        tap = SKSpriteNode(imageNamed: "tapTick")
        tap.size = CGSize(width: frame.size.width * 0.15, height: frame.size.width * 0.15)
        tap.position = CGPoint(x: frame.midX, y: frame.midY-140)
        addChild(tap)
        playButtonLabel =  SKLabelNode(fontNamed: "Arial-BoldMT")
        playButtonLabel.text = "Tap To Play!"
        playButtonLabel.fontSize = 24
        playButtonLabel.fontColor = SKColor.white
        playButtonLabel.position = CGPoint(x: tap.position.x, y: tap.position.y - 60 )
        addChild( playButtonLabel)
        gameOver = SKSpriteNode(imageNamed: "go")
        gameOver.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOver.alpha = 0
        
        gameOver.zPosition = 30
        addChild(gameOver)
    }
    func createReturnButton() {
        returnButton = SKSpriteNode(imageNamed: "home")
        returnButton.position = CGPoint(x: frame.midX , y: frame.midY - 20)
        returnButton.zPosition = 100
        returnButton.size = CGSize(width: 60, height: 60)
        addChild(returnButton)
    }
    func returnToTitleScene() {
        if let titleScene = TitleScene(fileNamed: "TitleScene") {
            titleScene.scaleMode = .resizeFill
            let transition = SKTransition.fade(withDuration: 1.0)
            self.view?.presentScene(titleScene, transition: transition)
        }
    }
    func createPlayer(characterName: String){
        let playerTexture = SKTexture(imageNamed: characterName)
        player = SKSpriteNode(texture: playerTexture)
        player.zPosition = 10
        
        player.position = CGPoint(x: frame.width / 6, y: frame.height * 0.75)
        player.physicsBody = SKPhysicsBody(texture: playerTexture, size: playerTexture.size())
        player.physicsBody!.contactTestBitMask = player.physicsBody!.collisionBitMask
        player.physicsBody?.isDynamic = false
        player.physicsBody?.collisionBitMask = 0
        player.size = CGSize(width: 90, height: 90)
        addChild(player)
        
        let frame2 = SKTexture(imageNamed: "\(characterName)2")
        let frame3 = SKTexture(imageNamed: "\(characterName)3")
        let animation = SKAction.animate(with: [playerTexture, frame2, frame3, frame2], timePerFrame: 0.1)
        let runForever = SKAction.repeatForever(animation)
        
        player.run(runForever)
    }
    
    func createSky(skyTexture: SKTexture){
        
        
        for i in 0 ... 1 {
            let sky = SKSpriteNode(texture: skyTexture)
            sky.zPosition = -35
            sky.anchorPoint = CGPoint.zero
            sky.size.height = frame.height
            sky.position = CGPoint(x: CGFloat(i) * skyTexture.size().width, y: 0)
            let moveLeft = SKAction.moveBy(x: -skyTexture.size().width, y: 0, duration: 20)
            let moveReset = SKAction.moveBy(x: skyTexture.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            sky.run(moveForever)
            addChild(sky)
        }
     
        
    }
    
    func createPipes(){
        var upTexture: SKTexture
        var downTexture: SKTexture
        var leftUpPipeName: String?
        var leftDownPipeName: String?
        repeat {
            upTexture = upPipeTextures.randomElement()!
            downTexture = downPipeTextures.randomElement()!
        } while (upTexture.description.contains("PipeDownBlue") && downTexture.description.contains("PipeUpRED"))
        
        //       finding pipe names
        let UpTextureDescription = "\(upTexture)"
        if let pipeDownName = UpTextureDescription.components(separatedBy: "'").dropFirst().first {
            leftUpPipeName = pipeDownName
        }
        let DownTextureDescription = "\(downTexture)"
        if let pipeUpName = DownTextureDescription.components(separatedBy: "'").dropFirst().first {
            leftDownPipeName = pipeUpName
        }
        
        
        
        
        upTexture.filteringMode = .nearest
        let upPipe = SKSpriteNode(texture: upTexture)
        
        upPipe.xScale = -5.0
        upPipe.physicsBody = SKPhysicsBody(texture: upTexture, size: upTexture.size())
        upPipe.physicsBody?.isDynamic = false
        
        
        downTexture.filteringMode = .nearest
        let downPipe = SKSpriteNode(texture: downTexture)
        downPipe.xScale = -5.0
        downPipe.physicsBody = SKPhysicsBody(texture: downTexture, size: downTexture.size())
        downPipe.physicsBody?.isDynamic = false
        
        
        
        // Adjust this value to increase or decrease the height
        upPipe.setScale(pipeScale)
        downPipe.setScale(pipeScale)
        
        let rightPipeCollision = SKSpriteNode(color: UIColor.red, size: CGSize(width: 25, height: frame.height))
        rightPipeCollision.name = "scoreDetect"
        rightPipeCollision.physicsBody = SKPhysicsBody(rectangleOf: rightPipeCollision.size)
        rightPipeCollision.physicsBody?.isDynamic = false
        
        let leftPipeCollision = SKSpriteNode(color: UIColor.blue, size: CGSize(width: 20, height: frame.height))
        leftPipeCollision.isHidden = true
        rightPipeCollision.isHidden = true
        
        //         changing Name of pipe accordingly
        if leftUpPipeName == "PipeDownBlue" && leftDownPipeName == "PipeUp" {
            leftPipeCollision.name = "Blower"
        }
        else if leftDownPipeName == "PipeUpRED" && leftUpPipeName == "PipeDown" {
            leftPipeCollision.name = "Vaccum"
        }
        else if leftUpPipeName == "PipeDown" && leftDownPipeName == "PipeUp"{
            leftPipeCollision.name = "Neutral"
        }
        print(leftPipeCollision.name!)
        
        leftPipeCollision.physicsBody = SKPhysicsBody(rectangleOf: leftPipeCollision.size)
        leftPipeCollision.physicsBody?.isDynamic = false
        
        addChild(upPipe)
        addChild(downPipe)
        addChild(rightPipeCollision)
        addChild(leftPipeCollision)
        
        
        let xPosition = frame.width + upPipe.frame.width
        let max = CGFloat(frame.height / 2)
     
           lastPipeXPosition = xPosition
        let yPosition = CGFloat.random(in: -50...max)
        
      
        
        upPipe.position = CGPoint(x: xPosition, y: yPosition + upPipe.size.height + pipeDistance)
        
        downPipe.position = CGPoint(x: xPosition, y: yPosition - pipeDistance)
        
        rightPipeCollision.position = CGPoint(x: xPosition + (rightPipeCollision.size.width * 2)+40, y: frame.midY)
        leftPipeCollision.position = CGPoint(x: xPosition - (leftPipeCollision.size.width * 2)-12, y: frame.midY)
        
        
        let endPosition = frame.width + (upPipe.frame.width * 2)
        let moveAction = SKAction.moveBy(x: -endPosition, y: 0, duration: 6.2 / Double(speedFactor))
        let moveSequence = SKAction.sequence([moveAction, SKAction.removeFromParent()])
        upPipe.run(moveSequence)
        downPipe.run(moveSequence)
        rightPipeCollision.run(moveSequence)
        leftPipeCollision.run(moveSequence)
        
    }
    
    func startPipes() {
        let create = SKAction.run { [unowned self] in
            self.createPipes()
        }
        
        let wait = SKAction.wait(forDuration: 4.5 / Double(speedFactor))
        let sequence = SKAction.sequence([create, wait])
        let repeatForever = SKAction.repeatForever(sequence)
        
        run(repeatForever)
      
    }
    func generatePowerup() {
        let spawnPowerUp = SKAction.run { [unowned self] in
            self.spawnChemicalPowerUp()
        }
        let powerUpWait = SKAction.wait(forDuration: 20)
        let powerUpSequence = SKAction.sequence([spawnPowerUp, powerUpWait])
        run(SKAction.repeatForever(powerUpSequence))
    }
    func createScore() {
        scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        scoreLabel.fontSize = 24
        
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 80)
        scoreLabel.text = "SCORE: 0"
        scoreLabel.fontColor = UIColor.black
        scoreLabel.zPosition = 20
        addChild(scoreLabel)
    }
    func endLine(){
        let gameOverLineHeight: CGFloat = 10.0 // Height of the game over line
        let gameOverLine = SKSpriteNode(color: .red, size: CGSize(width: frame.width, height: gameOverLineHeight))
        gameOverLine.zPosition = 1 // Ensure it's above other elements if needed
        gameOverLine.position = CGPoint(x: frame.midX, y: gameOverLineHeight / 2.0)
        
        gameOverLine.physicsBody = SKPhysicsBody(rectangleOf: gameOverLine.size)
        gameOverLine.physicsBody?.isDynamic = false
        gameOverLine.physicsBody?.categoryBitMask = 0x1 << 1 // Set a unique bit mask
        gameOverLine.physicsBody?.contactTestBitMask = 0x1 << 0 // Adjust according to your
        gameOverLine.isHidden = true
        addChild(gameOverLine)
    }
    func returnToGameOverScene() {
        let gameOverScene = GameOverScene(fileNamed: "GameOverScene")!
        gameOverScene.scaleMode = .resizeFill
        gameOverScene.alpha = 0 // Start with the scene completely transparent
        self.view?.presentScene(gameOverScene)
        
        // Create the scale action
        let scaleUp = SKAction.scale(to: 1.0, duration: 1.0)
        let fadeIn = SKAction.fadeIn(withDuration: 1.0) // Also fade in
        
        let group = SKAction.group([scaleUp, fadeIn])
        
        // Start with the scene at scale 0
        gameOverScene.setScale(0.0)
        
        // Run the scale action on the scene's root node
        gameOverScene.run(group)
    }
    func spawnChemicalPowerUp() {
        let powerups: [(String, Double)] = [("chemical", 0.45), ("Gap", 0.45), ("2x", 0.06)]
        let totalWeight = powerups.reduce(0) { $0 + $1.1 }
        let randomValue = Double.random(in: 0..<totalWeight)
        var cumulativeWeight: Double = 0
        var selectedPowerUp: String = ""

        for powerup in powerups {
            cumulativeWeight += powerup.1
            if randomValue < cumulativeWeight {
                selectedPowerUp = powerup.0
                break
            }
        }

        let image = selectedPowerUp
        chemicalPowerUp = SKSpriteNode(texture: SKTexture(imageNamed: image))
        if image == "chemical" {
            chemicalPowerUp.name = "chemicalPowerUp"
        }
        else if image == "Gap" {
            chemicalPowerUp.name = "gapPowerUp"
        }
        else {
            chemicalPowerUp.name = "2xPowerUp"
        }
     
        
           chemicalPowerUp.size = CGSize(width: 70, height: 80)
           
           // Calculate position between pipes
           let pipeSpacing: CGFloat = frame.width / 2  // Approximate space between pipes
           let spawnX = lastPipeXPosition + pipeSpacing/2 + 10  // Spawn halfway between pipes
           let spawnY = CGFloat.random(in: frame.height * 0.3...frame.height * 0.7)  // Safe vertical range
           
           chemicalPowerUp.position = CGPoint(x: spawnX, y: spawnY)
           
           chemicalPowerUp.physicsBody = SKPhysicsBody(circleOfRadius: chemicalPowerUp.size.width / 2)
           chemicalPowerUp.physicsBody?.isDynamic = false
           chemicalPowerUp.physicsBody?.categoryBitMask = 0x1 << 3
           chemicalPowerUp.physicsBody?.contactTestBitMask = 0x1 << 0
           chemicalPowerUp.physicsBody?.collisionBitMask = 0
           
           addChild(chemicalPowerUp)
           
           // Adjust movement duration to match pipe speed
           let moveLeft = SKAction.moveBy(x: -frame.width - 200, y: 0, duration: 6.0 / Double(speedFactor))
           let remove = SKAction.removeFromParent()
           chemicalPowerUp.run(SKAction.sequence([moveLeft, remove]))
    }
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "scoreDetect" || contact.bodyB.node?.name == "scoreDetect" {
            if contact.bodyA.node == player {
                contact.bodyB.node?.removeFromParent()
            } else {
                contact.bodyA.node?.removeFromParent()
            }
            
            
            let sound = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
            run(sound)
            
            physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
            
            score += 1
            speedFactor += speedIncrement
            
            
            return
        }
        
        guard contact.bodyA.node != nil && contact.bodyB.node != nil else {
            return
        }
        
        if contact.bodyA.node?.name == "Neutral" || contact.bodyB.node?.name == "Neutral" {
            if contact.bodyA.node == player {
                contact.bodyB.node?.removeFromParent()
                physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
                
            } else {
                contact.bodyA.node?.removeFromParent()
                
            }
            return }
        if contact.bodyA.node?.name == "Vaccum" || contact.bodyB.node?.name == "Vaccum" {
            if contact.bodyA.node == player {
                contact.bodyB.node?.removeFromParent()
                
                let sound = SKAction.playSoundFileNamed("vaccum.mp3", waitForCompletion: false)
                run(sound)
                physicsWorld.gravity = CGVector(dx: 0.0, dy: 4.5)
                physicsWorld.gravity.dy += 0.02
            } else {
                contact.bodyA.node?.removeFromParent()
                
            }
            return }
        if contact.bodyA.node?.name == "Blower" || contact.bodyB.node?.name == "Blower" {
            if contact.bodyA.node == player {
                contact.bodyB.node?.removeFromParent()
                let sound = SKAction.playSoundFileNamed("blower.mp3", waitForCompletion: false)
                run(sound)
                physicsWorld.gravity = CGVector(dx: 0.0, dy: -7.0)
                physicsWorld.gravity.dy += -0.02
                
            } else {
                contact.bodyA.node?.removeFromParent()
                
            }
            return }
        if contact.bodyA.node?.name == "chemicalPowerUp" || contact.bodyB.node?.name == "chemicalPowerUp" {
            if contact.bodyA.node == player {
                contact.bodyB.node?.removeFromParent()
                
                // Initial shrink effect
                if let explosion = SKEmitterNode(fileNamed: "Magic") {
                    explosion.setScale(0.2)
                    explosion.position = player.position
                    explosion.zPosition = player.zPosition + 2
                    addChild(explosion)
                    
                    let particleWait = SKAction.wait(forDuration: 0.4)
                    let particleRemove = SKAction.removeFromParent()
                    explosion.run(SKAction.sequence([particleWait, particleRemove]))
                }
                
                let shrink = SKAction.scale(to: 0.5, duration: 0.2)
                let wait = SKAction.wait(forDuration: 10.0)
                let growBack = SKAction.scale(to: 1.0, duration: 0.2)
                
                // Create grow effect with both particle and sound
                let growEffect = SKAction.run {
                    // Particle effect
                    if let explosion = SKEmitterNode(fileNamed: "Magic") {
                        explosion.setScale(0.2)
                        explosion.position = self.player.position
                        explosion.zPosition = self.player.zPosition + 2
                        self.addChild(explosion)
                        
                        let particleWait = SKAction.wait(forDuration: 0.4)
                        let particleRemove = SKAction.removeFromParent()
                        explosion.run(SKAction.sequence([particleWait, particleRemove]))
                    }
                    // Play grow sound
                    self.run(SKAction.playSoundFileNamed("shrink.mp3", waitForCompletion: false))
                }
                
                // Combine all actions
                let sequence = SKAction.sequence([
                    shrink,
                    SKAction.playSoundFileNamed("shrink.mp3", waitForCompletion: false), // Shrink sound
                    wait,
                    growEffect, // Particle effect and grow sound
                    growBack
                ])
                
                player.run(sequence)
            } else {
                contact.bodyA.node?.removeFromParent()
            }

            return        }
        if contact.bodyA.node?.name == "gapPowerUp" || contact.bodyB.node?.name == "gapPowerUp" {
            if contact.bodyA.node == player {
                contact.bodyB.node?.removeFromParent()
                if let explosion = SKEmitterNode(fileNamed: "Magic") {
                    explosion.setScale(0.1)  // Slightly larger for better visual impact
                      explosion.position = player.position
                      explosion.zPosition = player.zPosition + 1  // Ensure it's above the player
                      addChild(explosion)
                      
                      // Sync particle with shrink effect (disappear as shrink completes)
                      let particleWait = SKAction.wait(forDuration: 0.4)
                      let particleRemove = SKAction.removeFromParent()
                      explosion.run(SKAction.sequence([particleWait, particleRemove]))
                    
                }
                pipeDistance = 190  // Assuming pipeScale is a global or class property
                    let scaleWait = SKAction.wait(forDuration: 10.0)  // Same as `wait` above
                    let revertPipeScale = SKAction.run { [weak self] in
                        self?.pipeDistance = 120
                    }
                    run(SKAction.sequence([scaleWait, revertPipeScale]))
                
                let sound = SKAction.playSoundFileNamed("stretch.mp3", waitForCompletion: false)
                run(sound)
            }
            else {
                contact.bodyA.node?.removeFromParent()
            }
         
           
            
            return
        }
        if contact.bodyA.node?.name == "2xPowerUp" || contact.bodyB.node?.name == "2xPowerUp" {
            if contact.bodyA.node == player {
                contact.bodyB.node?.removeFromParent()
                if let explosion = SKEmitterNode(fileNamed: "Magic") {
                    explosion.setScale(0.1)  // Slightly larger for better visual impact
                      explosion.position = player.position
                      explosion.zPosition = player.zPosition + 1  // Ensure it's above the player
                      addChild(explosion)
                      
                      // Sync particle with shrink effect (disappear as shrink completes)
                      let particleWait = SKAction.wait(forDuration: 0.4)
                      let particleRemove = SKAction.removeFromParent()
                      explosion.run(SKAction.sequence([particleWait, particleRemove]))
                    
                }
                score = 2 * score
                
                let sound = SKAction.playSoundFileNamed("gameBonus.mp3", waitForCompletion: false)
                run(sound)
            }
            else {
                contact.bodyA.node?.removeFromParent()
            }
         
           
            
            return
        }
        if contact.bodyA.node == player || contact.bodyB.node == player {
            if let explosion = SKEmitterNode(fileNamed: "PlayerExplosion") {
                explosion.position = player.position
                addChild(explosion)
                
                
            }
            
            let soundNode = SKAudioNode(fileNamed: "explosion.wav")

         
            soundNode.autoplayLooped = false
            soundNode.run(SKAction.changeVolume(to: 0.2, duration: 0))

          
            addChild(soundNode)

            
            soundNode.run(SKAction.play())
            
            
            BackgroundMusic.shared.stop()
            player.removeFromParent()
            speed = 0
            UserDefaults.standard.set(score, forKey: "lastScore")
            gameState = .dead
            
            
            
            
            
            
        }
    }
    
    func highScoreSave(value: Int) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference().child("users").child(userID)
        ref.updateChildValues(["High Score":value ]) { error, _ in
            if let error = error {
                print("Failed to update high score \(error.localizedDescription)")
            } else {
                print("high score status updated successfully")
            }
        }
    }
    
}

