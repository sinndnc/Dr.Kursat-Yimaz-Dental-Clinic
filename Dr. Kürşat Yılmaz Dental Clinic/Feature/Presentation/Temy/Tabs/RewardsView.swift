import SwiftUI

struct RewardsView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#0D1117"), Color(hex: "#0F1729"), Color(hex: "#0D1117")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Title
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Ödüller")
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                Text("Başarılarını gör! 🏆")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "#8892A4"))
                            }
                            
                            Spacer()
                            
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.white)
                                    .padding()
                            }
                            
                        }
                        
                        // Stats Card
                        statsCard
                        
                        // Level Card
                        levelCard
                        
                        // Badges
                        badgesSection
                        
                        // Streak History
                        streakSection
                        
                        Spacer(minLength: 90)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Stats Card
    var statsCard: some View {
        VStack(spacing: 16) {
            // Total points
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Toplam Puan")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "#8892A4"))
                    HStack(alignment: .bottom, spacing: 4) {
                        Text("\(vm.user.totalPoints)")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "#FFD700"), Color(hex: "#FF8C00")],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                        Text("⭐")
                            .font(.system(size: 28))
                            .offset(y: -4)
                    }
                }
                Spacer()
                
                // Level badge
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#7C6BE8"), Color(hex: "#4A3FA8")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                    VStack(spacing: 0) {
                        Text("LVL")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.8))
                        Text("\(levelNumber)")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
            }
            
            // Stats row
            HStack(spacing: 12) {
                StatItem(icon: "flame.fill", value: "\(vm.user.currentStreak)", label: "Güncel Seri", color: Color(hex: "#FF6B35"))
                StatItem(icon: "crown.fill", value: "\(vm.user.longestStreak)", label: "En Uzun", color: Color(hex: "#FFD700"))
                StatItem(icon: "checkmark.circle.fill", value: "\(vm.user.completedTasksCount)", label: "Görev", color: Color(hex: "#00E5A0"))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: "#141B2D"))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(Color(hex: "#FFD700").opacity(0.15), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Level Card
    var levelCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text(levelTitle)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Text("\(vm.user.totalPoints) / \(nextLevelPoints) puan")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#8892A4"))
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "#1E2A3A"))
                        .frame(height: 12)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#7C6BE8"), Color(hex: "#FF6B9D")],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * levelProgress, height: 12)
                }
            }
            .frame(height: 12)
            
            HStack {
                Text("Sıradaki: \(nextLevelTitle)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "#7C6BE8"))
                Spacer()
                Text("%\(Int(levelProgress * 100))")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#7C6BE8"))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: "#141B2D"))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(Color(hex: "#7C6BE8").opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Badges
    var badgesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Rozetler")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("\(vm.user.badges.filter { $0.isUnlocked }.count)/\(vm.user.badges.count)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#8892A4"))
                Spacer()
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(vm.user.badges) { badge in
                    BadgeCard(badge: badge)
                }
            }
        }
    }
    
    // MARK: - Streak Section
    var streakSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Seri İstatistikleri")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
            
            HStack(spacing: 12) {
                StreakCard(
                    icon: "🔥",
                    title: "Güncel Seri",
                    value: "\(vm.user.currentStreak) Gün",
                    subtitle: "Devam et!",
                    gradient: [Color(hex: "#FF6B35"), Color(hex: "#FF3D6B")]
                )
                StreakCard(
                    icon: "👑",
                    title: "Rekor Seri",
                    value: "\(vm.user.longestStreak) Gün",
                    subtitle: "En iyi sonuç",
                    gradient: [Color(hex: "#FFD700"), Color(hex: "#FF8C00")]
                )
            }
        }
    }
    
    // MARK: - Helpers
    var levelNumber: Int {
        switch vm.user.totalPoints {
        case 0..<50: return 1
        case 50..<150: return 2
        case 150..<300: return 3
        case 300..<500: return 4
        default: return 5
        }
    }
    
    var levelTitle: String {
        switch levelNumber {
        case 1: return "🦷 Diş Çırağı"
        case 2: return "✨ Diş Savaşçısı"
        case 3: return "⚡ Diş Ustası"
        case 4: return "👑 Diş Şampiyonu"
        default: return "🏆 Diş Efsanesi"
        }
    }
    
    var nextLevelTitle: String {
        switch levelNumber {
        case 1: return "✨ Diş Savaşçısı"
        case 2: return "⚡ Diş Ustası"
        case 3: return "👑 Diş Şampiyonu"
        case 4: return "🏆 Diş Efsanesi"
        default: return "MAX SEVİYE!"
        }
    }
    
    var nextLevelPoints: Int {
        switch levelNumber {
        case 1: return 50
        case 2: return 150
        case 3: return 300
        case 4: return 500
        default: return 500
        }
    }
    
    var currentLevelBase: Int {
        switch levelNumber {
        case 1: return 0
        case 2: return 50
        case 3: return 150
        case 4: return 300
        default: return 500
        }
    }
    
    var levelProgress: Double {
        let base = currentLevelBase
        let next = nextLevelPoints
        if next == base { return 1.0 }
        return min(Double(vm.user.totalPoints - base) / Double(next - base), 1.0)
    }
}

// MARK: - Supporting Views

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 20))
            Text(value)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#8892A4"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(color.opacity(0.08))
        )
    }
}

struct BadgeCard: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(badge.isUnlocked ? badgeColor.opacity(0.2) : Color(hex: "#1E2A3A"))
                    .frame(width: 60, height: 60)
                Image(systemName: badge.iconName)
                    .font(.system(size: 26))
                    .foregroundColor(badge.isUnlocked ? badgeColor : Color(hex: "#3A4558"))
                
                if !badge.isUnlocked {
                    Circle()
                        .fill(Color(hex: "#0D1117").opacity(0.6))
                        .frame(width: 60, height: 60)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#3A4558"))
                }
            }
            
            Text(badge.name)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(badge.isUnlocked ? .white : Color(hex: "#3A4558"))
                .multilineTextAlignment(.center)
            
            Text(badge.description)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#8892A4"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "#141B2D"))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(
                            badge.isUnlocked ? badgeColor.opacity(0.3) : Color(hex: "#1E2A3A"),
                            lineWidth: 1.5
                        )
                )
        )
    }
    
    var badgeColor: Color {
        switch badge.color {
        case "yellow": return Color(hex: "#FFD700")
        case "orange": return Color(hex: "#FF6B35")
        case "purple": return Color(hex: "#7C6BE8")
        case "gold": return Color(hex: "#FFD700")
        case "green": return Color(hex: "#00E5A0")
        default: return Color(hex: "#00E5A0")
        }
    }
}

struct StreakCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let gradient: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(icon)
                .font(.system(size: 28))
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Color.white.opacity(0.7))
            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(subtitle)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(Color.white.opacity(0.7))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
        )
    }
}
