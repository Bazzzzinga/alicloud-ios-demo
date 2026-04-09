import Foundation
import AlicloudApmCore
import AlicloudApmCrashAnalysis
import AlicloudApmPerformance
import AlicloudApmRemoteLog
import AlicloudApmMemAlloc
import AlicloudApmMemLeak

struct DemoRecordedError: Equatable {
    let message: String
    let code: Int
    let metadata: [String: String]
}

enum DemoRemoteLogLevel: Equatable {
    case error
    case warn
    case debug
    case info
}

struct DemoRemoteLogEntry: Equatable {
    let level: DemoRemoteLogLevel
    let message: String
}

protocol ApmSDKServiceProtocol: AnyObject {
    var hasStarted: Bool { get }
    var utdid: String { get }
    func setUser(id: String?, nick: String?)
    func recordCustomError(_ error: DemoRecordedError)
    func writeRemoteLogs(moduleName: String, entries: [DemoRemoteLogEntry])
    func uploadRemoteLogs(comment: String)
}

final class ApmSDKService: ApmSDKServiceProtocol {
    var hasStarted: Bool {
        EAPMApm.apm() != nil
    }

    var utdid: String {
        let utdid = EAPMApm.utdid()
        guard !utdid.isEmpty else {
            return "获取失败"
        }
        return utdid
    }

    func setUser(id: String?, nick: String?) {
        EAPMApm.apm()?.setUserId(userId: SettingsStore.normalize(id) ?? "")
        EAPMApm.apm()?.setUserNick(userNick: SettingsStore.normalize(nick) ?? "")
    }

    func recordCustomError(_ error: DemoRecordedError) {
        let crashAnalysis = CrashAnalysis.crashAnalysis()
        error.metadata.forEach { key, value in
            crashAnalysis.setCustomValue(value, forKey: key)
        }

        let nsError = NSError(
            domain: error.message,
            code: error.code,
            userInfo: error.metadata
        )
        crashAnalysis.record(error: nsError, userInfo: error.metadata)
    }

    func writeRemoteLogs(moduleName: String, entries: [DemoRemoteLogEntry]) {
        let logger = RemoteLogFactory.createLog(moduleName: moduleName)
        for entry in entries {
            switch entry.level {
            case .error:
                logger.error(entry.message)
            case .warn:
                logger.warn(entry.message)
            case .debug:
                logger.debug(entry.message)
            case .info:
                logger.info(entry.message)
            }
        }
    }

    func uploadRemoteLogs(comment: String) {
        RemoteLog.uploadTLog(comment)
    }
}
