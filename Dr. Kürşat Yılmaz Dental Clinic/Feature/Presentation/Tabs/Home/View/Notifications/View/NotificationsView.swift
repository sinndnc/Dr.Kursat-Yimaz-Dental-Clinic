//
//  NotificationsView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//

import SwiftUI
import Combine


struct NotificationsView: View {
    
    @State private var showClearAlert = false
    @StateObject private var vm: NotificationViewModel = NotificationViewModel()
    
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            
            if vm.isLoading {
                skeletonView
            } else if !vm.isAuthorized {
                pushDisabledView
            } else {
                contentList
            }
        }
        .onAppear { vm.clearBadge() }
        .navigationTitle("Bildirimler")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.kyBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar { toolbarItems }
        .alert("Tüm bildirimler silinsin mi?", isPresented: $showClearAlert) {
            Button("Sil", role: .destructive) { /*deleteAll()*/ }
            Button("Vazgeç", role: .cancel) {}
        } message: {
            Text("Bu işlem geri alınamaz.")
        }
    }
    
    // MARK: - Push Disabled
    
    private var pushDisabledView: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle().fill(Color.kyCard).frame(width: 96, height: 96)
                    .overlay(Circle().strokeBorder(Color.kyBorder, lineWidth: 1))
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 34, weight: .light)).foregroundStyle(Color.kySubtext)
            }
            VStack(spacing: 8) {
                Text("Bildirimler Kapalı")
                    .font(.title3).fontWeight(.semibold).foregroundStyle(Color.kyText)
                Text("Randevu hatırlatmaları ve önemli güncellemeleri almak için bildirimlere izin verin.")
                    .font(.subheadline).foregroundStyle(Color.kySubtext)
                    .multilineTextAlignment(.center).lineSpacing(3)
            }
            Button {
                if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Ayarlara Git")
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(Color.kyBackground)
                    .padding(.horizontal, 24).padding(.vertical, 12)
                    .background(Color.kyAccent).clipShape(Capsule())
            }
            Spacer()
        }
        .padding()
    }
    
//    // MARK: - Content List
    
    private var contentList: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                filterBar
                    .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 6)
                
                if vm.unreadCount > 0 {
                    unreadBanner
                        .padding(.horizontal, 16).padding(.bottom, 10)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                if vm.grouped.isEmpty {
                    emptyStateView
                } else {
                    ForEach(vm.grouped, id: \.group) { section in
                        Section {
                            ForEach(section.items) { item in
                                DentalNotificationRow(
                                    item: item,
                                    onTap:    { markAsRead(item.id) },
                                    onDelete: { delete(item.id) }
                                )
                                .padding(.horizontal, 16).padding(.bottom, 8)
                            }
                        } header: {
                            groupHeader(section.group.rawValue)
                        }
                    }
                }
                Spacer(minLength: 40)
            }
        }
        .scrollIndicators(.hidden)
    }
    
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                KYFilterChip(label: "Tümü", icon: "tray.fill", color: .kyAccent,
                             isSelected: vm.selectedFilter == nil) {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) {
                        vm.selectedFilter = nil
                    }
                }
                ForEach(DentalNotificationCategory.allCases, id: \.self) { cat in
                    KYFilterChip(label: cat.rawValue, icon: cat.icon, color: cat.color,
                                 isSelected: vm.selectedFilter == cat) {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) {
                            vm.selectedFilter = (vm.selectedFilter == cat) ? nil : cat
                        }
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }
    
    
    private var unreadBanner: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().fill(Color.kyAccent.opacity(0.15)).frame(width: 30, height: 30)
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 13, weight: .semibold)).foregroundStyle(Color.kyAccent)
            }
            Text("\(vm.unreadCount) okunmamış bildiriminiz var")
                .font(.subheadline).fontWeight(.medium).foregroundStyle(Color.kyText)
            Spacer()
            Button("Tümünü Oku") { Task { await vm.markAllAsRead() } }
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(Color.kyBackground)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Color.kyAccent).clipShape(Capsule())
        }
        .padding(.horizontal, 12).padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14).fill(Color.kyCard)
                .overlay(RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.kyAccent.opacity(0.25), lineWidth: 1))
        )
    }
    
    // MARK: - Group Header
    
    private func groupHeader(_ title: String) -> some View {
        HStack(spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold)).tracking(1.4).foregroundStyle(Color.kySubtext)
            Rectangle().fill(Color.kyBorder).frame(height: 1)
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(Color.kyBackground)
    }
    
    // MARK: - Skeleton
    
    private var skeletonView: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(0..<6, id: \.self) { _ in KYSkeletonRow().padding(.horizontal, 16) }
            }
            .padding(.top, 16)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle().fill(Color.kyCard).frame(width: 96, height: 96)
                    .overlay(Circle().strokeBorder(Color.kyBorder, lineWidth: 1))
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 34, weight: .light)).foregroundStyle(Color.kySubtext)
            }
            VStack(spacing: 8) {
                Text("Bildirim Yok").font(.title3).fontWeight(.semibold).foregroundStyle(Color.kyText)
                Text("Randevu hatırlatmaları, tedavi sonuçları\nve kampanyalar burada görünecek.")
                    .font(.subheadline).foregroundStyle(Color.kySubtext)
                    .multilineTextAlignment(.center).lineSpacing(3)
            }
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button { Task { await vm.markAllAsRead() } } label: {
                    Label("Tümünü Okundu İşaretle", systemImage: "checkmark.circle")
                }
                .disabled(vm.unreadCount == 0)
                
                Divider()
                
                Button(role: .destructive) { showClearAlert = true } label: {
                    Label("Tümünü Sil", systemImage: "trash")
                }
                .disabled(vm.notifications.isEmpty)
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .symbolRenderingMode(.hierarchical).foregroundStyle(Color.kyAccent)
            }
        }
    }
    
    // MARK: - Actions
    
    private func markAsRead(_ id: String) {
        guard let n = vm.notifications.first(where: { $0.id == id }) else { return }
        Task { await vm.markAsRead(n) }
    }
    
    private func delete(_ id: String) {
        guard let n = vm.notifications.first(where: { $0.id == id }) else { return }
        Task { await vm.delete(n) }
    }
    
    private func deleteAll() {
        let all = vm.notifications
        Task { for n in all { await vm.delete(n) } }
    }
}

