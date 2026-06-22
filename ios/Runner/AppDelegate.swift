import UIKit
import Flutter
import HiddifyCore
import Network

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let aimaNetworkChannel = "aima/network"
    private let pathMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "aima.network.monitor")
    private var latestPath: NWPath?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        setupFileManager()
        registerHandlers()
        GeneratedPluginRegistrant.register(with: self)
        startNetworkMonitor()
        registerAimaNetworkChannel()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func setupFileManager() {
        try? FileManager.default.createDirectory(
            at: FilePath.workingDirectory,
            withIntermediateDirectories: true
        )
        FileManager.default.changeCurrentDirectoryPath(FilePath.sharedDirectory.path)
    }

    func registerHandlers() {
        MethodHandler.register(with: self.registrar(forPlugin: MethodHandler.name)!)
        PlatformMethodHandler.register(with: self.registrar(forPlugin: PlatformMethodHandler.name)!)
        FileMethodHandler.register(with: self.registrar(forPlugin: FileMethodHandler.name)!)
        StatusEventHandler.register(with: self.registrar(forPlugin: StatusEventHandler.name)!)
        AlertsEventHandler.register(with: self.registrar(forPlugin: AlertsEventHandler.name)!)
    }

    private func startNetworkMonitor() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            self?.latestPath = path
        }
        pathMonitor.start(queue: monitorQueue)
    }

    private func registerAimaNetworkChannel() {
        guard let controller = window?.rootViewController as? FlutterViewController else {
            return
        }

        let channel = FlutterMethodChannel(
            name: aimaNetworkChannel,
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { [weak self] call, result in
            guard call.method == "getNetworkSnapshot" else {
                result(FlutterMethodNotImplemented)
                return
            }

            result(self?.networkSnapshot() ?? [
                "hasNetwork": false,
                "validated": false,
                "captivePortal": false,
                "transport": "none",
                "radioGeneration": "unknown",
                "expensive": false,
                "constrained": false
            ])
        }
    }

    private func networkSnapshot() -> [String: Any] {
        let path = latestPath ?? pathMonitor.currentPath
        let hasNetwork = path.status == .satisfied

        let transport: String
        if !hasNetwork {
            transport = "none"
        } else if path.usesInterfaceType(.wifi) {
            transport = "wifi"
        } else if path.usesInterfaceType(.cellular) {
            transport = "cellular"
        } else if path.usesInterfaceType(.wiredEthernet) {
            transport = "ethernet"
        } else {
            transport = "other"
        }

        return [
            "hasNetwork": hasNetwork,
            "validated": hasNetwork,
            "captivePortal": false,
            "transport": transport,
            "radioGeneration": transport == "cellular" ? "Мобильная сеть" : "unknown",
            "expensive": path.isExpensive,
            "constrained": path.isConstrained
        ]
    }
}
