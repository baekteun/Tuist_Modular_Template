#!/usr/bin/swift
import Foundation

func writeContentInFile(path: String, content: String) {
    let fileURL = URL(filePath: path)
    let data = Data(content.utf8)
    try? data.write(to: fileURL)
}

print("Enter your Apple Developer ID Code Signing Identity: ", terminator: "")
guard let codeSigningIdentity = readLine() else {
    fatalError()
}

let codeSignContent = """
import ProjectDescription

public extension SettingsDictionary {
    static let codeSign = SettingsDictionary()
        .codeSignIdentityAppleDevelopment()
        .automaticCodeSigning(devTeam: "\(codeSigningIdentity)")
}

"""

writeContentInFile(path: "Tuist/ProjectDescriptionHelpers/CodeSign.swift", content: codeSignContent)

print("✅ Code Sign extension generated successfully!")


