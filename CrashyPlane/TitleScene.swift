import SpriteKit
import GameplayKit
import GoogleMobileAds

class TitleScene: SKScene {
    
    var player: SKSpriteNode!
    var playButton: SKSpriteNode!
    var settingsButton: SKSpriteNode!
    var scoresButton: SKSpriteNode!
    var charactersButton: SKSpriteNode!
    var info : SKSpriteNode!
    var logo: SKSpriteNode!
    var ad: SKSpriteNode!
    var modalBackground: SKShapeNode!
    var coinNo: Int = 0
    var coin: SKSpriteNode!
    var buttonLabel: SKLabelNode!
    var getMore: SKSpriteNode!
    var instructions: SKSpriteNode!
    override func didMove(to view: SKView) {
        // Enable user interaction
        
        if UserDefaults.standard.bool(forKey: "isSoundOn") {
            BackgroundMusic.shared.play()
        }
        if UserDefaults.standard.string(forKey: "selectedBackground") == nil {
            UserDefaults.standard.set("airadventurelevel1", forKey: "selectedBackground")
        }
        if let imageName = UserDefaults.standard.string(forKey: "selectedBackground") {
            let texture = SKTexture(imageNamed: imageName)
            createSky(skyTexture: texture)
        }
        
        if UserDefaults.standard.string(forKey: "selectedCharacter") == nil {
            UserDefaults.standard.set("planeRed", forKey: "selectedCharacter")
        }
        if let selectedCharacterName = UserDefaults.standard.string(forKey: "selectedCharacter") {
            createPlayer(characterName: selectedCharacterName)
        }
        
        createButtons()
        
        infoButton()
        coinNo = UserDefaults.standard.integer(forKey: "coinNo")
        coins()
        logoHome()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            
            if touchedNode.name == "Play" {
                loadGameScene()
                
            } else if touchedNode.name == "Settings" {
                loadSettingsScene()
                
            } else if touchedNode.name == "Score" {
                ScoreScene()
                
            } else if touchedNode.name == "Characters" {
                
                loadCharactersScene()
            }
            else if touchedNode.name == "about" {
                if modalBackground == nil {
                    showInstructions()
                } else {
                    hideInstructions()
                }
            } else if touchedNode.name == "closeButton" {
                hideInstructions()
            }
            else if touchedNode.name == "noAds" {
                //                show premium
            }
            else if touchedNode.name == "getMoreCoins" {
                showRewardedAd()
                
            }
            
            
            
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            if touchedNode.name == "infoButton" {
                // Reset scale and show instructions
                touchedNode.run(SKAction.scale(to: 1.0, duration: 0.1)) {
                    self.showInstructions()
                }
            } else if (touchedNode.name == "closeButton" || touchedNode.name == "skyNode") {
                hideInstructions()
            }
            
        }
        
    }
    
    func createPlayer(characterName: String) {
        let playerTexture = SKTexture(imageNamed: characterName)
        player = SKSpriteNode(texture: playerTexture)
        player.zPosition = 10
        player.position = CGPoint(x: frame.width / 6, y: frame.height * 0.75)
        player.physicsBody = SKPhysicsBody(texture: playerTexture, size: playerTexture.size())
        player.physicsBody!.contactTestBitMask = player.physicsBody!.collisionBitMask
        player.physicsBody?.isDynamic = false
        player.size = CGSize(width: 90 , height:90)
        player.physicsBody?.collisionBitMask = 0
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
            sky.name = "skyNode"
            sky.run(moveForever)
            addChild(sky)
        }
    }
    
    
    func menu(category: String, imageName: String, position: CGPoint) -> SKSpriteNode {
        let menuTexture = SKTexture(imageNamed: imageName)
        let menu = SKSpriteNode(texture: menuTexture)
        menu.zPosition = 30
        menu.position = position
        menu.name = category // Assign the category as the name for identification
        addChild(menu)
        
        let buttonLabel = SKLabelNode(fontNamed: "Arial")
        buttonLabel.text = category
        buttonLabel.fontSize = 24
        buttonLabel.fontColor = SKColor.white
        buttonLabel.zPosition = 31
        buttonLabel.position = CGPoint(x: 0, y: -menuTexture.size().height / 8)
        
        menu.addChild(buttonLabel)
        return menu
    }
    
    func createButtons() {
        playButton = menu(category: "Play", imageName: "blue_button04 1", position: CGPoint(x: self.frame.midX, y: self.frame.midY + 100))
        settingsButton = menu(category: "Settings", imageName: "green_button04", position: CGPoint(x: self.frame.midX, y: self.frame.midY))
        scoresButton = menu(category: "Score", imageName: "red_button11", position: CGPoint(x: self.frame.midX, y: self.frame.midY - 100))
        charactersButton = menu(category: "Characters", imageName: "yellow_button04", position: CGPoint(x: self.frame.midX, y: self.frame.midY - 200))
    }
    
    func logoHome() {
        logo = SKSpriteNode(imageNamed: "cranky")
        logo.position = CGPoint(x: frame.midX, y: frame.midY + 275)
        addChild(logo)
    }
    
    func loadGameScene() {
        
        if let scene = GameScene(fileNamed: "GameScene") {
            scene.scaleMode = .resizeFill
            let transition = SKTransition.fade(withDuration: 1.0)
            self.view?.presentScene(scene, transition: transition)
        }
    }
    func loadSettingsScene() {
        
        if let scene = SettingsScene(fileNamed: "SettingsScene") {
            scene.scaleMode = .resizeFill
            let transition = SKTransition.fade(withDuration: 1.0)
            self.view?.presentScene(scene, transition: transition)
        }
    }
    func loadCharactersScene() {
        
        if let scene = CharactersScene(fileNamed: "CharactersScene") {
            scene.scaleMode = .resizeFill
            let transition = SKTransition.fade(withDuration: 1.0)
            self.view?.presentScene(scene, transition: transition)
        }
    }
    func ScoreScene() {
        
        if let scene = ScoresScene(fileNamed: "ScoresScene") {
            scene.scaleMode = .resizeFill
            let transition = SKTransition.fade(withDuration: 1.0)
            self.view?.presentScene(scene, transition: transition)
        }
    }
    func infoButton(){
        info = SKSpriteNode(imageNamed: "info")
        info.size = CGSize(width: 70, height: 70)
        info.position = CGPoint(x: frame.midX - 50, y: frame.midY - 300)
        info.zPosition = 34
        info.name = "about"
        addChild(info)
        ad = SKSpriteNode(imageNamed: "NoAds")
        ad.size = CGSize(width: 65, height: 65)
        ad.position = CGPoint(x: frame.midX + 50, y: frame.midY - 300)
        ad.zPosition = 34
        ad.name = "noAds"
        addChild(ad)
    }
    func showInstructions() {
        // Create the modal background
        modalBackground = SKShapeNode(rectOf: CGSize(width: 360, height: 360), cornerRadius: 20)
        modalBackground.fillColor = SKColor.black.withAlphaComponent(0.8)
        modalBackground.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 50)
        modalBackground.zPosition = 100
        modalBackground.name = "modalBackground"
        
       let texture = SKTexture(imageNamed: "instructions")
        instructions = SKSpriteNode(texture: texture )
        instructions.zPosition = 101
        instructions.size = CGSize(width: 360, height: 360)
        instructions.position = CGPoint(x: 0, y: 0)
        
        
        
        
        
        
        
        let closeButton = SKSpriteNode(imageNamed: "close")
        closeButton.size = CGSize(width: 50, height: 50)
        closeButton.position = CGPoint(x: 175, y: 180)
        closeButton.zPosition = 102
        
        closeButton.name = "closeButton"
        
        
        
        
        modalBackground.addChild(closeButton)
        modalBackground.addChild(instructions)
        
        if let modalBackground = modalBackground {
            self.addChild(modalBackground)
        }
    }
    func hideInstructions() {
        // Remove the modal background and its children
        modalBackground?.removeFromParent()
        modalBackground = nil
    }
    func coins(){
        coin = SKSpriteNode(imageNamed:  "coin")
        coin.zPosition = 101
        coin.size = CGSize(width: 60, height: 60)
        coin.position = CGPoint(x: frame.midX - 140, y: frame.midY + 390)
        addChild(coin)
        buttonLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        
        buttonLabel.text = "\(coinNo)"
        buttonLabel.fontSize = 30
        buttonLabel.fontColor = SKColor.white
        
        buttonLabel.zPosition = 101
        let labelOffset: CGFloat = 4 // Adjust this offset as needed
        
        // Adjust the position to be just to the right of the coin sprite
        let labelXPosition = coin.position.x + coin.size.width / 3 + labelOffset
        let labelYPosition = coin.position.y - 10
        let labelAPosition = coin.position.x - coin.size.width / 3 - labelOffset
        
        
        buttonLabel.position = CGPoint(x: labelXPosition, y: labelYPosition)
        buttonLabel.horizontalAlignmentMode = .left
        addChild(buttonLabel)
        let texture = SKTexture(imageNamed: "plus")
        getMore = SKSpriteNode(texture: texture)
        getMore.zPosition = 101
        getMore.position = CGPoint(x: labelAPosition - 8, y: labelYPosition + 10)
        getMore.size = CGSize(width: 30, height: 30)
        getMore.alpha = 0.5
        getMore.name = "getMoreCoins"
        addChild(getMore)
        
    }
    
    
    
    
    func showRewardedAd() {
        if let rewardedAd = GameManager.shared.rewardedAd {
            BackgroundMusic.shared.stop()
            rewardedAd.present(fromRootViewController: self.view?.window?.rootViewController) {
                BackgroundMusic.shared.play()
                self.coinNo += 1
                self.buttonLabel.text = "\(self.coinNo)"
                // Optionally, you can reload the rewarded ad here
                UserDefaults.standard.set(self.coinNo, forKey: "coinNo")
                GameManager.shared.loadRewardedAd()
                
            }
        } else {
            print("Rewarded ad is not ready")
            GameManager.shared.loadRewardedAd()  // Reload the ad if it's not ready
        }
    }
}


