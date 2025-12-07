import Foundation

class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
    // MARK: - API Configuration
    struct APIEndpoints {
        var activationURL: String = ""
        var validationURL: String = ""
        var deactivationURL: String = ""
    }
    
    private var endpoints = APIEndpoints()
    
    func configure(activation: String, validation: String, deactivation: String) {
        endpoints.activationURL = activation
        endpoints.validationURL = validation
        endpoints.deactivationURL = deactivation
    }
    
    // MARK: - License Activation
    func activateLicense(email: String, licenseKey: String, completion: @escaping (Result<LicenseResponse, NetworkError>) -> Void) {
        guard !endpoints.activationURL.isEmpty else {
            completion(.failure(.notConfigured))
            return
        }
        
        guard let url = URL(string: endpoints.activationURL) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let parameters: [String: Any] = [
            "email": email,
            "license_key": licenseKey,
            "device_id": getDeviceID()
        ]
        
        performRequest(url: url, method: "POST", parameters: parameters, completion: completion)
    }
    
    // MARK: - License Validation
    func validateLicense(email: String, licenseKey: String, completion: @escaping (Result<LicenseResponse, NetworkError>) -> Void) {
        guard !endpoints.validationURL.isEmpty else {
            completion(.failure(.notConfigured))
            return
        }
        
        guard let url = URL(string: endpoints.validationURL) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let parameters: [String: Any] = [
            "email": email,
            "license_key": licenseKey,
            "device_id": getDeviceID()
        ]
        
        performRequest(url: url, method: "POST", parameters: parameters, completion: completion)
    }
    
    // MARK: - License Deactivation
    func deactivateLicense(email: String, licenseKey: String, completion: @escaping (Result<LicenseResponse, NetworkError>) -> Void) {
        guard !endpoints.deactivationURL.isEmpty else {
            completion(.failure(.notConfigured))
            return
        }
        
        guard let url = URL(string: endpoints.deactivationURL) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let parameters: [String: Any] = [
            "email": email,
            "license_key": licenseKey,
            "device_id": getDeviceID()
        ]
        
        performRequest(url: url, method: "POST", parameters: parameters, completion: completion)
    }
    
    // MARK: - Private Methods
    private func performRequest(url: URL, method: String, parameters: [String: Any], completion: @escaping (Result<LicenseResponse, NetworkError>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            completion(.failure(.encodingError))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                // Handle network error
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    completion(.failure(.connectionError))
                    return
                }
                
                // Check HTTP response
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                // Handle HTTP status codes
                switch httpResponse.statusCode {
                case 200...299:
                    // Success
                    guard let data = data else {
                        completion(.failure(.noData))
                        return
                    }
                    
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let response = try decoder.decode(LicenseResponse.self, from: data)
                        completion(.success(response))
                    } catch {
                        print("Decoding error: \(error)")
                        completion(.failure(.decodingError))
                    }
                    
                case 400:
                    completion(.failure(.badRequest))
                case 401:
                    completion(.failure(.unauthorized))
                case 404:
                    completion(.failure(.notFound))
                case 500...599:
                    completion(.failure(.serverError))
                default:
                    completion(.failure(.unknown))
                }
            }
        }
        
        task.resume()
    }
    
    private func getDeviceID() -> String {
        // Get or create unique device identifier
        let key = "device_identifier"
        
        if let existingID = UserDefaults.standard.string(forKey: key) {
            return existingID
        }
        
        // Create new UUID
        let newID = UUID().uuidString
        UserDefaults.standard.set(newID, forKey: key)
        return newID
    }
}

// MARK: - License Response
struct LicenseResponse: Codable {
    let success: Bool
    let message: String?
    let data: LicenseData?
    
    struct LicenseData: Codable {
        let email: String?
        let licenseKey: String?
        let status: String?
        let expiryDate: String?
        let activationDate: String?
    }
}

// MARK: - Network Errors
enum NetworkError: LocalizedError {
    case notConfigured
    case invalidURL
    case encodingError
    case connectionError
    case invalidResponse
    case noData
    case decodingError
    case badRequest
    case unauthorized
    case notFound
    case serverError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "API endpoints not configured"
        case .invalidURL:
            return "Invalid URL"
        case .encodingError:
            return "Failed to encode request"
        case .connectionError:
            return "license.error.network".localized
        case .invalidResponse:
            return "Invalid server response"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .badRequest:
            return "Bad request"
        case .unauthorized:
            return "license.error.invalidKey".localized
        case .notFound:
            return "License not found"
        case .serverError:
            return "Server error"
        case .unknown:
            return "license.error.unknown".localized
        }
    }
}

