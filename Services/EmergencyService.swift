import Foundation
import CoreLocation
import Combine

class EmergencyService: ObservableObject {
    @Published var currentEmergency: EmergencyEvent?
    @Published var isEmergencyActive = false
    @Published var emergencyHistory: [EmergencyEvent] = []
    
    private let locationManager: LocationManager
    private var emergencyTimer: Timer?
    private var mediaRecordingService: MediaRecordingService?
    
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }
    
    func setMediaRecordingService(_ service: MediaRecordingService) {
        self.mediaRecordingService = service
    }
    
    // MARK: - Emergency Activation
    
    func activateSOS() {
        let emergency = EmergencyEvent(
            type: .sos,
            timestamp: Date(),
            location: locationManager.getCurrentLocation()?.coordinate,
            isActive: true
        )
        
        startEmergency(emergency)
    }
    
    func activateSafetyTimer(duration: TimeInterval) {
        let emergency = EmergencyEvent(
            type: .safetyTimer,
            timestamp: Date(),
            location: locationManager.getCurrentLocation()?.coordinate,
            duration: duration,
            isActive: true
        )
        
        startEmergency(emergency)
        
        // Запускаем таймер
        emergencyTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.handleSafetyTimerExpired()
        }
    }
    
    func activateManualEmergency() {
        let emergency = EmergencyEvent(
            type: .manual,
            timestamp: Date(),
            location: locationManager.getCurrentLocation()?.coordinate,
            isActive: true
        )
        
        startEmergency(emergency)
    }
    
    private func startEmergency(_ emergency: EmergencyEvent) {
        currentEmergency = emergency
        isEmergencyActive = true
        
        // Уведомляем доверенных контактов
        notifyTrustedContacts(emergency)
        
        // Начинаем запись медиа
        startMediaRecording()
        
        // Добавляем в историю
        emergencyHistory.append(emergency)
    }
    
    func deactivateEmergency() {
        guard let emergency = currentEmergency else { return }
        
        // Останавливаем таймер если есть
        emergencyTimer?.invalidate()
        emergencyTimer = nil
        
        // Останавливаем запись медиа
        stopMediaRecording()
        
        // Обновляем событие
        var updatedEmergency = emergency
        updatedEmergency.isActive = false
        updatedEmergency.duration = Date().timeIntervalSince(emergency.timestamp)
        
        // Обновляем в истории
        if let index = emergencyHistory.firstIndex(where: { $0.id == emergency.id }) {
            emergencyHistory[index] = updatedEmergency
        }
        
        currentEmergency = nil
        isEmergencyActive = false
    }
    
    private func handleSafetyTimerExpired() {
        // Если таймер истек и пользователь не отключил его, активируем SOS
        if isEmergencyActive, let emergency = currentEmergency, emergency.type == .safetyTimer {
            activateSOS()
        }
    }
    
    // MARK: - Contact Notification
    
    private func notifyTrustedContacts(_ emergency: EmergencyEvent) {
        // TODO: Реализовать отправку уведомлений доверенным контактам
        print("Уведомляем доверенных контактов о событии: \(emergency.type.displayName)")
    }
    
    // MARK: - Media Recording
    
    private func startMediaRecording() {
        mediaRecordingService?.startEmergencyRecording()
        print("Начинаем запись медиа")
    }
    
    private func stopMediaRecording() {
        mediaRecordingService?.stopEmergencyRecording()
        print("Останавливаем запись медиа")
    }
    
    // MARK: - Emergency History
    
    func getEmergencyHistory() -> [EmergencyEvent] {
        return emergencyHistory.sorted { $0.timestamp > $1.timestamp }
    }
    
    func clearEmergencyHistory() {
        emergencyHistory.removeAll()
    }
} 