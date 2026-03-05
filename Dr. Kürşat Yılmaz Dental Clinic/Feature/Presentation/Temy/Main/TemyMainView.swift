//
//  TemyView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import SwiftUI

struct TemyMainView: View {
    @State private var showWelcome = false
    @StateObject private var vm = AppViewModel()
    
    var body: some View {
        ZStack {
            TabView(selection: $vm.selectedTab) {
                TemyHomeView()
                    .tabItem {
                        Label("Ana Sayfa", systemImage: "house.fill")
                    }
                    .tag(0)
                
                TasksView()
                    .tabItem {
                        Label("Görevler", systemImage: "checkmark.circle.fill")
                    }
                    .tag(1)
                
                RewardsView()
                    .tabItem {
                        Label("Ödüller", systemImage: "trophy.fill")
                    }
                    .tag(2)
            }
            .environmentObject(vm)
            .onAppear {
                vm.initIfNeeded()
            }
            // Floating point animation
            if vm.showPointAnimation {
                PointsBurstView(points: vm.earnedPoints)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.5).combined(with: .opacity),
                        removal: .opacity
                    ))
                    .zIndex(999)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: vm.showPointAnimation)
    }
}

// MARK: - Points Burst Animation
struct PointsBurstView: View {
    let points: Int
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        VStack(spacing: 4) {
            Text("+\(points)")
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "#FFD700"), Color(hex: "#FF8C00")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            Text("PUAN KAZANDIN! ⭐")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: "#1A1F35").opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(
                            LinearGradient(colors: [Color(hex: "#FFD700"), Color(hex: "#FF8C00")],
                                           startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 2
                        )
                )
        )
        .shadow(color: Color(hex: "#FFD700").opacity(0.4), radius: 20)
        .offset(y: offset)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                offset = -20
            }
            withAnimation(.easeIn(duration: 0.5).delay(1.8)) {
                opacity = 0
            }
        }
    }
}
