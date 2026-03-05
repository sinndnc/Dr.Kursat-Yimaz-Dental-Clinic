import Foundation
import SwiftUI

// MARK: - User Model
struct TemyUser: Codable {
    var name: String
    var totalPoints: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastLoginDate: Date?
    var badges: [Badge]
    var completedTasksCount: Int
    
    static let `default` = TemyUser(
        name: "Kahraman",
        totalPoints: 0,
        currentStreak: 0,
        longestStreak: 0,
        lastLoginDate: nil,
        badges: [],
        completedTasksCount: 0
    )
}

// MARK: - Badge Model
struct Badge: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let iconName: String
    let color: String
    var isUnlocked: Bool
    
    static let allBadges: [Badge] = [
        Badge(id: "first_day", name: "İlk Adım", description: "İlk günlük görevi tamamla", iconName: "star.fill", color: "yellow", isUnlocked: false),
        Badge(id: "streak_3", name: "3 Gün Serisi", description: "3 gün üst üste görev tamamla", iconName: "flame.fill", color: "orange", isUnlocked: false),
        Badge(id: "streak_7", name: "Haftalık Kahraman", description: "7 gün üst üste görev tamamla", iconName: "crown.fill", color: "purple", isUnlocked: false),
        Badge(id: "points_100", name: "100 Puan", description: "100 puana ulaş", iconName: "trophy.fill", color: "gold", isUnlocked: false),
        Badge(id: "all_tasks", name: "Mükemmel Gün", description: "Tüm günlük görevleri tamamla", iconName: "checkmark.seal.fill", color: "green", isUnlocked: false)
    ]
}

// MARK: - Daily Task Model
struct DailyTask: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let color: String
    let points: Int
    let taskType: TaskType
    var isCompleted: Bool
    var completedAt: Date?
    
    enum TaskType: String, Codable {
        case timer       // Süre sayacı ile
        case counter     // Sayım mekanizması ile
        case checklist   // Kontrol listesi ile
    }
    
    // Timer task config
    var timerDuration: Int? // seconds
    
    // Counter task config
    var counterTarget: Int?
    var counterLabel: String?
    
    // Checklist items
    var checklistItems: [ChecklistItem]?
}

struct ChecklistItem: Identifiable, Codable {
    let id: String
    let label: String
    var isChecked: Bool
}

// MARK: - Default Tasks
extension DailyTask {
    static var defaultTasks: [DailyTask] {
        [
            DailyTask(
                id: "morning_brush",
                title: "Sabah Fırçalama",
                description: "Dişlerini en az 2 dakika fırçala!",
                iconName: "sunrise.fill",
                color: "orange",
                points: 30,
                taskType: .timer,
                isCompleted: false,
                completedAt: nil,
                timerDuration: 120,
                counterTarget: nil,
                counterLabel: nil,
                checklistItems: nil
            ),
            DailyTask(
                id: "evening_brush",
                title: "Akşam Fırçalama",
                description: "Yatmadan önce dişlerini fırçala!",
                iconName: "moon.stars.fill",
                color: "indigo",
                points: 30,
                taskType: .timer,
                isCompleted: false,
                completedAt: nil,
                timerDuration: 120,
                counterTarget: nil,
                counterLabel: nil,
                checklistItems: nil
            ),
            DailyTask(
                id: "floss",
                title: "Diş İpi Kullanımı",
                description: "Tüm dişlerin arasını temizle",
                iconName: "arrow.up.and.down.circle.fill",
                color: "pink",
                points: 20,
                taskType: .counter,
                isCompleted: false,
                completedAt: nil,
                timerDuration: nil,
                counterTarget: 5,
                counterLabel: "Diş arası",
                checklistItems: nil
            ),
            DailyTask(
                id: "mouthwash",
                title: "Ağız Çalkalama",
                description: "Ağzını 30 saniye çalkala",
                iconName: "drop.fill",
                color: "cyan",
                points: 15,
                taskType: .timer,
                isCompleted: false,
                completedAt: nil,
                timerDuration: 30,
                counterTarget: nil,
                counterLabel: nil,
                checklistItems: nil
            ),
            DailyTask(
                id: "healthy_food",
                title: "Sağlıklı Beslenme",
                description: "Dişlerini koruyan besinleri ye",
                iconName: "leaf.fill",
                color: "green",
                points: 25,
                taskType: .checklist,
                isCompleted: false,
                completedAt: nil,
                timerDuration: nil,
                counterTarget: nil,
                counterLabel: nil,
                checklistItems: [
                    ChecklistItem(id: "c1", label: "🥛 Süt veya yoğurt içtim", isChecked: false),
                    ChecklistItem(id: "c2", label: "🧀 Peynir yedim", isChecked: false),
                    ChecklistItem(id: "c3", label: "🍎 Meyve/sebze yedim", isChecked: false),
                    ChecklistItem(id: "c4", label: "💧 Bol su içtim", isChecked: false)
                ]
            )
        ]
    }
}
