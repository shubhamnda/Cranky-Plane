import SpriteKit
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import GameplayKit
import GoogleMobileAds
import SAConfettiView
import FirebaseDatabase
import Firebase
class TitleScene: SKScene {
    
    
    
    
    
    
    var player: SKSpriteNode!
    var playButton: SKSpriteNode!
    var adButton: SKSpriteNode!
    var settingsButton: SKSpriteNode!
    var scoresButton: SKSpriteNode!
    var charactersButton: SKSpriteNode!
    var playLabel: SKSpriteNode!
    var info : SKSpriteNode!
    var logo: SKSpriteNode!
    var ad: SKSpriteNode!
    var modalBackground: SKShapeNode!
    var coinNo: Int = 0
    var coin: SKSpriteNode!
    var buttonLabel: SKLabelNode!
    var getMore: SKSpriteNode!
    var instructions: SKSpriteNode!
    let premium = PaymentManager()
    var premiumLogo: SKSpriteNode!
    var reset: SKSpriteNode!
    var confettiShown = UserDefaults.standard.bool(forKey: "confettiShown")
    var confettiView: SAConfettiView?
  
  
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
        confettiView = SAConfettiView(frame: view.bounds)
        confettiView?.intensity = 0.5
        confettiView?.type = .Confetti // Choose the type you prefer
        
        if let confettiView = confettiView {
            view.addSubview(confettiView)
        }
        
        resetButton()
        
        createButtons()
        
        infoButton()
        
