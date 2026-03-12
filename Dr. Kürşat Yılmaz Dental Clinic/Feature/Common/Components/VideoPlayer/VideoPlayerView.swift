//
//  VideoPlayerView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import Combine
import SwiftUI
import AVKit


struct VideoPlayerView: View {
    let videoURL : URL
    
    @StateObject private var playerModel = VideoPlayerModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let player = playerModel.player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            }
            
            // Close Button
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 40, height: 40)
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.leading, 20)
                    .padding(.top, 60)
                    
                    Spacer()
                }
                Spacer()
            }
        }
        .onAppear {
            playerModel.setup(url: videoURL)
        }
        .onDisappear {
            playerModel.cleanup()
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
    }
}

class VideoPlayerModel: ObservableObject {
    @Published var player: AVPlayer?
    
    func setup(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
        
        // Loop video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            self?.player?.seek(to: .zero)
            self?.player?.play()
        }
    }
    
    func cleanup() {
        player?.pause()
        player = nil
        NotificationCenter.default.removeObserver(self)
    }
}
