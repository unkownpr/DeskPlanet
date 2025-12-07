import SwiftUI

struct LicenseActivationView: View {
    @ObservedObject private var licenseManager = LicenseManager.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var email: String = ""
    @State private var licenseKey: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showSuccess: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "key.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.accentColor)
                
                Text("license.activate".localized)
                    .font(.title2)
                    .bold()
            }
            .padding(.top, 20)
            
            Divider()
            
            // Form
            VStack(alignment: .leading, spacing: 16) {
                // Email field
                VStack(alignment: .leading, spacing: 6) {
                    Text("license.email".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("license.enterEmail".localized, text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(isLoading)
                }
                
                // License key field
                VStack(alignment: .leading, spacing: 6) {
                    Text("license.key".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("license.enterKey".localized, text: $licenseKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(isLoading)
                }
                
                // Error message
                if let errorMessage = errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .padding(.vertical, 8)
                }
                
                // Success message
                if showSuccess {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("license.success".localized)
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Purchase link
            HStack {
                Image(systemName: "cart.fill")
                    .foregroundColor(.accentColor)
                Text("license.purchase.description".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            Button(action: openPurchaseLink) {
                HStack {
                    Image(systemName: "cart.badge.plus")
                    Text("license.purchase.open".localized)
                }
            }
            .buttonStyle(.link)
            
            Divider()
                .padding(.vertical, 8)
            
            // Buttons
            HStack(spacing: 12) {
                Button("license.cancel".localized) {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)
                .frame(width: 100)
                
                Button(action: activateLicense) {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 100)
                    } else {
                        Text("license.activateButton".localized)
                            .frame(width: 100)
                    }
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .disabled(isLoading || email.isEmpty || licenseKey.isEmpty)
            }
            .padding(.bottom, 20)
        }
        .frame(width: 400, height: 350)
        .id(localizationManager.currentLanguage)
    }
    
    private func activateLicense() {
        errorMessage = nil
        isLoading = true
        
        licenseManager.activateLicense(email: email, licenseKey: licenseKey) { result in
            isLoading = false
            
            switch result {
            case .success:
                showSuccess = true
                // Close after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    presentationMode.wrappedValue.dismiss()
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func openPurchaseLink() {
        if let url = URL(string: "https://eshop.ssilistre.dev/buy/5399c73c-21b1-40df-b841-f823d5a20a98") {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - License Info View
struct LicenseInfoView: View {
    @ObservedObject private var licenseManager = LicenseManager.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showDeactivateConfirmation: Bool = false
    @State private var isDeactivating: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: licenseManager.licenseInfo.isPro ? "checkmark.seal.fill" : "lock.fill")
                    .font(.system(size: 50))
                    .foregroundColor(licenseManager.licenseInfo.isPro ? .green : .orange)
                
                Text("license.title".localized)
                    .font(.title2)
                    .bold()
            }
            .padding(.top, 20)
            
            Divider()
            
            // License details
            VStack(alignment: .leading, spacing: 16) {
                InfoRow(title: "license.type".localized, value: licenseManager.licenseInfo.type.displayName)
                InfoRow(title: "license.currentStatus".localized, value: licenseManager.licenseInfo.status.displayName)
                
                if let email = licenseManager.licenseInfo.email {
                    InfoRow(title: "license.email".localized, value: email)
                }
                
                if let activationDate = licenseManager.licenseInfo.activationDate {
                    InfoRow(title: "license.activatedOn".localized, value: formatDate(activationDate))
                }
                
                // Pro features info for free users
                if !licenseManager.licenseInfo.isPro {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("license.features.title".localized)
                            .font(.headline)
                        
                        FeatureRow(icon: "leaf.fill", text: "license.features.allPlants".localized)
                        FeatureRow(icon: "clock.fill", text: "license.features.customTimer".localized)
                        FeatureRow(icon: "chart.bar.fill", text: "license.features.fullStats".localized)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Buttons
            HStack(spacing: 12) {
                Button("license.cancel".localized) {
                    presentationMode.wrappedValue.dismiss()
                }
                .frame(width: 100)
                
                if licenseManager.licenseInfo.isPro {
                    Button("license.deactivate".localized) {
                        showDeactivateConfirmation = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .disabled(isDeactivating)
                    .frame(width: 120)
                } else {
                    Button(action: openPurchaseLink) {
                        HStack {
                            Image(systemName: "cart.fill")
                            Text("license.purchase".localized)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(width: 140)
                }
            }
            .padding(.bottom, 20)
        }
        .frame(width: 400, height: licenseManager.licenseInfo.isPro ? 300 : 450)
        .alert("license.deactivateConfirm".localized, isPresented: $showDeactivateConfirmation) {
            Button("license.cancel".localized, role: .cancel) { }
            Button("license.deactivate".localized, role: .destructive) {
                deactivateLicense()
            }
        }
        .id(localizationManager.currentLanguage)
    }
    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
    
    private func deactivateLicense() {
        isDeactivating = true
        
        licenseManager.deactivateLicense { result in
            isDeactivating = false
            
            switch result {
            case .success:
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                print("Deactivation error: \(error.localizedDescription)")
            }
        }
    }
    
    private func openPurchaseLink() {
        if let url = URL(string: "https://eshop.ssilistre.dev/buy/5399c73c-21b1-40df-b841-f823d5a20a98") {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - Helper Views
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .bold()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 20)
            Text(text)
                .font(.caption)
        }
    }
}

// MARK: - Preview
struct LicenseActivationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LicenseActivationView()
            LicenseInfoView()
        }
    }
}

