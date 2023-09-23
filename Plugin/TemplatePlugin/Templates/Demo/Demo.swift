import ProjectDescription

private let layerAttribute = Template.Attribute.required("layer")
private let nameAttribute = Template.Attribute.required("name")

private let template = Template(
    description: "A template for a new module's demo target",
    attributes: [
        layerAttribute,
        nameAttribute
    ],
    items: [
        .file(
            path: "Projects/\(layerAttribute)/\(nameAttribute)/Demo/Sources/AppDelegate.swift",
            templatePath: "DemoSources.stencil"
        ),
        .file(
            path: "Projects/\(layerAttribute)/\(nameAttribute)/Demo/Resources/LaunchScreen.storyboard",
            templatePath: "DemoResources.stencil"
        )
    ]
)
