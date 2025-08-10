public protocol PumpManagerUIPlugin {
    var pumpManagerType: PumpManagerUI.Type? { get }
}

public protocol CGMManagerUIPlugin {
    var cgmManagerType: CGMManagerUI.Type? { get }
}

public protocol ServiceUIPlugin {
    var serviceType: ServiceUI.Type? { get }
}

public protocol OnboardingUIPlugin {
    var onboardingType: OnboardingUI.Type? { get }
}

public protocol SupportUIPlugin {
    var support: SupportUI { get }
}
