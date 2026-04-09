import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    private let settingsStore: SettingsStoreProtocol
    private let sdkService: ApmSDKServiceProtocol
    private let toastCenter: ToastCenter

    @Published var userId: String = ""
    @Published var userNick: String = ""
    @Published private(set) var utdidText: String = "获取失败"

    init(
        settingsStore: SettingsStoreProtocol,
        sdkService: ApmSDKServiceProtocol,
        toastCenter: ToastCenter
    ) {
        self.settingsStore = settingsStore
        self.sdkService = sdkService
        self.toastCenter = toastCenter
        refresh()
    }

    func refresh() {
        let settings = settingsStore.loadSettings()
        userId = settings.userId
        userNick = settings.userNick
        utdidText = sdkService.utdid
    }

    func save() {
        let userSettings = DemoUserSettings(userId: userId, userNick: userNick)

        settingsStore.save(settings: userSettings)

        if sdkService.hasStarted {
            sdkService.setUser(id: userId, nick: userNick)
        }

        refresh()
        toastCenter.show(message: "设置已保存")
    }
}

struct SettingsFormContent: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            DemoTextField(
                title: "UserID",
                placeholder: "请输入 UserID",
                isEditable: true,
                identifier: "settings.userId",
                text: $viewModel.userId
            )

            DemoTextField(
                title: "用户昵称",
                placeholder: "请输入用户昵称",
                isEditable: true,
                identifier: "settings.userNick",
                text: $viewModel.userNick
            )

            DemoTextField(
                title: "UTDID",
                placeholder: "",
                isEditable: false,
                identifier: "settings.utdid",
                text: .constant(viewModel.utdidText)
            )
        }
    }
}

struct SettingsScreen: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        SecondaryPageLayout(title: "设置") {
            VStack(alignment: .leading, spacing: 0) {
                SettingsFormContent(viewModel: viewModel)

                DemoPrimaryButton(title: "保存设置", isEnabled: true, identifier: "settings.save") {
                    viewModel.save()
                }
                .padding(.top, 20)
            }
            .padding(.horizontal, DemoSpacing.horizontal)
            .padding(.top, DemoSpacing.contentTopSpacing)
        }
        .onAppear {
            viewModel.refresh()
        }
        .dismissKeyboardOnTap()
    }
}
