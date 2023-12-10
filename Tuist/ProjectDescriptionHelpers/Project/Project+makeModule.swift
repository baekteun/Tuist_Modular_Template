import ConfigurationPlugin
import DependencyPlugin
import EnvironmentPlugin
import Foundation
import ProjectDescription

public enum MicroFeatureTarget {
    case interface
    case testing
    case unitTest
    case uiTest
    case demo
}

public extension Project {
    static func makeModule(
        name: String,
        destinations: Destinations = env.destinations,
        product: Product,
        targets: Set<MicroFeatureTarget>,
        packages: [Package] = [],
        externalDependencies: [TargetDependency] = [],
        internalDependencies: [TargetDependency] = [],
        interfaceDependencies: [TargetDependency] = [],
        testingDependencies: [TargetDependency] = [],
        unitTestDependencies: [TargetDependency] = [],
        uiTestDependencies: [TargetDependency] = [],
        demoDependencies: [TargetDependency] = [],
        sources: SourceFilesList = .sources,
        resources: ResourceFileElements? = nil,
        settings: SettingsDictionary = [:],
        additionalPlistRows: [String: ProjectDescription.Plist.Value] = [:],
        additionalFiles: [FileElement] = [],
        configurations: [Configuration] = []
    ) -> Project {
        let scripts: [TargetScript] = generateEnvironment.scripts
        let ldFlagsSettings: SettingsDictionary = product == .framework ?
        ["OTHER_LDFLAGS": .string("$(inherited) -all_load")] :
        ["OTHER_LDFLAGS": .string("$(inherited)")]

        var configurations = configurations
        if configurations.isEmpty {
            configurations = [
                .debug(name: .dev, xcconfig: .shared),
                .debug(name: .stage, xcconfig: .shared),
                .release(name: .prod, xcconfig: .shared)
            ]
        }

        let settings: Settings = .settings(
            base: env.baseSetting
                .merging(.codeSign)
                .merging(settings)
                .merging(ldFlagsSettings),
            configurations: configurations,
            defaultSettings: .recommended
        )
        var allTargets: [Target] = []
        var dependencies = internalDependencies + externalDependencies

        // MARK: - Interface
        if targets.contains(.interface) {
            dependencies.append(.target(name: "\(name)Interface"))
            allTargets.append(
                Target(
                    name: "\(name)Interface",
                    destinations: destinations,
                    product: .framework,
                    bundleId: "\(env.organizationName).\(name)Interface",
                    deploymentTargets: env.deploymentTargets,
                    infoPlist: .default,
                    sources: .interface,
                    scripts: scripts,
                    dependencies: interfaceDependencies,
                    additionalFiles: additionalFiles
                )
            )
        }

        // MARK: - Sources
        allTargets.append(
            Target(
                name: name,
                destinations: destinations,
                product: product,
                bundleId: "\(env.organizationName).\(name)",
                deploymentTargets: env.deploymentTargets,
                infoPlist: .extendingDefault(with: additionalPlistRows),
                sources: sources,
                resources: resources,
                scripts: scripts,
                dependencies: dependencies
            )
        )

        // MARK: - Testing
        if targets.contains(.testing) && targets.contains(.interface) {
            allTargets.append(
                Target(
                    name: "\(name)Testing",
                    destinations: destinations,
                    product: .framework,
                    bundleId: "\(env.organizationName).\(name)Testing",
                    deploymentTargets: env.deploymentTargets,
                    infoPlist: .default,
                    sources: .testing,
                    scripts: scripts,
                    dependencies: [
                        .target(name: "\(name)Interface")
                    ] + testingDependencies
                )
            )
        }

        var testTargetDependencies = [
            targets.contains(.demo) ?
                TargetDependency.target(name: "\(name)DemoApp") :
                TargetDependency.target(name: name)
        ]
        if targets.contains(.testing) {
            testTargetDependencies.append(.target(name: "\(name)Testing"))
        }

        // MARK: - Unit Test
        if targets.contains(.unitTest) {
            allTargets.append(
                Target(
                    name: "\(name)Tests",
                    destinations: destinations,
                    product: .unitTests,
                    bundleId: "\(env.organizationName).\(name)Tests",
                    deploymentTargets: env.deploymentTargets,
                    infoPlist: .default,
                    sources: .unitTests,
                    scripts: scripts,
                    dependencies: testTargetDependencies + unitTestDependencies
                )
            )
        }

        // MARK: - UI Test
        if targets.contains(.uiTest) {
            allTargets.append(
                Target(
                    name: "\(name)UITests",
                    destinations: destinations,
                    product: .uiTests,
                    bundleId: "\(env.organizationName).\(name)UITests",
                    deploymentTargets: env.deploymentTargets,
                    infoPlist: .default,
                    scripts: scripts,
                    dependencies: testTargetDependencies + uiTestDependencies
                )
            )
        }

        // MARK: - Demo App
        if targets.contains(.demo) {
            var demoDependencies = demoDependencies
            demoDependencies.append(.target(name: name))
            if targets.contains(.testing) {
                demoDependencies.append(.target(name: "\(name)Testing"))
            }
            allTargets.append(
                Target(
                    name: "\(name)DemoApp",
                    destinations: destinations,
                    product: .app,
                    bundleId: "\(env.organizationName).\(name)DemoApp",
                    deploymentTargets: env.deploymentTargets,
                    infoPlist: .extendingDefault(with: [
                        "UIMainStoryboardFile": "",
                        "UILaunchStoryboardName": "LaunchScreen",
                        "ENABLE_TESTS": .boolean(true),
                    ]),
                    sources: .demoSources,
                    resources: ["Demo/Resources/**"],
                    scripts: scripts,
                    dependencies: demoDependencies
                )
            )
        }

        let schemes: [Scheme] = targets.contains(.demo) ?
        [.makeScheme(target: .dev, name: name), .makeDemoScheme(target: .dev, name: name)] :
        [.makeScheme(target: .dev, name: name)]

        return Project(
            name: name,
            organizationName: env.organizationName,
            packages: packages,
            settings: settings,
            targets: allTargets,
            schemes: schemes
        )
    }
}
