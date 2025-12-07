import Foundation

// MARK: - LemonSqueezy Configuration
struct LemonSqueezyConfig {
    static let storeId = 53624
    static let productId = 720905
    static let apiBaseURL = "https://api.lemonsqueezy.com/v1/licenses"
}

// MARK: - Activation Response
struct LicenseActivationResponse: Codable {
    let activated: Bool
    let error: String?
    let licenseKey: LicenseKey
    let instance: LicenseInstance?
    let meta: LicenseMeta
    
    enum CodingKeys: String, CodingKey {
        case activated, error
        case licenseKey = "license_key"
        case instance, meta
    }
}

// MARK: - Validation Response
struct LicenseValidationResponse: Codable {
    let valid: Bool
    let error: String?
    let licenseKey: LicenseKey
    let instance: LicenseInstance?
    let meta: LicenseMeta
    
    enum CodingKeys: String, CodingKey {
        case valid, error
        case licenseKey = "license_key"
        case instance, meta
    }
}

// MARK: - License Key
struct LicenseKey: Codable {
    let id: Int
    let status: String
    let key: String
    let activationLimit: Int
    let activationUsage: Int
    let createdAt: String
    let expiresAt: String?
    let testMode: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, status, key
        case activationLimit = "activation_limit"
        case activationUsage = "activation_usage"
        case createdAt = "created_at"
        case expiresAt = "expires_at"
        case testMode = "test_mode"
    }
}

// MARK: - License Instance
struct LicenseInstance: Codable {
    let id: String
    let name: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case createdAt = "created_at"
    }
}

// MARK: - License Meta
struct LicenseMeta: Codable {
    let storeId: Int
    let orderId: Int
    let orderItemId: Int
    let variantId: Int
    let variantName: String
    let productId: Int
    let productName: String
    let customerId: Int
    let customerName: String?
    let customerEmail: String
    
    enum CodingKeys: String, CodingKey {
        case storeId = "store_id"
        case orderId = "order_id"
        case orderItemId = "order_item_id"
        case variantId = "variant_id"
        case variantName = "variant_name"
        case productId = "product_id"
        case productName = "product_name"
        case customerId = "customer_id"
        case customerName = "customer_name"
        case customerEmail = "customer_email"
    }
}

// MARK: - Stored License Info
struct StoredLicense: Codable {
    let key: String
    let email: String
    let instanceId: String
    let instanceName: String
    let activatedAt: Date
    
    var isValid: Bool {
        return !key.isEmpty && !email.isEmpty
    }
}

