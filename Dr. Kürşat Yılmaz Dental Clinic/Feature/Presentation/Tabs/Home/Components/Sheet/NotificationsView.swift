//
//  NotificationsView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import SwiftUI
import Combine

enum DentalNotificationCategory: String, CaseIterable {
    case appointment = "Randevu"
    case reminder    = "Hatırlatma"
    case result      = "Sonuç"
    case payment     = "Ödeme"
    case promotion   = "Kampanya"
    case system      = "Sistem"

    var icon: String {
        switch self {
        case .appointment: return "calendar.badge.clock"
        case .reminder:    return "bell.badge.fill"
        case .result:      return "cross.case.fill"
        case .payment:     return "creditcard.fill"
        case .promotion:   return "gift.fill"
        case .system:      return "gearshape.fill"
        }
    }

    var color: Color {
        switch self {
        case .appointment: return .kyBlue
        case .reminder:    return .kyOrange
        case .result:      return .kyGreen
        case .payment:     return .kyAccent
        case .promotion:   return .kyPurple
        case .system:      return .kySubtext
        }
    }
}

enum NotificationTimeGroup: String {
    case today    = "Bugün"
    case thisWeek = "Bu Hafta"
    case older    = "Daha Önce"
}

struct DentalNotification: Identifiable, Equatable {
    let id: UUID
    var isRead: Bool
    let category: DentalNotificationCategory
    let title: String
    let body: String
    let date: Date
    let actionLabel: String?
    let isUrgent: Bool

    init(
        id: UUID = UUID(),
        isRead: Bool = false,
        category: DentalNotificationCategory,
        title: String,
        body: String,
        date: Date,
        actionLabel: String? = nil,
        isUrgent: Bool = false
    ) {
        self.id = id; self.isRead = isRead; self.category = category
        self.title = title; self.body = body; self.date = date
        self.actionLabel = actionLabel; self.isUrgent = isUrgent
    }
}

// MARK: - ViewModel

@MainActor
final class DentalNotificationsViewModel: ObservableObject {
    @Published private(set) var notifications: [DentalNotification] = []
    @Published var isLoading: Bool = false
    @Published var selectedFilter: DentalNotificationCategory? = nil

    var unreadCount: Int { notifications.filter { !$0.isRead }.count }

    var filtered: [DentalNotification] {
        guard let f = selectedFilter else { return notifications }
        return notifications.filter { $0.category == f }
    }

    var grouped: [(group: NotificationTimeGroup, items: [DentalNotification])] {
        let now        = Date()
        let todayStart = Calendar.current.startOfDay(for: now)
        let weekStart  = Calendar.current.date(byAdding: .day, value: -7, to: todayStart)!

        let todayItems = filtered.filter { $0.date >= todayStart }
        let weekItems  = filtered.filter { $0.date >= weekStart && $0.date < todayStart }
        let oldItems   = filtered.filter { $0.date < weekStart }

        var result: [(NotificationTimeGroup, [DentalNotification])] = []
        if !todayItems.isEmpty { result.append((.today,    todayItems)) }
        if !weekItems.isEmpty  { result.append((.thisWeek, weekItems))  }
        if !oldItems.isEmpty   { result.append((.older,    oldItems))   }
        return result
    }

    func markAsRead(_ id: UUID) {
        guard let i = notifications.firstIndex(where: { $0.id == id }) else { return }
        withAnimation(.easeInOut(duration: 0.2)) { notifications[i].isRead = true }
    }

    func markAllAsRead() {
        withAnimation(.easeInOut(duration: 0.3)) {
            for i in notifications.indices { notifications[i].isRead = true }
        }
    }

