import XCTest
import AlicloudApmCore
@testable import apm_ios_demo_swift

final class SettingsStoreTests: XCTestCase {
    func testSaveTrimsAndLoadsValues() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let store = SettingsStore(defaults: defaults)

        store.save(settings: DemoUserSettings(userId: "  user-1  ", userNick: "  nick-1 \n"))

        XCTAssertEqual(store.loadSettings(), DemoUserSettings(userId: "user-1", userNick: "nick-1"))
    }

    func testSaveRemovesEmptyValues() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let store = SettingsStore(defaults: defaults)

        store.save(settings: DemoUserSettings(userId: " ", userNick: "\n"))

        XCTAssertEqual(store.loadSettings(), DemoUserSettings(userId: "", userNick: ""))
        XCTAssertNil(defaults.string(forKey: SettingsStore.userIDKey))
        XCTAssertNil(defaults.string(forKey: SettingsStore.userNickKey))
    }
}

final class DemoConfigurationTests: XCTestCase {
    func testConfigurationRequiresAllSecrets() {
        let configuration = DemoConfiguration(
            appKey: "appKey",
            appSecret: "appSecret",
            appRsaSecret: "appRsaSecret"
        )

        XCTAssertTrue(configuration.isValid)
    }

    func testInvalidConfigurationRequiresAllSecrets() {
        let configuration = DemoConfiguration(appKey: "appKey", appSecret: "", appRsaSecret: "rsa")

        XCTAssertFalse(configuration.isValid)
    }

    func testApmSDKServiceHasStartedMatchesSDKRuntimeState() {
        let service = ApmSDKService()

        XCTAssertEqual(service.hasStarted, EAPMApm.apm() != nil)
    }
}

@MainActor
final class HomeViewModelTests: XCTestCase {
    func testHomeSectionsMatchObjectiveCDemoStructure() {
        let sections = HomeViewModel.makeSections()

        XCTAssertEqual(sections.map(\.title), ["崩溃分析", "性能分析", "内存分析", "远程日志"])
        XCTAssertEqual(sections[0].cards.map(\.title), ["崩溃", "卡顿", "自定义异常", "其它类型崩溃"])
        XCTAssertEqual(sections[1].cards.map(\.title), ["启动分析", "页面分析", "网络分析"])
        XCTAssertEqual(sections[2].cards.map(\.title), ["OOM", "内存泄漏", "大对象"])
        XCTAssertEqual(sections[3].cards.map(\.title), ["日志回捞", "主动上报"])
    }
}

@MainActor
final class NetworkAnalysisViewModelTests: XCTestCase {
    func testInvalidURLShowsValidationAlert() {
        let overlay = OverlayCoordinator()
        let viewModel = NetworkAnalysisViewModel(
            overlayCoordinator: overlay,
            networkClient: MockNetworkClient()
        )

        viewModel.sendRequest(urlString: "invalid-url")

        XCTAssertEqual(overlay.alert?.title, "提示")
        XCTAssertEqual(overlay.alert?.message, "请输入有效的完整 HTTP(S) URL")
    }

    func testSuccessRequestBuildsSuccessMessage() {
        let overlay = OverlayCoordinator()
        let viewModel = NetworkAnalysisViewModel(
            overlayCoordinator: overlay,
            networkClient: MockNetworkClient(result: .success((Data(), HTTPURLResponse(url: URL(string: "https://www.aliyun.com")!, statusCode: 204, httpVersion: nil, headerFields: nil))))
        )

        viewModel.sendRequest(urlString: "https://www.aliyun.com")

        XCTAssertEqual(overlay.alert?.title, "网络请求")
        XCTAssertTrue(overlay.alert?.message.contains("Result: Success") == true)
        XCTAssertTrue(overlay.alert?.message.contains("Status Code: 204") == true)
    }

    func testTransportErrorBuildsFailureMessageWithErrorDescription() {
        let overlay = OverlayCoordinator()
        let viewModel = NetworkAnalysisViewModel(
            overlayCoordinator: overlay,
            networkClient: MockNetworkClient(result: .failure(URLError(.timedOut)))
        )

        viewModel.sendRequest(urlString: "https://www.aliyun.com")

        XCTAssertEqual(overlay.alert?.title, "网络请求")
        XCTAssertTrue(overlay.alert?.message.contains("Result: Failure") == true)
        XCTAssertTrue(overlay.alert?.message.contains("Status Code: -") == true)
        XCTAssertTrue(overlay.alert?.message.contains("Error:") == true)
    }
}

