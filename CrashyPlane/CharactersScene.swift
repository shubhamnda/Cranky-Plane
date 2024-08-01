//
//  CharactersScene.swift
//  CrashyPlane

//  Created by Shubham Nanda on 23/06/24.
//

import SpriteKit
import GameplayKit

class CharactersScene: SKScene {
    var imageView : SKSpriteNode!
    var returnButton: SKSpriteNode!
    var highlightNode: SKShapeNode!
    var score: SKSpriteNode!
    override func didMove(to view: SKView) {
        
        if UserDefaults.standard.bool(forKey: "isSoundOn") {
            BackgroundMusic.shared.play()
        }
        if let imageName = UserDefaults.standard.string(forKey: "selectedBackground") {
            let texture = SKTexture(imageNamed: imageName)
            createSky(skyTexture: texture)
        }
        logo()
        createReturnButton()
        characterView(characterName: "planeRed", position: CGPoint(x: frame.midX - 80, y: frame.midY + 190), nodeName: "planeRed")
        characterView(characterName: "planeGreen", position: CGPoint(x: frame.midX + 80, y: frame.midY + 190), nodeName: "planeGreen")
        characterView(characterName: "bat", position: CGPoint(x: frame.midX - 80, y: frame.midY + 20), nodeName: "bat",isLocked: true)
        characterView(characterName: "bird", position: CGPoint(x: frame.midX + 80, y: frame.midY + 20), nodeName: "bird",isLocked: true)
        characterView(characterName: "dragon", position: CGPoint(x: frame.midX - 80, y: frame.midY - 140), nodeName: "dragon",isLocked: true)
        characterView(characterName: "skeleton", position: CGPoint(x: frame.midX + 80, y: frame.midY - 140), nodeName: "skeleton",isLocked: true)
        
        
        let buttonLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        buttonLabel.text = "Characters"
        buttonLabel.fontSize = 40
        buttonLabel.fontColor = SKColor.white
        
        buttonLabel.zPosition = 31
        buttonLabel.position = CGPoint(x: frame.midX, y:frame.midY + 300 )
        addChild(buttonLabel)
        
        highlightNode = SKShapeNode(rectOf: CGSize(width: 110, height: 110))
        highlightNode.strokeColor = .white
        highlightNode.lineWidth = 5
        highlightNode.zPosition = 40
        highlightNode.isHidden = true // Initially hidden
        addChild(highlightNode)
        
        if let selectedCharacter = UserDefaults.standard.string(forKey: "selectedCharacter") {
            if let selectedNode = childNode(withName: selectedCharacter) {
                showHighlight(at: selectedNode.position)
            }
        }
        if UserDefaults.standard.string(forKey: "selectedCharacter") == nil || !isPremiumUser() {
            UserDefaults.standard.set("planeRed", forKey: "selectedCharacter")
        }
    }
    
    
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            if let nodeName = touchedNode.name {
                if nodeName == "skyNode" {
                    UserDefaults.standard.set("planeRed", forKey: "selectedCharacter")
                    if let redPlaneNode = childNode(withName: "planeRed") {
                        showHighlight(at: redPlaneNode.position)
                    }
                } else {
                    if isCharacterLocked(nodeName) && !isPremiumUser() {
                                          
                                           print("Character \(nodeName) is locked. Please purchase premium to unlock.")
                                       } else {
                                           showHighlight(at: touchedNode.position)
                                           UserDefaults.standard.set(nodeName, forKey: "selectedCharacter")
                                       }
                }
            }
            if returnButton.contains(location) {
                returnToTitleScene()
                
            }
        }
    }
    
    
    func createSky(skyTexture: SKTexture){
        
        
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
        returnButton = SKSpriteNode(imageNamed: "back4")
        returnButton.position = CGPoint(x: frame.midX , y: frame.midY - 260)
        returnButton.zPosition = 100
        returnButton.size = CGSize(width: 80, height: 80)
        addChild(returnButton)
    }
    
    func returnToTitleScene() {
        if let titleScene = TitleScene(fileNamed: "TitleScene") {
            titleScene.scaleMode = .resizeFill
            let transition = SKTransition.fade(withDuration: 1)
            
            self.view?.presentScene(titleScene, transition: transition)
        }
    }
    func characterView(characterName: String, position: CGPoint, nodeName: String, isLocked:Bool = false){
        let rectWidth: CGFloat = 100
        let rectHeight: CGFloat = 100
        let characterTexture = SKTexture(imageNamed: characterName)
        
        imageView = SKSpriteNode(texture: characterTexture)
        
        imageView.size = CGSize(width: rectWidth, height: rectHeight)
        imageView.position = position
        imageView.name = nodeName
        imageView.zPosition = 30
        let frame2 = SKTexture(imageNamed: "\(characterName)2")
        let frame3 = SKTexture(imageNamed: "\(characterName)3")
        let animation = SKAction.animate(with: [characterTexture, frame2, frame3, frame2], timePerFrame: 0.1)
        let runForever = SKAction.repeatForever(animation)
        
        imageView.run(runForever)
        if isLocked && !isPremiumUser() {
                    let lockOverlay = SKSpriteNode(imageNamed: "locked_image")
                    lockOverlay.size = CGSize(width: rectWidth, height: rectHeight)
                    lockOverlay.position = CGPoint(x: 0, y: 0)
                    lockOverlay.zPosition = 40
           
            lockOverlay.size = CGSize(width: 60, height: 60)
                    imageView.addChild(lockOverlay)
                }
        addChild(imageView)
    }
    
    func showHighlight(at position: CGPoint) {
        highlightNode.position = position
        highlightNode.isHidden = false
    }
    func logo(){
        score = SKSpriteNode(imageNamed: "score")
        score.position = CGPoint(x: frame.midX, y: frame.midY - 20)
        score.zPosition = 11
        score.size = CGSize(width: 360, height: 600)
        addChild(score)}
    func isPremiumUser() -> Bool {
            return UserDefaults.standard.bool(forKey: "isPremiumUser")
        }
        
        func isCharacterLocked(_ characterName: String) -> Bool {
            let lockedCharacters = ["bat", "bird", "dragon", "skeleton"]
            return lockedCharacters.contains(characterName)
        }
    
}
