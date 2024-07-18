

import SpriteKit
import GameplayKit

class GameOverScene: SKScene {
    var gameOver: SKSpriteNode!
    var score: SKSpriteNode!
    var playAgainButton: SKSpriteNode!
    var medal : SKSpriteNode!
    let YourScore = UserDefaults.standard.integer(forKey: "lastScore")
    
    let highScore = UserDefaults.standard.integer(forKey: "highScore")
    override func didMove(to view: SKView) {
        if let imageName = UserDefaults.standard.string(forKey: "selectedBackground") {
            let texture = SKTexture(imageNamed: imageName)
            createSky(skyTexture: texture)
        }
        PlayAgainButton()
        logo()
        showMedal()
        
    }
    
    
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
            
            if playAgainButton.contains(location) {
                returnToTitleScene()
            }}
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
        }}
    
    func logo(){
        score = SKSpriteNode(imageNamed: "score")
        score.position = CGPoint(x: frame.midX, y: frame.midY)
        score.zPosition = 51
        score.size = CGSize(width: 350, height: 350)
        addChild(score)
        
        gameOver = SKSpriteNode(imageNamed: "go")
        
        
        gameOver.zPosition = 52
        gameOver.position = CGPoint(x: score.position.x, y: score.position.y + 190 )
        addChild(gameOver)
        let buttonLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        buttonLabel.text = "Your Score:   \(YourScore)"
        buttonLabel.fontSize = 30
        buttonLabel.fontColor = SKColor.black
        
        buttonLabel.zPosition = 53
        buttonLabel.position = CGPoint(x: gameOver.position.x , y:gameOver.position.y - 100)
        addChild(buttonLabel)
        let HighLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        HighLabel.text = "High Score:   \(highScore)"
        HighLabel.fontSize = 30
        HighLabel.fontColor = SKColor.black
        
        HighLabel.zPosition = 53
        HighLabel.position = CGPoint(x: buttonLabel.position.x , y:buttonLabel.position.y - 80)
        addChild(HighLabel)
    }
    func PlayAgainButton() {
        let texture = SKTexture(imageNamed: "playAgain")
        playAgainButton = SKSpriteNode(texture: texture)
        playAgainButton.position = CGPoint(x: frame.midX , y: frame.midY - 240)
        playAgainButton.zPosition = 100
        playAgainButton.size = CGSize(width: 200, height: 70)
        addChild(playAgainButton)
        let buttonLabel = SKLabelNode(fontNamed: "Arial")
        buttonLabel.text = "Play Again"
        buttonLabel.fontSize = 30
        buttonLabel.fontColor = SKColor.white
        buttonLabel.zPosition = 101
        buttonLabel.position = CGPoint(x: 0, y: -texture.size().height / 10)
        playAgainButton.addChild(buttonLabel)
        
    }
    
    func returnToTitleScene() {
        if let titleScene = GameScene(fileNamed: "GameScene") {
            titleScene.scaleMode = .resizeFill
            let transition = SKTransition.fade(withDuration: 1)
            
            self.view?.presentScene(titleScene, transition: transition)
        }
    }
    func showMedal(){
        if YourScore > 400  {
            medal(name: "medalGold")
        }
        else if YourScore > 200 && YourScore <= 400 {
            medal(name: "medalSilver")
        }
        else {
            medal(name: "medalBronze")
        }
    }
    func medal(name: String){
        let texture = SKTexture(imageNamed: name)
        medal = SKSpriteNode(texture: texture)
        medal.zPosition = 56
        medal.position = CGPoint(x: frame.midX, y: frame.midY - 90)
        
        addChild(medal)
    }
}




