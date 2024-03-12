#!/usr/bin/swift
import Foundation

func handleSIGINT(_ signal: Int32) {
    exit(0)
}

signal(SIGINT, handleSIGINT)

enum LayerType: String {
    case feature = "Feature"
    case domain = "Domain"
    case core = "Core"
    case shared = "Shared"
    case userInterface = "UserInterface"
}

enum MicroTargetType: String {
    case interface = "Interface"
    case sources = ""
    case testing = "Testing"
    case unitTest = "Tests"
    case uiTest = "UITests"
    case demo = "Demo"
}

struct ModuleInfo {
    let moduleName: String
    let hasInterface: Bool
    let hasTesting: Bool
    let hasUnitTests: Bool
    let hasUITests: Bool
    let hasDemo: Bool
}

let fileManager = FileManager.default
let currentPath = "./"
let bash = Bash()

func registerModuleDependency() {
    registerModulePaths()
    makeProjectDirectory()
    registerXCConfig()

    let layerPrefix = layer.rawValue.lowercased()
    let moduleEnum = ".\(layerPrefix)(.\(moduleName))"
    var targetString = "[\n"
    if hasInterface {
        makeScaffold(target: .interface)
        targetString += "\(tab(2)).interface(module: \(moduleEnum)),\n"
    }
    targetString += "\(tab(2)).implements(module: \(moduleEnum)"
    if hasInterface {
        targetString += ", dependencies: [\n\(tab(3)).\(layerPrefix)(target: .\(moduleName), type: .interface)\n\(tab(2))])"
    } else {
        targetString += ")"
    }
    if hasTesting {
        makeScaffold(target: .testing)
        let interfaceDependency = ".\(layerPrefix)(target: .\(moduleName), type: .interface)"
        targetString += ",\n\(tab(2)).testing(module: \(moduleEnum), dependencies: [\n\(tab(3))\(interfaceDependency)\n\(tab(2))])"
    }
    if hasUnitTests {
        makeScaffold(target: .unitTest)
        targetString += ",\n\(tab(2)).tests(module: \(moduleEnum), dependencies: [\n\(tab(3)).\(layerPrefix)(target: .\(moduleName))\n\(tab(2))])"
    }
    if hasUITests {
        makeScaffold(target: .uiTest)
        // TODO: - ui test 타겟 설정 로직 추가
    }
    if hasDemo {
        makeScaffold(target: .demo)
        targetString += ",\n\(tab(2)).demo(module: \(moduleEnum), dependencies: [\n\(tab(3)).\(layerPrefix)(target: .\(moduleName))\n\(tab(2))])"
    }
    targetString += "\n\(tab(1))]"
    makeProjectSwift(targetString: targetString)
    makeSourceScaffold()
}

func tab(_ count: Int) -> String {
    var tabString = ""
    for _ in 0..<count {
        tabString += "    "
    }
    return tabString
}

func registerModulePaths() {
    updateFileContent(
        filePath: currentPath + "Plugin/DependencyPlugin/ProjectDescriptionHelpers/ModulePaths.swift",
        finding: "enum \(layer.rawValue): String, MicroTargetPathConvertable {\n",
        inserting: "        case \(moduleName)\n"
    )
    print("Register \(moduleName) to ModulePaths.swift")
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
import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.\(layer.rawValue).\(moduleName).rawValue,
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

func makeSourceScaffold() {
    _ = try? bash.run(
        commandName: "tuist",
        arguments: ["scaffold", "Sources", "--name", "\(moduleName)", "--layer", "\(layer.rawValue)"]
    )
}

func makeScaffold(target: MicroTargetType) {
    _ = try? bash.run(
        commandName: "tuist",
        arguments: ["scaffold", "\(target.rawValue)", "--name", "\(moduleName)", "--layer", "\(layer.rawValue)"]
    )
}

func writeContentInFile(path: String, content: String) {
    let fileURL = URL(fileURLWithPath: path)
    let data = Data(content.utf8)
    try? data.write(to: fileURL)
}

func updateFileContent(
    filePath: String,
    finding findingString: String,
    inserting insertString: String
) {
    let fileURL = URL(fileURLWithPath: filePath)
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

func makeModuleInfo() -> ModuleInfo {
    print("Enter module name", terminator: " : ")
    let moduleInput = readLine()
    guard let moduleNameUnwrapping = moduleInput, !moduleNameUnwrapping.isEmpty else {
        print("Module name is empty")
        exit(1)
    }
    let moduleName = moduleNameUnwrapping
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
    
    return ModuleInfo(
        moduleName: moduleName,
        hasInterface: hasInterface,
        hasTesting: hasTesting,
        hasUnitTests: hasUnitTests,
        hasUITests: hasUITests,
        hasDemo: hasDemo
    )
}

func checkModuleInfo() -> Bool {
    print("")
    print("------------------------------------------------------------------------------------------------------------------------")
    print("Is this the correct module information you are generating? (y\\n, default = y)")
    print("Layer: \(layer.rawValue)")
    print("Module name: \(moduleName)")
    print("interface: \(hasInterface), testing: \(hasTesting), unitTests: \(hasUnitTests), uiTests: \(hasUITests), demo: \(hasDemo)")
    print("------------------------------------------------------------------------------------------------------------------------")
    
    guard var checkInput = readLine() else {
        exit(1)
    }
    
    if checkInput.isEmpty {
        checkInput = "y"
    }
    
    let isCorrect = checkInput.lowercased() == "y"
    return !isCorrect
}

// MARK: - Starting point

print("Enter layer name\n(Feature | Domain | Core | Shared | UserInterface)", terminator: " : ")
let layerInput = readLine()
guard
    let layerInput,
    !layerInput.isEmpty,
    let layerUnwrapping = LayerType(rawValue: layerInput)
else {
    print("Layer is empty or invalid")
    exit(1)
}
let layer = layerUnwrapping
print("Layer: \(layer.rawValue)\n")

var moduleName: String = ""
var hasInterface: Bool = false
var hasTesting: Bool = false
var hasUnitTests: Bool = false
var hasUITests: Bool = false
var hasDemo: Bool = false

repeat {
    let moduleInfo = makeModuleInfo()
    moduleName = moduleInfo.moduleName
    hasInterface = moduleInfo.hasInterface
    hasTesting = moduleInfo.hasTesting
    hasUnitTests = moduleInfo.hasUnitTests
    hasUITests = moduleInfo.hasUITests
    hasDemo = moduleInfo.hasDemo
}
while checkModuleInfo()
        
registerModuleDependency()

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
        guard var bashCommand = try? run("/bin/bash", with: ["-l", "-c", "which \(command)"]) else {
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
