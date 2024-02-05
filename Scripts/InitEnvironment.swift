#!/usr/bin/swift
import Foundation

func handleSIGINT(_ signal: Int32) {
    exit(0)
}

signal(SIGINT, handleSIGINT)

let currentPath = "./"

func writeCodeInFile(filePath: String, codes: String) {
    let fileURL = URL(fileURLWithPath: filePath)
    guard let writeHandle = try? FileHandle(forWritingTo: fileURL) else {
        fatalError("\(filePath)을 찾을 수 없습니다")
    }
    writeHandle.seek(toFileOffset: 0)
    try? writeHandle.write(contentsOf: Data(codes.utf8))
    try? writeHandle.close()
}

func envString(projectName: String, organizationName: String) -> String {
    return """
import Foundation
import ProjectDescription

public struct ProjectEnvironment {
    public let name: String
    public let organizationName: String
    public let destinations: Destinations
    public let deploymentTargets: DeploymentTargets
    public let baseSetting: SettingsDictionary
}

public let env = ProjectEnvironment(
    name: "\(projectName)",
    organizationName: "\(organizationName)",
    destinations: [.iPhone, .iPad],
    deploymentTargets: .iOS("16.0"),
    baseSetting: [:]
)
"""
}

func makeEnv(projectName: String, organizationName: String) {
    let env = envString(projectName: projectName, organizationName: organizationName)
    writeCodeInFile(filePath: currentPath + "Plugin/EnvironmentPlugin/ProjectDescriptionHelpers/ProjectEnvironment.swift", codes: env)
}

print("Enter your project name", terminator: " : ")
let projectName = readLine() ?? ""

print("Enter your organization name", terminator: " : ")
let organizationName = readLine() ?? ""

makeEnv(projectName: projectName, organizationName: organizationName)

print("")
print("✅ ProjectEnvironment is created successfully!")
