//
//  TemyWidget.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import SwiftUI

struct TemyWidget: View {
    
    let geometry : GeometryProxy
    @Binding var isPresented : Bool
    
    @State private var isTaping = false
    @State private var isDragging = false
    @State private var dragOffset = CGSize.zero
    @State private var currentOffset = CGSize(width: 0, height: 100)
    
    private let viewSize = CGSize(width: 75, height: 75)
    
    var body: some View {
        Image("Temy")
            .resizable()
            .scaledToFit()
            .frame(
                width: viewSize.width,
                height: viewSize.height
            )
            .overlay{ Circle().stroke(.gray, lineWidth: 2) }
            .background(isDragging || isTaping ? .white : .gray.opacity(0.2))
            .clipShape(Circle())
            .offset(
                x: currentOffset.width + dragOffset.width,
                y: currentOffset.height + dragOffset.height
            )
            .onTapGesture {
                if isTaping || isDragging { isPresented.toggle() }
                
                withAnimation{ isTaping = true }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation{
                        isTaping = false
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        withAnimation {
                            isDragging = true
                            dragOffset = value.translation
                        }
                    }
                    .onEnded { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isDragging = false
                            }
                        }
                        let finalX = currentOffset.width + dragOffset.width
                        let finalY = currentOffset.height + dragOffset.height
                        
                        withAnimation(.easeOut) {
                            let screenWidth = geometry.size.width
                            let maxX = screenWidth - viewSize.width
                            
                            currentOffset.width = finalX > screenWidth / 2 ? maxX : 0
                            currentOffset.height = finalY.clamped(to: 0...(geometry.size.height - viewSize.height))
                            dragOffset = .zero
                        }
                    }
            )
    }
}

#Preview {
    GeometryReader { geometry in
        TemyWidget(geometry: geometry,isPresented: .constant(.random()))
    }
}
