import Foundation

struct User: Identifiable, Codable {
    let id = UUID()
    var name: String
    var email: String
    var profileImageURL: String?
    var createdAt: Date
    var lastActiveAt: Date
    
    init(name: String, email: String, profileImageURL: String? = nil) {
        self.name = name
        self.email = email
        self.profileImageURL = profileImageURL
        self.createdAt = Date()
        self.lastActiveAt = Date()
    }
}