//
//  DentalNotificationRow.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import SwiftUI

struct DentalNotificationRow: View {
    let item: DentalNotification
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var offsetX: CGFloat = 0
    @State private var revealDelete     = false
    private let threshold: CGFloat      = -72
    
    var body: some View {
        ZStack(alignment: .trailing) {
            deleteLayer
            cardLayer.offset(x: offsetX).gesture(swipe)
        }
        .clipped()
    }
    
    private var cardLayer: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(item.isRead ? Color.clear : Color.kyAccent)
                .frame(width: 7, height: 7).padding(.top, 7)
                .animation(.easeInOut(duration: 0.2), value: item.isRead)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(item.category.color.opacity(0.12)).frame(width: 44, height: 44)
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(item.category.color.opacity(0.2), lineWidth: 1))
                Image(systemName: item.category.icon)
                    .font(.system(size: 18, weight: .semibold)).foregroundStyle(item.category.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center, spacing: 6) {
                    if item.isUrgent {
                        Text("ÖNEMLİ")
                            .font(.system(size: 9, weight: .black)).tracking(0.8)
                            .foregroundStyle(Color.kyDanger)
                            .padding(.horizontal, 5).padding(.vertical, 2)
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
                        .font(.system(size: 11)).foregroundStyle(Color.kySubtext.opacity(0.7))
                }
                
                Text(item.body)
                    .font(.subheadline).foregroundStyle(Color.kySubtext)
                    .lineLimit(2).fixedSize(horizontal: false, vertical: true).lineSpacing(2)
                
                if let action = item.actionLabel {
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Text(action).font(.caption).fontWeight(.semibold)
                            Image(systemName: "chevron.right").font(.system(size: 9, weight: .bold))
                        }
                        .foregroundStyle(item.category.color)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(item.category.color.opacity(0.1)).clipShape(Capsule())
                        .overlay(Capsule().strokeBorder(item.category.color.opacity(0.2), lineWidth: 0.5))
                    }
                    .buttonStyle(.plain).padding(.top, 3)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(item.isRead ? Color.kyCard : Color.kyCardElevated)
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(item.isRead ? Color.kyBorderSubtle : Color.kyBorder, lineWidth: 1))
                .shadow(color: item.isRead ? .clear : Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
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
                Image(systemName: "trash.fill").font(.system(size: 16, weight: .semibold))
                Text("Sil").font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(.white).frame(width: 62, height: 62)
            .background(Color.kyDanger).clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain).padding(.trailing, 2)
        .opacity(revealDelete ? 1 : 0)
        .scaleEffect(revealDelete ? 1 : 0.72, anchor: .trailing)
        .animation(.spring(response: 0.28, dampingFraction: 0.72), value: revealDelete)
    }
    
    private var swipe: some Gesture {
        DragGesture(minimumDistance: 18, coordinateSpace: .local)
            .onChanged { v in
                let x = v.translation.width
                guard x < 0 else { if revealDelete { resetSwipe() }; return }
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
        withAnimation(.spring(response: 0.33, dampingFraction: 0.8)) { offsetX = 0; revealDelete = false }
    }
}
