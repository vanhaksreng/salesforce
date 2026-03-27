import Flutter
import UIKit
import WebKit

public class FlutterHtmlToPdfPlugin: NSObject, FlutterPlugin {
    var wkWebView: WKWebView!
    var urlObservation: NSKeyValueObservation?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_html_to_pdf", binaryMessenger: registrar.messenger())
        let instance = FlutterHtmlToPdfPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "convertHtmlToPdf":
            guard let args = call.arguments as? [String: Any],
                  let htmlFilePath = args["htmlFilePath"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "htmlFilePath is required", details: nil))
                return
            }

            let viewController: UIViewController
            let keyWindow = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow })

            if let rootVC = keyWindow?.rootViewController {
                viewController = rootVC
            } else if let legacyVC = UIApplication.shared.delegate?.window??.rootViewController {
                viewController = legacyVC
            } else {
                result(FlutterError(code: "NO_ROOT_VC", message: "Could not find root view controller", details: nil))
                return
            }

            // Workaround for issue with rendering PDF images on iOS — WKWebView must be in the view hierarchy
            wkWebView = WKWebView(frame: viewController.view.bounds)
            wkWebView.isHidden = true
            wkWebView.tag = 100
            viewController.view.addSubview(wkWebView)

            let htmlFileContent = FileHelper.getContent(from: htmlFilePath)
            wkWebView.loadHTMLString(htmlFileContent, baseURL: Bundle.main.bundleURL)

            urlObservation = wkWebView.observe(\.isLoading, changeHandler: { [weak self] (webView, _) in
                guard let self = self, !webView.isLoading else { return }
                self.urlObservation = nil // invalidate immediately to prevent multiple firings

                // Workaround for issue with loading local images
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    let convertedFileURL = PDFCreator.create(printFormatter: self.wkWebView.viewPrintFormatter())
                    let convertedFilePath = convertedFileURL.absoluteString.replacingOccurrences(of: "file://", with: "")

                    if let viewWithTag = viewController.view.viewWithTag(100) {
                        viewWithTag.removeFromSuperview()

                        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                            records.forEach { record in
                                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                            }
                        }
                    }

                    self.wkWebView = nil
                    result(convertedFilePath)
                }
            })

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
