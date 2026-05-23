import ManagedSettings
import UIKit

@available(iOS 15.0, *)
class ShieldActionExtension: ShieldActionDelegate {
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        let defaults = AppUsageShieldSupport.sharedDefaults()
        let snoozeMins = defaults?.integer(forKey: "snoozeDurationMinutes") ?? 15
        
        switch action {
        case .primaryButtonPressed:
            completionHandler(.close)
            
        case .secondaryButtonPressed:
            AppUsageShieldSupport.setSnoozeExpiry(for: application, minutes: snoozeMins, defaults: defaults)
            AppUsageShieldSupport.refreshShields(defaults: defaults)
            completionHandler(.close)
            
        case .firstSecondarySubmenuItemPressed,
             .secondSecondarySubmenuItemPressed,
             .thirdSecondarySubmenuItemPressed:
            completionHandler(.close)
        }
    }
    
    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        completionHandler(.close)
    }
    
    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            completionHandler(.close)
        case .secondaryButtonPressed:
            completionHandler(.close)
        case .firstSecondarySubmenuItemPressed,
             .secondSecondarySubmenuItemPressed,
             .thirdSecondarySubmenuItemPressed:
            completionHandler(.close)
        }
    }
}
