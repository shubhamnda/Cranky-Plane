//
//  GameScene.swift
//  nnnf
//
//  Created by Shubham Nanda on 19/06/24.
//

import SpriteKit
import GameplayKit

class ScoresScene: SKScene {
    var score: SKSpriteNode!
    var returnButton: SKSpriteNode!
    let YourScore = UserDefaults.standard.integer(forKey: "lastScore")
    
    let highScore = UserDefaults.standard.integer(forKey: "highScore")
    override func didMove(to view: SKView) {
        if UserDefaults.standard.bool(forKey: "isSoundOn") {
            BackgroundMusic.shared.play()
        }
        if let imageName = UserDefaults.standard.string(forKey: "selectedBackground") {
            let texture = SKTexture(imageNamed: imageName)
            createSky(skyTexture: texture)
        }
        
        let buttonLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        buttonLabel.text = "Score"
        buttonLabel.fontSize = 40
        buttonLabel.fontColor = SKColor.white
        
        buttonLabel.zPosition = 31
        buttonLabel.position = CGPoint(x: frame.midX, y:frame.midY + 300 )
        addChild(buttonLabel)
        
        
        createReturnButton()
        logo()
    }
    
    
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if returnButton.contains(location){
                returnToTitleScene()
            }        }
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
    func logo(){
        score = SKSpriteNode(imageNamed: "score")
        score.position = CGPoint(x: frame.midX, y: frame.midY - 20)
        score.zPosition = 51
        score.size = CGSize(width: 360, height: 600)
        addChild(score)
        
        let buttonLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        buttonLabel.text = "Last Score:   \(YourScore)"
        buttonLabel.fontSize = 40
        buttonLabel.fontColor = SKColor.black
        
        buttonLabel.zPosition = 53
        buttonLabel.position = CGPoint(x: frame.midX , y:frame.midY + 40 )
        addChild(buttonLabel)
        let HighLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        HighLabel.text = "High Score:   \(highScore)"
        HighLabel.fontSize = 40
        HighLabel.fontColor = SKColor.black
        
        HighLabel.zPosition = 53
        HighLabel.position = CGPoint(x: buttonLabel.position.x , y:buttonLabel.position.y - 100)
        addChild(HighLabel)
    }
    
    func createReturnButton() {
        returnButton = SKSpriteNode(imageNamed: "back3")
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
}
