import ManagedSettings
import ManagedSettingsUI
import UIKit

@available(iOS 15.0, *)
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        let defaults = UserDefaults(suiteName: "group.com.smartremind.shared")
        let pendingCount = defaults?.integer(forKey: "pendingTaskCount") ?? 0
        let snoozeMins = defaults?.integer(forKey: "snoozeDurationMinutes") ?? 15
        let topCategory = defaults?.string(forKey: "topCategoryName") ?? "Inbox"
        
        return ShieldConfiguration(
            backgroundBlurStyle: .systemThickMaterial,
            backgroundColor: UIColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 0.95),
            icon: UIImage(named: "AppIcon"), // Ensure you add this icon to the extension target assets or use system icon
            title: ShieldConfiguration.Label(
                text: "Finish a task first.",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "You have \(pendingCount) pending items in '\(topCategory)'. Close this app or snooze the reminder.",
                color: UIColor(white: 1.0, alpha: 0.7)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Close app",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor(red: 0.34, green: 0.56, blue: 1.0, alpha: 1.0),
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Skip for \(snoozeMins) mins",
                color: UIColor(red: 0.34, green: 0.56, blue: 1.0, alpha: 1.0)
            )
        )
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        // Fallback for web domains if configured
        return ShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        return ShieldConfiguration()
    }
}
