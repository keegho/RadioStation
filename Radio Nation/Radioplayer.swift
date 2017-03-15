//
//  Radioplayer.swift
//  Radio Nation
//
//  Created by Kegham Karsian on 3/10/17.
//  Copyright © 2017 appologi. All rights reserved.
//

import Foundation
import AVFoundation

class Radioplayer {
    
    static let sharedInstance = Radioplayer()
    //private var player = AVPlayer(url: URL(string: "http://82.199.155.35:8012")!)
    private var player: AVPlayer!
    private var isPLaying = false
    
    public var urlString = String()
    
    
    func play() {
        if urlString != "" {
            if let url = URL(string: urlString) {
                player = AVPlayer(url: url)
                player.play()
                isPLaying = true
            } else {
                
                return
            }

        } else {
            
            return
        }
        
    }
    
    func pause() {
        if  urlString != "" {
            if let url = URL(string: urlString) {
                player = AVPlayer(url: url)
                player.pause()
                isPLaying = false
            }
        }
    }
    
    
    func toggle() {
        
        if isPLaying {
            
            pause()
            
        } else {
            
            play()
        }
        
    }
    
    func currentlyPLaying() -> Bool {
        
        return isPLaying
        
    }
    
    
    
    
}
