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
    var ui = touch()
  
   
    override func didMove(to view: SKView) {
        setupGoogleButton()
        setupLogo()
        setupBackground()
        setupCharacter()
        playBackgroundMusic()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            if touchedNode.name == "google" {
                ui.glow(button: button)
                ui.ui(button: button)
                signInWithGoogle()
            }
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
                return
            }
            
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                print("Failed to get ID token or user information")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                if let error = error {
                    print("Firebase authentication error: \(error.localizedDescription)")
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
                                           
                                           
                                if let isPremiumUser = userData["isPremiumUser"] as? Bool {
                                    UserDefaults.standard.setValue(isPremiumUser, forKey: "isPremiumUser")
                                    print("Fetched isPremiumUser: \(isPremiumUser)")
                                    self?.transitionToTitleScene()
                                } else if let isPremiumUser = userData["isPremiumUser"] as? Int {
                                    let isPremium = (isPremiumUser == 1)
                                    UserDefaults.standard.setValue(isPremium, forKey: "isPremiumUser")
                                    print("Fetched isPremiumUser: \(isPremium)")
                                   
                                    self?.transitionToTitleScene()
                                } else {
                                    print("isPremiumUser key is missing or not a valid type")
                                }
                            } else {
                                print("Failed to cast snapshot value to [String: Any]")
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
    func transitionToTitleScene(){
        if let scene = SettingsScene(fileNamed: "TitleScene") {
            scene.scaleMode = .resizeFill
            let transition = SKTransition.fade(withDuration: 1.0)
            self.view?.presentScene(scene, transition: transition)
        }
    }
}

