import SwiftUI
import FamilyControls
import ManagedSettings

struct ContentView: View {
    @AppStorage("AppData", store: Repository.suiteUserDefaults)
    var appData: Data = Data()
    
    @StateObject private var manager = ShieldManager.shared
    @State private var showActivityPicker = false
    @State private var isBlockingEnabled = false
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        VStack(spacing: 20) {
            Text("App Blocking Status: \(isBlockingEnabled ? "Enabled" : "Disabled")")
                .font(.headline)
            
            Button(action: {
                showActivityPicker.toggle()
            }) {
                HStack {
                    Image(systemName: "app.badge")
                    Text("Select Apps to Block")
                    Spacer()
                    if !manager.selection.applicationTokens.isEmpty {
                        Text("\(manager.selection.applicationTokens.count) selected")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            }
            
            Text("When blocking is enabled, selected apps will be blocked.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .onAppear {
            updateFromAppData()
        }
        .onChange(of: appData) { newValue in
            updateFromAppData()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                // Update when app becomes active again
                updateFromAppData()
            } else if newPhase == .background {
                // Make sure state is correct before going to background
                updateFromAppData()
            }
        }
        .familyActivityPicker(isPresented: $showActivityPicker, selection: $manager.selection)
        .onChange(of: manager.selection) { _ in
            // When selection changes, update the shield if blocking is enabled
            if isBlockingEnabled {
                manager.shield()
            }
        }
    }
    
    private func updateFromAppData() {
        let decoder = JSONDecoder()
        guard let appDataModel = try? decoder.decode(AppDataModel.self, from: appData) else {
            return
        }
        
        isBlockingEnabled = appDataModel.isBlockingEnabled
        
        if isBlockingEnabled {
            manager.shield()
        } else {
            manager.unshield()
        }
    }
}

#Preview {
    ContentView()
}
