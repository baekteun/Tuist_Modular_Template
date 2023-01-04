# Template 개요
## 레이어 
Features - Services - Core - Shared
4개의 레이어를 가집니다.


## Micro Architecture
확장 가능하고 커지는 프로젝트를 기능별로 수평 확장이 가능하도록 Micro Service에서 영감을 얻은 아키텍쳐입니다.

<img src="https://user-images.githubusercontent.com/74440939/210211725-5ac7c9fe-bf25-4707-9775-4f46f1c0c522.png" width="200">

##### https://docs.tuist.io/building-at-scale/microfeatures/#product


## 프로젝트 세팅
프로젝트 루트에서 `make init` 를 실행하면 프로젝트 이름과 organization 이름을 입력하여 세팅을 할 수 있습니다.


## 프로젝트 Signing
프로젝트 루트에서 `make signing`를 실행하면 프로젝트 Signing을 할 수 있습니다.


## Makefile
- make init // 프로젝트 세팅 (이름, organization)
  - swift Scripts/InitEnvironment.swift

- make signing // 프로젝트 Signing
  - swift Scripts/CodeSigning.swift

- make generate // 디펜던시 fetch 및 프로젝트 generate
  - tuist fetch
  - tuist generate

- make module // 모듈 생성
  - swift Scripts/GenerateModule.swift

- make ci_generate // 디펜던시 fetch 및 CI용 프로젝트 generate (SwiftLint X)
  - tuist fetch
  - TUIST_CI=1 tuist generate

- make clean // xcodeproj, xcworkspace 파일 삭제
  - rm -rf **/*.xcodeproj
  - rm -rf *.xcworkspace

- make reset // tuist clean 후 xcodeproj, xcworkspace 파일 삭제
  - tuist clean
  - rm -rf **/*.xcodeproj
  - rm -rf *.xcworkspace

## Scaffold
tuist scaffold (Demo/Interface/Sources/Testing/Tests/UITests) 
  -- layer (Features/Services/Core/Shared)
  -- name (모듈 이름)

으로 Project 모듈의 Target 모듈을 직접 생성 가능합니다.
