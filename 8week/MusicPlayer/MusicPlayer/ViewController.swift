//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Beisenali on 29.10.2026.
//

import UIKit
import AVFoundation

struct Track {
    let title: String
    let artist: String
    let fileName: String
    let coverImageName: String
}

struct TrackLibrary {
    static let tracks: [Track] = [
        Track(title: "Династия", artist: "madK1d & VILLIAN", fileName: "track1", coverImageName: "cover1"),
        Track(title: "Father", artist: "Kanye West & TRAVIS SCOT", fileName: "track2", coverImageName: "cover2"),
        Track(title: "Франсе", artist: "Voskresenskii", fileName: "track3", coverImageName: "cover3"),
        Track(title: "Запрещаю забывать", artist: "MACAN, SALUKI", fileName: "track4", coverImageName: "cover4"),
        Track(title: "Self Aware", artist: "Temper City", fileName: "track5", coverImageName: "cover5"),
        Track(title: "Сквиртана", artist: "GONE.Fludd", fileName: "track6", coverImageName: "cover6"),
        Track(title: "До сих пор", artist: "MAYOT", fileName: "track7", coverImageName: "cover7"),
        Track(title: "Сквиртана", artist: "GONE.Fludd", fileName: "track8", coverImageName: "cover8"),
        Track(title: "Malo 2.0", artist: "Егор Крид, OG Buda, Toxi$, Мэйби Бэйби, Baby Cute, Дора, madk1d Тёмный принц", fileName: "track9", coverImageName: "cover9"),
        Track(title: "CARNIVAL", artist: "¥$ & Rich The Kid & Playboi Carti", fileName: "track10", coverImageName: "cover10")
    ]
}

class ViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!

    private let tracks = TrackLibrary.tracks
    private var currentIndex: Int = 0
    private var isPlaying: Bool = false
    private var audioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        coverImageView.layer.cornerRadius = 16
        coverImageView.clipsToBounds = true
        loadTrack(at: currentIndex, shouldPlay: false)
    }

    private func loadTrack(at index: Int, shouldPlay: Bool) {
        let track = tracks[index]
        
        let url = Bundle.main.url(forResource: track.fileName, withExtension: "mp3")
               ?? Bundle.main.url(forResource: track.fileName, withExtension: "m4a")
        
        guard let validURL = url else {
            print("⚠️ Error: Audio file '\(track.fileName)' not found in bundle!")
            isPlaying = false
            updateUI()
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: validURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            
            if shouldPlay {
                audioPlayer?.play()
                isPlaying = true
            } else {
                isPlaying = false
            }
        } catch {
            print("⚠️ Error initializing AVAudioPlayer: \(error.localizedDescription)")
            isPlaying = false
        }
        
        updateUI()
    }

    private func updateUI() {
        let track = tracks[currentIndex]
        titleLabel.text = track.title
        artistLabel.text = track.artist
        
        if let image = UIImage(named: track.coverImageName) {
            coverImageView.image = image
        } else {
            coverImageView.image = UIImage(systemName: "music.note")
        }
        
        let iconName = isPlaying ? "pause.fill" : "play.fill"
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
        playPauseButton.setImage(UIImage(systemName: iconName, withConfiguration: config), for: .normal)
    }

    @IBAction func previousTapped(_ sender: UIButton) {
        currentIndex = (currentIndex - 1 + tracks.count) % tracks.count
        loadTrack(at: currentIndex, shouldPlay: isPlaying)
    }

    @IBAction func playPauseTapped(_ sender: UIButton) {
        guard let player = audioPlayer else {
            loadTrack(at: currentIndex, shouldPlay: true)
            return
        }
        
        if player.isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
        updateUI()
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        currentIndex = (currentIndex + 1) % tracks.count
        loadTrack(at: currentIndex, shouldPlay: isPlaying)
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        currentIndex = (currentIndex + 1) % tracks.count
        loadTrack(at: currentIndex, shouldPlay: true)
    }
}
