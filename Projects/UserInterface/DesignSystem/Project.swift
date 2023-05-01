import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeModule(
    name: ModulePaths.UserInterface.DesignSystem.rawValue,
    product: .framework,
    targets: [.demo]
)
