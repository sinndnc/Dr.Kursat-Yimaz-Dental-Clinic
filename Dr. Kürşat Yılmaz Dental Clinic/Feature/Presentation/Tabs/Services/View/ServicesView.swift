import SwiftUI


struct ServicesView: View {
    
    @Namespace private var categoryNamespace
    
    @State private var showDetail = false
    @State private var selectedService: DentalService? = nil
    @State private var selectedCategory: ServiceCategory = .restorative
    @State private var headerAppeared = false
    
    private var filteredServices: [DentalService] {
        DentalService.all.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                Color.kyBackground.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // MARK: Header
                        headerSection
                        // MARK: Category Picker
                        categoryPicker
                            .padding(.bottom, 4)
                        
                        // MARK: Service Cards
                        LazyVStack(spacing: 16) {
                            ForEach(Array(filteredServices.enumerated()), id: \.element.id) { index, service in
                                ServiceCard(service: service)
                                    .onTapGesture {
                                        selectedService = service
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                            showDetail = true
                                        }
                                    }
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .bottom).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: selectedCategory)
                        
                        // MARK: CTA Banner
                        appointmentBanner
                            .padding(.horizontal, 20)
                            .padding(.bottom, 100)
                    }
                    .safeAreaPadding(.vertical)
                }
                .ignoresSafeArea()
                
            }
            .ignoresSafeArea()
            .sheet(item: $selectedService) { service in
                ServiceDetailSheet(service: service)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.7)) { headerAppeared = true }
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
                    .opacity(headerAppeared ? 1 : 0)
                    .offset(y: headerAppeared ? 0 : 10)
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
                        selectedCategory = cat
                    }
                } label: {
                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: cat.icon)
                                .font(.system(size: 12, weight: .semibold))
                            Text(cat.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(selectedCategory == cat ? Color.kyAccent : Color.kySubtext)
                        .padding(.vertical, 10)

                        Rectangle()
                            .fill(selectedCategory == cat ? Color.kyAccent : Color.clear)
                            .frame(height: 2)
                            .matchedGeometryEffect(id: "underline", in: categoryNamespace, isSource: selectedCategory == cat)
                    }
                }
                .frame(maxWidth: .infinity)
                .animation(.spring(response: 0.3), value: selectedCategory)
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
                    .font(.system(size: 17, weight: .bold, design: .serif))
                    .foregroundColor(Color.kyBackground)
                Text("Uzman değerlendirme için hemen iletişime geçin.")
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

// MARK: - Service Card

struct ServiceCard: View {
    let service: DentalService
    @State private var isPressed = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .top, spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(service.accentColor.opacity(0.12))
                        .frame(width: 52, height: 52)
                    Image(systemName: service.sfSymbol)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(service.accentColor)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(service.title)
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .foregroundColor(Color.kyText)

                    Text(service.subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(service.accentColor)

                    Text(service.description)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color.kySubtext)
                        .lineSpacing(3)
                        .lineLimit(3)
                        .padding(.top, 2)

                    // Tags
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(service.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 10, weight: .semibold))
                                    .tracking(0.3)
                                    .foregroundColor(service.accentColor.opacity(0.9))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(service.accentColor.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.top, 4)
                }

                Spacer(minLength: 0)
            }
            .padding(18)
            .background(Color.kyCard)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.kyBorder, lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)

            // Badge
            if let badge = service.badgeText {
                Text(badge)
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.5)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(service.accentColor)
                    .clipShape(Capsule())
                    .padding(.top, 14)
                    .padding(.trailing, 14)
            }
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation { isPressed = pressing }
        }, perform: {})
    }
}

// MARK: - Service Detail Sheet

struct ServiceDetailSheet: View {
    let service: DentalService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            Color.kyBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero area
                    ZStack(alignment: .bottomLeading) {
                        // Gradient background
                        service.accentColor
                            .opacity(0.12)
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .overlay(
                                LinearGradient(
                                    colors: [Color.clear, Color.kyBackground],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        VStack(alignment: .leading, spacing: 8) {
                            // Icon large
                            ZStack {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(service.accentColor.opacity(0.18))
                                    .frame(width: 68, height: 68)
                                Image(systemName: service.sfSymbol)
                                    .font(.system(size: 30, weight: .medium))
                                    .foregroundColor(service.accentColor)
                            }

                            Text(service.category.rawValue.uppercased())
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .tracking(2.5)
                                .foregroundColor(service.accentColor)

                            Text(service.title)
                                .font(.system(size: 28, weight: .bold, design: .serif))
                                .foregroundColor(Color.kyText)

                            Text(service.subtitle)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.kySubtext)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }

                    VStack(alignment: .leading, spacing: 24) {
                        // Description
                        Text(service.description)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color.kySubtext)
                            .lineSpacing(5)

                        Divider()
                            .background(Color.kyBorder)

                        // Details
                        ForEach(service.details) { detail in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(detail.heading)
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .tracking(0.5)
                                    .foregroundColor(service.accentColor)

                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(detail.bullets, id: \.self) { bullet in
                                        HStack(alignment: .top, spacing: 10) {
                                            Circle()
                                                .fill(service.accentColor)
                                                .frame(width: 5, height: 5)
                                                .padding(.top, 6)
                                            Text(bullet)
                                                .font(.system(size: 14, weight: .regular))
                                                .foregroundColor(Color.kyText.opacity(0.85))
                                                .lineSpacing(3)
                                        }
                                    }
                                }
                            }
                        }

                        // Tags
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Etiketler")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .tracking(1)
                                .foregroundColor(Color.kySubtext)
                            FlowLayout(tags: service.tags, accentColor: service.accentColor)
                        }

                        // CTA Button
                        Button {
                            // Navigate to appointment
                        } label: {
                            HStack {
                                Spacer()
                                Text("Randevu Al")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color.kyBackground)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color.kyBackground)
                                Spacer()
                            }
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.kyAccent, Color(red: 0.75, green: 0.6, blue: 0.35)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
            }

            // Dismiss handle
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color.kySubtext)
                            .padding(10)
                            .background(Color.kySurface)
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 16)
                }
                Spacer()
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.kyBackground)
    }
}

// MARK: - Flow Layout for Tags

struct FlowLayout: View {
    let tags: [String]
    let accentColor: Color

    var body: some View {
        // Simple wrapping tag layout
        var width = CGFloat.zero
        var height = CGFloat.zero

        return GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                ForEach(tags, id: \.self) { tag in
                    tagView(tag)
                        .alignmentGuide(.leading) { d in
                            if abs(width - d.width) > geo.size.width {
                                width = 0
                                height -= d.height + 8
                            }
                            let result = width
                            if tag == tags.last {
                                width = 0
                            } else {
                                width -= d.width + 8
                            }
                            return result
                        }
                        .alignmentGuide(.top) { _ in
                            let result = height
                            if tag == tags.last { height = 0 }
                            return result
                        }
                }
            }
        }
        .frame(height: CGFloat(((tags.count - 1) / 3 + 1)) * 34)
    }

    @ViewBuilder
    private func tagView(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(accentColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(accentColor.opacity(0.1))
            .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview {
    ServicesView()
        .preferredColorScheme(.dark)
}
