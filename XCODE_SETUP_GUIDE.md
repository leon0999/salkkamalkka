# 🛠️ Xcode 프로젝트 생성 가이드

## 📋 단계별 설정 방법

### 1️⃣ Xcode에서 새 프로젝트 생성

1. **Xcode 실행** (버전 15.0 이상 권장)
2. **File > New > Project** 선택
3. **iOS > App** 템플릿 선택 후 Next
4. 프로젝트 정보 입력:
   ```
   Product Name: SalkkaMalkka
   Team: [본인의 Apple Developer 팀 선택]
   Organization Identifier: com.JaehyunPark
   Bundle Identifier: com.JaehyunPark.SalkkaMalkka
   Interface: SwiftUI ✅
   Language: Swift ✅
   Storage: None (Core Data 체크 해제) ✅
   Include Tests: 체크 (선택 사항)
   ```
5. **저장 위치**: `/Users/user/Desktop/SalkkaMalkka` 선택
6. **Create Git repository**: 체크 해제 (이미 Git 초기화됨)

---

### 2️⃣ 기존 파일 삭제 및 새 파일 추가

#### A. 기본 생성된 파일 삭제
Xcode 좌측 Project Navigator에서 다음 파일들을 **Delete (Move to Trash)** 선택:
- `ContentView.swift` (덮어쓸 예정)
- `SalkkaMalkkaApp.swift` (덮어쓸 예정)
- `Assets.xcassets` 폴더 안의 불필요한 파일들

#### B. 그룹(폴더) 생성
프로젝트 루트 `SalkkaMalkka` 우클릭 > **New Group** 으로 다음 그룹들 생성:
```
SalkkaMalkka/
├── Models
├── ViewModels
├── Views
├── Services
└── Utilities
```

#### C. Swift 파일 추가
각 그룹에 해당하는 파일들을 드래그앤드롭:

1. **Models 그룹**에 추가:
   - `WishItem.swift`
   - `UserStats.swift`

2. **ViewModels 그룹**에 추가:
   - `WishListViewModel.swift`

3. **Views 그룹**에 추가:
   - `ContentView.swift`
   - `AddWishItemView.swift`
   - `DecisionView.swift`
   - `StatsView.swift`

4. **Services 그룹**에 추가:
   - `DataManager.swift`
   - `NotificationManager.swift`

5. **Utilities 그룹**에 추가:
   - `Extensions.swift`

6. **프로젝트 루트**에 추가:
   - `SalkkaMalkkaApp.swift`

**주의**: 파일 추가 시 "Copy items if needed" 체크 필수!

---

### 3️⃣ Info.plist 권한 설정

**방법 1: Target 설정에서 추가**
1. 프로젝트 네비게이터에서 **프로젝트 파일** 선택
2. **TARGETS > SalkkaMalkka** 선택
3. **Info 탭** 클릭
4. **Custom iOS Target Properties** 섹션에서 `+` 버튼 클릭
5. 다음 항목들 추가:

```
Key: Privacy - Photo Library Usage Description
Value: 물건 사진을 등록하기 위해 사진 라이브러리 접근이 필요합니다.

Key: Privacy - Camera Usage Description
Value: 물건 사진을 촬영하기 위해 카메라 접근이 필요합니다.
```

**방법 2: Info.plist 파일 직접 편집**
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>물건 사진을 등록하기 위해 사진 라이브러리 접근이 필요합니다.</string>

<key>NSCameraUsageDescription</key>
<string>물건 사진을 촬영하기 위해 카메라 접근이 필요합니다.</string>
```

---

### 4️⃣ Build Settings 설정

1. **TARGETS > SalkkaMalkka > General 탭**
2. **Deployment Info** 섹션:
   ```
   iOS Deployment Target: 15.0
   iPhone Orientation: Portrait만 체크 ✅
   iPad Orientation: 모두 체크 ✅
   Supports multiple windows: 체크 해제
   ```

3. **Signing & Capabilities 탭**:
   - Team: 본인 Apple Developer 계정 선택
   - Bundle Identifier: `com.JaehyunPark.SalkkaMalkka`

---

### 5️⃣ 앱 아이콘 설정 (선택 사항)

1. **Assets.xcassets** 폴더 열기
2. **AppIcon** 선택
3. 1024x1024 PNG 이미지를 **App Store** 슬롯에 드래그앤드롭
4. 다른 사이즈들은 자동 생성되거나 수동으로 추가

**임시 앱 아이콘 생성 (온라인 도구)**:
- https://appicon.co
- https://www.appicon.build

---

### 6️⃣ 빌드 및 실행

#### 시뮬레이터에서 실행
1. **Product > Destination > iPhone 16** 선택
2. **Cmd + R** 또는 ▶️ 버튼 클릭
3. 시뮬레이터가 실행되고 앱이 로드됨

#### 실제 기기에서 실행
1. iPhone을 USB로 Mac에 연결
2. **Product > Destination > [본인 iPhone]** 선택
3. **신뢰하겠습니까?** 메시지 승인
4. **Cmd + R** 실행
5. 기기에서 **설정 > 일반 > VPN 및 기기 관리 > 개발자 앱 신뢰** 필요할 수 있음

---

### 7️⃣ 문제 해결

#### 빌드 에러: "No such module 'Charts'"
- iOS 16.0 이상 필요
- `StatsView.swift` 에서 `import Charts` 주석 처리

#### 푸시 알림 테스트 안 됨
- 시뮬레이터는 로컬 알림 제한적 지원
- **실제 기기에서만 푸시 알림 완전 동작**

#### 사진 선택 안 됨
- Info.plist 권한 확인
- 시뮬레이터: Photos 앱에 샘플 이미지 추가 필요

---

## ✅ 완료 체크리스트

베타 테스트 전 확인사항:

- [ ] Xcode 프로젝트 빌드 성공 (에러 0개)
- [ ] 시뮬레이터에서 앱 실행 확인
- [ ] 물건 등록 기능 테스트
- [ ] 7일 타이머 작동 확인
- [ ] 푸시 알림 권한 요청 확인
- [ ] 다크모드 전환 테스트
- [ ] 절약 통계 화면 확인
- [ ] 실제 기기에서 테스트

---

## 🚀 다음 단계: TestFlight 배포

1. **Archive 빌드 생성**
   - Product > Archive
   - Organizer 창에서 "Distribute App" 클릭
   - TestFlight & App Store 선택

2. **App Store Connect 설정**
   - https://appstoreconnect.apple.com
   - 새 앱 생성
   - 메타데이터 입력

3. **베타 테스터 초대**
   - TestFlight 섹션에서 Internal/External 테스터 추가
   - 이메일 초대 발송

---

**도움이 필요하면 언제든 물어보세요!** 🙋‍♂️
