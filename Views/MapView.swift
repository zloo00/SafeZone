import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var showingLocationDetails = false
    @State private var selectedLocation: MapLocation?
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: locationAnnotations) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        LocationAnnotationView(location: location) {
                            selectedLocation = location
                            showingLocationDetails = true
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                
                // Кнопка центрирования на пользователе
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: centerOnUser) {
                            Image(systemName: "location.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Карта безопасности")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Детали") {
                        showingLocationDetails = true
                    }
                }
            }
            .onAppear {
                centerOnUser()
            }
            .onChange(of: locationManager.location) { _ in
                centerOnUser()
            }
            .sheet(isPresented: $showingLocationDetails) {
                LocationDetailsView(location: selectedLocation?.coordinate, locationName: selectedLocation?.title)
            }
        }
    }
    
    private var locationAnnotations: [MapLocation] {
        guard let location = locationManager.location else { return [] }
        return [MapLocation(coordinate: location.coordinate, title: "Ваше местоположение", subtitle: locationManager.getLocationString())]
    }
    
    private func centerOnUser() {
        guard let location = locationManager.location else { return }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            region.center = location.coordinate
        }
    }
}

// MARK: - Map Location Model
struct MapLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    let subtitle: String
}

// MARK: - Location Annotation View
struct LocationAnnotationView: View {
    let location: MapLocation
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                Image(systemName: "location.circle.fill")
                    .font(.title)
                    .foregroundColor(.red)
                    .background(Color.white)
                    .clipShape(Circle())
                
                Image(systemName: "triangle.fill")
                    .font(.caption)
                    .foregroundColor(.red)
                    .offset(y: -5)
            }
        }
    }
}

// MARK: - Location Details View
struct LocationDetailsView: View {
    let location: CLLocationCoordinate2D?
    let locationName: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let location = location {
                    VStack(spacing: 15) {
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text(locationName ?? "Координаты")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Широта:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text(String(format: "%.6f", location.latitude))
                                    .font(.system(.body, design: .monospaced))
                            }
                            
                            HStack {
                                Text("Долгота:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text(String(format: "%.6f", location.longitude))
                                    .font(.system(.body, design: .monospaced))
                            }
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(10)
                        
                        // Кнопки действий
                        VStack(spacing: 10) {
                            Button("Поделиться локацией") {
                                shareLocation(location)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                            
                            Button("Открыть в Картах") {
                                openInMaps(location)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                } else {
                    VStack(spacing: 15) {
                        Image(systemName: "location.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Локация недоступна")
                            .font(.headline)
                        
                        Text("Убедитесь, что геолокация включена в настройках")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Детали локации")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func shareLocation(_ location: CLLocationCoordinate2D) {
        let locationString = "Мое местоположение: \(location.latitude), \(location.longitude)"
        let activityVC = UIActivityViewController(activityItems: [locationString], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func openInMaps(_ location: CLLocationCoordinate2D) {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location))
        mapItem.openInMaps(launchOptions: nil)
    }
}

#Preview {
    MapView()
        .environmentObject(LocationManager())
} 