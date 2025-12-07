import Foundation
import SwiftUI

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

class LicenseManager: ObservableObject {
    static let shared = LicenseManager()
    
    @Published var isLicensed: Bool = false
    @Published var licenseInfo: StoredLicense?
    @Published var lastError: String?
    
    private let licenseKey = "com.ssilistre.deskplant.license"
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    // Free version: Only Cactus
    // Pro version: All 6 plants
    var freePlants: [PlantType] {
        [.cactus]
    }
    
    var isPro: Bool {
        return isLicensed
    }
    
    private init() {
        loadStoredLicense()
    }
    
    // MARK: - Hostname
    private func getHostname() -> String {
        return Host.current().localizedName ?? "Unknown-Mac"
    }
    
    // MARK: - Load Stored License
    private func loadStoredLicense() {
        guard let data = UserDefaults.standard.data(forKey: licenseKey),
              let license = try? decoder.decode(StoredLicense.self, from: data) else {
            isLicensed = false
            licenseInfo = nil
            return
        }
        
        licenseInfo = license
        isLicensed = license.isValid
    }
    
    // MARK: - Save License
    private func saveLicense(_ license: StoredLicense) {
        guard let data = try? encoder.encode(license) else { return }
        UserDefaults.standard.set(data, forKey: licenseKey)
        licenseInfo = license
        isLicensed = true
    }
    
    // MARK: - Clear License
    private func clearLicense() {
        UserDefaults.standard.removeObject(forKey: licenseKey)
        licenseInfo = nil
        isLicensed = false
    }
    
    // MARK: - Activate License
    func activateLicense(key: String, email: String) async throws {
        let hostname = getHostname()
        
        guard let url = URL(string: "\(LemonSqueezyConfig.apiBaseURL)/activate") else {
            throw LicenseError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyParams = [
            "license_key": key,
            "instance_name": hostname
        ]
        
        request.httpBody = bodyParams
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LicenseError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw LicenseError.serverError(httpResponse.statusCode)
        }
        
        let activationResponse = try decoder.decode(LicenseActivationResponse.self, from: data)
        
        // Check for errors
        if let error = activationResponse.error {
            throw LicenseError.apiError(error)
        }
        
        // Validate product and store
        guard activationResponse.meta.storeId == LemonSqueezyConfig.storeId,
              activationResponse.meta.productId == LemonSqueezyConfig.productId else {
            throw LicenseError.invalidProduct
        }
        
        // Validate email
        guard activationResponse.meta.customerEmail.lowercased() == email.lowercased() else {
            throw LicenseError.emailMismatch
        }
        
        // Check if activated successfully
        guard activationResponse.activated else {
            throw LicenseError.activationFailed
        }
        
        // Save license
        let license = StoredLicense(
            key: key,
            email: email,
            instanceId: activationResponse.instance?.id ?? "",
            instanceName: hostname,
            activatedAt: Date()
        )
        
        await MainActor.run {
            saveLicense(license)
            lastError = nil
        }
    }
    
    // MARK: - Validate License
    func validateLicense() async throws {
        guard let license = licenseInfo else {
            throw LicenseError.noLicenseStored
        }
        
        guard let url = URL(string: "\(LemonSqueezyConfig.apiBaseURL)/validate") else {
            throw LicenseError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyParams = [
            "license_key": license.key
        ]
        
        request.httpBody = bodyParams
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LicenseError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw LicenseError.serverError(httpResponse.statusCode)
        }
        
        let validationResponse = try decoder.decode(LicenseValidationResponse.self, from: data)
        
        // Check for errors
        if let error = validationResponse.error {
            throw LicenseError.apiError(error)
        }
        
        // Validate product and store
        guard validationResponse.meta.storeId == LemonSqueezyConfig.storeId,
              validationResponse.meta.productId == LemonSqueezyConfig.productId else {
            throw LicenseError.invalidProduct
        }
        
        // Validate email
        guard validationResponse.meta.customerEmail.lowercased() == license.email.lowercased() else {
            throw LicenseError.emailMismatch
        }
        
        // Check if valid
        guard validationResponse.valid else {
            await MainActor.run {
                clearLicense()
            }
            throw LicenseError.invalidLicense
        }
        
        // Check status
        guard validationResponse.licenseKey.status == "active" else {
            await MainActor.run {
                clearLicense()
            }
            throw LicenseError.licenseNotActive(validationResponse.licenseKey.status)
        }
        
        await MainActor.run {
            isLicensed = true
            lastError = nil
        }
    }
    
    // MARK: - Deactivate License (Local Only)
    func deactivateLicense() {
        clearLicense()
        lastError = nil
    }
    
    // MARK: - Check License on Startup
    func checkLicenseOnStartup() async {
        guard licenseInfo != nil else {
            await MainActor.run {
                isLicensed = false
            }
            return
        }
        
        do {
            try await validateLicense()
        } catch {
            await MainActor.run {
                isLicensed = false
                lastError = error.localizedDescription
            }
        }
    }
    
    // MARK: - Get Available Plants
    func getAvailablePlants() -> [PlantType] {
        if isLicensed {
            return PlantType.allCases
        } else {
            return freePlants
        }
    }
}

// MARK: - License Errors
enum LicenseError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case apiError(String)
    case invalidProduct
    case emailMismatch
    case activationFailed
    case invalidLicense
    case licenseNotActive(String)
    case noLicenseStored
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "license.error.invalidURL".localized
        case .invalidResponse:
            return "license.error.invalidResponse".localized
        case .serverError(let code):
            return String(format: "license.error.serverError".localized, code)
        case .apiError(let message):
            return message
        case .invalidProduct:
            return "license.error.invalidProduct".localized
        case .emailMismatch:
            return "license.error.emailMismatch".localized
        case .activationFailed:
            return "license.error.activationFailed".localized
        case .invalidLicense:
            return "license.error.invalidLicense".localized
        case .licenseNotActive(let status):
            return String(format: "license.error.notActive".localized, status)
        case .noLicenseStored:
            return "license.error.noLicense".localized
        }
    }
}
