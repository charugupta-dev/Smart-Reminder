import DeviceActivity
import FamilyControls
import ManagedSettings
import Foundation

@available(iOS 15.0, *)
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        AppUsageShieldSupport.refreshShields()
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        if activity == AppUsageShieldSupport.activityName {
            let store = AppUsageShieldSupport.shieldStore()
            store.shield.applications = nil
            store.shield.applicationCategories = nil
        }
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        AppUsageShieldSupport.refreshShields()
    }
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
    }
}
