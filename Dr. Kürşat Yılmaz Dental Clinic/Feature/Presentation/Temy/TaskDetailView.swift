import SwiftUI
import Combine

struct TaskDetailView: View {
    let task: DailyTask
    @Binding var isPresented: Bool
    @EnvironmentObject var vm: AppViewModel
    
    var body: some View {
        ZStack {
            Color(hex: "#0D1117").ignoresSafeArea()
            
            switch task.taskType {
            case .timer:
                TimerTaskView(task: task, isPresented: $isPresented)
                    .environmentObject(vm)
            case .counter:
                CounterTaskView(task: task, isPresented: $isPresented)
                    .environmentObject(vm)
            case .checklist:
                ChecklistTaskView(task: task, isPresented: $isPresented)
                    .environmentObject(vm)
            }
        }
        .interactiveDismissDisabled(false)
    }
}

// MARK: - Timer Task View
struct TimerTaskView: View {
    let task: DailyTask
    @Binding var isPresented: Bool
    @EnvironmentObject var vm: AppViewModel
    
    @State private var timeRemaining: Int
    @State private var isRunning = false
    @State private var isCompleted = false
    @State private var timer: Timer?
    @State private var progress: Double = 1.0
    @State private var celebrateScale: CGFloat = 1.0
    
    private let totalTime: Int
    
    init(task: DailyTask, isPresented: Binding<Bool>) {
        self.task = task
        self._isPresented = isPresented
        let dur = task.timerDuration ?? 120
        self._timeRemaining = State(initialValue: dur)
        self.totalTime = dur
    }
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            HStack {
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "#3A4558"))
                }
                Spacer()
                Text(task.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Color.clear.frame(width: 28, height: 28)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            Spacer()
            
            // Emoji instruction
            Text(isCompleted ? "🦷✨" : taskEmoji)
                .font(.system(size: 64))
                .scaleEffect(isRunning && !isCompleted ? (celebrateScale) : (isCompleted ? 1.3 : 1.0))
                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isRunning)
            
            // Circular Timer
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color(hex: "#1E2A3A"), lineWidth: 16)
                    .frame(width: 220, height: 220)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: isCompleted
                            ? [Color(hex: "#00E5A0"), Color(hex: "#00B4D8")]
                            : [timerColor, timerColor.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)
                
                // Time display
                VStack(spacing: 4) {
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(Color(hex: "#00E5A0"))
                    } else {
                        Text(timeString(timeRemaining))
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("saniye")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "#8892A4"))
                    }
                }
            }
            
            // Instruction
            Text(isCompleted ? "Mükemmel! Tamamladın! 🎉" : task.description)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#C8D4E8"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            // Control button
            if !isCompleted {
                Button {
                    toggleTimer()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 20, weight: .bold))
                        Text(isRunning ? "Duraklat" : (timeRemaining < totalTime ? "Devam Et" : "Başla"))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(Color(hex: "#0D1117"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [timerColor, timerColor.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 24)
            } else {
                Button {
                    vm.completeTask(task)
                    isPresented = false
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                        Text("Puanı Al! (+\(task.points)⭐)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#00E5A0"), Color(hex: "#00B4D8")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 24)
            }
            
            Spacer(minLength: 32)
        }
        .onDisappear { timer?.invalidate() }
    }
    
    func toggleTimer() {
        if isRunning {
            timer?.invalidate()
            isRunning = false
        } else {
            isRunning = true
            withAnimation {
                celebrateScale = 1.1
            }
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                    progress = Double(timeRemaining) / Double(totalTime)
                } else {
                    timer?.invalidate()
                    isRunning = false
                    isCompleted = true
                }
            }
        }
    }
    
    func timeString(_ seconds: Int) -> String {
        if totalTime >= 60 {
            return String(format: "%d:%02d", seconds / 60, seconds % 60)
        }
        return "\(seconds)"
    }
    
    var timerColor: Color {
        switch task.color {
        case "orange": return Color(hex: "#FF6B35")
        case "indigo": return Color(hex: "#7C6BE8")
        case "cyan": return Color(hex: "#00B4D8")
        default: return Color(hex: "#FF6B35")
        }
    }
    
    var taskEmoji: String {
        switch task.id {
        case "morning_brush": return "🦷"
        case "evening_brush": return "🌙"
        case "mouthwash": return "💧"
        default: return "⏱️"
        }
    }
}

// MARK: - Counter Task View
struct CounterTaskView: View {
    let task: DailyTask
    @Binding var isPresented: Bool
    @EnvironmentObject var vm: AppViewModel
    
    @State private var count = 0
    @State private var bounceScale: CGFloat = 1.0
    
    private var target: Int { task.counterTarget ?? 5 }
    private var isCompleted: Bool { count >= target }
    
