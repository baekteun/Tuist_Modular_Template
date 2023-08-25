import ProjectDescription

public extension SettingsDictionary {
    static let ldFlages: SettingsDictionary = [
        "OTHER_LDFLAGS": .string("$(inherited)")
    ]

    static let allLoadLDFlages: SettingsDictionary = [
        "OTHER_LDFLAGS": .string("$(inherited) -all_load")
    ]
}
