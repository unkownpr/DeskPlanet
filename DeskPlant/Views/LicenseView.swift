import SwiftUI

struct LicenseView: View {
    @ObservedObject private var licenseManager = LicenseManager.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var licenseKey: String = ""
    @State private var email: String = ""
    @State private var isActivating: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showSuccess: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("license.title".localized)
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            
            Divider()
            
            ScrollView {
                VStack(spacing: 20) {
                    if licenseManager.isLicensed, let info = licenseManager.licenseInfo {
                        // Licensed View
                        licensedView(info: info)
                    } else {
                        // Activation View
                        activationView
                    }
                }
                .padding()
            }
        }
        .frame(width: 500, height: 400)
        .background(Color(NSColor.windowBackgroundColor))
        .alert("license.error.title".localized, isPresented: $showError) {
            Button("button.ok".localized, role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("license.success.title".localized, isPresented: $showSuccess) {
            Button("button.ok".localized, role: .cancel) {
                dismiss()
            }
        } message: {
            Text("license.success.message".localized)
        }
        .id(localizationManager.currentLanguage)
    }
    
    // MARK: - Licensed View
    private func licensedView(info: StoredLicense) -> some View {
        VStack(spacing: 20) {
            // Success Icon
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("license.activated.title".localized)
                .font(.title3)
                .bold()
            
            // License Info
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(
                    icon: "key.fill",
                    title: "license.field.key".localized,
                    value: maskLicenseKey(info.key)
                )
                
                InfoRow(
                    icon: "envelope.fill",
                    title: "license.field.email".localized,
                    value: info.email
                )
                
                InfoRow(
                    icon: "desktopcomputer",
                    title: "license.field.device".localized,
                    value: info.instanceName
                )
                
                InfoRow(
                    icon: "calendar",
                    title: "license.field.activated".localized,
                    value: formatDate(info.activatedAt)
                )
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            
            Spacer()
            
            // Deactivate Button
            Button(action: deactivate) {
                HStack {
                    Image(systemName: "trash")
                    Text("license.button.deactivate".localized)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
    }
    
    // MARK: - Activation View
    private var activationView: some View {
        VStack(spacing: 20) {
            // Info
            VStack(spacing: 12) {
                Image(systemName: "key.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.accentColor)
                
                Text("license.intro.title".localized)
                    .font(.title3)
                    .bold()
                
                Text("license.intro.description".localized)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            
            // Form
            VStack(alignment: .leading, spacing: 16) {
                // License Key Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("license.field.key".localized)
                        .font(.system(size: 13, weight: .medium))
                    
                    TextField("XXXX-XXXX-XXXX-XXXX", text: $licenseKey)
                        .textFieldStyle(.roundedBorder)
                        .textCase(.uppercase)
                        .autocorrectionDisabled()
                }
                
                // Email Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("license.field.email".localized)
                        .font(.system(size: 13, weight: .medium))
                    
                    TextField("you@example.com", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textCase(.lowercase)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                }
                
                // Help Text
                Text("license.help.text".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            
            Spacer()
            
            // Activate Button
            HStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Text("button.cancel".localized)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button(action: activate) {
                    HStack {
                        if isActivating {
                            ProgressView()
                                .scaleEffect(0.7)
                                .frame(width: 16, height: 16)
                        }
                        Text("license.button.activate".localized)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(licenseKey.isEmpty || email.isEmpty || isActivating)
            }
            
            // Purchase Link
            Link(destination: URL(string: "https://ssilistre.dev/deskplant")!) {
                HStack(spacing: 4) {
                    Image(systemName: "cart")
                    Text("license.link.purchase".localized)
                }
                .font(.caption)
                .foregroundColor(.accentColor)
            }
        }
    }
    
    // MARK: - Actions
    private func activate() {
        isActivating = true
        
        Task {
            do {
                try await licenseManager.activateLicense(
                    key: licenseKey.trimmingCharacters(in: .whitespacesAndNewlines),
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                
                await MainActor.run {
                    isActivating = false
                    showSuccess = true
                    licenseKey = ""
                    email = ""
                }
            } catch {
                await MainActor.run {
                    isActivating = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func deactivate() {
        licenseManager.deactivateLicense()
    }
    
    // MARK: - Helpers
    private func maskLicenseKey(_ key: String) -> String {
        let parts = key.split(separator: "-")
        guard parts.count == 4 else { return key }
        return "\(parts[0])-****-****-\(parts[3])"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(size: 13))
            }
            
            Spacer()
        }
    }
}

#Preview {
    LicenseView()
}

