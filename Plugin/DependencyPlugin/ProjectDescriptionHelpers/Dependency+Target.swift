import ProjectDescription

// swiftlint: disable all
public extension TargetDependency {
    struct Feature {}
    struct Domain {}
    struct Core {}
    struct Shared {}
    struct UserInterface {}
}

public extension TargetDependency.Feature {
    static let BaseFeature = TargetDependency.project(
        target: ModulePaths.Feature.BaseFeature.targetName(type: .sources),
        path: .relativeToFeature(ModulePaths.Feature.BaseFeature.rawValue)
    )
}

public extension TargetDependency.Domain {
    static let BaseDomain = TargetDependency.project(
        target: ModulePaths.Domain.BaseDomain.targetName(type: .sources),
        path: .relativeToDomain(ModulePaths.Domain.BaseDomain.rawValue)
    )
}

public extension TargetDependency.Core {
    static let CoreKit = TargetDependency.project(
        target: ModulePaths.Core.CoreKit.targetName(type: .sources),
        path: .relativeToCore(ModulePaths.Core.CoreKit.rawValue)
    )
}

public extension TargetDependency.Shared {
    static let GlobalThirdPartyLibrary = TargetDependency.project(
        target: ModulePaths.Shared.GlobalThirdPartyLibrary.targetName(type: .sources),
        path: .relativeToShared(ModulePaths.Shared.GlobalThirdPartyLibrary.rawValue)
    )
}

public extension TargetDependency.UserInterface {
    static let DesignSystem = TargetDependency.project(
        target: ModulePaths.UserInterface.DesignSystem.targetName(type: .sources),
        path: .relativeToUserInterface(ModulePaths.UserInterface.DesignSystem.rawValue)
    )
}
