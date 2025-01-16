import SpriteKit
import GameplayKit
import FirebaseCore
import GoogleSignIn
import FirebaseAuth
import FirebaseDatabase



class StartScene: SKScene {
    var button: SKSpriteNode!
    var player: SKSpriteNode!
    var logo: SKSpriteNode!
    var loadingIndicator: UIActivityIndicatorView!
    var ui = touch()
    var termsCheckmark: SKSpriteNode!
      var termsLabel: SKLabelNode!
      var isTermsAccepted = false
  
  
    override func didMove(to view: SKView) {
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
              // Transition to the title screen
              transitionToTitleScene()
              return
          }
        setupGoogleButton()
        setupLogo()
        setupBackground()
        setupCharacter()
        playBackgroundMusic()
        setupLoadingIndicator()
        setupTermsCheckmark()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            if touchedNode.name == "google" {
                            if isTermsAccepted {
                                ui.glow(button: button)
                                ui.ui(button: button)
                                showLoadingIndicator()
                                signInWithGoogle()
                            } else {
                                showAlert()
                                
                            }
                        } else if touchedNode.name == "termsCheckmark" {
                           
                            toggleTermsCheckmark()
                        }
            else if touchedNode.name == "termsButton" {
                print("url open")
                if let url = URL(string: "https://website-two-red-68.vercel.app/") {
                    UIApplication.shared.open(url)}
                        }
        }
    }
    func toggleTermsCheckmark() {
        let uncheckedTexture = SKTexture(imageNamed: "checkboxUnchecked")
        let checkedTexture = SKTexture(imageNamed: "checkboxChecked")
        
        if isTermsAccepted {
            termsCheckmark.texture = uncheckedTexture
            isTermsAccepted = false
            print("rejected")
        } else {
            termsCheckmark.texture = checkedTexture
            isTermsAccepted = true
            print("accepted")
        }
    }
    func setupTermsCheckmark() {
        termsLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        termsLabel.alpha = 0.7
        termsLabel.text =  "I accept the terms and conditions"
           termsLabel.fontSize = 18
           termsLabel.fontColor = .black
       
           termsLabel.position = CGPoint(x: frame.midX + 20, y: frame.midY - 257)
        termsLabel.zPosition = 100
           termsLabel.name = "termsLabel"
           addChild(termsLabel)
        let underline = SKSpriteNode(color: .black, size: CGSize(width: termsLabel.frame.width, height: 2))
        underline.position = CGPoint(x: termsLabel.position.x, y: termsLabel.position.y - termsLabel.frame.height / 3 )
          underline.zPosition = 99
          underline.name = "underline"
          addChild(underline)
           
           let uncheckedTexture = SKTexture(imageNamed: "checkboxUnchecked")
           termsCheckmark = SKSpriteNode(texture: uncheckedTexture)
           termsCheckmark.position = CGPoint(x: frame.midX - 150, y: frame.midY - 250)
           termsCheckmark.name = "termsCheckmark"
        termsCheckmark.alpha = 0.7
        termsCheckmark.size = CGSize(width: 25, height: 25)
           addChild(termsCheckmark)
        let termsButton = SKSpriteNode(color: .clear, size: CGSize(width: termsLabel.frame.width, height: termsLabel.frame.height + 20))
        termsButton.position = termsLabel.position
        termsButton.name = "termsButton"
        addChild(termsButton)
        
       }
    func showAlert() {
        let alertController = UIAlertController(
            title: "Terms Required",
            message: "To continue, Please review and accept our Terms and Conditions. Your acceptance is required for further access.",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "Understood", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        if let viewController = self.view?.window?.rootViewController {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }

    func signInWithGoogle() {
        guard let presentingVC = self.view?.window?.rootViewController else { return }
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { [unowned self] result, error in
            if let error = error {
                print("Google Sign-In error: \(error.localizedDescription)")
                self.hideLoadingIndicator()
                return
            }
            
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                print("Failed to get ID token or user information")
                self.hideLoadingIndicator()
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                if let error = error {
                    print("Firebase authentication error: \(error.localizedDescription)")
                    self?.hideLoadingIndicator()
                    return
                }
                
                print("User signed in: \(authResult?.user.email ?? "no email")")
         
                if let currentUser = Auth.auth().currentUser {
                    let userID = currentUser.uid
                    let userEmail = currentUser.email ?? "No Email"
                    let ref = Database.database().reference().child("users").child(userID)
                    
                    ref.observeSingleEvent(of: .value) { snapshot in
                        if !snapshot.exists() {
                            print("Data does not exist, creating new user data")
                            ref.setValue(["email": userEmail, "isPremiumUser": false,"Coins": 0, "High Score": 0]) { error, _ in
                                if let error = error {
                                    print("Failed to write user data to database: \(error.localizedDescription)")
                                } else {
                                    print("Successfully wrote user data to database")
                                    UserDefaults.standard.setValue(false, forKey: "isPremiumUser")
                                }
                                self?.hideLoadingIndicator()
                                self?.transitionToTitleScene()
                            }
                        } else {
                            print("Data exists, reading isPremiumUser value")
                            if let userData = snapshot.value as? [String: Any] {
                                print("User data: \(userData)")
                                
                                if let coin = userData["Coins"] as? Int {
                                    UserDefaults.standard.setValue(coin, forKey: "coinNo")
                                    print("coin updated")
                                }
                                if let highScore = userData["High Score"] as? Int {
                                    UserDefaults.standard.setValue(highScore, forKey: "highScore")
                                    print("high score")
                                }
                                if let expirationDateString = userData["premiumExpirationDate"] as? String {
                                    print("\(expirationDateString)")
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                    if let expirationDate = dateFormatter.date(from: expirationDateString), Date() > expirationDate {
                                        ref.updateChildValues(["isPremiumUser": false]) { error, _ in
                                            if let error = error {
                                                print("Failed to update premium status: \(error.localizedDescription)")
                                            } else {
                                                print("expiry status updated successfully")
                                            }
                                        }
                                        UserDefaults.standard.setValue(false, forKey: "isPremiumUser")
                                        print("was expired so changed")
                                    }
                                    else {
                                        
                                        print("not expired yet")
                                        UserDefaults.standard.setValue(true, forKey: "isPremiumUser")
                                    }}
                              
                                    
                                    print("Fetched isPremiumUser")
                                    self?.hideLoadingIndicator()
                                    self?.transitionToTitleScene()
                                 
                                   
                                    self?.hideLoadingIndicator()
                                
                            } else {
                                print("Failed to cast snapshot value to [String: Any]")
                                self?.hideLoadingIndicator()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setupGoogleButton() {
        let texture = SKTexture(imageNamed: "google")
        button = SKSpriteNode(texture: texture)
        button.zPosition = 20
        button.position = CGPoint(x: frame.midX, y: frame.midY + 30)
        button.name = "google"
        addChild(button)
    }
    
    func setupLogo() {
        logo = SKSpriteNode(imageNamed: "cranky")
        logo.size = CGSize(width: frame.size.width * 1.3, height: frame.size.width * 1.3)
        logo.position = CGPoint(x: frame.midX, y: frame.midY + 280)
        addChild(logo)
    }
    
    func setupBackground() {
        if UserDefaults.standard.string(forKey: "selectedBackground") == nil {
            UserDefaults.standard.set("airadventurelevel1", forKey: "selectedBackground")
        }
        if let imageName = UserDefaults.standard.string(forKey: "selectedBackground") {
            let texture = SKTexture(imageNamed: imageName)
            createSky(skyTexture: texture)
        }
    }
    
    func setupCharacter() {
        if UserDefaults.standard.string(forKey: "selectedCharacter") == nil {
            UserDefaults.standard.set("planeRed", forKey: "selectedCharacter")
        }
        if let selectedCharacterName = UserDefaults.standard.string(forKey: "selectedCharacter") {
            createPlayer(characterName: selectedCharacterName)
        }
    }
    
    func playBackgroundMusic() {
        if UserDefaults.standard.bool(forKey: "isSoundOn") {
            BackgroundMusic.shared.play()
        }
    }
    
    func setupLoadingIndicator() {
        if let view = self.view {
            loadingIndicator = UIActivityIndicatorView(style: .large)
            loadingIndicator.center = view.center
            loadingIndicator.color = .black
            loadingIndicator.hidesWhenStopped = true
            view.addSubview(loadingIndicator)
        }
    }
    
    func showLoadingIndicator() {
        loadingIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
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
    
    func createSky(skyTexture: SKTexture) {
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
    
    func transitionToTitleScene() {
        if let scene = SettingsScene(fileNamed: "TitleScene") {
            scene.scaleMode = .resizeFill
            let transition = SKTransition.fade(withDuration: 1.0)
            self.view?.presentScene(scene, transition: transition)
        }
    }
}
