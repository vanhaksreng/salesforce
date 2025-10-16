import Flutter
import GoogleMaps
import UIKit
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        GeneratedPluginRegistrant.register(with: self)

        GMSServices.provideAPIKey("AIzaSyC3pUau1zh5lLPMEKG8-WanuIKMb8895sg")

        FlutterHtmlToPdfPlugin.register(with: self.registrar(forPlugin: "flutter_html_to_pdf")!)
        MyLocationPlugin.register(
            with: self.registrar(forPlugin: "com.clearviewerp.salesforce/background_service")!)
        WorkmanagerPlugin.registerPeriodicTask(
            withIdentifier: "com.clearviewerp.salesforce.periodic_task",
            frequency: NSNumber(value: 20 * 60)  // 20 minutes (15 min minimum)
        )

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
