//
//  ServiceView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

struct ServicesView: View {
    
    @Namespace private var categoryNamespace
    
    @EnvironmentObject private var vm: ServicesViewModel
    @EnvironmentObject private var navState: ServiceNavigationState
    
    var body: some View {
        NavigationStack(path: $navState.path){
            ZStack {
                Color.kyBackground.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // MARK: Header
                        headerSection
                        // MARK: Category Picker
                        categoryPicker
                            .padding(.vertical)
                        
                        // MARK: Service Cards
                        LazyVStack(spacing: 16) {
                            ForEach(Array(vm.filteredServices.enumerated()), id: \.element.id) { index, service in
                                Button{
                                    navState.navigate(to: .serviceDetail(service: service))
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                        vm.showDetail = true
                                    }
                                } label: {
                                    ServiceCard(service: service)
                                }
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .opacity
                                ))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: vm.selectedCategory)
                        
                        // MARK: CTA Banner
                        Button{
                            vm.showAppointment.toggle()
                        }label:{
                            appointmentBanner
                                .padding(.horizontal, 20)
                                .padding(.bottom, 100)
                        }
                    }
                    .safeAreaPadding(.vertical)
                }
                .ignoresSafeArea()
            }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeOut(duration: 0.7)) { vm.headerAppeared = true }
            }
            .sheet(isPresented: $vm.showAppointment){
                BookingView()
            }
            .navigationDestination(for: ServicesDestination.self) { destination in
                switch destination {
                case .serviceDetail(let service):
                    ServiceDetailView(service: service)
                case .serviceCategory(let category):
                    Text("\(category.id)")
//                    ServiceCategoryView(category: category)
                case .bookService(let id):
                    Text("\(id)")
//                    BookServiceView(id: id)
                }
            }
        }
    }
    
    // MARK: Header Section
    private var headerSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Subtle gradient accent top
            LinearGradient(
                colors: [Color.kyAccent.opacity(0.12), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 250)
            .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.kyAccent)
                        .frame(width: 6, height: 6)
                    Text("KY CLINIC")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .tracking(3)
                        .foregroundColor(Color.kyAccent)
                }
                
                Text("Tedavi\nSeçenekleri")
                    .font(.system(size: 38, weight: .bold, design: .serif))
                    .foregroundColor(Color.kyText)
                    .opacity(vm.headerAppeared ? 1 : 0)
                    .offset(y: vm.headerAppeared ? 0 : 10)
                    .lineSpacing(2)
                
                Text("Dijital planlama ile kişiye özel,\nminimal invaziv yaklaşım.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color.kySubtext)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
            .padding(.bottom, 24)
        }
    }
    
    // MARK: Category Picker
    private var categoryPicker: some View {
        HStack(spacing: 0) {
            ForEach(ServiceCategory.allCases) { cat in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        vm.selectedCategory = cat
                    }
                } label: {
                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: cat.icon)
                                .font(.system(size: 12, weight: .semibold))
                            Text(cat.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(vm.selectedCategory == cat ? Color.kyAccent : Color.kySubtext)
                        .padding(.vertical, 10)
                        
                        Rectangle()
                            .fill(vm.selectedCategory == cat ? Color.kyAccent : Color.clear)
                            .frame(height: 2)
                            .matchedGeometryEffect(id: "underline", in: categoryNamespace, isSource: vm.selectedCategory == cat)
                    }
                }
                .frame(maxWidth: .infinity)
                .animation(.spring(response: 0.3), value: vm.selectedCategory)
            }
        }
        .padding(.horizontal, 20)
        .background(
            Rectangle()
                .fill(Color.kyBorder)
                .frame(height: 1),
            alignment: .bottom
        )
    }

    // MARK: Appointment CTA
    private var appointmentBanner: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Randevu Alın")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 17, weight: .bold, design: .serif))
                    .foregroundColor(Color.kyBackground)
                Text("Uzman değerlendirme için hemen iletişime geçin.")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.kyBackground.opacity(0.65))
                    .lineSpacing(2)
            }
            
            Spacer()
            
            Image(systemName: "arrow.right")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.kyBackground)
                .padding(12)
                .background(Color.kyBackground.opacity(0.2))
                .clipShape(Circle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            LinearGradient(
                colors: [Color.kyAccent, Color(red: 0.75, green: 0.6, blue: 0.35)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}


// MARK: - Preview

#Preview {
    ServicesView()
        .preferredColorScheme(.dark)
}
