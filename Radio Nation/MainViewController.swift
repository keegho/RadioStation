//
//  ViewController.swift
//  Radio Nation
//
//  Created by Kegham Karsian on 3/10/17.
//  Copyright © 2017 appologi. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import AlamofireImage

class MainViewController: UIViewController {

    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var playPauseButton: UIButton!
    var radioStation = Radiostation()
    @IBOutlet var radioStationImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupMediaPlayer()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .allowAirPlay)
            UIApplication.shared.beginReceivingRemoteControlEvents()
            print("Receiving remote control events\n")
            
        } catch {
            print("Error audio session\n")
        }
        
        navigationItem.title = radioStation.name
        navigationController?.navigationBar.isHidden = false
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if radioStation.imgURL != "" {
            radioStationImage.af_setImage(withURL: URL(string: radioStation.imgURL)!)
        }
        
        categoryLabel.text = radioStation.categoryTitle
        
        if Radioplayer.sharedInstance.currentlyPLaying() {

            playPauseButton.setTitle("Pause", for: .normal)
        } else {

            playPauseButton.setTitle("Play", for: .normal)
        }
    }
    
    @IBAction func play(_ sender: UIButton) {
        if radioStation.streamURL != "" {
            
            Radioplayer.sharedInstance.urlString = radioStation.streamURL
            
            if Radioplayer.sharedInstance.currentlyPLaying() {
                Radioplayer.sharedInstance.toggle()
                playPauseButton.setTitle("Play", for: .normal)
            } else {
                Radioplayer.sharedInstance.toggle()
                playPauseButton.setTitle("Pause", for: .normal)
            }
        } else {
            print("Empty Stream URL")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupMediaPlayer() {
        
        if NSClassFromString("MPNowPlayingInfoCenter") != nil {
            let image:UIImage = #imageLiteral(resourceName: "radioTest") // comment this if you don't use an image
            let albumArt = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (size) -> UIImage in
                return image
            }) // comment this if you don't use an image
            let songInfo = [
                MPMediaItemPropertyTitle: radioStation.name,
                MPMediaItemPropertyArtist: "87,8fm",
                MPMediaItemPropertyArtwork: albumArt // comment this if you don't use an image
            ] as [String : Any]
            MPNowPlayingInfoCenter.default().nowPlayingInfo = songInfo
        }
    }


}
