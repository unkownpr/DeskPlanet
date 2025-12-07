import Foundation

// MARK: - License Type
enum LicenseType: String, Codable {
    case free = "free"
    case pro = "pro"
    
    var displayName: String {
        switch self {
        case .free:
            return "license.free".localized
        case .pro:
            return "license.pro".localized
        }
    }
}

// MARK: - License Status
enum LicenseStatus: String, Codable {
    case notActivated = "not_activated"
    case active = "active"
    case expired = "expired"
    case invalid = "invalid"
    
    var displayName: String {
        switch self {
        case .notActivated:
            return "license.status.notActivated".localized
        case .active:
            return "license.status.active".localized
        case .expired:
            return "license.status.expired".localized
        case .invalid:
            return "license.status.invalid".localized
        }
    }
}

// MARK: - License Info
struct LicenseInfo: Codable {
    var type: LicenseType
    var status: LicenseStatus
    var email: String?
    var licenseKey: String?
    var activationDate: Date?
    var expiryDate: Date?
    
    var isActive: Bool {
        return status == .active && type == .pro
    }
    
    var isPro: Bool {
        return type == .pro && status == .active
    }
    
    static var free: LicenseInfo {
        return LicenseInfo(
            type: .free,
            status: .notActivated,
            email: nil,
            licenseKey: nil,
            activationDate: nil,
            expiryDate: nil
        )
    }
}