    func delete(_ id: UUID) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            notifications.removeAll { $0.id == id }
        }
    }

    func deleteAll() {
        withAnimation(.spring(response: 0.4)) { notifications.removeAll() }
    }

    func load() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            guard let self else { return }
            withAnimation { self.isLoading = false }
            self.notifications = Self.mockData()
        }
    }

    private static func mockData() -> [DentalNotification] {
        let now = Date()
        func ago(_ min: Double) -> Date { now.addingTimeInterval(-min * 60) }
        return [
            DentalNotification(
                isRead: false, category: .reminder,
                title: "Yarınki Randevunuzu Unutmayın",
                body: "Yarın saat 14:30'da Dr. Selin Arslan ile ortodonti kontrolü randevunuz bulunuyor.",
                date: ago(20), actionLabel: "Randevuyu Gör", isUrgent: true),

            DentalNotification(
                isRead: false, category: .appointment,
                title: "Randevunuz Onaylandı",
                body: "3 Nisan Perşembe 10:00 — Diş taşı temizliği randevunuz doktor tarafından onaylandı.",
                date: ago(95), actionLabel: "Takvime Ekle"),

            DentalNotification(
                isRead: false, category: .result,
                title: "Röntgen Sonuçlarınız Hazır",
                body: "Panoramik röntgen görüntüleriniz sisteme yüklendi. Hekiminiz inceleme notunu ekledi.",
                date: ago(210), actionLabel: "Sonuçları İncele"),

            DentalNotification(
                isRead: true, category: .payment,
                title: "Ödeme Başarıyla Alındı",
                body: "₺1.250 tutarındaki implant tedavisi ödemesi alındı. Makbuzunuz e-postanıza iletildi.",
                date: ago(60 * 5)),

            DentalNotification(
                isRead: false, category: .promotion,
                title: "Diş Beyazlatma Kampanyası 🎁",
                body: "Nisan ayına özel beyazlatma tedavisinde %25 indirim kazanın. Son 3 gün!",
                date: ago(60 * 9), actionLabel: "Kampanyayı Gör"),

            DentalNotification(
                isRead: true, category: .reminder,
                title: "6 Aylık Kontrol Zamanı",
                body: "Son muayenenizin üzerinden 6 ay geçti. Periyodik kontrolünüzü planlamanızı öneririz.",
                date: ago(60 * 26), actionLabel: "Randevu Al"),

            DentalNotification(
                isRead: true, category: .appointment,
                title: "Randevu Saati Değişti",
                body: "12 Mart tarihli randevunuz saat 11:00'den 13:30'a alındı. Onaylamak için tıklayın.",
                date: ago(60 * 48), actionLabel: "Onayla", isUrgent: true),

            DentalNotification(
                isRead: true, category: .result,
                title: "Tedavi Planınız Güncellendi",
                body: "Dr. Murat Yıldız kanal tedavisi için yeni bir plan oluşturdu. Detayları inceleyebilirsiniz.",
                date: ago(60 * 72)),

            DentalNotification(
                isRead: true, category: .system,
                title: "Kişisel Bilgiler Güncellendi",
                body: "İletişim bilgileriniz başarıyla güncellendi. Değişiklik size ait değilse bizimle iletişime geçin.",
                date: ago(60 * 120)),

            DentalNotification(
                isRead: true, category: .payment,
                title: "Fatura Kesildi",
                body: "Diş teli 2. seans tedavisi için ₺850 tutarında fatura düzenlendi.",
                date: ago(60 * 168)),
        ]
    }
}

// MARK: - Root View

struct NotificationsView: View {
    @StateObject private var vm = DentalNotificationsViewModel()
    @State private var showClearAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.kyBackground.ignoresSafeArea()

