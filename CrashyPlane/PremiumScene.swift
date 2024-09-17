import SpriteKit
import FirebaseDatabaseInternal
import FirebaseAuth

class PremiumScene: SKScene {
    private var buyButton: SKShapeNode!
    var coinButton: SKShapeNode!
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
        let benefits = ["✓ Ad-free experience", "✓ Exclusive skins", "✓ More Backgrounds"]
        
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
           buyButton.position = CGPoint(x: frame.midX - 180, y: frame.midY - 360)
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
   
        
       

    func setUpCoinButton() {
        let buttonWidth: CGFloat = 120
        let buttonHeight: CGFloat = 90
        let cornerRadius: CGFloat = 20
        let spacing: CGFloat = 10// spacing between buttons

        // Create button paths
        let buttonPath = UIBezierPath(roundedRect: CGRect(x: -buttonWidth/2, y: -buttonHeight/2, width: buttonWidth, height: buttonHeight), cornerRadius: cornerRadius)

        // Define coin amounts
        let coinRequirements = [200, 600, 1000]
        let orLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
                orLabel.text = "------------------Use Coins------------------"
                orLabel.fontSize = 24
                orLabel.fontColor = .white
                orLabel.verticalAlignmentMode = .center
        orLabel.position = CGPoint(x: frame.midX - 180, y: frame.midY - 420)
                addChild(orLabel)
        // Position buttons
        let totalWidth = CGFloat(coinRequirements.count) * buttonWidth + CGFloat(coinRequirements.count - 1) * spacing
        let startingX = frame.midX - 180 - totalWidth / 2 + buttonWidth / 2

        for (index, requirement) in coinRequirements.enumerated() {
             coinButton = SKShapeNode(path: buttonPath.cgPath)
            coinButton.fillColor = .systemBlue
            coinButton.strokeColor = .clear
            coinButton.position = CGPoint(x: startingX + CGFloat(index) * (buttonWidth + spacing), y: frame.midY - 500)
            coinButton.zPosition = 2

            var durationText = ""
              switch requirement {
              case 200:
                  durationText = "2 months"
              case 600:
                  durationText = "5 months"
              case 1000:
                  durationText = "1 year"
              default:
                  durationText = "N/A"
              }
            // Coin label
            let buyLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            buyLabel.text = "\(coinNo)/\(requirement)"
            buyLabel.fontSize = 20
            buyLabel.fontColor = .yellow
            buyLabel.verticalAlignmentMode = .center
            buyLabel.position = CGPoint(x: 0, y: 0)
            coinButton.addChild(buyLabel)

            coinButton.alpha = 0.9
            addChild(coinButton)
            let durationLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            durationLabel.text = durationText
            durationLabel.fontSize = 20
            durationLabel.fontColor = .white
            durationLabel.verticalAlignmentMode = .center
            durationLabel.position = CGPoint(x: 0, y: 25)
            coinButton.addChild(durationLabel)
            
            // Coin sprite
            let coin = SKSpriteNode(imageNamed: "coin")
            coin.zPosition = 101
            coin.size = CGSize(width: 40, height: 40)
            coin.position = CGPoint(x: buyLabel.position.x , y: buyLabel.position.y - 30)
            coinButton.addChild(coin)

            // Add glow effect
            let glowAction = SKAction.sequence([
                SKAction.fadeAlpha(to: 1.0, duration: 1.0),
                SKAction.fadeAlpha(to: 0.8, duration: 1.0)
            ])
            coinButton.run(SKAction.repeatForever(glowAction))

            // Tag buttons with a unique name or identifier
            coinButton.name = "coinButton\(requirement)"
        }
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
        else if touchedNode.name == "coinButton200" {
            
            coinPremium(nodeName: touchedNode.name!)
        }
        else if touchedNode.name == "coinButton600" {
            
            coinPremium(nodeName: touchedNode.name!)
        }
        else if touchedNode.name == "coinButton1000" {
            
            coinPremium(nodeName: touchedNode.name!)
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
    private func coinPremium(nodeName: String) {
   print("\(coinNo)")
        
        if coinNo >= 200 && nodeName == "coinButton200" {
               UserDefaults.standard.set(true, forKey: "isPremiumUser")
          
                coinNo -= 200
           
           
            savePremiumStatus(isPremium: true, coin: coinNo, Category: 200)
//               UserDefaults.standard.set(coinNo, forKey: "coinNo")
          
               NotificationCenter.default.post(name: NSNotification.Name("PremiumPurchased"), object: nil)
           
              
           }
        else if coinNo >= 600  && nodeName == "coinButton600"{
            UserDefaults.standard.set(true, forKey: "isPremiumUser")
         
            coinNo -= 600
         savePremiumStatus(isPremium: true, coin: coinNo, Category: 600)
//               UserDefaults.standard.set(coinNo, forKey: "coinNo")
       
            NotificationCenter.default.post(name: NSNotification.Name("PremiumPurchased"), object: nil)
        }
        else if coinNo >= 1000 && nodeName == "coinButton1000" {
            UserDefaults.standard.set(true, forKey: "isPremiumUser")
         
            coinNo -= 1000
         savePremiumStatus(isPremium: true, coin: coinNo, Category: 1000)
//               UserDefaults.standard.set(coinNo, forKey: "coinNo")
       
            NotificationCenter.default.post(name: NSNotification.Name("PremiumPurchased"), object: nil)
        }
            else {
               print("Need more coins")
               let alertController = UIAlertController(title: "Insufficient Coins", message: "Need More Coins To buy Premium", preferredStyle: .alert)
               
               let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
               alertController.addAction(cancelAction)
               if let viewController = self.view?.window?.rootViewController {
                   viewController.present(alertController, animated: true, completion: nil)
               }
           }
        
        
    }
  private  func returnToTitleScene() {
        if let titleScene = TitleScene(fileNamed: "TitleScene") {
            titleScene.scaleMode = .resizeFill
            let transition = SKTransition.fade(withDuration: 1.0)
            self.view?.presentScene(titleScene, transition: transition)
        }
    }
    func savePremiumStatus(isPremium: Bool, coin: Int, Category: Int) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        // Get current date and time
        let purchaseDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let purchaseDateString = dateFormatter.string(from: purchaseDate)
        
        // Calculate expiration date
        var expirationDate: Date
        switch Category {
        case 200:
            expirationDate = Calendar.current.date(byAdding: .month, value: 2, to: purchaseDate)!
        case 600:
            expirationDate = Calendar.current.date(byAdding: .month, value: 5, to: purchaseDate)!
        case 1000:
            expirationDate = Calendar.current.date(byAdding: .year, value: 1, to: purchaseDate)!
        default:
            expirationDate = purchaseDate
        }
        let expirationDateString = dateFormatter.string(from: expirationDate)
        
        // Create a new purchase entry with date, time, coins used, and expiration date
        let purchaseEntry = ["date": purchaseDateString, "category": Category, "expirationDate": expirationDateString] as [String : Any]
        
        let ref = Database.database().reference().child("users").child(userID)
        
        // Append the new purchase entry to the 'purchases' child in Firebase
        ref.child("purchases").childByAutoId().setValue(purchaseEntry) { error, _ in
            if let error = error {
                print("Failed to save purchase entry: \(error.localizedDescription)")
            } else {
                print("Purchase entry saved successfully")
            }
        }
        
        // Update the overall premium status and coin count
        ref.updateChildValues(["isPremiumUser": isPremium, "Coins": coin, "premiumExpirationDate": expirationDateString]) { error, _ in
            if let error = error {
                print("Failed to update premium status: \(error.localizedDescription)")
            } else {
                print("Premium status updated successfully")
            }
        }
    }



}
