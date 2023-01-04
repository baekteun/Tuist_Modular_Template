import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeModule(
    name: ModulePaths.Shared.UtilityModule.rawValue,
    product: .staticFramework,
    targets: [.unitTest]
)
