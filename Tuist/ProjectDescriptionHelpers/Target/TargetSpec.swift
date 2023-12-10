import ConfigurationPlugin
import EnvironmentPlugin
import ProjectDescription

public struct TargetSpec: Configurable {
    public var name: String
    public var destinations: Destinations
    public var product: Product
    public var productName: String?
    public var bundleId: String?
    public var deploymentTargets: DeploymentTargets?
    public var infoPlist: InfoPlist?
    public var sources: SourceFilesList?
    public var resources: ResourceFileElements?
    public var copyFiles: [CopyFilesAction]?
    public var headers: Headers?
    public var entitlements: Entitlements?
    public var scripts: [TargetScript]
    public var dependencies: [TargetDependency]
    public var settings: Settings?
    public var coreDataModels: [CoreDataModel]
    public var environmentVariables: [String: EnvironmentVariable]
    public var launchArguments: [LaunchArgument]
    public var additionalFiles: [FileElement]
    public var buildRules: [BuildRule]
    public var mergedBinaryType: MergedBinaryType
    public var mergeable: Bool

    public init(
        name: String = "",
        destinations: Destinations = env.destinations,
        product: Product = .staticLibrary,
        productName: String? = nil,
        bundleId: String? = nil,
        deploymentTargets: DeploymentTargets? = env.deploymentTargets,
        infoPlist: InfoPlist = .default,
        sources: SourceFilesList? = .sources,
        resources: ResourceFileElements? = nil,
        copyFiles: [CopyFilesAction]? = nil,
        headers: Headers? = nil,
        entitlements: Entitlements? = nil,
        scripts: [TargetScript] = generateEnvironment.scripts,
        dependencies: [TargetDependency] = [],
        settings: Settings? = nil,
        coreDataModels: [CoreDataModel] = [],
        environmentVariables: [String: EnvironmentVariable] = [:],
        launchArguments: [LaunchArgument] = [],
        additionalFiles: [FileElement] = [],
        buildRules: [BuildRule] = [],
        mergedBinaryType: MergedBinaryType = .disabled,
        mergeable: Bool = false
    ) {
        self.name = name
        self.destinations = destinations
        self.product = product
        self.productName = productName
        self.bundleId = bundleId
        self.deploymentTargets = deploymentTargets
        self.infoPlist = infoPlist
        self.sources = sources
        self.resources = resources
        self.copyFiles = copyFiles
        self.headers = headers
        self.entitlements = entitlements
        self.scripts = scripts
        self.dependencies = dependencies
        self.settings = settings
        self.coreDataModels = coreDataModels
        self.environmentVariables = environmentVariables
        self.launchArguments = launchArguments
        self.additionalFiles = additionalFiles
        self.buildRules = buildRules
        self.mergedBinaryType = mergedBinaryType
        self.mergeable = mergeable
    }

    func toTarget() -> Target {
        self.toTarget(with: self.name)
    }

    func toTarget(with name: String, product: Product? = nil) -> Target {
        Target(
            name: name,
            destinations: destinations,
            product: product ?? self.product,
            productName: productName,
            bundleId: bundleId ?? "\(env.organizationName).\(name)",
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            copyFiles: copyFiles,
            headers: headers,
            entitlements: entitlements,
            scripts: scripts,
            dependencies: dependencies,
            settings: settings ?? .settings(
                base: env.baseSetting
                    .merging((product ?? self.product) == .framework ? .allLoadLDFlages : .ldFlages),
                configurations: .default,
                defaultSettings: .recommended
            ),
            coreDataModels: coreDataModels,
            environmentVariables: environmentVariables,
            launchArguments: launchArguments,
            additionalFiles: additionalFiles,
            buildRules: buildRules,
            mergedBinaryType: mergedBinaryType,
            mergeable: mergeable
        )
    }
}
