import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var biometricAuthService: BiometricAuthService
    @EnvironmentObject var mediaRecordingService: MediaRecordingService
    @State private var showingLocationPermission = false
    @State private var showingPrivacyPolicy = false
    @State private var showingAbout = false
    @State private var showingBiometricAuth = false
    
    var body: some View {
        NavigationView {
            List {
                // Геолокация
                Section("Геолокация") {
                    HStack {
                        Image(systemName: locationManager.isLocationEnabled ? "location.fill" : "location.slash")
                            .foregroundColor(locationManager.isLocationEnabled ? .green : .red)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Статус геолокации")
                                .font(.headline)
                            Text(locationManager.isLocationEnabled ? "Активна" : "Отключена")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(locationManager.isLocationEnabled ? "Отключить" : "Включить") {
                            if locationManager.isLocationEnabled {
                                locationManager.stopLocationUpdates()
                            } else {
                                locationManager.startLocationUpdates()
                            }
                        }
                        .foregroundColor(locationManager.isLocationEnabled ? .red : .blue)
                    }
                    
                    if !locationManager.isLocationEnabled {
                        Button("Запросить разрешение") {
                            showingLocationPermission = true
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                // Биометрическая аутентификация
                if biometricAuthService.isBiometricAvailable {
                    Section("Биометрическая аутентификация") {
                        HStack {
                            Image(systemName: biometricAuthService.getBiometricIcon())
                                .foregroundColor(biometricAuthService.isAuthenticated ? .green : .orange)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(biometricAuthService.getBiometricTypeString())
                                    .font(.headline)
                                Text(biometricAuthService.isAuthenticated ? "Активна" : "Неактивна")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(biometricAuthService.isAuthenticated ? "Отключить" : "Активировать") {
                                if biometricAuthService.isAuthenticated {
                                    biometricAuthService.resetAuthentication()
                                } else {
                                    showingBiometricAuth = true
                                }
                            }
                            .foregroundColor(biometricAuthService.isAuthenticated ? .red : .blue)
                        }
                    }
                }
                
                // Медиа запись
                Section("Медиа запись") {
                    HStack {
                        Image(systemName: mediaRecordingService.audioPermissionGranted ? "mic.fill" : "mic.slash")
                            .foregroundColor(mediaRecordingService.audioPermissionGranted ? .green : .red)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Аудио запись")
                                .font(.headline)
                            Text(mediaRecordingService.audioPermissionGranted ? "Разрешено" : "Запрещено")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if !mediaRecordingService.audioPermissionGranted {
                            Button("Запросить") {
                                mediaRecordingService.checkPermissions()
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    
                    HStack {
                        Image(systemName: mediaRecordingService.videoPermissionGranted ? "video.fill" : "video.slash")
                            .foregroundColor(mediaRecordingService.videoPermissionGranted ? .green : .red)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Видео запись")
                                .font(.headline)
                            Text(mediaRecordingService.videoPermissionGranted ? "Разрешено" : "Запрещено")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if !mediaRecordingService.videoPermissionGranted {
                            Button("Запросить") {
                                mediaRecordingService.checkPermissions()
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                
                // Уведомления
                Section("Уведомления") {
                    NavigationLink(destination: NotificationSettingsView()) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(.orange)
                            Text("Настройки уведомлений")
                        }
                    }
                }
                
                // Безопасность
                Section("Безопасность") {
                    NavigationLink(destination: SecuritySettingsView()) {
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.green)
                            Text("Настройки безопасности")
                        }
                    }
                    
                    NavigationLink(destination: PrivacySettingsView()) {
                        HStack {
                            Image(systemName: "hand.raised")
                                .foregroundColor(.purple)
                            Text("Конфиденциальность")
                        }
                    }
                }
                
                // О приложении
                Section("О приложении") {
                    Button("Политика конфиденциальности") {
                        showingPrivacyPolicy = true
                    }
                    .foregroundColor(.blue)
                    
                    Button("О SafeZone") {
                        showingAbout = true
                    }
                    .foregroundColor(.blue)
                    
                    HStack {
                        Text("Версия")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Поддержка
                Section("Поддержка") {
                    Button("Связаться с поддержкой") {
                        // TODO: Открыть email или чат поддержки
                    }
                    .foregroundColor(.blue)
                    
                    Button("Оценить приложение") {
                        // TODO: Открыть App Store
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Настройки")
            .alert("Разрешение геолокации", isPresented: $showingLocationPermission) {
                Button("Отмена", role: .cancel) { }
                Button("Разрешить") {
                    locationManager.requestLocationPermission()
                }
            } message: {
                Text("SafeZone нужен доступ к геолокации для отправки вашего местоположения доверенным контактам в случае экстренной ситуации.")
            }
            .task {
                if showingBiometricAuth {
                    let success = await biometricAuthService.authenticateUser(reason: "Подтвердите для активации биометрии")
                    if !success {
                        biometricAuthService.resetAuthentication()
                    }
                    showingBiometricAuth = false
                }
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }
}

// MARK: - Notification Settings View
struct NotificationSettingsView: View {
    @State private var sosNotifications = true
    @State private var timerNotifications = true
    @State private var locationUpdates = true
    @State private var soundEnabled = true
    @State private var vibrationEnabled = true
    
    var body: some View {
        Form {
            Section("Типы уведомлений") {
                Toggle("SOS уведомления", isOn: $sosNotifications)
                Toggle("Таймер безопасности", isOn: $timerNotifications)
                Toggle("Обновления локации", isOn: $locationUpdates)
            }
            
            Section("Звук и вибрация") {
                Toggle("Звуковые сигналы", isOn: $soundEnabled)
                Toggle("Вибрация", isOn: $vibrationEnabled)
            }
        }
        .navigationTitle("Уведомления")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Security Settings View
struct SecuritySettingsView: View {
    @State private var biometricAuth = true
    @State private var autoLock = true
    @State private var hideAppIcon = false
    @State private var stealthMode = false
    
    var body: some View {
        Form {
            Section("Аутентификация") {
                Toggle("Face ID / Touch ID", isOn: $biometricAuth)
                Toggle("Автоблокировка", isOn: $autoLock)
            }
            
            Section("Скрытность") {
                Toggle("Скрыть иконку приложения", isOn: $hideAppIcon)
                Toggle("Режим невидимки", isOn: $stealthMode)
            }
        }
        .navigationTitle("Безопасность")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Privacy Settings View
struct PrivacySettingsView: View {
    @State private var shareLocation = true
    @State private var recordAudio = false
    @State private var recordVideo = false
    @State private var autoDelete = true
    @State private var deleteAfterDays = 30
    
    var body: some View {
        Form {
            Section("Данные") {
                Toggle("Делиться локацией", isOn: $shareLocation)
                Toggle("Записывать аудио", isOn: $recordAudio)
                Toggle("Записывать видео", isOn: $recordVideo)
            }
            
            Section("Автоудаление") {
                Toggle("Автоматически удалять", isOn: $autoDelete)
                
                if autoDelete {
                    Picker("Удалять через", selection: $deleteAfterDays) {
                        Text("7 дней").tag(7)
                        Text("30 дней").tag(30)
                        Text("90 дней").tag(90)
                    }
                }
            }
        }
        .navigationTitle("Конфиденциальность")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Политика конфиденциальности")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("SafeZone собирает и обрабатывает ваши данные исключительно для обеспечения вашей безопасности.")
                    
                    Text("Собираемые данные:")
                        .font(.headline)
                    
                    Text("• Геолокация - для отправки доверенным контактам\n• Аудио/видео - только при активации SOS\n• Контакты - только добавленные вами доверенные лица")
                    
                    Text("Данные хранятся локально на устройстве и в зашифрованном виде в облаке.")
                }
                .padding()
            }
            .navigationTitle("Политика конфиденциальности")
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
}

// MARK: - About View
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "shield.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.red)
                
                VStack(spacing: 10) {
                    Text("SafeZone")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Безопасность на расстоянии одного касания")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 8) {
                    Text("Версия 1.0.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("© 2025 SafeZone Team")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("О приложении")
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
}

#Preview {
    SettingsView()
        .environmentObject(LocationManager())
        .environmentObject(BiometricAuthService())
        .environmentObject(MediaRecordingService())
} 