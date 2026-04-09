import SwiftUI

@MainActor
final class RemoteLogFeatureViewModel: ObservableObject {
    private let overlayCoordinator: OverlayCoordinator
    private let sdkService: ApmSDKServiceProtocol

    init(overlayCoordinator: OverlayCoordinator, sdkService: ApmSDKServiceProtocol) {
        self.overlayCoordinator = overlayCoordinator
        self.sdkService = sdkService
    }

    func captureLogs() {
        sdkService.writeRemoteLogs(
            moduleName: "YourModuleName",
            entries: [
                DemoRemoteLogEntry(level: .error, message: "error message"),
                DemoRemoteLogEntry(level: .warn, message: "warn message"),
                DemoRemoteLogEntry(level: .debug, message: "debug message"),
                DemoRemoteLogEntry(level: .info, message: "info message"),
            ]
        )

        overlayCoordinator.presentGuide(
            title: "日志回捞",
            statusText: "打日志成功",
            guideItems: [
                "在 EMAS 控制台「远程日志」模块，根据当前设备，创建回捞任务",
                "Demo App 切换前后台上报日志",
                "等待1-2分钟，在控制台查看日志",
            ]
        )
    }

    func uploadLogs() {
        sdkService.writeRemoteLogs(
            moduleName: "YourModuleName",
            entries: [DemoRemoteLogEntry(level: .error, message: "主动上报日志内容")]
        )
        sdkService.uploadRemoteLogs(comment: "主动上报 bizComment")

        overlayCoordinator.presentGuide(
            title: "主动上报",
            statusText: "打日志成功",
            guideItems: [
                "等待1-2分钟，在 EMAS 控制台「远程日志」模块查看日志",
            ]
        )
    }
}
