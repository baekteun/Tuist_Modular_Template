import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Core.CoreKit.rawValue,
    targets: [
        .implements(module: .core(.CoreKit))
    ]
)
