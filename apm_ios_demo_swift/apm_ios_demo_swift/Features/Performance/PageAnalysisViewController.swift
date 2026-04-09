import SwiftUI
import UIKit

final class PageAnalysisViewController: UIViewController {
    private var hostingController: UIHostingController<PageAnalysisScreen>?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = ""
        navigationItem.hidesBackButton = true
        view.backgroundColor = .white

        let hostingController = UIHostingController(
            rootView: PageAnalysisScreen(
                onBack: { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            )
        )

        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        hostingController.didMove(toParent: self)
        self.hostingController = hostingController
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
