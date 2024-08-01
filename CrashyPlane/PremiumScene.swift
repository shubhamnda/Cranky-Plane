import SpriteKit

class PremiumScene: SKScene {
    private var buyButton: SKShapeNode!
    private var coinButton: SKShapeNode!
    private var titleLabel: SKLabelNode!
    private var descriptionLabel: SKLabelNode!
    private var benefitsNode: SKNode!
    private var backgroundNode: SKSpriteNode!
    private var coin: SKSpriteNode!
    private var premiumLogo: SKSpriteNode!
    private var closeLogo: SKSpriteNode!
  private let premium = PaymentManager()
    private var coinNo = UserDefaults.standard.integer(forKey: "coinNo")

    override func sceneDidLoad() {
        super.sceneDidLoad()
        setupBackground()
        setupTitleLabel()
        setupDescriptionLabel()
        setupBenefits()
        setupBuyButton()
        setUpCoinButton()
        NotificationCenter.default.addObserver(self, selector: #selector(handlePremiumPurchase), name: NSNotification.Name("PremiumPurchased"), object: nil)
    }
    @objc func handlePremiumPurchase() {
        let isPremiumUser = UserDefaults.standard.bool(forKey: "isPremiumUser")
        if  (isPremiumUser == true ){
            self.returnToTitleScene()
        }
    }

    func setupBackground() {
     
            let skyBlueColor = UIColor(red: 135/255, green: 222/255, blue: 241/255, alpha: 1.0)
        backgroundNode = SKSpriteNode(color: skyBlueColor, size: self.size)
        backgroundNode.position = CGPoint(x: frame.midX, y: frame.midY)
        backgroundNode.zPosition = -1
        
        premiumLogo = SKSpriteNode(imageNamed: "premium")
        premiumLogo.size = CGSize(width: frame.size.width * 0.11, height: frame.size.width * 0.11)
        premiumLogo.position = CGPoint(x: frame.midX - 180, y: frame.midY + 70)
        
        closeLogo = SKSpriteNode(imageNamed: "close")
//       closeLogo.position = CGPoint(x: frame.midX - 20 , y: frame.midY + 140)

        closeLogo.position = CGPoint(x: frame.midX - 0.05 * frame.size.width, y: frame.midY + 0.08 * frame.size.height)
        closeLogo.size =  CGSize(width: frame.size.width * 0.08, height: frame.size.width * 0.08)
  
        
        closeLogo.name = "close"
        addChild(closeLogo)
        addChild(premiumLogo)
        addChild(backgroundNode)

       
    }

    func setupTitleLabel() {
        titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "Go Premium!"
        titleLabel.fontSize = 52
        titleLabel.fontColor = .yellow
        titleLabel.position = CGPoint(x: frame.midX - 180, y: frame.midY)
        titleLabel.verticalAlignmentMode = .center
        addChild(titleLabel)
    }

    func setupDescriptionLabel() {
        descriptionLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        descriptionLabel.text = "Unlock exclusive features!"
        descriptionLabel.fontSize = 30
        descriptionLabel.fontColor = .white
        descriptionLabel.position = CGPoint(x: frame.midX - 180, y: frame.midY - 80)
        descriptionLabel.verticalAlignmentMode = .center
        addChild(descriptionLabel)
    }

    func setupBenefits() {
        benefitsNode = SKNode()
        let benefits = ["✓ Ad-free experience", "✓ Exclusive skins", "✓ More Backgrounds", "✓ Priority support"]
        
        for (index, benefit) in benefits.enumerated() {
            let benefitLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
            benefitLabel.text = benefit
            benefitLabel.fontSize = 25
            benefitLabel.fontColor = .white
            benefitLabel.position = CGPoint(x: 0, y: -CGFloat(index * 40))
            benefitLabel.verticalAlignmentMode = .center
            benefitsNode.addChild(benefitLabel)
        }
        
        benefitsNode.position = CGPoint(x: frame.midX - 180, y: frame.midY - 160)
        addChild(benefitsNode)
    }

    func setupBuyButton() {
      
        let buttonWidth: CGFloat = 220
           let buttonHeight: CGFloat = 60
           let cornerRadius: CGFloat = 20
        
           let buttonPath = UIBezierPath(roundedRect: CGRect(x: -buttonWidth/2, y: -buttonHeight/2, width: buttonWidth, height: buttonHeight), cornerRadius: cornerRadius)
           
           buyButton = SKShapeNode(path: buttonPath.cgPath)
           buyButton.fillColor = .systemBlue
           buyButton.strokeColor = .clear
           buyButton.position = CGPoint(x: frame.midX - 180, y: frame.midY - 380)
           buyButton.zPosition = 2
        

        let buyLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        buyLabel.text = "Buy for $9.99"
        buyLabel.fontSize = 24
        buyLabel.fontColor = .white
        buyLabel.verticalAlignmentMode = .center
        buyLabel.position = CGPoint(x: 0, y: 0)
        buyButton.addChild(buyLabel)

        buyButton.alpha = 0.9
        addChild(buyButton)

        let glowAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 1.0, duration: 1.0),
            SKAction.fadeAlpha(to: 0.8, duration: 1.0)
        ])
        buyButton.run(SKAction.repeatForever(glowAction))
    }
   
        
       
    func  setUpCoinButton() {
      
        let buttonWidth: CGFloat = 220
           let buttonHeight: CGFloat = 60
           let cornerRadius: CGFloat = 20
        
           let buttonPath = UIBezierPath(roundedRect: CGRect(x: -buttonWidth/2, y: -buttonHeight/2, width: buttonWidth, height: buttonHeight), cornerRadius: cornerRadius)
           
           coinButton = SKShapeNode(path: buttonPath.cgPath)
        coinButton.fillColor = .systemBlue
        coinButton.strokeColor = .clear
        coinButton.position = CGPoint(x: frame.midX - 180, y: frame.midY - 500)
        coinButton.zPosition = 2
      
        coin = SKSpriteNode(imageNamed:  "coin")
        coin.zPosition = 101
        coin.size = CGSize(width: 60, height: 60)
        coin.position = CGPoint(x: 75, y: 0)
        coinButton.addChild(coin)
       
      
        let orLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        orLabel.text = "OR"
        orLabel.fontSize = 24
        orLabel.fontColor = .white
        orLabel.verticalAlignmentMode = .center
        orLabel.position = CGPoint(x: coinButton.position.x, y: coinButton.position.y + 60)
        addChild(orLabel)
        let buyLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        buyLabel.text = "\(coinNo)/ 200 "
        buyLabel.fontSize = 24
        buyLabel.fontColor = .white
        buyLabel.verticalAlignmentMode = .center
        buyLabel.position = CGPoint(x: 0, y: 0)
        coinButton.addChild(buyLabel)

        coinButton.alpha = 0.9
        addChild(coinButton)

        let glowAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 1.0, duration: 1.0),
            SKAction.fadeAlpha(to: 0.8, duration: 1.0)
        ])
        coinButton.run(SKAction.repeatForever(glowAction))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        if buyButton.contains(location) {
            buyButton.run(SKAction.sequence([
                SKAction.scale(to: 0.9, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1)
            ]))
            purchasePremium()
        }
        else if coinButton.contains(location) {
            coinButton.run(SKAction.sequence([
                SKAction.scale(to: 0.9, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1)
            ]))
            coinPremium()
        }
        else if touchedNode.name == "close" {
          returnToTitleScene()
        }
    }

    private func purchasePremium() {
        print("Buy Premium button tapped! Implement your in-app purchase logic here.")
        premium.buyPremium { success in
            if success {print("bought")
                       UserDefaults.standard.set(true, forKey: "isPremiumUser")
                
               

                   } else {
                       print("nooo!!")
                       UserDefaults.standard.set(false, forKey: "isPremiumUser")
                       

                }
           

        }
    }
    private func coinPremium() {
   print("\(coinNo)")
        if coinNo >= 200 {
               UserDefaults.standard.set(true, forKey: "isPremiumUser")
               coinNo -= 200
//               UserDefaults.standard.set(coinNo, forKey: "coinNo")
          
               NotificationCenter.default.post(name: NSNotification.Name("PremiumPurchased"), object: nil)
           
              
           } else {
               print("Need more coins")
           }
    }
  private  func returnToTitleScene() {
        if let titleScene = TitleScene(fileNamed: "TitleScene") {
            titleScene.scaleMode = .resizeFill
            let transition = SKTransition.fade(withDuration: 1.0)
            self.view?.presentScene(titleScene, transition: transition)
        }
    }


}