        coinNo = UserDefaults.standard.integer(forKey: "coinNo")
        coins()
        logoHome()
        let isPremiumUser = UserDefaults.standard.bool(forKey: "isPremiumUser")
        print("\(isPremiumUser)")
                    if isPremiumUser {
                        updatePremiumUI()
                    }
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePremiumPurchase), name: NSNotification.Name("PremiumPurchased"), object: nil)
        
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
              
                InformationScene()
            }
            else if touchedNode.name == "reset" {
                
//                                print("user is now reset")
//                                UserDefaults.standard.set(false, forKey: "isPremiumUser")
//                                UserDefaults.standard.setValue(false, forKey: "confettiShown")
//                                updatePremiumUI()
             showLogoutAlert()
             
            }
            else if touchedNode.name == "noAds" {
                loadPremuimScene()
                //
            }
            //
            
            else if touchedNode.name == "Watch Ad" {
                showRewardedAd()
                
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
        player.size = CGSize(width: frame.size.width * 0.23, height: frame.size.width * 0.23)
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
        menu.size =  CGSize(width: frame.size.width * 0.42, height: frame.size.width * 0.13)
        menu.name = category // Assign the category as the name for identification
        addChild(menu)
        
        let buttonLabel = SKLabelNode(fontNamed: "Arial")
        buttonLabel.text = category
        buttonLabel.fontSize = 24
        buttonLabel.fontColor = SKColor.white
        buttonLabel.zPosition = 31
        buttonLabel.position = CGPoint(x: 0, y: -menuTexture.size().height / 8)
        
        menu.addChild(buttonLabel)
        if menu.name == "Watch Ad" {
            buttonLabel.position = CGPoint(x: -20, y: -menuTexture.size().height / 8)
            
            let playTexture = SKTexture(imageNamed: "video")
          playLabel = SKSpriteNode(texture: playTexture)
            playLabel.size =  CGSize(width: frame.size.width * 0.12, height: frame.size.width * 0.1)
            playLabel.position = CGPoint(x: buttonLabel.position.x + 95, y: buttonLabel.position.y + 15)
            buttonLabel.addChild(playLabel)
        }
        return menu
    }
    
    func createButtons() {
        playButton = menu(category: "Play", imageName: "blue_button04", position: CGPoint(x: self.frame.midX, y: self.frame.midY + 120))
        adButton = menu(category: "Watch Ad", imageName: "button04", position: CGPoint(x: self.frame.midX, y: self.frame.midY + 40))
        settingsButton = menu(category: "Settings", imageName: "green_button04", position: CGPoint(x: self.frame.midX, y: self.frame.midY - 200 ))
        scoresButton = menu(category: "Score", imageName: "red_button11", position: CGPoint(x: self.frame.midX, y: self.frame.midY - 40))
        charactersButton = menu(category: "Characters", imageName: "yellow_button04", position: CGPoint(x: self.frame.midX, y: self.frame.midY - 120))
    }
    
    func logoHome() {
        logo = SKSpriteNode(imageNamed: "cranky")
        logo.size = CGSize(width: frame.size.width * 1.3, height: frame.size.width * 1.3)
        logo.position = CGPoint(x: frame.midX, y: frame.midY + 280)
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
    func loadPremuimScene() {
        
        if let scene = PremiumScene(fileNamed: "PremiumScene") {
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
    func InformationScene() {
        
        if let scene = InfoScene(fileNamed: "InfoScene") {
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
        info.size = CGSize(width: frame.size.width * 0.1, height: frame.size.width * 0.1)
        info.position = CGPoint(x: frame.midX - 50, y: frame.midY - 280)
        info.zPosition = 34
        info.name = "about"
        addChild(info)
        ad = SKSpriteNode(imageNamed: "NoAds")
        ad.size = CGSize(width: frame.size.width * 0.18, height: frame.size.width * 0.18)
        ad.position = CGPoint(x: frame.midX + 50, y: frame.midY - 280)
        ad.zPosition = 34
        ad.name = "noAds"
        addChild(ad)
    }
    
    func coins(){
        coin = SKSpriteNode(imageNamed:  "coin")
        coin.zPosition = 101
        coin.size = CGSize(width: frame.size.width * 0.12, height: frame.size.width * 0.12)
        coin.position = CGPoint(x: frame.maxX - 0.18 * frame.size.width, y: frame.maxY - 0.04 * frame.size.height)
        addChild(coin)
        buttonLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        
        buttonLabel.text = "\(coinNo)"
        buttonLabel.fontSize = 0.06 * frame.size.width
        buttonLabel.fontColor = SKColor.white
        
        buttonLabel.zPosition = 101
        let labelOffset: CGFloat = 4 // Adjust this offset as needed
        
        // Adjust the position to be just to the right of the coin sprite
        let labelXPosition = coin.position.x + coin.size.width / 3 + labelOffset
        let labelYPosition = coin.position.y - 10
        _ = coin.position.x - coin.size.width / 3 - labelOffset
        
        
        buttonLabel.position = CGPoint(x: labelXPosition, y: labelYPosition)
        buttonLabel.horizontalAlignmentMode = .left
        addChild(buttonLabel)
        
        let premiumTexture = SKTexture(imageNamed: "premium")
        premiumLogo = SKSpriteNode(texture: premiumTexture)
        premiumLogo.zPosition = 101
        premiumLogo.position = CGPoint(x: frame.midX + 130, y: labelYPosition + 10)
        premiumLogo.size = CGSize(width: 0.12 * frame.size.width, height: 0.12 * frame.size.width) // Adjust size proportionallyr
        premiumLogo.isHidden = true
        
        addChild(premiumLogo)
        
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
                self.updateCoinNumberInFirebase()
                GameManager.shared.loadRewardedAd()
                
            }
        } else {
            print("Rewarded ad is not ready")
            GameManager.shared.loadRewardedAd()  // Reload the ad if it's not ready
        }
    }
    @objc func handlePremiumPurchase() {
        let isPremiumUser = UserDefaults.standard.bool(forKey: "isPremiumUser")
        if  (isPremiumUser == true ){
            updatePremiumUI()
        }
    }
    func updatePremiumUI() {
        
        
        premiumLogo.isHidden = false
        coin.removeFromParent()
        buttonLabel.removeFromParent()
        getMore.removeFromParent()
        ad.removeFromParent()
        info.position = CGPoint(x: frame.midX, y: frame.midY - 260)
        if !confettiShown {
            UserDefaults.standard.setValue(true, forKey: "confettiShown")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                
                self?.confettiView?.startConfetti()
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) { [weak self] in
                self?.confettiView?.stopConfetti()
                self?.confettiView?.removeFromSuperview()
            }
        }
        
    }
    func resetButton(){
        reset = SKSpriteNode(imageNamed: "logout")
        reset.size = CGSize(width: frame.size.width * 0.1, height: frame.size.width * 0.1)
        
        reset.position = CGPoint(x: frame.minX + 0.14 * frame.size.width, y: frame.maxY - 0.04 * frame.size.height)

        reset.zPosition = 102
        reset.alpha = 0.5
        reset.name = "reset"
        addChild(reset)
    }
    func logOut() {
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                GIDSignIn.sharedInstance.signOut()
                print("User signed out")
            if let scene = StartScene(fileNamed: "StartScene") {
                        scene.scaleMode = .resizeFill
                        let transition = SKTransition.fade(withDuration: 1.0)
                        self.view?.presentScene(scene, transition: transition)
                    }
                
                
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
        }
    func showLogoutAlert() {
        let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.logOut()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        
        if let viewController = self.view?.window?.rootViewController {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    func updateCoinNumberInFirebase() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("users").child(userID)
        ref.updateChildValues(["Coins": coinNo]) { error, _ in
            if let error = error {
                print("Failed to update coin number in Firebase: \(error.localizedDescription)")
            } else {
                print("Successfully updated coin number in Firebase")
            }
        }
    }
}

