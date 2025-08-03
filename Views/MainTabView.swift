import SwiftUI

struct MainTabView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var emergencyService: EmergencyService
    @StateObject private var biometricAuthService = BiometricAuthService()
    @StateObject private var mediaRecordingService = MediaRecordingService()
    
    init() {
        let locationManager = LocationManager()
        self._locationManager = StateObject(wrappedValue: locationManager)
        self._emergencyService = StateObject(wrappedValue: EmergencyService(locationManager: locationManager))
    }
    
    var body: some View {
        TabView {
            HomeView()
                .environmentObject(locationManager)
                .environmentObject(emergencyService)
                .environmentObject(biometricAuthService)
                .environmentObject(mediaRecordingService)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Главная")
                }
            
            MapView()
                .environmentObject(locationManager)
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Карта")
                }
            
            ContactsView()
                .environmentObject(locationManager)
                .environmentObject(emergencyService)
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Контакты")
                }
            
            HistoryView()
                .environmentObject(emergencyService)
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("История")
                }
            
            SettingsView()
                .environmentObject(locationManager)
                .environmentObject(biometricAuthService)
                .environmentObject(mediaRecordingService)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Настройки")
                }
        }
        .accentColor(.red)
    }
}

#Preview {
    MainTabView()
} 