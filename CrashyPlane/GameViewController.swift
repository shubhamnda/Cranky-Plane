//
//  GameViewController.swift
//  CrashyPlane
//
//  Created by Shubham Nanda on 13/06/24.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds


class GameViewController: UIViewController {
    
    var bannerView: GADBannerView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(removeBannerView), name: NSNotification.Name("PremiumPurchased"), object: nil)
        if !UserDefaults.standard.bool(forKey: "isPremiumUser"){
          
            print("\(UserDefaults.standard.bool(forKey: "isPremiumUser"))")
            let viewWidth = view.frame.inset(by: view.safeAreaInsets).width
            let adaptiveSize = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
            bannerView = GADBannerView(adSize: adaptiveSize)
            
            addBannerViewToView(bannerView)
            
            bannerView.adUnitID = "ca-app-pub-4131085170810437/1584949641"
            bannerView.rootViewController = self
            
            bannerView.load(GADRequest())}
        
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = StartScene(fileNamed: "StartScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .resizeFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
            view.showsPhysics = false
            
        }
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        NSLayoutConstraint.activate([
                   bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                   bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
               ])
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: view.safeAreaLayoutGuide,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 33),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    @objc func removeBannerView() {
           bannerView?.removeFromSuperview()
       }
}