                if vm.isLoading {
                    skeletonView
                } else if vm.grouped.isEmpty {
                    emptyStateView
                } else {
                    contentList
                }
            }
            .navigationTitle("Bildirimler")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.kyBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar { toolbarItems }
            .alert("Tüm bildirimler silinsin mi?", isPresented: $showClearAlert) {
                Button("Sil", role: .destructive) { vm.deleteAll() }
                Button("Vazgeç", role: .cancel) {}
            } message: {
                Text("Bu işlem geri alınamaz.")
            }
        }
        .preferredColorScheme(.dark)
        .task { vm.load() }
    }

    // MARK: Content List

    private var contentList: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {

                filterBar
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 6)

                if vm.unreadCount > 0 {
                    unreadBanner
                        .padding(.horizontal, 16)
                        .padding(.bottom, 10)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                ForEach(vm.grouped, id: \.group) { section in
                    Section {
                        ForEach(section.items) { item in
                            DentalNotificationRow(
                                item: item,
                                onTap: { vm.markAsRead(item.id) },
                                onDelete: { vm.delete(item.id) }
                            )
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                        }
                    } header: {
                        groupHeader(section.group.rawValue)
                    }
                }

                Spacer(minLength: 40)
            }
        }
        .scrollIndicators(.hidden)
    }

    // MARK: Filter Bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                KYFilterChip(
                    label: "Tümü",
                    icon: "tray.fill",
                    color: .kyAccent,
                    isSelected: vm.selectedFilter == nil
                ) {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) {
                        vm.selectedFilter = nil
                    }
                }
                ForEach(DentalNotificationCategory.allCases, id: \.self) { cat in
                    KYFilterChip(
                        label: cat.rawValue,
                        icon: cat.icon,
                        color: cat.color,
                        isSelected: vm.selectedFilter == cat
                    ) {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) {
                            vm.selectedFilter = (vm.selectedFilter == cat) ? nil : cat
                        }
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: Unread Banner

    private var unreadBanner: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.kyAccent.opacity(0.15))
                    .frame(width: 30, height: 30)
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.kyAccent)
            }
            Text("\(vm.unreadCount) okunmamış bildiriminiz var")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.kyText)
            Spacer()
            Button("Tümünü Oku") { vm.markAllAsRead() }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.kyBackground)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.kyAccent)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.kyCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.kyAccent.opacity(0.25), lineWidth: 1)
                )
        )
    }

    // MARK: Group Header

    private func groupHeader(_ title: String) -> some View {
        HStack(spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(1.4)
                .foregroundStyle(Color.kySubtext)
            Rectangle()
                .fill(Color.kyBorder)
                .frame(height: 1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.kyBackground)
    }

    // MARK: Skeleton

    private var skeletonView: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(0..<6, id: \.self) { _ in
                    KYSkeletonRow().padding(.horizontal, 16)
                }
            }
            .padding(.top, 16)
        }
    }

    // MARK: Empty State

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.kyCard)
                    .frame(width: 96, height: 96)
                    .overlay(Circle().strokeBorder(Color.kyBorder, lineWidth: 1))
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 34, weight: .light))
                    .foregroundStyle(Color.kySubtext)
            }
            VStack(spacing: 8) {
                Text("Bildirim Yok")
                    .font(.title3).fontWeight(.semibold)
                    .foregroundStyle(Color.kyText)
                Text("Randevu hatırlatmaları, tedavi sonuçları\nve kampanyalar burada görünecek.")
                    .font(.subheadline)
                    .foregroundStyle(Color.kySubtext)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            Spacer()
        }
        .padding()
    }

    // MARK: Toolbar

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {
                    vm.markAllAsRead()
                } label: {
                    Label("Tümünü Okundu İşaretle", systemImage: "checkmark.circle")
                }
                .disabled(vm.unreadCount == 0)

                Divider()

                Button(role: .destructive) {
                    showClearAlert = true
                } label: {
                    Label("Tümünü Sil", systemImage: "trash")
                }
                .disabled(vm.notifications.isEmpty)
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.kyAccent)
            }
        }
    }
}

// MARK: - Notification Row

struct DentalNotificationRow: View {
    let item: DentalNotification
    let onTap: () -> Void
    let onDelete: () -> Void

    @State private var offsetX: CGFloat = 0
    @State private var revealDelete: Bool = false

    private let threshold: CGFloat = -72

    var body: some View {
        ZStack(alignment: .trailing) {
            deleteLayer
            cardLayer
                .offset(x: offsetX)
                .gesture(swipe)
        }
        .clipped()
    }

