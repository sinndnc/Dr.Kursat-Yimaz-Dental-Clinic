import SwiftUI

struct TemyHomeView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var animateStreak = false
    @State private var animateProgress = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(hex: "#0D1117"), Color(hex: "#0F1729"), Color(hex: "#0D1117")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Streak Card
                        streakCard
                        
                        // Daily Progress
                        dailyProgressCard
                        
                        // Quick Task Preview
                        quickTasksPreview
                        
                        // Character/Mascot
                        mascotSection
                        
                        Spacer(minLength: 90)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Header
    var headerSection: some View {
        HStack {
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Merhaba,")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "#8892A4"))
                Text("\(vm.user.name)! 👋")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Points Badge
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .foregroundColor(Color(hex: "#FFD700"))
                    .font(.system(size: 16))
                Text("\(vm.user.totalPoints)")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color(hex: "#1E2A3A"))
                    .overlay(
                        Capsule()
                            .strokeBorder(Color(hex: "#FFD700").opacity(0.3), lineWidth: 1)
                    )
            )
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.white)
                    .padding()
            }
            
        }
    }
    
    // MARK: - Streak Card
    var streakCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#FF6B35"), Color(hex: "#FF3D6B")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Decorative circles
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 120)
                .offset(x: 80, y: -40)
            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 80)
                .offset(x: 110, y: 20)
            
            HStack(spacing: 20) {
                // Flame
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 64, height: 64)
                    Text("🔥")
                        .font(.system(size: 36))
                        .scaleEffect(animateStreak ? 1.2 : 1.0)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(vm.user.currentStreak) Günlük Seri")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("En uzun: \(vm.user.longestStreak) gün")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text("🏆")
                        .font(.system(size: 24))
                    Text("Rekor")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.8))
                }
            }
            .padding(20)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                animateStreak = true
            }
        }
    }
    
    // MARK: - Daily Progress Card
    var dailyProgressCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Bugünkü İlerleme")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Text("\(vm.completedTasksToday)/\(vm.dailyTasks.count)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#00E5A0"))
            }
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "#1E2A3A"))
                        .frame(height: 16)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#00E5A0"), Color(hex: "#00B4D8")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: animateProgress ? geo.size.width * vm.progressToday : 0, height: 16)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: animateProgress)
                }
            }
            .frame(height: 16)
            
            // Points earned today
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(Color(hex: "#FFD700"))
                    .font(.system(size: 13))
                Text("Bugün \(vm.totalPointsToday) puan kazandın")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "#8892A4"))
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: "#141B2D"))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(Color(hex: "#1E2A3A"), lineWidth: 1)
                )
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateProgress = true
            }
        }
    }
    
    // MARK: - Quick Tasks Preview
    var quickTasksPreview: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Görevler")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Button {
                    vm.selectedTab = 1
                } label: {
                    Text("Tümünü Gör →")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "#00E5A0"))
                }
            }
            
            ForEach(vm.dailyTasks.prefix(3)) { task in
                MiniTaskRow(task: task)
            }
        }
    }
    
    // MARK: - Mascot
    var mascotSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#1A1F35"), Color(hex: "#141B2D")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(Color(hex: "#00E5A0").opacity(0.2), lineWidth: 1)
                )
            
            HStack(spacing: 16) {
                Text(mascotEmoji)
                    .font(.system(size: 52))
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Diş Kahramanı")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#00E5A0"))
                    Text(mascotMessage)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "#C8D4E8"))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            .padding(20)
        }
    }
    
    var mascotEmoji: String {
        if vm.progressToday == 1.0 { return "🦷✨" }
        if vm.progressToday > 0.5 { return "😊" }
        return "🦷"
    }
    
    var mascotMessage: String {
        if vm.progressToday == 1.0 { return "Harika iş! Dişlerin ışıl ışıl! 🎉" }
        if vm.completedTasksToday == 0 { return "Hadi başlayalım! Görevlerin seni bekliyor 💪" }
        return "Çok iyi gidiyorsun! Devam et! 🚀"
    }
}

// MARK: - Mini Task Row
struct MiniTaskRow: View {
    let task: DailyTask
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(taskColor.opacity(task.isCompleted ? 0.3 : 0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : task.iconName)
                    .foregroundColor(task.isCompleted ? Color(hex: "#00E5A0") : taskColor)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(task.isCompleted ? Color(hex: "#8892A4") : .white)
                    .strikethrough(task.isCompleted)
                Text("+\(task.points) puan")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "#8892A4"))
            }
            
            Spacer()
            
            if task.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(hex: "#00E5A0"))
                    .font(.system(size: 22))
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(hex: "#3A4558"))
                    .font(.system(size: 14))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#141B2D"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            task.isCompleted ? Color(hex: "#00E5A0").opacity(0.2) : Color(hex: "#1E2A3A"),
                            lineWidth: 1
                        )
                )
        )
    }
    
    var taskColor: Color {
        switch task.color {
        case "orange": return Color(hex: "#FF6B35")
        case "indigo": return Color(hex: "#7C6BE8")
        case "pink": return Color(hex: "#FF6B9D")
        case "cyan": return Color(hex: "#00B4D8")
        case "green": return Color(hex: "#00E5A0")
        default: return Color(hex: "#00E5A0")
        }
    }
}
