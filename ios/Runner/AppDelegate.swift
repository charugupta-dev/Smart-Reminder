import Flutter
import UIKit
import FamilyControls
import ManagedSettings
import DeviceActivity
import SwiftUI

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    guard let registrar = self.registrar(forPlugin: "SmartRemindAppAlertChannel") else {
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    let channel = FlutterMethodChannel(
        name: "com.smartremind/app_alert",
        binaryMessenger: registrar.messenger()
    )
    
    channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
        switch call.method {
        case "checkPermissions":
            #if targetEnvironment(simulator)
            result([String: Bool]())
            #else
            if #available(iOS 15.0, *) {
                let status = AuthorizationCenter.shared.authorizationStatus
                let allowed = (status == .approved)
                result(["usageStats": allowed, "overlay": allowed])
            } else {
                result([String: Bool]())
            }
            #endif
            
        case "getSettings":
            let defaults = UserDefaults(suiteName: AppUsageShieldSupport.appGroupIdentifier)
            result([
                "alertsEnabled": defaults?.bool(forKey: "alerts_enabled") ?? false,
                "snoozeDuration": defaults?.integer(forKey: "snoozeDurationMinutes") ?? 15,
            ])
            
        case "setSnoozeDuration":
            guard let args = call.arguments as? [String: Any],
                  let minutes = args["minutes"] as? Int else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments for setSnoozeDuration", details: nil))
                return
            }
            let defaults = UserDefaults(suiteName: AppUsageShieldSupport.appGroupIdentifier)
            defaults?.set(minutes, forKey: "snoozeDurationMinutes")
            result(nil)
            
        case "requestAuthorization":
            #if targetEnvironment(simulator)
            result(false)
            #else
            if #available(iOS 15.0, *) {
                let status = AuthorizationCenter.shared.authorizationStatus
                if status == .approved {
                    result(true)
                    return
                }

                if #available(iOS 16.0, *) {
                    Task {
                        do {
                            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                            result(true)
                        } catch {
                            print("Auth error: \(error)")
                            result(false)
                        }
                    }
                } else {
                    AuthorizationCenter.shared.requestAuthorization { authorizationResult in
                        switch authorizationResult {
                        case .success:
                            result(true)
                        case .failure(let error):
                            print("Auth error: \(error)")
                            result(false)
                        }
                    }
                }
            } else {
                result(false)
            }
            #endif
            
        case "showAppPicker":
            #if targetEnvironment(simulator)
            result(FlutterError(code: "UNSUPPORTED", message: "App usage alerts require a real iPhone running iOS 15 or newer.", details: nil))
            #else
            if #available(iOS 15.0, *) {
                self.presentFamilyActivityPicker()
                result(nil)
            } else {
                result(FlutterError(code: "UNSUPPORTED", message: "App usage alerts require iOS 15 or newer.", details: nil))
            }
            #endif
            
        case "startMonitoring":
            let defaults = UserDefaults(suiteName: AppUsageShieldSupport.appGroupIdentifier)
            defaults?.set(true, forKey: "alerts_enabled")
            
            #if targetEnvironment(simulator)
            result(FlutterError(code: "UNSUPPORTED", message: "App usage alerts cannot run in the iOS simulator.", details: nil))
            #else
            if #available(iOS 15.0, *) {
                do {
                    try AppUsageShieldSupport.schedulePrimaryMonitoring()
                    AppUsageShieldSupport.refreshShields(defaults: defaults)
                    result(nil)
                } catch {
                    result(FlutterError(code: "MONITOR_ERROR", message: error.localizedDescription, details: nil))
                }
            } else {
                result(FlutterError(code: "UNSUPPORTED", message: "App usage alerts require iOS 15 or newer.", details: nil))
            }
            #endif
            
        case "stopMonitoring":
            let defaults = UserDefaults(suiteName: AppUsageShieldSupport.appGroupIdentifier)
            defaults?.set(false, forKey: "alerts_enabled")
            
            if #available(iOS 15.0, *) {
                AppUsageShieldSupport.stopAllMonitoringAndClear(defaults: defaults)
            }
            
            result(nil)
            
        case "syncTaskData":
            guard let args = call.arguments as? [String: Any],
                  let pendingCount = args["pendingCount"] as? Int,
                  let topCategory = args["topCategory"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments for syncTaskData", details: nil))
                return
            }
            let defaults = UserDefaults(suiteName: AppUsageShieldSupport.appGroupIdentifier)
            defaults?.set(pendingCount, forKey: "pendingTaskCount")
            defaults?.set(topCategory, forKey: "topCategoryName")

            if #available(iOS 15.0, *) {
                if pendingCount <= 0 {
                    AppUsageShieldSupport.clearSnoozeExpiries(defaults: defaults)
                }
                AppUsageShieldSupport.refreshShields(defaults: defaults)
            }
            result(nil)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func presentFamilyActivityPicker() {
      guard #available(iOS 15.0, *) else {
          return
      }

      Task { @MainActor in
          let status = AuthorizationCenter.shared.authorizationStatus
          if status != .approved {
              if #available(iOS 16.0, *) {
                  do {
                      try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                  } catch {
                      return
                  }
              } else {
                  let granted = await withCheckedContinuation { continuation in
                      AuthorizationCenter.shared.requestAuthorization { authorizationResult in
                          switch authorizationResult {
                          case .success:
                              continuation.resume(returning: true)
                          case .failure:
                              continuation.resume(returning: false)
                          }
                      }
                  }

                  if !granted {
                      return
                  }
              }
          }

          let defaults = AppUsageShieldSupport.sharedDefaults()
          let initialSelection = AppUsageShieldSupport.loadSelection(defaults: defaults) ?? FamilyActivitySelection()
          let pickerView = AppSelectionPickerView(
              initialSelection: initialSelection,
              onSave: { selection in
                  do {
                      try AppUsageShieldSupport.saveSelection(selection, defaults: defaults)
                      if defaults?.bool(forKey: AppUsageShieldSupport.alertsEnabledKey) ?? false {
                          try? AppUsageShieldSupport.schedulePrimaryMonitoring()
                          AppUsageShieldSupport.refreshShields(defaults: defaults)
                      }
                  } catch {
                      return
                  }
              }
          )

          let hostingController = UIHostingController(rootView: pickerView)
          hostingController.modalPresentationStyle = .formSheet
          topViewController()?.present(hostingController, animated: true)
      }
  }

  private func topViewController(base: UIViewController? = nil) -> UIViewController? {
      let baseController: UIViewController? = {
          if let base {
              return base
          }

          return UIApplication.shared.connectedScenes
              .compactMap { $0 as? UIWindowScene }
              .flatMap(\.windows)
              .first { $0.isKeyWindow }?
              .rootViewController
      }()

      if let navigationController = baseController as? UINavigationController {
          return topViewController(base: navigationController.visibleViewController)
      }

      if let tabController = baseController as? UITabBarController,
         let selectedController = tabController.selectedViewController {
          return topViewController(base: selectedController)
      }

      if let presentedController = baseController?.presentedViewController {
          return topViewController(base: presentedController)
      }

      return baseController
  }
}

@available(iOS 15.0, *)
private struct AppSelectionPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selection: FamilyActivitySelection

    let onSave: (FamilyActivitySelection) -> Void

    init(initialSelection: FamilyActivitySelection, onSave: @escaping (FamilyActivitySelection) -> Void) {
        _selection = State(initialValue: initialSelection)
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            FamilyActivityPicker(selection: $selection)
            .navigationTitle("Monitored Apps")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(selection)
                        dismiss()
                    }
                }
            }
        }
    }
}