    private var cardLayer: some View {
        HStack(alignment: .top, spacing: 12) {

            // Unread indicator dot
            Circle()
                .fill(item.isRead ? Color.clear : Color.kyAccent)
                .frame(width: 7, height: 7)
                .padding(.top, 7)
                .animation(.easeInOut(duration: 0.2), value: item.isRead)

            // Category icon badge
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(item.category.color.opacity(0.12))
                    .frame(width: 44, height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(item.category.color.opacity(0.2), lineWidth: 1)
                    )
                Image(systemName: item.category.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(item.category.color)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Title row
                HStack(alignment: .center, spacing: 6) {
                    if item.isUrgent {
                        Text("ÖNEMLİ")
                            .font(.system(size: 9, weight: .black))
                            .tracking(0.8)
                            .foregroundStyle(Color.kyDanger)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.kyDanger.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    Text(item.title)
                        .font(.subheadline)
                        .fontWeight(item.isRead ? .regular : .semibold)
                        .foregroundStyle(item.isRead ? Color.kySubtext : Color.kyText)
                        .lineLimit(1)
                    Spacer(minLength: 4)
                    Text(item.date.kyRelative)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.kySubtext.opacity(0.7))
                }

                // Body
                Text(item.body)
                    .font(.subheadline)
                    .foregroundStyle(Color.kySubtext)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)

                // Action CTA
                if let action = item.actionLabel {
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Text(action)
                                .font(.caption)
                                .fontWeight(.semibold)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundStyle(item.category.color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(item.category.color.opacity(0.1))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(item.category.color.opacity(0.2), lineWidth: 0.5)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 3)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(item.isRead ? Color.kyCard : Color.kyCardElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            item.isRead ? Color.kyBorderSubtle : Color.kyBorder,
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: item.isRead ? .clear : Color.black.opacity(0.3),
                    radius: 10, x: 0, y: 5
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture {
            if revealDelete { resetSwipe(); return }
            if !item.isRead { onTap() }
        }
    }

    private var deleteLayer: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.22)) { offsetX = -500 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) { onDelete() }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 16, weight: .semibold))
                Text("Sil")
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(width: 62, height: 62)
            .background(Color.kyDanger)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .padding(.trailing, 2)
        .opacity(revealDelete ? 1 : 0)
        .scaleEffect(revealDelete ? 1 : 0.72, anchor: .trailing)
        .animation(.spring(response: 0.28, dampingFraction: 0.72), value: revealDelete)
    }

    private var swipe: some Gesture {
        DragGesture(minimumDistance: 18, coordinateSpace: .local)
            .onChanged { v in
                let x = v.translation.width
                guard x < 0 else {
                    if revealDelete { resetSwipe() }
                    return
                }
                offsetX = max(x, threshold * 1.25)
                revealDelete = offsetX <= threshold * 0.45
            }
            .onEnded { v in
                if v.translation.width < threshold {
                    withAnimation(.spring(response: 0.33, dampingFraction: 0.8)) {
                        offsetX = threshold; revealDelete = true
                    }
                } else { resetSwipe() }
            }
    }

    private func resetSwipe() {
        withAnimation(.spring(response: 0.33, dampingFraction: 0.8)) {
            offsetX = 0; revealDelete = false
        }
    }
}

// MARK: - Filter Chip

struct KYFilterChip: View {
    let label: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(label)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundStyle(isSelected ? Color.kyBackground : Color.kySubtext)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Capsule().fill(isSelected ? color : Color.kyCard))
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? Color.clear : Color.kyBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.22), value: isSelected)
    }
}

// MARK: - Skeleton Row

struct KYSkeletonRow: View {
    @State private var phase: CGFloat = 0

    private var shimmer: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color.kyCard,         location: phase - 0.3),
                .init(color: Color.kyCardElevated,  location: phase),
                .init(color: Color.kyCard,          location: phase + 0.3),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle().frame(width: 7, height: 7).padding(.top, 7)
            RoundedRectangle(cornerRadius: 12).frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4).frame(height: 12)
                RoundedRectangle(cornerRadius: 4).frame(height: 11).padding(.trailing, 60)
                RoundedRectangle(cornerRadius: 4).frame(height: 11).padding(.trailing, 110)
            }
        }
        .padding(12)
        .foregroundStyle(shimmer)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.kyCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.kyBorderSubtle, lineWidth: 1)
                )
        )
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                phase = 1.6
            }
        }
    }
}

#Preview {
    NotificationsView()
}
