//
//  ViewController.swift
//  Reproductor
//
//  Created by Pablo on 27/12/2018.
//  Copyright © 2018 Pablo. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController , AVAudioPlayerDelegate{

    @IBOutlet var buttonPlay: UIButton!
    @IBOutlet var buttonPause: UIButton!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelArtist: UILabel!
    @IBOutlet var labelAlbum: UILabel!
    @IBOutlet var imageAlbum: UIImageView!
    @IBOutlet var songProgress: UISlider!
    @IBOutlet var labelTime: UILabel!
    @IBOutlet var labelDuration: UILabel!
    
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    var player = AVAudioPlayer()
    var pos : Int = 0
    var soundPathURL : URL?
    var music : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
//        print(documentsPath.path)
       
        if music.isEmpty {
            let fm = FileManager.default
            let allFiles = try! fm.contentsOfDirectory(atPath: documentsPath.path)
            
            for file in allFiles {
                if file.contains(".mp3") {
                    music.append(file)
                }
            }
        }
        loadTrack(pos)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        player.pause()
    }
    
    @IBAction func playSound(_ sender: Any) {
       

        player.prepareToPlay()
        buttonPlay.isHidden = true
        buttonPause.isHidden = false
        player.play()
        
        // Timer para actualizar el progreso de la cancion
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (Timer) in
            if self.player.isPlaying {
                self.songProgress.setValue(Float(self.player.currentTime / self.player.duration), animated: true)
                self.labelTime.text = self.player.currentTime.stringFromTimeInterval()
            }
        })
    }
    
    @IBAction func pauseSound(_ sender: UIButton) {
        buttonPlay.isHidden = false
        buttonPause.isHidden = true
        
        player.pause()
    }
    
    @IBAction func nextSong(_ sender: Any) {
        if pos < music.count - 1 {
            pos = pos + 1
        } else {
            pos = 0
        }
        loadTrack(pos)
    }
    
    @IBAction func previousSong(_ sender: Any) {
        if pos > 0 {
            pos = pos - 1
        } else {
            pos = music.count - 1
        }
        loadTrack(pos)
    }
    
    @IBAction func updateProgress(_ sender: Any) {
        // Se actualiza los segundos de la canción cuando el usuario interactúa con el slider
        player.currentTime = Double(songProgress.value) * player.duration
        labelTime.text = player.currentTime.stringFromTimeInterval()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        nextSong(self)
    }
    
    func loadTrack(_ pos: Int) {
        soundPathURL = documentsPath.appendingPathComponent(music[pos])
        player = try! AVAudioPlayer(contentsOf: soundPathURL!)
        player.delegate = self
        
        songProgress.setValue(0.0, animated: true)
        labelTime.text = player.currentTime.stringFromTimeInterval()
        labelDuration.text = player.duration.stringFromTimeInterval()
        
        let playerItem = AVPlayerItem(url: soundPathURL!)
        let metadataList = playerItem.asset.commonMetadata
        for item in metadataList {
            if item.commonKey == nil {
                continue
            }
            
            if let key = item.commonKey?.rawValue, let value = item.value {
                switch key {
                case "title":
                    print(value)
                    labelTitle.text = value as? String
                case "artist":
                    print(value)
                    labelArtist.text = value as? String
                case "albumName":
                    print(value)
                    labelAlbum.text = value as? String
                case "artwork" where value is Data:
                    imageAlbum.image = UIImage(data: value as! Data)
                default:
                    continue
                }
            }
        }
        
        playSound(self)
    }
}

extension TimeInterval {
    
    // función para obtener un string a partir del TimeInterval de la canción
    func stringFromTimeInterval() -> String {
        
        let time = NSInteger(self)
        
        let seconds = time % 60
        let minutes = (time / 60) % 60
        
        return String(format: "%0.2d:%0.2d", minutes, seconds)
    }
}

