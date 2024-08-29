import AVFoundation

class BackgroundMusic {
    static let shared = BackgroundMusic()
    private var player: AVAudioPlayer?
    
    func play() {
        let isSoundOn = UserDefaults.standard.bool(forKey: "isSoundOn")
        if isSoundOn {
            if player == nil {
                if let musicURL = Bundle.main.url(forResource: "bgMusic", withExtension: "mp3") {
                    do {
                        player = try AVAudioPlayer(contentsOf: musicURL)
                        player?.numberOfLoops = -1 // Loop indefinitely
                        player?.volume = 0.3
                    } catch {
                        print("Error loading background music: \(error)")
                    }
                }
            }
            player?.play()
        }
    }
    
    func stop() {
        player?.stop()
    }
}
