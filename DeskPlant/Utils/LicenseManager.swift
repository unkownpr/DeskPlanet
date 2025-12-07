import Foundation
import SwiftUI

class LicenseManager: ObservableObject {
    static let shared = LicenseManager()
    
    @Published var isLicensed: Bool = false
    @Published var licenseInfo: StoredLicense?
    @Published var lastError: String?
    
    private let licenseKey = "com.ssilistre.deskplant.license"
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    // Free version: Cactus, Monstera, Bamboo
    // Pro version: All 6 plants
    var freePlants: [PlantType] {
        [.cactus, .monstera, .bamboo]
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
