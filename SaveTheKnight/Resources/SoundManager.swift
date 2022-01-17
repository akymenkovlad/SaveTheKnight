//
//  SoundManager.swift
//  SaveTheKnight
//
//  Created by Valados on 17.01.2022.
//

import Foundation
import AVFoundation

class SoundManager : NSObject, AVAudioPlayerDelegate {
    static let sharedInstance = SoundManager()
    
    private(set) var isMuted = false
    var audioPlayer : AVAudioPlayer?
    var trackPosition = 0
    
    //Music: http://www.bensound.com/royalty-free-music
    static private let tracks = [
        "battle_1",
        "battle_2"
    ]
    
    private override init() {
        //This is private so you can only have one Sound Manager ever.
        trackPosition = Int(arc4random_uniform(UInt32(SoundManager.tracks.count)))
        
        let defaults = UserDefaults.standard
        
        isMuted = defaults.bool(forKey: MuteKey)
    }
    
    public func startPlaying() {
        if !isMuted && (audioPlayer == nil || audioPlayer?.isPlaying == false) {
            let soundURL = Bundle.main.url(forResource: SoundManager.tracks[trackPosition], withExtension: "mp3")
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL!)
                audioPlayer?.delegate = self
            } catch {
                print("audio player failed to load")
                
                startPlaying()
            }
            
            audioPlayer?.prepareToPlay()
            
            audioPlayer?.play()
            
            trackPosition = (trackPosition + 1) % SoundManager.tracks.count
        } else {
            print("Audio player is already playing!")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        startPlaying()
    }
    func toggleMute() -> Bool {
        isMuted = !isMuted
        
        let defaults = UserDefaults.standard
        defaults.set(isMuted, forKey: MuteKey)
        defaults.synchronize()
        
        if isMuted {
            audioPlayer?.stop()
        } else {
            startPlaying()
        }
        
        return isMuted
    }
}
