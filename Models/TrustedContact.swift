import Foundation
import CoreData

struct TrustedContact: Identifiable, Codable {
    let id = UUID()
    var name: String
    var phoneNumber: String
    var email: String?
    var receivesLocation: Bool = true
    var receivesMedia: Bool = false
    var receivesCall: Bool = false
    var isActive: Bool = true
    var createdAt: Date = Date()
    
    init(name: String, phoneNumber: String, email: String? = nil) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
    }
}

// MARK: - Core Data Extension
extension TrustedContact {
    static func fromManagedObject(_ object: NSManagedObject) -> TrustedContact? {
        guard let name = object.value(forKey: "name") as? String,
              let phoneNumber = object.value(forKey: "phoneNumber") as? String else {
            return nil
        }
        
        var contact = TrustedContact(name: name, phoneNumber: phoneNumber)
        contact.email = object.value(forKey: "email") as? String
        contact.receivesLocation = object.value(forKey: "receivesLocation") as? Bool ?? true
        contact.receivesMedia = object.value(forKey: "receivesMedia") as? Bool ?? false
        contact.receivesCall = object.value(forKey: "receivesCall") as? Bool ?? false
        contact.isActive = object.value(forKey: "isActive") as? Bool ?? true
        contact.createdAt = object.value(forKey: "createdAt") as? Date ?? Date()
        
        return contact
    }
} 