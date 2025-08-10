import AuthenticationServices
import LoopKit
import LoopKitUI
import SwiftUI
import TidepoolKit
import TidepoolServiceKit

class WindowContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
        window
    }
}

enum TidepoolServiceError: Error {
    case missingWindow
}

extension TidepoolService: ServiceUI {
    public static var image: UIImage? {
        UIImage(frameworkImage: "Tidepool Logo")
    }

    public static func setupViewController(
        colorPalette _: LoopUIColorPalette,
        pluginHost: PluginHost
    ) -> SetupUIResult<ServiceViewController, ServiceUI> {
        let navController = ServiceNavigationController()
        navController.isNavigationBarHidden = true

        Task {
            let service = TidepoolService(hostIdentifier: pluginHost.hostIdentifier, hostVersion: pluginHost.hostVersion)

            let settingsView = await SettingsView(service: service, login: { environment in

                guard let window = await navController.view.window else {
                    throw TidepoolServiceError.missingWindow
                }

                let windowContextProvider = WindowContextProvider(window: window)
                let sessionProvider = await ASWebAuthenticationSessionProvider(contextProviding: windowContextProvider)
                let auth = OAuth2Authenticator(api: service.tapi, environment: environment, sessionProvider: sessionProvider)
                try await auth.login()
                try await service.completeCreate()
                await navController.notifyServiceCreatedAndOnboarded(service)
            }, dismiss: {
                Task {
                    await navController.notifyComplete()
                }
            })

            let hostingController = await UIHostingController(rootView: settingsView)
            await navController.pushViewController(hostingController, animated: false)
        }

        return .userInteractionRequired(navController)
    }

    public func settingsViewController(colorPalette _: LoopUIColorPalette) -> ServiceViewController {
        let navController = ServiceNavigationController()
        navController.isNavigationBarHidden = true

        Task {
            let settingsView = await SettingsView(service: self, login: { [weak self] environment in
                if let self {
                    guard let window = await navController.view.window else {
                        throw TidepoolServiceError.missingWindow
                    }

                    let windowContextProvider = WindowContextProvider(window: window)
                    let sessionProvider = await ASWebAuthenticationSessionProvider(contextProviding: windowContextProvider)
                    let auth = OAuth2Authenticator(api: self.tapi, environment: environment, sessionProvider: sessionProvider)
                    try await auth.login()
                }
            }, dismiss: {
                Task {
                    await navController.notifyComplete()
                }
            })

            let hostingController = await UIHostingController(rootView: settingsView)
            await navController.pushViewController(hostingController, animated: false)
        }

        return navController
    }
}
