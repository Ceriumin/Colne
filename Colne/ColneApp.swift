import SwiftUI
import FamilyControls
import BackgroundTasks
import OSLog

@main
struct ColneApp: App {
    let center = AuthorizationCenter.shared
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "App")
    
    init() {
        registerBackgroundTasks()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    do {
                        try await center.requestAuthorization(for: .individual)
                    } catch {
                        logger.error("Failed to get Authorization: \(error)")
                    }
                    
                    // Schedule background refresh when app starts
                    scheduleAppRefresh()
                    
                    // Make sure shield state is correct on app launch
                    ShieldManager.shared.updateShieldState()
                }
                .onChange(of: ScenePhase.active) { _ in
                    // Update shield state when app becomes active
                    ShieldManager.shared.updateShieldState()
                }
                .onDisappear {
                    // Schedule a refresh when app closes
                    scheduleAppRefresh()
                }
        }
    }
    
    private func registerBackgroundTasks() {
        // Register for app refresh
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.baryla.Colne.refresh", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.baryla.Colne.refresh")
        // Run in 15 minutes at minimum
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            logger.debug("Background refresh task scheduled")
        } catch {
            logger.error("Could not schedule app refresh: \(error.localizedDescription)")
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        // Schedule the next refresh
        scheduleAppRefresh()
        
        // Create task to update shield state
        let updateTask = Task {
            ShieldManager.shared.updateShieldState()
        }
        
        // Inform system when work is complete
        task.expirationHandler = {
            updateTask.cancel()
        }
        
        // Mark task as complete once the update is done
        Task {
            await updateTask.value
            task.setTaskCompleted(success: true)
        }
    }
}
