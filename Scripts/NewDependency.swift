#!/usr/bin/swift
 import Foundation

func handleSIGINT(_ signal: Int32) {
    exit(0)
}

signal(SIGINT, handleSIGINT)

 let currentPath = "./"

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

 func registerDependenciesSwift(url: String, version: String) {
     let filePath = currentPath + "Tuist/Dependencies.swift"
     let findingString = "    swiftPackageManager: SwiftPackageManagerDependencies(\n        [\n"
     let inserting = "            .remote(url: \"\(url)\", requirement: .exact(\"\(version)\")),\n"
     updateFileContent(filePath: filePath, finding: findingString, inserting: inserting)
 }

 func registerDependencySPM(name: String, package: String) {
     let filePath = currentPath + "Plugin/DependencyPlugin/ProjectDescriptionHelpers/Dependency+SPM.swift"
     let findingString = "public extension TargetDependency.SPM {\n"
     let inserting = "    static let \(name) = TargetDependency.external(name: \"\(package)\")\n"
     updateFileContent(filePath: filePath, finding: findingString, inserting: inserting)
 }

 func registerDependency(name: String, package: String, url: String, version: String) {
     registerDependenciesSwift(url: url, version: version)
     registerDependencySPM(name: name, package: package)
 }

 print("Enter dependency name", terminator: " : ")
 guard let dependencyName = readLine() else {
     fatalError("Dependency name is nil")
 }

 print("Enter package name", terminator: " : ")
 guard let packageName = readLine() else {
     fatalError("Package name is nil")
 }

 print("Enter dependency github URL", terminator: " : ")
 guard let dependencyURL = readLine() else {
     fatalError("Dependency URL is nil")
 }

 print("Enter dependency version", terminator: " : ")
 guard let dependencyVersion = readLine() else {
     fatalError("Dependency version is nil")
 }

 registerDependency(name: dependencyName, package: packageName, url: dependencyURL, version: dependencyVersion)
 
 print("")
 print("✅ New Dependency is registered successfully!")