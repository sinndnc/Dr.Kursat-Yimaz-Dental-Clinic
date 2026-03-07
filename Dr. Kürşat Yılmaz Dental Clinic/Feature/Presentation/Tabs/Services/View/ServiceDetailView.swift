//
//  DentalServiceDetailView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//

import SwiftUI

struct ServiceDetailView: View {
    
    let service: DentalService
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var appeared = false
    @State private var heroScale: CGFloat = 1.0
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroSection
                    contentSection
                }
            }
            .ignoresSafeArea()
            
            // Floating dismiss button
            HStack {
                dismissButton
                Spacer()
                badgeChip
            }
            .safeAreaPadding()
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    // MARK: - Hero
    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Gradient background
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            service.accentColor.opacity(0.25),
                            service.accentColor.opacity(0.08),
                            Color.kyBackground
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 300)
                .overlay(
                    // Subtle mesh pattern
                    ZStack {
                        ForEach(0..<6) { i in
                            Circle()
                                .fill(service.accentColor.opacity(0.04))
                                .frame(width: CGFloat(80 + i * 30))
                                .offset(
                                    x: CGFloat([-60, 80, -30, 100, -80, 50][i]),
                                    y: CGFloat([-40, 20, 60, -20, 80, -60][i])
                                )
                                .blur(radius: 20)
                        }
                    }
                )
            
            // Icon + Title
            VStack(alignment: .leading, spacing: 12) {
                // SF Symbol
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(service.accentColor.opacity(0.15))
                        .frame(width: 64, height: 64)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(service.accentColor.opacity(0.3), lineWidth: 1)
                        )
                    Image(systemName: service.sfSymbol)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(service.accentColor)
                }
                .scaleEffect(appeared ? 1 : 0.7)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1), value: appeared)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(service.category.rawValue.uppercased())
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(service.accentColor.opacity(0.8))
                        .tracking(2)

                    Text(service.title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.kyText)
                        .lineLimit(2)

                    Text(service.subtitle)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.kySubtext)
                }
                .offset(y: appeared ? 0 : 12)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)
            }
            .safeAreaPadding(.top)
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
    }

    // MARK: - Content
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 24) {

            // Tags
            tagsRow

            // Description card
            descriptionCard

            // Tab selector
            tabSelector

            // Tab content
            if selectedTab == 0 {
                detailsGrid
            } else {
                whatToExpectSection
            }

            // CTA
            ctaButton

            Spacer(minLength: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }

    // MARK: - Tags
    private var tagsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(service.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(service.accentColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(service.accentColor.opacity(0.1))
                        .clipShape(Capsule())
                        .overlay(Capsule().strokeBorder(service.accentColor.opacity(0.2), lineWidth: 1))
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, -20)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.3), value: appeared)
    }

    // MARK: - Description
    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Hizmet Hakkında", systemImage: "info.circle.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(service.accentColor)

            Text(service.description)
                .font(.system(size: 15))
                .foregroundColor(.kySubtext)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.kyBorder, lineWidth: 1)
        )
        .offset(y: appeared ? 0 : 16)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.35), value: appeared)
    }

    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(["Detaylar", "Süreç"], id: \.self) { tab in
                let index = tab == "Detaylar" ? 0 : 1
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                } label: {
                    Text(tab)
                        .font(.system(size: 14, weight: selectedTab == index ? .semibold : .regular))
                        .foregroundColor(selectedTab == index ? .kyText : .kySubtext)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedTab == index
                            ? service.accentColor.opacity(0.12)
                            : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
        .padding(4)
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.kyBorder, lineWidth: 1)
        )
    }

    // MARK: - Details Grid
    private var detailsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(Array(service.details.enumerated()), id: \.offset) { idx, detail in
                DetailCard(detail: detail, accentColor: service.accentColor)
                    .offset(y: appeared ? 0 : 20)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.1 * Double(idx)), value: appeared)
            }
        }
    }

    // MARK: - What to Expect
    private var whatToExpectSection: some View {
        VStack(spacing: 12) {
            ForEach(Array(service.details.enumerated()), id: \.offset) { idx, detail in
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(service.accentColor.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Text("\(idx + 1)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(service.accentColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(detail.heading)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.kyText)
                    }
                    Spacer()
                }
                .padding(14)
                .background(Color.kyCard)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.kyBorder, lineWidth: 1)
                )
                .offset(y: appeared ? 0 : 16)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.35).delay(0.08 * Double(idx)), value: appeared)
            }
        }
    }

    // MARK: - CTA Button
    private var ctaButton: some View {
        Button {
            // Randevu al aksiyonu
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 16, weight: .semibold))
                Text("Randevu Al")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(Color.kyBackground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                LinearGradient(
                    colors: [Color.kyAccent, Color.kyAccentDark],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.kyAccent.opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .padding(.top, 8)
        .scaleEffect(appeared ? 1 : 0.95)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.5).delay(0.5), value: appeared)
    }

    // MARK: - Dismiss Button
    private var dismissButton: some View {
        Button { dismiss() } label: {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 38, height: 38)
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.kyText)
            }
        }
    }

    // MARK: - Badge
    private var badgeChip: some View {
        Group {
            if let badge = service.badgeText {
                Text(badge)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color.kyBackground)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.kyGreen)
                    .clipShape(Capsule())
            }
        }
    }
}

// MARK: - Detail Card
struct DetailCard: View {
    let detail: ServiceDetail
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: detail.heading)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(accentColor)
                .padding(8)
                .background(accentColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                
            Spacer()
                
            Text(detail.heading)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.kySubtext)
                .lineLimit(2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.kyBorder, lineWidth: 1)
        )
    }
}
