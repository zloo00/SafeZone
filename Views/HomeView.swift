import SwiftUI

struct HomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var emergencyService: EmergencyService
    @EnvironmentObject var biometricAuthService: BiometricAuthService
    @EnvironmentObject var mediaRecordingService: MediaRecordingService
    @State private var showingSafetyTimer = false
    @State private var showingEmergencyAlert = false
    @State private var showingBiometricAuth = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фон
                LinearGradient(
                    gradient: Gradient(colors: [Color.red.opacity(0.1), Color.orange.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Заголовок
                    VStack(spacing: 10) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                        
                        Text("SafeZone")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Безопасность на расстоянии одного касания")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Кнопка SOS
                    VStack(spacing: 20) {
                        if emergencyService.isEmergencyActive {
                            EmergencyActiveView()
                        } else {
                            SOSButton()
                        }
                        
                        // Дополнительные кнопки
                        HStack(spacing: 20) {
                            SafetyTimerButton()
                            ManualEmergencyButton()
                        }
                    }
                    
                    Spacer()
                    
                    // Статус системы
                    VStack(spacing: 10) {
                        LocationStatusView()
                        
                        if mediaRecordingService.isRecording {
                            RecordingStatusView()
                        }
                        
                        if biometricAuthService.isBiometricAvailable {
                            BiometricStatusView()
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingSafetyTimer) {
            SafetyTimerView()
                .environmentObject(emergencyService)
        }
        .alert("Экстренная ситуация", isPresented: $showingEmergencyAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Активировать SOS", role: .destructive) {
                emergencyService.activateSOS()
            }
        } message: {
            Text("Вы уверены, что хотите активировать SOS сигнал? Это уведомит всех доверенных контактов.")
        }
        .onAppear {
            // Устанавливаем связь между сервисами
            emergencyService.setMediaRecordingService(mediaRecordingService)
        }
    }
}

// MARK: - SOS Button
struct SOSButton: View {
    @EnvironmentObject var emergencyService: EmergencyService
    @EnvironmentObject var biometricAuthService: BiometricAuthService
    @State private var showingAlert = false
    @State private var showingBiometricAuth = false
    
    var body: some View {
        Button(action: {
            if biometricAuthService.isBiometricAvailable {
                showingBiometricAuth = true
            } else {
                showingAlert = true
            }
        }) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .shadow(color: .red.opacity(0.3), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 5) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    
                    Text("SOS")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        }
        .scaleEffect(showingAlert ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: showingAlert)
        .alert("Активировать SOS?", isPresented: $showingAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Активировать", role: .destructive) {
                emergencyService.activateSOS()
            }
        } message: {
            Text("Это отправит уведомление всем доверенным контактам с вашим местоположением.")
        }
        .task {
            if showingBiometricAuth {
                let success = await biometricAuthService.authenticateUser(reason: "Подтвердите для активации SOS")
                if success {
                    emergencyService.activateSOS()
                }
                showingBiometricAuth = false
            }
        }
    }
}

// MARK: - Safety Timer Button
struct SafetyTimerButton: View {
    @State private var showingTimer = false
    
    var body: some View {
        Button(action: {
            showingTimer = true
        }) {
            VStack(spacing: 8) {
                Image(systemName: "timer")
                    .font(.system(size: 24))
                    .foregroundColor(.orange)
                
                Text("Таймер")
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(width: 80, height: 80)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
        .sheet(isPresented: $showingTimer) {
            SafetyTimerView()
        }
    }
}

// MARK: - Manual Emergency Button
struct ManualEmergencyButton: View {
    @EnvironmentObject var emergencyService: EmergencyService
    @EnvironmentObject var biometricAuthService: BiometricAuthService
    @State private var showingAlert = false
    @State private var showingBiometricAuth = false
    
    var body: some View {
        Button(action: {
            if biometricAuthService.isBiometricAvailable {
                showingBiometricAuth = true
            } else {
                showingAlert = true
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.red)
                
                Text("Ручная")
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(width: 80, height: 80)
            .background(Color.red.opacity(0.1))
            .cornerRadius(12)
        }
        .alert("Ручная активация", isPresented: $showingAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Активировать", role: .destructive) {
                emergencyService.activateManualEmergency()
            }
        } message: {
            Text("Активировать ручной режим экстренной помощи?")
        }
        .task {
            if showingBiometricAuth {
                let success = await biometricAuthService.authenticateUser(reason: "Подтвердите для ручной активации")
                if success {
                    emergencyService.activateManualEmergency()
                }
                showingBiometricAuth = false
            }
        }
    }
}

// MARK: - Emergency Active View
struct EmergencyActiveView: View {
    @EnvironmentObject var emergencyService: EmergencyService
    @EnvironmentObject var mediaRecordingService: MediaRecordingService
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
                .scaleEffect(1.2)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: emergencyService.isEmergencyActive)
            
            Text("ЭКСТРЕННАЯ СИТУАЦИЯ")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.red)
            
            Text("Доверенные контакты уведомлены")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if mediaRecordingService.isRecording {
                Text("Запись медиа: \(formatDuration(mediaRecordingService.recordingDuration))")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            Button("Остановить", role: .destructive) {
                emergencyService.deactivateEmergency()
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(20)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Location Status View
struct LocationStatusView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        HStack {
            Image(systemName: locationManager.isLocationEnabled ? "location.fill" : "location.slash")
                .foregroundColor(locationManager.isLocationEnabled ? .green : .red)
            
            Text(locationManager.isLocationEnabled ? "Геолокация активна" : "Геолокация отключена")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(20)
    }
}

// MARK: - Recording Status View
struct RecordingStatusView: View {
    @EnvironmentObject var mediaRecordingService: MediaRecordingService
    
    var body: some View {
        HStack {
            Image(systemName: "record.circle")
                .foregroundColor(.red)
                .scaleEffect(1.2)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: mediaRecordingService.isRecording)
            
            Text("Запись медиа: \(formatDuration(mediaRecordingService.recordingDuration))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.red.opacity(0.1))
        .cornerRadius(20)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Biometric Status View
struct BiometricStatusView: View {
    @EnvironmentObject var biometricAuthService: BiometricAuthService
    
    var body: some View {
        HStack {
            Image(systemName: biometricAuthService.getBiometricIcon())
                .foregroundColor(biometricAuthService.isAuthenticated ? .green : .orange)
            
            Text("\(biometricAuthService.getBiometricTypeString()) \(biometricAuthService.isAuthenticated ? "активен" : "неактивен")")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(20)
    }
}

#Preview {
    HomeView()
        .environmentObject(LocationManager())
        .environmentObject(EmergencyService(locationManager: LocationManager()))
        .environmentObject(BiometricAuthService())
        .environmentObject(MediaRecordingService())
} 