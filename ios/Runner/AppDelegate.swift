import UIKit
import Flutter
import GoogleMaps
import Firebase
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyAR9ywRibffc54PFDNx4G9c_rEaXYm6kQ4")
    GeneratedPluginRegistrant.register(with: self)
      return super.application(application, didFinishLaunchingWithOptions:
        launchOptions)
    //GeneratedPluginRegistrant.register(with: self)
    //return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    override func application(_ application: UIApplication,
     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

      Messaging.messaging().apnsToken = deviceToken
      print("Token: \(deviceToken)")
      super.application(application,
      didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
}
