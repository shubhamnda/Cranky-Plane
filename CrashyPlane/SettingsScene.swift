//
//  SettingsScene.swift
//  CrashyPlane
//
//  Created by Shubham Nanda on 19/06/24.
//


import SpriteKit
import GameplayKit

class SettingsScene: SKScene {
    var skyChangeButton: SKSpriteNode!
    let imageView = SKSpriteNode()
    let rightButton = SKLabelNode(fontNamed: "Arial-BoldMT")
    let leftButton = SKLabelNode(fontNamed: "Arial-BoldMT")
    let imageNumberLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
    var isPremiumUser: Bool = UserDefaults.standard.bool(forKey: "isPremiumUser")
    
   var images = ["airadventurelevel1", "airadventurelevel2", "airadventurelevel3", "airadventurelevel4","BG" ,"airadventurelevel6", "airadventurelevel7" ]
    var currentImageIndex = 0
    var score : SKSpriteNode!
    var returnButton: SKSpriteNode!
    var player: SKSpriteNode!
    var soundToggleButton: SKSpriteNode!
    var soundToggleLabel: SKLabelNode!
   
    var isSoundOn: Bool = UserDefaults.standard.bool(forKey: "isSoundOn")
    
    override func didMove(to view: SKView) {
//        if isPremiumUser {
//            images = ["airadventurelevel1", "airadventurelevel2", "airadventurelevel3", "airadventurelevel4","BG" ,"airadventurelevel6", "airadventurelevel7" ]
//        } else{
//          images =   ["airadventurelevel1", "airadventurelevel2" ]
//        }
        
        setupUI()
        logo()
        loadSelectedSkyTexture()
        updateImage()
        createReturnButton()
        if UserDefaults.standard.object(forKey: "isSoundOn") == nil {
            isSoundOn = true
            UserDefaults.standard.set(isSoundOn, forKey: "isSoundOn")
        } else {
            isSoundOn = UserDefaults.standard.bool(forKey: "isSoundOn")
        }
        if isSoundOn {
            BackgroundMusic.shared.play()
        }
        createSoundToggleButton()
        
        
        
        let buttonLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        buttonLabel.text = "Settings"
        buttonLabel.fontSize = 40
        buttonLabel.fontColor = SKColor.white
        
        buttonLabel.zPosition = 31
        buttonLabel.position = CGPoint(x: frame.midX, y:frame.midY + 300 )
        addChild(buttonLabel)
        
        let SoundLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        SoundLabel.text = "BG Music"
        SoundLabel.fontSize = 38
        SoundLabel.fontColor = SKColor.black
        SoundLabel.alpha = 0.7
        SoundLabel.zPosition = 31
        SoundLabel.position = CGPoint(x: frame.midX - 20, y: frame.midY + 210)
        addChild(SoundLabel)
        
        let imageLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        imageLabel.text = "Background"
        imageLabel.alpha = 0.7
        imageLabel.fontSize = 38
        imageLabel.fontColor = SKColor.black
        
        imageLabel.zPosition = 31
        imageLabel.position = CGPoint(x: frame.midX, y:SoundLabel.frame.midY - 100 )
        addChild(imageLabel)
        
    }
    
    
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            if returnButton.contains(location) {
                returnToTitleScene()
            }
            else if touchedNode.name == "skyChangeButton" {
                
                
                updateSky()
            }
            else if rightButton.contains(location) {
                currentImageIndex = (currentImageIndex + 1) % images.count
                updateImage()
            } else if leftButton.contains(location) {
                currentImageIndex = (currentImageIndex - 1 + images.count) % images.count
                updateImage()
            }
            else if touchedNode.name == "soundToggleButton" {
                toggleSound()
            }
           
            
        }
    }
    
    
    func toggleSound() {
        isSoundOn.toggle() // Toggle the sound state
        UserDefaults.standard.set(isSoundOn, forKey: "isSoundOn")
        if isSoundOn {
            BackgroundMusic.shared.play()
            
            soundToggleButton.texture = SKTexture(imageNamed: "sound_on")
        } else {
            BackgroundMusic.shared.stop()
            
            soundToggleButton.texture = SKTexture(imageNamed: "sound_off")
        }
    }
    
    func createSky(skyTexture: SKTexture){
        let skyTexture = SKTexture(imageNamed: images[currentImageIndex])
        
        skyTexture.filteringMode = .linear
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
    func createReturnButton() {
        returnButton = SKSpriteNode(imageNamed: "back")
        returnButton.position = CGPoint(x: frame.midX , y: frame.midY - 260)
        returnButton.zPosition = 100
        returnButton.size = CGSize(width: 80, height: 80)
        addChild(returnButton)
    }
    func returnToTitleScene() {
        if let titleScene = TitleScene(fileNamed: "TitleScene") {
            titleScene.scaleMode = .resizeFill
            let transition = SKTransition.fade(withDuration: 1.0)
            self.view?.presentScene(titleScene, transition: transition)
        }
    }
    
    
    func createSoundToggleButton() {
        let textureName = isSoundOn ? "sound_on" : "sound_off"
        soundToggleButton = SKSpriteNode(imageNamed: textureName)
        soundToggleButton.position = CGPoint(x: frame.midX + 120, y: frame.midY + 225)
        soundToggleButton.size = CGSize(width: 50, height: 50)
        soundToggleButton.zPosition = 31
        soundToggleButton.name = "soundToggleButton"
        addChild(soundToggleButton)
        
        
        
    }
    func setupUI() {
        // Setup imageView
        let rectWidth: CGFloat = 240
        let rectHeight: CGFloat = 240
        
        imageView.size = CGSize(width: rectWidth, height: rectHeight)
        imageView.position = CGPoint(x: frame.midX, y: frame.midY - 40 )
        imageView.zPosition = 30
        addChild(imageView)
        
        // Create the sky change button
        let skyChangeTexture = SKTexture(imageNamed: "green_button04")
        skyChangeButton = SKSpriteNode(texture: skyChangeTexture)
        skyChangeButton.position = CGPoint(x: frame.midX, y: frame.midY - 160) // Adjust position as needed
        skyChangeButton.size = CGSize(width: 180, height: 50)
        skyChangeButton.name = "skyChangeButton"
        skyChangeButton.zPosition = 32
        
        addChild(skyChangeButton)
        
        let buttonLabel = SKLabelNode(fontNamed: "Arial")
        buttonLabel.text = "Apply"
        buttonLabel.fontSize = 24
        buttonLabel.fontColor = SKColor.white
        buttonLabel.zPosition = 31
        buttonLabel.position = CGPoint(x: 0, y: -skyChangeTexture.size().height / 8)
        
        skyChangeButton.addChild(buttonLabel)
        
        // Setup rightButton
        rightButton.text = ">"
        rightButton.fontSize = 60
        rightButton.fontColor = SKColor.white
        rightButton.position = CGPoint(x: frame.midX + 150, y: frame.midY - 55)
        rightButton.zPosition = 31
        addChild(rightButton)
        
        // Setup leftButton
        leftButton.text = "<"
        leftButton.fontSize = 60
        leftButton.fontColor = SKColor.white
        leftButton.position = CGPoint(x: frame.midX - 150, y: frame.midY - 55)
        leftButton.zPosition = 31
        addChild(leftButton)
        //         image Label
        imageNumberLabel.fontSize = 38
        imageNumberLabel.alpha = 0.7
        imageNumberLabel.fontColor = SKColor.black
        imageNumberLabel.position = CGPoint(x: frame.midX, y: frame.midY + 50)
        imageNumberLabel.zPosition = 31
        addChild(imageNumberLabel)
        
    }
    func loadSelectedSkyTexture() {
        if let imageName = UserDefaults.standard.string(forKey: "selectedBackground") {
            let texture = SKTexture(imageNamed: imageName)
            createSky(skyTexture: texture)
        }
    }
    func updateImage() {
        let imageName = images[currentImageIndex]
        let texture = SKTexture(imageNamed: imageName)
        
        imageView.texture = texture
        
        
        
        
        let maxWidth: CGFloat = 240
        let maxHeight: CGFloat = 240
        
        // Get the original size of the texture
        let textureSize = texture.size()
        
        // Calculate the aspect ratio
        let aspectRatio = textureSize.width / textureSize.height
        
        // Determine the new size that fits within the defined rectangle while maintaining the aspect ratio
        var newWidth = maxWidth
        var newHeight = maxHeight
        
        if aspectRatio > 1 {
            // Landscape image
            newHeight = newWidth / aspectRatio
        } else {
            // Portrait image
            newWidth = newHeight * aspectRatio
        }
      
        // Ensure the image fits within the defined rectangle
        imageView.size = CGSize(width: newWidth, height: newHeight)
        imageNumberLabel.text = "\(currentImageIndex + 1) / \(images.count)"
       
        if currentImageIndex >= 2 && !isPremiumUser {
            imageView.enumerateChildNodes(withName: "lockedImage") { node, _ in
                       node.removeFromParent()
                   }
                // Create a locked image overlay or indicator
                let lockedImage = SKSpriteNode(imageNamed: "locked_image")
                lockedImage.position = CGPoint(x: 0, y: 0)
                lockedImage.zPosition = imageView.zPosition + 1
            lockedImage.name = "lockedImage"
          lockedImage.size = CGSize(width: 60, height: 60)
                imageView.addChild(lockedImage)
           
            skyChangeButton.isUserInteractionEnabled = true
                    skyChangeButton.alpha = 0.5
            UserDefaults.standard.removeObject(forKey: "selectedBackground")
          
            }
        else {
                // Remove the locked image if the image is unlocked or user is premium
                imageView.enumerateChildNodes(withName: "lockedImage") { node, _ in
                    node.removeFromParent()
                    
                }
            skyChangeButton.isUserInteractionEnabled = false
            skyChangeButton.alpha = 1
            UserDefaults.standard.set(imageName, forKey: "selectedBackground")
            }
       
    }
    
    
    func updateSky() {
        
        
        enumerateChildNodes(withName: "skyNode") { node, _ in
            node.removeFromParent()}
        if currentImageIndex < 2 || isPremiumUser{
        let nSkyTexture = SKTexture(imageNamed: images[currentImageIndex])
        nSkyTexture.filteringMode = .linear
            for i in 0 ... 1 {
                let sky = SKSpriteNode(texture: nSkyTexture)
                sky.zPosition = -35
                sky.anchorPoint = CGPoint.zero
                sky.size.height = frame.height
                sky.position = CGPoint(x: CGFloat(i) * nSkyTexture.size().width, y: 0)
                let moveLeft = SKAction.moveBy(x: -nSkyTexture.size().width, y: 0, duration: 20)
                let moveReset = SKAction.moveBy(x: nSkyTexture.size().width, y: 0, duration: 0)
                let moveLoop = SKAction.sequence([moveLeft, moveReset])
                let moveForever = SKAction.repeatForever(moveLoop)
                sky.name = "skyNode"
                sky.run(moveForever)
                
                addChild(sky)}
        }
        
    }
    func logo(){
        score = SKSpriteNode(imageNamed: "score")
        score.position = CGPoint(x: frame.midX, y: frame.midY - 20)
        score.zPosition = 12
        score.name = "bg"
        score.size = CGSize(width: 360, height: 600)
        addChild(score)}
}

