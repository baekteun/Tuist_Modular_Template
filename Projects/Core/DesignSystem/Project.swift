import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeModule(
    name: ModulePaths.Core.DesignSystem.rawValue,
    product: .framework,
    targets: [.demo]
)