@MainActor
final class FeatureActionTests: XCTestCase {
    func testRemoteLogViewModelWritesLogsAndPresentsGuide() {
        let overlay = OverlayCoordinator()
        let sdkService = MockApmSDKService()
        let viewModel = RemoteLogFeatureViewModel(overlayCoordinator: overlay, sdkService: sdkService)

        viewModel.captureLogs()

        XCTAssertEqual(sdkService.loggedEntries.count, 4)
        XCTAssertEqual(overlay.guideSheet?.title, "日志回捞")
    }

    func testCrashViewModelRecordsCustomErrors() {
        let overlay = OverlayCoordinator()
        let sdkService = MockApmSDKService()
        let viewModel = CrashFeatureViewModel(
            overlayCoordinator: overlay,
            toastCenter: ToastCenter(),
            sdkService: sdkService,
            crashTrigger: MockCrashTrigger()
        )

        viewModel.recordCustomExceptions()

        XCTAssertEqual(sdkService.recordedErrors.count, 8)
        XCTAssertEqual(overlay.alert?.title, "自定义异常")
    }

    func testCrashViewModelPrimaryCrashUsesSwiftRuntimeCrash() {
        let overlay = OverlayCoordinator()
        let crashTrigger = MockCrashTrigger()
        let viewModel = CrashFeatureViewModel(
            overlayCoordinator: overlay,
            toastCenter: ToastCenter(),
            sdkService: MockApmSDKService(),
            crashTrigger: crashTrigger
        )

        viewModel.triggerCrash()
        overlay.alert?.primaryAction.handler?()

        XCTAssertEqual(overlay.alert?.title, "崩溃")
        XCTAssertEqual(crashTrigger.triggers, [.swiftRuntime])
    }

    func testMemoryViewModelCreatesLeakScenario() {
        let overlay = OverlayCoordinator()
        let leakScenario = MockLeakScenario()
        let viewModel = MemoryFeatureViewModel(
            overlayCoordinator: overlay,
            crashTrigger: MockCrashTrigger(),
            leakScenario: leakScenario,
            largeObjectScenario: MockLargeObjectScenario()
        )

        viewModel.triggerMemoryLeak()

        XCTAssertTrue(leakScenario.didCreateScenario)
        XCTAssertEqual(overlay.alert?.title, "内存泄漏")
    }

    func testMemoryViewModelTriggersLargeObjectScenario() {
        let overlay = OverlayCoordinator()
        let largeObjectScenario = MockLargeObjectScenario()
        largeObjectScenario.result = true
        let viewModel = MemoryFeatureViewModel(
            overlayCoordinator: overlay,
            crashTrigger: MockCrashTrigger(),
            leakScenario: MockLeakScenario(),
            largeObjectScenario: largeObjectScenario
        )

        viewModel.triggerLargeObject()

        XCTAssertTrue(largeObjectScenario.didTriggerScenario)
        XCTAssertEqual(overlay.alert?.title, "大对象")
    }

    func testOtherCrashTypesViewModelKeepsNSExceptionEntry() {
        let overlay = OverlayCoordinator()
        let crashTrigger = MockCrashTrigger()
        let viewModel = OtherCrashTypesViewModel(
            overlayCoordinator: overlay,
            crashTrigger: crashTrigger
        )

        let item = try! XCTUnwrap(viewModel.items.first(where: { $0.type == .nsException }))
        viewModel.trigger(item)
        overlay.alert?.primaryAction.handler?()

        XCTAssertEqual(overlay.alert?.title, "NSException")
        XCTAssertEqual(crashTrigger.triggers, [.nsException])
    }

    func testOtherCrashTypesViewModelUsesDedicatedWatchdogCrashType() {
        let overlay = OverlayCoordinator()
        let crashTrigger = MockCrashTrigger()
        let viewModel = OtherCrashTypesViewModel(
            overlayCoordinator: overlay,
            crashTrigger: crashTrigger
        )

        let item = try! XCTUnwrap(viewModel.items.first(where: { $0.title == "卡死" }))
        viewModel.trigger(item)
        overlay.alert?.primaryAction.handler?()

        XCTAssertEqual(crashTrigger.triggers, [.watchdog])
        XCTAssertTrue(overlay.alert?.message.contains("阻塞 30 秒") == true)
    }

