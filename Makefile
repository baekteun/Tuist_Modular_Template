generate:
	tuist fetch
	tuist generate

ci_generate:
	tuist fetch
	TUIST_ENV=CI tuist generate

cd_generate:
	tuist fetch
	TUIST_ENV=CD tuist generate

clean:
	rm -rf **/*.xcodeproj
	rm -rf *.xcworkspace

reset:
	tuist clean
	rm -rf **/*.xcodeproj
	rm -rf *.xcworkspace

module:
	swift Scripts/GenerateModule.swift

dependency:
	swift Scripts/NewDependency.swift

init:
	swift Scripts/InitEnvironment.swift

signing:
	swift Scripts/CodeSigning.swift
