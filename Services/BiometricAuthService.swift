import Foundation
import LocalAuthentication
import Combine

class BiometricAuthService: ObservableObject {
    @Published var biometricType: LABiometryType = .none
    @Published var isBiometricAvailable = false
    @Published var isAuthenticated = false
    
    private let context = LAContext()
    
    init() {
        checkBiometricAvailability()
    }
    
    func checkBiometricAvailability() {
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            isBiometricAvailable = true
            biometricType = context.biometryType
        } else {
            isBiometricAvailable = false
            biometricType = .none
            print("Биометрия недоступна: \(error?.localizedDescription ?? "Неизвестная ошибка")")
        }
    }
    
    func authenticateUser(reason: String = "Подтвердите вашу личность для доступа к SafeZone") async -> Bool {
        guard isBiometricAvailable else {
            print("Биометрия недоступна")
            return false
        }
        
        return await withCheckedContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    self.isAuthenticated = success
                    if let error = error {
                        print("Ошибка аутентификации: \(error.localizedDescription)")
                    }
                    continuation.resume(returning: success)
                }
            }
        }
    }
    
    func getBiometricTypeString() -> String {
        switch biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .none:
            return "Недоступно"
        @unknown default:
            return "Неизвестно"
        }
    }
    
    func getBiometricIcon() -> String {
        switch biometricType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .none:
            return "lock"
        @unknown default:
            return "lock"
        }
    }
    
    func resetAuthentication() {
        isAuthenticated = false
    }
} 