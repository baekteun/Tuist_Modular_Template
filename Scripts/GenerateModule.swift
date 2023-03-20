#!/usr/bin/swift
import Foundation

enum LayerType: String {
    case feature = "Feature"
    case domain = "Domain"
    case core = "Core"
    case shared = "Shared"
}

enum MicroTargetType: String {
    case interface = "Interface"
    case sources = ""
    case testing = "Testing"
    case unitTest = "Tests"
    case uiTest = "UITests"
    case demo = "Demo"
}

let fileManager = FileManager.default
let currentPath = "./"
let bash = Bash()

func registerModuleDependency() {
    registerModulePaths()
    makeProjectDirectory()
    registerXCConfig()
    registerMicroTarget(target: .sources)
    var targetString = "["
    if hasInterface {
        registerMicroTarget(target: .interface)
        makeScaffold(target: .interface)
        targetString += ".\(MicroTargetType.interface), "
    }
    if hasTesting {
        registerMicroTarget(target: .testing)
        makeScaffold(target: .testing)
        targetString += ".\(MicroTargetType.testing), "
    }
    if hasUnitTests {
        makeScaffold(target: .unitTest)
        targetString += ".\(MicroTargetType.unitTest), "
    }
    if hasUITests {
        makeScaffold(target: .uiTest)
        targetString += ".\(MicroTargetType.uiTest), "
    }
    if hasDemo {
        makeScaffold(target: .demo)
        targetString += ".\(MicroTargetType.demo), "
    }
    if targetString.hasSuffix(", ") {
        targetString.removeLast(2)
    }
    targetString += "]"
    makeProjectSwift(targetString: targetString)
    makeProjectScaffold(targetString: targetString)
}

func registerModulePaths() {
    updateFileContent(
        filePath: currentPath + "Plugin/DependencyPlugin/ProjectDescriptionHelpers/ModulePaths.swift",
        finding: "enum \(layer.rawValue): String {\n",
        inserting: "        case \(moduleName)\n"
    )
    print("Register \(moduleName) to ModulePaths.swift")
}

func registerMicroTarget(target: MicroTargetType) {
    let targetString = """
    static let \(moduleName)\(target.rawValue) = TargetDependency.project(
        target: ModulePaths.\(layer.rawValue).\(moduleName).targetName(type: .\(target)),
        path: .relativeTo\(layer.rawValue)(ModulePaths.\(layer.rawValue).\(moduleName).rawValue)
    )\n
"""
    updateFileContent(
        filePath: currentPath + "Plugin/DependencyPlugin/ProjectDescriptionHelpers/Dependency+Target.swift",
        finding: "public extension TargetDependency.\(layer.rawValue) {\n",
        inserting: targetString
    )
    print("Register \(moduleName) \(target.rawValue) target to Dependency+Target.swift")
}

func registerXCConfig() {
    makeDirectory(path: currentPath + "XCConfig/\(moduleName)")
    let xcconfigContent = "#include \"../Shared.xcconfig\""
    for configuration in ["DEV", "STAGE", "PROD"] {
        writeContentInFile(
            path: currentPath + "XCConfig/\(moduleName)/\(configuration).xcconfig",
            content: xcconfigContent
        )
    }
}

func makeDirectory(path: String) {
    do {
        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
    } catch {
        fatalError("❌ failed to create directory: \(path)")
    }
}

func makeDirectories(_ paths: [String]) {
    paths.forEach(makeDirectory(path:))
}

func makeProjectSwift(targetString: String) {
    let projectSwift = """
import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeModule(
    name: ModulePaths.\(layer.rawValue).\(moduleName).rawValue,
    product: .staticFramework,
    targets: \(targetString)
)

"""
    writeContentInFile(
        path: currentPath + "Projects/\(layer.rawValue)/\(moduleName)/Project.swift", 
        content: projectSwift
    )
}

func makeProjectDirectory() {
    makeDirectory(path: currentPath + "Projects/\(layer.rawValue)/\(moduleName)")
}

func makeProjectScaffold(targetString: String) {
    _ = try? bash.run(
        commandName: "tuist", 
        arguments: ["scaffold", "Module", "--name", "\(moduleName)", "--layer", "\(layer.rawValue)", "--target", "\(targetString)"]
    )
}

