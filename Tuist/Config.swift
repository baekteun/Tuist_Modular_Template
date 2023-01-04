import ProjectDescription

let config = Config(
    plugins: [
        .local(path: .relativeToRoot("Plugin/DependencyPlugin")),
        .local(path: .relativeToRoot("Plugin/ConfigurationPlugin")),
        .local(path: .relativeToRoot("Plugin/EnvironmentPlugin"))
    ],
    generationOptions: .options()
)
