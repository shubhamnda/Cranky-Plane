//
//  AdManager.swift
//  CrashyPlane
//
//  Created by Shubham Nanda on 03/07/24.
//

import GoogleMobileAds
class GameManager {
    static let shared = GameManager()
    var rewardedAd: GADRewardedAd?
    
    private init() {
        BackgroundMusic.shared.stop()
        loadRewardedAd()
    }
    
    func loadRewardedAd() {
        GADRewardedAd.load(withAdUnitID: "ca-app-pub-3940256099942544/1712485313",
                           request: GADRequest()) { [weak self] ad, error in
            if let error = error {
                print("Failed to load rewarded ad with error: \(error.localizedDescription)")
                return
            }
            
            self?.rewardedAd = ad
        }
    }
}
