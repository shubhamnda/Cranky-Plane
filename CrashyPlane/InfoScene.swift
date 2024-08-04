import SpriteKit
import GameplayKit

class InfoScene: SKScene {
    let imageView = SKSpriteNode()
    let rightButton = SKLabelNode(fontNamed: "Arial-BoldMT")
    let leftButton = SKLabelNode(fontNamed: "Arial-BoldMT")
    let imageNumberLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
    var score: SKSpriteNode!
    
    var images = ["instructions", "Instructions2","Instructions3"]
    var currentImageIndex = 0
    
    var returnButton: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        setupUI()
        logo()
        updateImage()
        createReturnButton()
        
        BackgroundMusic.shared.play()
        
        if let imageName = UserDefaults.standard.string(forKey: "selectedBackground") {
            let texture = SKTexture(imageNamed: imageName)
            createSky(skyTexture: texture)
        }
        
        let buttonLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        buttonLabel.text = "Instructions"
        buttonLabel.fontSize = 40
        buttonLabel.fontColor = SKColor.black
        buttonLabel.zPosition = 31
        buttonLabel.position = CGPoint(x: frame.midX, y: frame.midY + 300)
        addChild(buttonLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if returnButton.contains(location) {
                returnToTitleScene()
            } else if rightButton.contains(location) {
                currentImageIndex = (currentImageIndex + 1) % images.count
                updateImage()
            } else if leftButton.contains(location) {
                currentImageIndex = (currentImageIndex - 1 + images.count) % images.count
                updateImage()
            }
        }
    }
    
    func createSky(skyTexture: SKTexture) {
        skyTexture.filteringMode = .linear
        for i in 0...1 {
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
        returnButton.position = CGPoint(x: frame.midX, y: frame.midY - 260)
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
    
    func setupUI() {
        // Setup imageView
        let rectWidth: CGFloat = 230
        let rectHeight: CGFloat = 440
        
        imageView.size = CGSize(width: rectWidth, height: rectHeight)
        imageView.position = CGPoint(x: frame.midX, y: frame.midY + 20  )
        imageView.zPosition = 30
        imageView.color = .red
        addChild(imageView)
        
        // Setup rightButton
        rightButton.text = ">"
        rightButton.fontSize = 60
        rightButton.fontColor = SKColor.white
        rightButton.position = CGPoint(x: frame.midX + 150, y: frame.midY)
        rightButton.zPosition = 31
        addChild(rightButton)
        
        // Setup leftButton
        leftButton.text = "<"
        leftButton.fontSize = 60
        leftButton.fontColor = SKColor.white
        leftButton.position = CGPoint(x: frame.midX - 150, y: frame.midY)
        leftButton.zPosition = 31
        addChild(leftButton)
        
     
    }
    
    func updateImage() {
        let imageName = images[currentImageIndex]
        let texture = SKTexture(imageNamed: imageName)
        imageView.texture = texture
        
        let maxWidth: CGFloat = 230
        let maxHeight: CGFloat = 440
        
        // Get the original size of the texture
        let textureSize = texture.size()
        
        // Calculate the aspect ratio
        let aspectRatio = textureSize.width / textureSize.height
        
        // Determine the new size that fits within the defined rectangle while maintaining the aspect ratio
        var newWidth = maxWidth
        var newHeight = maxHeight
        
        if aspectRatio > 1 {
            // Landscape image
            newWidth = maxWidth
            newHeight = maxWidth / aspectRatio
        } else {
            // Portrait image
            newHeight = maxHeight
            newWidth = maxHeight * aspectRatio
        }
        
        // Ensure the image fits within the defined rectangle
        imageView.size = CGSize(width: newWidth, height: newHeight)
       
    }
    
    func logo() {
        score = SKSpriteNode(imageNamed: "score")
        score.position = CGPoint(x: frame.midX, y: frame.midY - 20)
        score.zPosition = 12
        score.name = "bg"
        score.size = CGSize(width: 360, height: 600)
        addChild(score)
    }
}
