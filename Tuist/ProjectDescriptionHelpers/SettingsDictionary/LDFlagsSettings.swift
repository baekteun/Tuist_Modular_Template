import ProjectDescription

public extension SettingsDictionary {
    static let ldFlags: SettingsDictionary = [
        "OTHER_LDFLAGS": .string("$(inherited)")
    ]

    static let allLoadLDFlags: SettingsDictionary = [
        "OTHER_LDFLAGS": .string("$(inherited) -all_load")
    ]
}
