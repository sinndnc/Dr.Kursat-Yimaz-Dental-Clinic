//
//  DocumentsSection.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/9/26.
//

import SwiftUI

struct DocumentCard: View {
    let document: PatientDocument
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
//                        .fill(document.type.typeColor.opacity(0.12))
                        .frame(height: 72)
                    Image(systemName: document.thumbnailSystemImage)
                        .font(.system(size: 28))
//                        .foregroundColor(document.type.typeColor)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(document.title)
                        .font(.kySans(13, weight: .semibold))
                        .foregroundColor(.kyText)
                        .lineLimit(2)
                    Text(document.date.kyFormatted)
                        .font(.kyMono(10))
                        .foregroundColor(.kySubtext)
                    HStack(spacing: 4) {
                        KYBadge(text: document.type.rawValue, color: .gray)
                        Spacer()
                        Text(document.fileSize)
                            .font(.kyMono(9))
                            .foregroundColor(.kySubtext.opacity(0.6))
                    }
                }
            }
            .padding(12)
            .background(Color.kyCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
struct DocumentsListView: View {
    @EnvironmentObject private var vm: ProfileViewModel
    @EnvironmentObject private var navState: ProfileNavigationState
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                KYDetailHeader(title: "Belgelerim", subtitle: "\(vm.documents.count) belge")
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(vm.documents) { doc in
                            DocumentCard(document: doc) {
                                navState.navigate(to: .documentDetail(id: doc.id.uuidString))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Document Detail

struct DocumentDetailView: View {
    @EnvironmentObject private var vm: ProfileViewModel
    let documentId: String

    var document: PatientDocument? {
        vm.documents.first { $0.id.uuidString == documentId }
    }

    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                KYDetailHeader(title: "Belge Detayı")

                if let doc = document {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Preview area
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
//                                    .fill(doc.type.typeColor.opacity(0.08))
                                    .frame(height: 180)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
//                                            .strokeBorder(doc.type.typeColor.opacity(0.2), lineWidth: 1)
                                    )
                                VStack(spacing: 12) {
                                    Image(systemName: doc.thumbnailSystemImage)
                                        .font(.system(size: 44))
//                                        .foregroundColor(doc.type.typeColor)
                                    Text(doc.type.rawValue)
                                        .font(.kyMono(12, weight: .semibold))
                                        .tracking(1)
//                                        .foregroundColor(doc.type.typeColor)
                                }
                            }

                            // Info
                            KYCard {
                                VStack(spacing: 14) {
                                    KYDetailRow(icon: "doc.fill", label: "Belge Adı", value: doc.title, iconColor: .gray)
                                    KYDivider()
                                    KYDetailRow(icon: "calendar", label: "Tarih", value: doc.date.kyFormatted, iconColor: .kyBlue)
                                    KYDivider()
                                    KYDetailRow(icon: "archivebox.fill", label: "Boyut", value: doc.fileSize, iconColor: .kySubtext)
                                    KYDivider()
                                    KYDetailRow(icon: "tag.fill", label: "Tür", value: doc.type.rawValue, iconColor: .gray)
                                }
                            }

                            // Actions
                            VStack(spacing: 10) {
                                ActionButton(title: "İndir", icon: "arrow.down.circle.fill", color: .kyAccent, style: .filled) {}
                                ActionButton(title: "Paylaş", icon: "square.and.arrow.up", color: .kyBlue, style: .outlined) {}
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}
