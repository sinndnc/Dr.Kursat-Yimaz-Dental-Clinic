import Foundation
import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    @Published var user: TemyUser
    @Published var dailyTasks: [DailyTask]
    @Published var showPointAnimation: Bool = false
    @Published var earnedPoints: Int = 0
    @Published var selectedTab: Int = 0
    @Published var todayLoginBonus: Bool = false
    
    private let userKey = "dentbuddy_user"
    private let tasksKey = "dentbuddy_tasks"
    private let tasksDateKey = "dentbuddy_tasks_date"
    
    init() {
        // Load user
        if let data = UserDefaults.standard.data(forKey: "dentbuddy_user"),
           let saved = try? JSONDecoder().decode(TemyUser.self, from: data) {
            self.user = saved
        } else {
            self.user = TemyUser.default
        }
        
        // Load or reset daily tasks
        let today = Calendar.current.startOfDay(for: Date())
        if let savedDate = UserDefaults.standard.object(forKey: "dentbuddy_tasks_date") as? Date,
           Calendar.current.isDate(savedDate, inSameDayAs: today),
           let data = UserDefaults.standard.data(forKey: "dentbuddy_tasks"),
           let saved = try? JSONDecoder().decode([DailyTask].self, from: data) {
            self.dailyTasks = saved
        } else {
            self.dailyTasks = DailyTask.defaultTasks
            UserDefaults.standard.set(today, forKey: "dentbuddy_tasks_date")
            self.saveTasks()
        }
        
        // Check login streak
        checkDailyLogin()
    }
    
    // MARK: - Login & Streak
    func checkDailyLogin() {
        let today = Calendar.current.startOfDay(for: Date())
        
        guard let lastLogin = user.lastLoginDate else {
            // First login ever
            user.lastLoginDate = today
            user.currentStreak = 1
            awardPoints(10, reason: "İlk Giriş Bonusu! 🎉")
            todayLoginBonus = true
            saveUser()
            return
        }
        
        let lastLoginDay = Calendar.current.startOfDay(for: lastLogin)
        
        if Calendar.current.isDate(lastLoginDay, inSameDayAs: today) {
            // Already logged in today
            return
        }
        
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        if Calendar.current.isDate(lastLoginDay, inSameDayAs: yesterday) {
            // Consecutive day
            user.currentStreak += 1
            if user.currentStreak > user.longestStreak {
                user.longestStreak = user.currentStreak
            }
        } else {
            // Streak broken
            user.currentStreak = 1
        }
        
        user.lastLoginDate = today
        let bonus = min(10 + (user.currentStreak * 2), 50)
        awardPoints(bonus, reason: "\(user.currentStreak) Günlük Seri Bonusu! 🔥")
        todayLoginBonus = true
        checkBadges()
        saveUser()
    }
    
    // MARK: - Task Completion
    func completeTask(_ task: DailyTask) {
        guard let index = dailyTasks.firstIndex(where: { $0.id == task.id }),
              !dailyTasks[index].isCompleted else { return }
        
        dailyTasks[index].isCompleted = true
        dailyTasks[index].completedAt = Date()
        user.completedTasksCount += 1
        
        awardPoints(task.points, reason: "\(task.title) tamamlandı!")
        
        // Check if all tasks done
        if dailyTasks.allSatisfy({ $0.isCompleted }) {
            awardPoints(50, reason: "Tüm görevler tamamlandı! 🏆")
        }
        
        checkBadges()
        saveTasks()
        saveUser()
    }
    
    // MARK: - Points
    func awardPoints(_ points: Int, reason: String) {
        user.totalPoints += points
        earnedPoints = points
        withAnimation {
            showPointAnimation = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                self.showPointAnimation = false
            }
        }
    }
    
    // MARK: - Badges
    func checkBadges() {
        var updated = false
        
        for i in 0..<user.badges.count {
            var badge = user.badges[i]
            if badge.isUnlocked { continue }
            
            switch badge.id {
            case "first_day":
                if user.completedTasksCount >= 1 { badge.isUnlocked = true; updated = true }
            case "streak_3":
                if user.currentStreak >= 3 { badge.isUnlocked = true; updated = true }
            case "streak_7":
                if user.currentStreak >= 7 { badge.isUnlocked = true; updated = true }
            case "points_100":
                if user.totalPoints >= 100 { badge.isUnlocked = true; updated = true }
            case "all_tasks":
                if dailyTasks.allSatisfy({ $0.isCompleted }) { badge.isUnlocked = true; updated = true }
            default: break
            }
            user.badges[i] = badge
        }
        
        // Init badges if empty
        if user.badges.isEmpty {
            user.badges = Badge.allBadges
            checkBadges()
        }
        
        if updated { saveUser() }
    }
    
    var completedTasksToday: Int {
        dailyTasks.filter { $0.isCompleted }.count
    }
    
    var totalPointsToday: Int {
        dailyTasks.filter { $0.isCompleted }.reduce(0) { $0 + $1.points }
    }
    
    var progressToday: Double {
        guard !dailyTasks.isEmpty else { return 0 }
        return Double(completedTasksToday) / Double(dailyTasks.count)
    }
    
    // MARK: - Persistence
    func saveUser() {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userKey)
        }
    }
    
    func saveTasks() {
        if let data = try? JSONEncoder().encode(dailyTasks) {
            UserDefaults.standard.set(data, forKey: tasksKey)
        }
    }
    
    // Init badges on first launch
    func initIfNeeded() {
        if user.badges.isEmpty {
            user.badges = Badge.allBadges
            saveUser()
        }
    }
}
