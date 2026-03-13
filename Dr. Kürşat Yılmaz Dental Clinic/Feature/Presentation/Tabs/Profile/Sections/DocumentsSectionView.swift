//
//  DocumentsSection.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/9/26.
//

import SwiftUI

struct DocumentsSectionView: View {
    @EnvironmentObject private var vm: ProfileViewModel
    @EnvironmentObject private var navState: ProfileNavigationState
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                KYDetailHeader(title: "Belgelerim", subtitle: "\(vm.documents.count) belge")
                ScrollView(showsIndicators: false) {
                    if(vm.documents.isEmpty){
                        KYEmptyState(
                            icon: "document",
                            title: "Döküman Yok",
                            message: "Bu hastaya ait henüz\nbir döküman/belge eklenmemiş."
                        )
                    }else{
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
        }
        .navigationBarHidden(true)
    }
}