    var body: some View {
        VStack(spacing: 28) {
            HStack {
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "#3A4558"))
                }
                Spacer()
                Text(task.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Color.clear.frame(width: 28, height: 28)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            // Icon
            Text(isCompleted ? "🎉" : "🦷")
                .font(.system(size: 56))
                .scaleEffect(bounceScale)
            
            // Description
            Text(task.description)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#C8D4E8"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            // Counter display
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(hex: "#141B2D"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .strokeBorder(
                                isCompleted ? Color(hex: "#00E5A0").opacity(0.4) : Color(hex: "#FF6B9D").opacity(0.3),
                                lineWidth: 2
                            )
                    )
                
                VStack(spacing: 12) {
                    Text("\(count)")
                        .font(.system(size: 72, weight: .black, design: .rounded))
                        .foregroundColor(isCompleted ? Color(hex: "#00E5A0") : .white)
                    
                    Text("/ \(target) \(task.counterLabel ?? "")")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#8892A4"))
                    
                    // Dots progress
                    HStack(spacing: 8) {
                        ForEach(0..<target, id: \.self) { i in
                            Circle()
                                .fill(i < count ? Color(hex: "#FF6B9D") : Color(hex: "#1E2A3A"))
                                .frame(width: 14, height: 14)
                                .scaleEffect(i < count ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: count)
                        }
                    }
                }
                .padding(32)
            }
            .padding(.horizontal, 24)
            
            // Tap button
            if !isCompleted {
                Button {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                        count = min(count + 1, target)
                        bounceScale = 1.3
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation { bounceScale = 1.0 }
                    }
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 28))
                        Text("DOKUN! (\(target - count) kaldı)")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#FF6B9D"), Color(hex: "#FF3D6B")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 24)
            } else {
                Button {
                    vm.completeTask(task)
                    isPresented = false
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "star.fill")
                        Text("Harika! Puanı Al! (+\(task.points)⭐)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(LinearGradient(
                                colors: [Color(hex: "#00E5A0"), Color(hex: "#00B4D8")],
                                startPoint: .leading, endPoint: .trailing
                            ))
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 24)
            }
            
            Spacer(minLength: 32)
        }
    }
}

// MARK: - Checklist Task View
struct ChecklistTaskView: View {
    let task: DailyTask
    @Binding var isPresented: Bool
    @EnvironmentObject var vm: AppViewModel
    
    @State private var items: [ChecklistItem]
    
    init(task: DailyTask, isPresented: Binding<Bool>) {
        self.task = task
        self._isPresented = isPresented
        self._items = State(initialValue: task.checklistItems ?? [])
    }
    
    private var allChecked: Bool { items.allSatisfy { $0.isChecked } }
    private var checkedCount: Int { items.filter { $0.isChecked }.count }
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "#3A4558"))
                }
                Spacer()
                Text(task.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Color.clear.frame(width: 28, height: 28)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            // Header
            Text(allChecked ? "🌟 Harika iş!" : "🥗")
                .font(.system(size: 52))
            
            Text(task.description)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#C8D4E8"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            // Progress
            HStack(spacing: 8) {
                ForEach(0..<items.count, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(i < checkedCount ? Color(hex: "#00E5A0") : Color(hex: "#1E2A3A"))
                        .frame(height: 6)
                        .animation(.spring(response: 0.4), value: checkedCount)
                }
            }
            .padding(.horizontal, 24)
            
            // Checklist items
            VStack(spacing: 12) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            items[index].isChecked.toggle()
                        }
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .stroke(item.isChecked ? Color(hex: "#00E5A0") : Color(hex: "#3A4558"), lineWidth: 2)
                                    .frame(width: 28, height: 28)
                                if item.isChecked {
                                    Circle()
                                        .fill(Color(hex: "#00E5A0"))
                                        .frame(width: 28, height: 28)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Text(item.label)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(item.isChecked ? Color(hex: "#8892A4") : .white)
                                .strikethrough(item.isChecked)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "#141B2D"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(
                                            item.isChecked ? Color(hex: "#00E5A0").opacity(0.3) : Color(hex: "#1E2A3A"),
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Complete button
            if allChecked {
                Button {
                    vm.completeTask(task)
                    isPresented = false
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 20))
                        Text("Tamamla! (+\(task.points)⭐)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(LinearGradient(
                                colors: [Color(hex: "#00E5A0"), Color(hex: "#00B4D8")],
                                startPoint: .leading, endPoint: .trailing
                            ))
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 24)
            } else {
                Text("\(items.count - checkedCount) madde kaldı")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "#8892A4"))
            }
            
            Spacer(minLength: 32)
        }
    }
}