    func testOtherCrashTypesViewModelIncludesSwiftSpecificCrashEntries() {
        let viewModel = OtherCrashTypesViewModel(
            overlayCoordinator: OverlayCoordinator(),
            crashTrigger: MockCrashTrigger()
        )

        XCTAssertTrue(viewModel.items.contains(where: { $0.type == .backgroundCrash }))
        XCTAssertTrue(viewModel.items.contains(where: { $0.type == .swiftArrayOutOfBounds }))
        XCTAssertTrue(viewModel.items.contains(where: { $0.type == .swiftFatalError }))
        XCTAssertTrue(viewModel.items.contains(where: { $0.type == .swiftPreconditionFailure }))
        XCTAssertTrue(viewModel.items.contains(where: { $0.type == .swiftUnownedReference }))
    }
}

final class LargeObjectScenarioTests: XCTestCase {
    func testTriggerLargeObjectWarmsUpMemoryBeforeSchedulingVMLargeObject() {
        let allocator = MockLargeObjectAllocator(memoryUsageRatios: [0.02, 0.12])
        var scheduledWork: (() -> Void)?
        let scenario = LargeObjectScenario(
            allocator: allocator,
            delayedVMLargeObjectAllocator: { work in
                scheduledWork = work
            }
        )

        XCTAssertTrue(scenario.triggerScenario())
        XCTAssertEqual(allocator.warmupRequests, [LargeObjectScenarioConstants.mallocChunkSize])
        XCTAssertNotNil(scheduledWork)
        XCTAssertTrue(allocator.vmRequests.isEmpty)

        scheduledWork?()

        XCTAssertEqual(allocator.vmRequests, [LargeObjectScenarioConstants.vmAllocateSize])
    }

    func testTriggerLargeObjectReturnsFalseWhenWarmupNeverReachesThreshold() {
        let allocator = MockLargeObjectAllocator(
            memoryUsageRatios: Array(
                repeating: 0.01,
                count: LargeObjectScenarioConstants.maxMallocIterations + 1
            )
        )
        var didSchedule = false
        let scenario = LargeObjectScenario(
            allocator: allocator,
            delayedVMLargeObjectAllocator: { _ in
                didSchedule = true
            }
        )

        XCTAssertFalse(scenario.triggerScenario())
        XCTAssertEqual(allocator.warmupRequests.count, LargeObjectScenarioConstants.maxMallocIterations)
        XCTAssertFalse(didSchedule)
        XCTAssertTrue(allocator.vmRequests.isEmpty)
    }
}

private struct MockNetworkClient: NetworkClient {
    var result: NetworkClientResult = .failure(URLError(.notConnectedToInternet))

    func data(for request: URLRequest, completion: @escaping @MainActor (NetworkClientResult) -> Void) {
        completion(result)
    }
}

private final class MockApmSDKService: ApmSDKServiceProtocol {
    var hasStarted: Bool = false
    var utdid: String = "mock-utdid"
    var recordedErrors: [DemoRecordedError] = []
    var loggedEntries: [DemoRemoteLogEntry] = []
    var uploadedComments: [String] = []

    func setUser(id: String?, nick: String?) {}

    func recordCustomError(_ error: DemoRecordedError) {
        recordedErrors.append(error)
    }

    func writeRemoteLogs(moduleName: String, entries: [DemoRemoteLogEntry]) {
        loggedEntries.append(contentsOf: entries)
    }

    func uploadRemoteLogs(comment: String) {
        uploadedComments.append(comment)
    }
}

private final class MockCrashTrigger: CrashTriggering {
    var triggers: [CrashTriggerType] = []

    func trigger(type: CrashTriggerType) {
        triggers.append(type)
    }
}

private final class MockLargeObjectAllocator: LargeObjectMemoryAllocating {
    private let memoryUsageRatios: [Float]
    private var ratioIndex = 0

    var warmupRequests: [Int] = []
    var vmRequests: [Int] = []

    init(memoryUsageRatios: [Float]) {
        self.memoryUsageRatios = memoryUsageRatios
    }

    func currentMemoryUsageRatio() -> Float {
        let safeIndex = min(ratioIndex, memoryUsageRatios.count - 1)
        let ratio = memoryUsageRatios[safeIndex]
        ratioIndex += 1
        return ratio
    }

    func allocateWarmupChunk(bytes: Int) -> Bool {
        warmupRequests.append(bytes)
        return true
    }

    func allocateVMLargeObject(bytes: Int) -> Bool {
        vmRequests.append(bytes)
        return true
    }
}

private final class MockLeakScenario: LeakScenarioSimulating {
    var didCreateScenario = false

    func createScenario() {
        didCreateScenario = true
    }
}

private final class MockLargeObjectScenario: LargeObjectScenarioSimulating {
    var didTriggerScenario = false
    var result = false

    func triggerScenario() -> Bool {
        didTriggerScenario = true
        return result
    }
}
