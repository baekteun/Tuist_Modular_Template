# Template 개요
## 레이어 
Features - Services - Core - Shared
4개의 레이어를 가집니다.

- Feature
  - Presentation 부분
  - ex) AuthFeature, ProfileFeature
- Domain
  - Business Logic 부분
  - ex) AuthDomain, ProfileDomain
- Core
  - Feature, Domain에 공통적으로 쓰일 모듈
  - ex) NetworkingModule, DatabaseModule
- Shared
  - 모든 계층에서 사용 가능한 모듈
  - 더 넓은 의미의 공통적
  - ex) UtilityModule, LoggingModule

을 생각하여 레이어를 분리하였습니다.

## Micro Feature
확장 가능하고 커지는 프로젝트를 기능별로 수평 확장이 가능하도록 Micro Service에서 영감을 얻은 아키텍쳐입니다.

<img src="https://user-images.githubusercontent.com/74440939/210211725-5ac7c9fe-bf25-4707-9775-4f46f1c0c522.png" width="200">

##### https://docs.tuist.io/building-at-scale/microfeatures/#product

## 프로젝트 세팅
프로젝트 루트에서 `make init` 를 실행하면 프로젝트 이름과 organization 이름을 입력하여 세팅을 할 수 있습니다.


## 프로젝트 Signing
프로젝트 루트에서 `make signing`를 실행하면 프로젝트 Signing을 할 수 있습니다.

## 모듈 생성
프로젝트 루트에서 `make module`를 실행하면 모듈 레이어, 이름, Micro Feature 종류를 선택하여 새 모듈을 생성합니다.
(DependencyPlugin에 자동으로 등록되니 해당 모듈이 필요한 곳에 .Projects.\(레이어).\(모듈명)\(MicroFeature종류) 로 디펜던시를 추가해주면 됩니다)

## Makefile
- make init `// 프로젝트 세팅 (이름, organization)`
  - swift Scripts/InitEnvironment.swift

- make signing `// 프로젝트 Signing`
  - swift Scripts/CodeSigning.swift

- make generate `// 디펜던시 fetch 및 프로젝트 generate`
  - tuist fetch
  - tuist generate

- make module `// 모듈 생성`
  - swift Scripts/GenerateModule.swift

- make dependency `// 디펜던시 추기`
  - swift Scripts/NewDependency.swift

- make ci_generate `// 디펜던시 fetch 및 CI용 프로젝트 generate (SwiftLint X)`
  - tuist fetch
  - TUIST_CI=1 tuist generate

- make clean `// xcodeproj, xcworkspace 파일 삭제`
  - rm -rf **/*.xcodeproj
  - rm -rf *.xcworkspace

- make reset `// tuist clean 후 xcodeproj, xcworkspace 파일 삭제`
  - tuist clean
  - rm -rf **/*.xcodeproj
  - rm -rf *.xcworkspace

## Scaffold
tuist scaffold (Demo/Interface/Sources/Testing/Tests/UITests) 
  -- layer (Features/Services/Core/Shared)
  -- name (모듈 이름)

으로 Project 모듈의 Target 모듈을 직접 생성 가능합니다.
