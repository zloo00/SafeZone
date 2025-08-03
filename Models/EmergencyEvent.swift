import Foundation
import CoreLocation

struct EmergencyEvent: Identifiable, Codable {
    let id = UUID()
    var type: EmergencyType
    var timestamp: Date
    var location: CLLocationCoordinate2D?
    var duration: TimeInterval?
    var isActive: Bool
    var contactsNotified: [String] = []
    var mediaRecorded: Bool = false
    var notes: String?
    
    enum EmergencyType: String, CaseIterable, Codable {
        case sos = "SOS"
        case safetyTimer = "Safety Timer"
        case manual = "Manual"
        
        var displayName: String {
            switch self {
            case .sos: return "SOS Сигнал"
            case .safetyTimer: return "Таймер безопасности"
            case .manual: return "Ручная активация"
            }
        }
        
        var icon: String {
            switch self {
            case .sos: return "exclamationmark.triangle.fill"
            case .safetyTimer: return "timer"
            case .manual: return "hand.raised.fill"
            }
        }
    }
}

// MARK: - CoreLocation Extension
extension CLLocationCoordinate2D: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    private enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }
} 