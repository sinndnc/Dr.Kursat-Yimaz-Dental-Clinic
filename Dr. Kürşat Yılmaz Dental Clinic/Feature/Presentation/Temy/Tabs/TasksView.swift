import SwiftUI

struct TasksView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var selectedTask: DailyTask?
    @State private var showTaskDetail = false
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
                    VStack(spacing: 20) {
                        // Title
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Günlük Görevler")
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                Text(todayDateString)
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
                        
                        // Summary chips
                        HStack(spacing: 12) {
                            SummaryChip(
                                icon: "checkmark.circle.fill",
                                value: "\(vm.completedTasksToday)/\(vm.dailyTasks.count)",
                                label: "Görev",
                                color: Color(hex: "#00E5A0")
                            )
                            SummaryChip(
                                icon: "star.fill",
                                value: "+\(vm.totalPointsToday)",
                                label: "Bugün",
                                color: Color(hex: "#FFD700")
                            )
                            SummaryChip(
                                icon: "flame.fill",
                                value: "\(vm.user.currentStreak)",
                                label: "Seri",
                                color: Color(hex: "#FF6B35")
                            )
                        }
                        
                        // Task Cards
                        ForEach(vm.dailyTasks) { task in
                            TaskCard(task: task) {
                                selectedTask = task
                                showTaskDetail = true
                            }
                        }
                        
                        Spacer(minLength: 90)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showTaskDetail) {
                if let task = selectedTask {
                    TaskDetailView(task: task, isPresented: $showTaskDetail)
                        .environmentObject(vm)
                }
            }
        }
    }
    
    var todayDateString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMMM, EEEE"
        return f.string(from: Date())
    }
}

// MARK: - Summary Chip
struct SummaryChip: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 18))
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#8892A4"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#141B2D"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Task Card
struct TaskCard: View {
    let task: DailyTask
    let onTap: () -> Void
    
    @State private var pulse = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(taskColor.opacity(task.isCompleted ? 0.2 : 0.15))
                        .frame(width: 60, height: 60)
                    
                    if task.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "#00E5A0"))
                            .font(.system(size: 28))
                    } else {
                        Image(systemName: task.iconName)
                            .foregroundColor(taskColor)
                            .font(.system(size: 26))
                    }
                }
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(task.title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(task.isCompleted ? Color(hex: "#8892A4") : .white)
                        .strikethrough(task.isCompleted, color: Color(hex: "#8892A4"))
                    
                    Text(task.description)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "#8892A4"))
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        // Points badge
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "#FFD700"))
                            Text("+\(task.points)")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#FFD700"))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color(hex: "#FFD700").opacity(0.1))
                        )
                        
                        // Type badge
                        HStack(spacing: 4) {
                            Image(systemName: typeIcon)
                                .font(.system(size: 10))
                                .foregroundColor(taskColor)
                            Text(typeLabel)
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(taskColor)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(taskColor.opacity(0.1))
                        )
                    }
                }
                
                Spacer()
                
                // Arrow or done
                if task.isCompleted {
                    VStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color(hex: "#00E5A0"))
                            .font(.system(size: 24))
                        Text("Tamam!")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#00E5A0"))
                    }
                } else {
                    Image(systemName: "chevron.right.circle.fill")
                        .foregroundColor(taskColor.opacity(0.6))
                        .font(.system(size: 24))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "#141B2D"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                task.isCompleted
                                ? Color(hex: "#00E5A0").opacity(0.25)
                                : taskColor.opacity(0.2),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: task.isCompleted ? Color(hex: "#00E5A0").opacity(0.08) : taskColor.opacity(0.08), radius: 12)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(task.isCompleted)
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
    
    var typeIcon: String {
        switch task.taskType {
        case .timer: return "timer"
        case .counter: return "hand.tap.fill"
        case .checklist: return "list.bullet.circle"
        }
    }
    
    var typeLabel: String {
        switch task.taskType {
        case .timer: return "Süre Sayacı"
        case .counter: return "Sayım"
        case .checklist: return "Kontrol Listesi"
        }
    }
}