func makeScaffold(target: MicroTargetType) {
    _ = try? bash.run(
        commandName: "tuist", 
        arguments: ["scaffold", "\(target.rawValue)", "--name", "\(moduleName)", "--layer", "\(layer.rawValue)"]
    )
}

func writeContentInFile(path: String, content: String) {
    let fileURL = URL(filePath: path)
    let data = Data(content.utf8)
    try? data.write(to: fileURL)
}

func updateFileContent(
    filePath: String,
    finding findingString: String,
    inserting insertString: String
) {
    let fileURL = URL(filePath: filePath)
    guard let readHandle = try? FileHandle(forReadingFrom: fileURL) else {
        fatalError("❌ Failed to find \(filePath)")
    }
    guard let readData = try? readHandle.readToEnd() else { 
        fatalError("❌ Failed to find \(filePath)")
    }
    try? readHandle.close()

    guard var fileString = String(data: readData, encoding: .utf8) else { fatalError() }
    fileString.insert(contentsOf: insertString, at: fileString.range(of: findingString)?.upperBound ?? fileString.endIndex)

    guard let writeHandle = try? FileHandle(forWritingTo: fileURL) else {
        fatalError("❌ Failed to find \(filePath)")
    }
    writeHandle.seek(toFileOffset: 0)
    try? writeHandle.write(contentsOf: Data(fileString.utf8))
    try? writeHandle.close()
}


// MARK: - Starting point

print("Enter layer name\n(Feature | Domain | Core | Shared)", terminator: " : ")
let layerInput = readLine()
guard 
    let layerInput, 
    !layerInput.isEmpty ,
    let layerUnwrapping = LayerType(rawValue: layerInput)
else {
    print("Layer is empty or invalid")
    exit(1)
}
let layer = layerUnwrapping
print("Layer: \(layer.rawValue)\n")

print("Enter module name", terminator: " : ")
let moduleInput = readLine()
guard let moduleNameUnwrapping = moduleInput, !moduleNameUnwrapping.isEmpty else {
    print("Module name is empty")
    exit(1)
}
var moduleName = moduleNameUnwrapping
print("Module name: \(moduleName)\n")

print("This module has a 'Interface' Target? (y\\n, default = n)", terminator: " : ")
let hasInterface = readLine()?.lowercased() == "y"

print("This module has a 'Testing' Target? (y\\n, default = n)", terminator: " : ")
let hasTesting = readLine()?.lowercased() == "y"

print("This module has a 'UnitTests' Target? (y\\n, default = n)", terminator: " : ")
let hasUnitTests = readLine()?.lowercased() == "y"

print("This module has a 'UITests' Target? (y\\n, default = n)", terminator: " : ")
let hasUITests = readLine()?.lowercased() == "y"

print("This module has a 'Demo' Target? (y\\n, default = n)", terminator: " : ")
let hasDemo = readLine()?.lowercased() == "y"

print("")

registerModuleDependency()

print("")
print("------------------------------------------------------------------------------------------------------------------------")
print("Layer: \(layer.rawValue)")
print("Module name: \(moduleName)")
print("interface: \(hasInterface), testing: \(hasTesting), unitTests: \(hasUnitTests), uiTests: \(hasUITests), demo: \(hasDemo)")
print("------------------------------------------------------------------------------------------------------------------------")
print("✅ Module is created successfully!")


// MARK: - Bash
protocol CommandExecuting {
    func run(commandName: String, arguments: [String]) throws -> String
}

enum BashError: Error {
    case commandNotFound(name: String)
}

struct Bash: CommandExecuting {
    func run(commandName: String, arguments: [String] = []) throws -> String {
        return try run(resolve(commandName), with: arguments)
    }

    private func resolve(_ command: String) throws -> String {
        guard var bashCommand = try? run("/bin/bash" , with: ["-l", "-c", "which \(command)"]) else {
            throw BashError.commandNotFound(name: command)
        }
        bashCommand = bashCommand.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        return bashCommand
    }

    private func run(_ command: String, with arguments: [String] = []) throws -> String {
        let process = Process()
        process.launchPath = command
        process.arguments = arguments
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.launch()
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outputData, as: UTF8.self)
        return output
    }
}

