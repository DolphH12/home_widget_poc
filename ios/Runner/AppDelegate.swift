import UIKit
import Flutter
import WidgetKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    override func applicationDidBecomeActive(_ application: UIApplication) {
        checkForWidgetUpdate()
    }

    private func checkForWidgetUpdate() {
        let defaults = UserDefaults(suiteName: "group.bancolombia.homeWidgetPoc")
        let needsUpdate = defaults?.bool(forKey: "widgetNeedsUpdate") ?? false

        if needsUpdate {
            print("🔍 [AppDelegate] Detectada solicitud de actualización del widget.")

          if #available(iOS 14.0, *) {
            Task {
              let message = await fetchMessageFromFlutter()
              print("✅ [AppDelegate] Mensaje obtenido de Flutter: \(message)")
              
              defaults?.set(message, forKey: "widgetMessage")
              defaults?.set(false, forKey: "widgetNeedsUpdate")
              defaults?.synchronize()
              
              WidgetCenter.shared.reloadAllTimelines()
            }
          }
        }
    }

    private func fetchMessageFromFlutter() async -> String {
      if #available(iOS 13.0, *) {
        return await withCheckedContinuation { continuation in
          if let controller = window?.rootViewController as? FlutterViewController {
            let channel = FlutterMethodChannel(name: "com.example.home_widget_poc/channel", binaryMessenger: controller.binaryMessenger)
            
            channel.invokeMethod("fetchMessage", arguments: nil) { result in
              if let message = result as? String {
                continuation.resume(returning: message)
              } else {
                continuation.resume(returning: "******")
              }
            }
          } else {
            continuation.resume(returning: "******")
          }
        }
      } else {
        return "******"
      }
    }
}

