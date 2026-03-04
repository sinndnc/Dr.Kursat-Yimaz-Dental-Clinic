import SwiftUI

// MARK: - Services View
struct ServicesView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var selectedService: DentalService? = nil
    private let primaryBlue = Color(red: 0.15, green: 0.45, blue: 0.95)
    
    var displayServices: [DentalService] {
        let list = appState.services.isEmpty ? DentalService.sampleData : appState.services
        if searchText.isEmpty { return list }
        return list.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                    TextField("Hizmet ara...", text: $searchText).font(.system(size: 15))
                }
                .padding(14).background(Color.white).cornerRadius(14)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 16)
                
                if appState.isLoadingData {
                    Spacer(); ProgressView("Hizmetler yükleniyor..."); Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                            ForEach(displayServices) { service in
                                Button(action: { selectedService = service }) { serviceCard(service: service) }
                                    .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20).padding(.bottom, 100)
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Hizmetler")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedService) { service in ServiceDetailView(service: service) }
    }
    
    func serviceCard(service: DentalService) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20).fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
            Circle().fill(service.color.opacity(0.06)).frame(width: 100).offset(x: 60, y: -30)
            
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(service.color.opacity(0.12)).frame(width: 50, height: 50)
                    Image(systemName: service.icon).font(.system(size: 22, weight: .semibold)).foregroundColor(service.color)
                }
                Text(service.name).font(.system(size: 15, weight: .bold)).foregroundColor(.primary)
                Text(service.description).font(.system(size: 12)).foregroundColor(.secondary).lineLimit(2)
                HStack {
                    Text(service.price).font(.system(size: 14, weight: .bold)).foregroundColor(service.color)
                    Spacer()
                    Text(service.duration).font(.system(size: 11)).foregroundColor(.secondary)
                        .padding(.horizontal, 8).padding(.vertical, 4).background(Color.gray.opacity(0.1)).cornerRadius(8)
                }
            }
            .padding(16)
        }
    }
}
