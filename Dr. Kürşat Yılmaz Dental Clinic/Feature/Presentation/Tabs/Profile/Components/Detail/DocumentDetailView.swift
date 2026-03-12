//
//  DocumentDetailView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/12/26.
//

import SwiftUI

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
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(height: 180)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                    )
                                VStack(spacing: 12) {
                                    Image(systemName: doc.thumbnailSystemImage)
                                        .font(.system(size: 44))
                                    Text(doc.type.rawValue)
                                        .font(.kyMono(12, weight: .semibold))
                                        .tracking(1)
                                }
                            }
                            
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
