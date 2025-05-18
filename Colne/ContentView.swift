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
        NavigationView {
            Form {
                Section(header: Text("BLOCKING")){
                    ActionButton(icon: "app.badge", iconColor: .blue, label: "Block Apps", action: {showActivityPicker = true})
                }
            }
            .navigationTitle("\(isBlockingEnabled ? "Enabled" : "Disabled")")
        }
        .onAppear {
            updateFromAppData()
        }
        .onChange(of: appData) { oldValue, newValue in
            updateFromAppData()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                updateFromAppData()
            } else if newPhase == .background {
                updateFromAppData()
            }
        }
        .familyActivityPicker(isPresented: $showActivityPicker, selection: $manager.selection)
        .onChange(of: manager.selection) { oldSelection, newSelection in
            manager.selectionDidChange()
            
            if isBlockingEnabled {
                manager.shield()
            }
        }
    }
    
    struct ActionButton: View {
        let icon: String
        let iconColor: Color
        let label: String
        let action: () -> Void
        
        var body: some View{
            Button(action: action){
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(iconColor)
                            .frame(width: 28, height: 28)
                        Image(systemName: icon)
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .padding(.vertical, -2)
                    .padding(.leading, -6)
                    
                    Text(label)
                        .font(.system(size: 17))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 6)
            }
            .buttonStyle(PlainButtonStyle())
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
