import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings

enum AppUsageShieldSupport {
    static let appGroupIdentifier = "group.com.smartremind.shared"
    static let alertsEnabledKey = "alerts_enabled"
    static let monitoredAppsKey = "monitoredApps"
    static let pendingTaskCountKey = "pendingTaskCount"
    static let topCategoryNameKey = "topCategoryName"
    static let snoozeDurationMinutesKey = "snoozeDurationMinutes"
    static let snoozeExpiriesKey = "snoozeExpiries"

    @available(iOS 15.0, *)
    static let activityName = DeviceActivityName("SmartRemindActivity")

    @available(iOS 15.0, *)
    static let snoozeActivityName = DeviceActivityName("SmartRemindSnooze")

    static func sharedDefaults() -> UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }

    @available(iOS 15.0, *)
    static func shieldStore() -> ManagedSettingsStore {
        ManagedSettingsStore()
    }

    @available(iOS 15.0, *)
    static func loadSelection(defaults: UserDefaults? = sharedDefaults()) -> FamilyActivitySelection? {
        guard let data = defaults?.data(forKey: monitoredAppsKey) else {
            return nil
        }

        return try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
    }

    @available(iOS 15.0, *)
    static func saveSelection(
        _ selection: FamilyActivitySelection,
        defaults: UserDefaults? = sharedDefaults()
    ) throws {
        var normalizedSelection = selection
        normalizedSelection.categoryTokens.removeAll()
        normalizedSelection.webDomainTokens.removeAll()

        let data = try JSONEncoder().encode(normalizedSelection)
        defaults?.set(data, forKey: monitoredAppsKey)
        clearSnoozeExpiries(defaults: defaults)
    }

    @available(iOS 15.0, *)
    static func tokenKey(for token: ApplicationToken) -> String? {
        guard let data = try? JSONEncoder().encode(token) else {
            return nil
        }

        return data.base64EncodedString()
    }

    static func snoozeExpiries(defaults: UserDefaults? = sharedDefaults()) -> [String: TimeInterval] {
        let rawExpiries = defaults?.dictionary(forKey: snoozeExpiriesKey) ?? [:]
        return rawExpiries.reduce(into: [String: TimeInterval]()) { result, item in
            if let number = item.value as? NSNumber {
                result[item.key] = number.doubleValue
            } else if let value = item.value as? Double {
                result[item.key] = value
            }
        }
    }

    static func saveSnoozeExpiries(
        _ expiries: [String: TimeInterval],
        defaults: UserDefaults? = sharedDefaults()
    ) {
        defaults?.set(expiries, forKey: snoozeExpiriesKey)
    }

    @discardableResult
    @available(iOS 15.0, *)
    static func pruneSnoozeExpiries(
        selection: FamilyActivitySelection? = nil,
        defaults: UserDefaults? = sharedDefaults(),
        now: Date = Date()
    ) -> [String: TimeInterval] {
        let activeSelection = selection ?? loadSelection(defaults: defaults)
        let allowedKeys = Set(activeSelection?.applicationTokens.compactMap { tokenKey(for: $0) } ?? [])
        let cutoff = now.timeIntervalSince1970

        let cleaned = snoozeExpiries(defaults: defaults).filter { key, expiry in
            allowedKeys.contains(key) && expiry > cutoff
        }

        saveSnoozeExpiries(cleaned, defaults: defaults)
        return cleaned
    }

    @available(iOS 15.0, *)
    static func clearSnoozeExpiries(defaults: UserDefaults? = sharedDefaults()) {
        defaults?.removeObject(forKey: snoozeExpiriesKey)
        stopSnoozeMonitoring()
    }

    @available(iOS 15.0, *)
    static func setSnoozeExpiry(
        for token: ApplicationToken,
        minutes: Int,
        defaults: UserDefaults? = sharedDefaults()
    ) {
        guard let key = tokenKey(for: token) else {
            return
        }

        var expiries = snoozeExpiries(defaults: defaults)
        expiries[key] = Date().addingTimeInterval(TimeInterval(minutes * 60)).timeIntervalSince1970
        saveSnoozeExpiries(expiries, defaults: defaults)
    }

    @available(iOS 15.0, *)
    static func activeApplicationTokens(
        selection: FamilyActivitySelection,
        defaults: UserDefaults? = sharedDefaults(),
        now: Date = Date()
    ) -> Set<ApplicationToken> {
        let expiries = pruneSnoozeExpiries(selection: selection, defaults: defaults, now: now)
        let cutoff = now.timeIntervalSince1970

        return Set(selection.applicationTokens.filter { token in
            guard let key = tokenKey(for: token) else {
                return true
            }

            return (expiries[key] ?? 0) <= cutoff
        })
    }

    @available(iOS 15.0, *)
    static func refreshShields(defaults: UserDefaults? = sharedDefaults(), now: Date = Date()) {
        let store = shieldStore()

        guard defaults?.bool(forKey: alertsEnabledKey) ?? false,
              (defaults?.integer(forKey: pendingTaskCountKey) ?? 0) > 0,
              let selection = loadSelection(defaults: defaults),
              !selection.applicationTokens.isEmpty else {
            store.shield.applications = nil
            store.shield.applicationCategories = nil
            stopSnoozeMonitoring()
            return
        }

        let activeApplications = activeApplicationTokens(selection: selection, defaults: defaults, now: now)
        store.shield.applications = activeApplications.isEmpty ? nil : activeApplications
        store.shield.applicationCategories = nil
        scheduleNextSnoozeMonitoring(selection: selection, defaults: defaults, now: now)
    }

    @available(iOS 15.0, *)
    static func schedulePrimaryMonitoring() throws {
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true,
            warningTime: nil
        )

        try DeviceActivityCenter().startMonitoring(activityName, during: schedule)
    }

    @available(iOS 15.0, *)
    static func stopPrimaryMonitoring() {
        DeviceActivityCenter().stopMonitoring([activityName])
    }

    @available(iOS 15.0, *)
    static func stopSnoozeMonitoring() {
        DeviceActivityCenter().stopMonitoring([snoozeActivityName])
    }

    @available(iOS 15.0, *)
    static func stopAllMonitoringAndClear(defaults: UserDefaults? = sharedDefaults()) {
        DeviceActivityCenter().stopMonitoring([activityName, snoozeActivityName])
        clearSnoozeExpiries(defaults: defaults)

        let store = shieldStore()
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }

    @available(iOS 15.0, *)
    static func scheduleNextSnoozeMonitoring(
        selection: FamilyActivitySelection? = nil,
        defaults: UserDefaults? = sharedDefaults(),
        now: Date = Date()
    ) {
        let center = DeviceActivityCenter()
        center.stopMonitoring([snoozeActivityName])

        let activeSelection = selection ?? loadSelection(defaults: defaults)
        guard let activeSelection else {
            return
        }

        let futureExpiries = pruneSnoozeExpiries(selection: activeSelection, defaults: defaults, now: now)
        guard let nextExpiry = futureExpiries.values.min() else {
            return
        }

        let startDate = Date(timeIntervalSince1970: nextExpiry)
        let endDate = startDate.addingTimeInterval(60)
        let calendar = Calendar.current

        let schedule = DeviceActivitySchedule(
            intervalStart: calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: startDate),
            intervalEnd: calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: endDate),
            repeats: false,
            warningTime: nil
        )

        try? center.startMonitoring(snoozeActivityName, during: schedule)
    }
}
