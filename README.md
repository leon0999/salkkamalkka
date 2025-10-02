# 🛍️ 살까말까 - 충동구매 방지 앱

## 📱 프로젝트 개요
**"7일 후에도 사고 싶다면, 진짜 필요한 것입니다"**

즉각적인 구매 욕구와 실제 필요를 구분하여 충동구매를 방지하는 iOS 앱입니다.

## ✨ 주요 기능

### 1️⃣ 위시리스트 등록
- 사고 싶은 물건을 빠르게 등록 (10초 내)
- 사진, 가격, 메모 입력
- 자동 7일 대기 상태 설정

### 2️⃣ 대기 기간 관리
- D-7 ~ D-1 카운트다운
- 실시간 프로그레스 바
- 대기 중인 총 금액 표시

### 3️⃣ 구매 의사 재확인
- 7일 후 푸시 알림
- 3가지 선택: 구매/포기/7일 연장
- 최대 3회까지 연장 가능

### 4️⃣ 절약 성과 대시보드
- 이번 달 절약 금액
- 총 누적 절약 금액
- 충동구매 방지율 (%)
- 완료된 아이템 이력

## 🛠 기술 스택

- **Language**: Swift 5.0+
- **UI Framework**: SwiftUI (iOS 15.0+)
- **Architecture**: MVVM + Combine
- **Storage**: UserDefaults (로컬 저장)
- **Notifications**: UserNotifications Framework
- **Photo Picker**: PhotosUI Framework

## 📂 프로젝트 구조

```
SalkkaMalkka/
├── Models/
│   ├── WishItem.swift          # 위시 아이템 모델
│   └── UserStats.swift         # 사용자 통계 모델
├── ViewModels/
│   └── WishListViewModel.swift # 위시리스트 ViewModel
├── Views/
│   ├── ContentView.swift       # 메인 화면
│   ├── AddWishItemView.swift   # 물건 등록 화면
│   ├── DecisionView.swift      # 재확인 화면
│   └── StatsView.swift         # 통계 화면
├── Services/
│   ├── DataManager.swift       # 데이터 관리
│   └── NotificationManager.swift # 알림 관리
├── Utilities/
│   └── Extensions.swift        # 확장 함수
└── SalkkaMalkkaApp.swift       # 앱 진입점
```

## 🚀 Xcode 프로젝트 생성 방법

### 1. Xcode에서 새 프로젝트 생성
1. Xcode 실행
2. **File > New > Project**
3. **iOS > App** 선택
4. 다음 정보 입력:
   - Product Name: `SalkkaMalkka`
   - Team: 본인의 Apple Developer 팀
   - Organization Identifier: `com.JaehyunPark` (또는 본인 ID)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **None** (Core Data 사용 안 함)
5. 저장 위치: `/Users/user/Desktop/SalkkaMalkka`

### 2. 프로젝트에 파일 추가
1. 프로젝트 네비게이터에서 기존 `ContentView.swift`, `SalkkaMalkkaApp.swift` 삭제
2. 프로젝트 루트에 그룹 생성:
   - Models
   - ViewModels
   - Views
   - Services
   - Utilities
3. 각 폴더의 Swift 파일들을 해당 그룹에 드래그앤드롭

### 3. Info.plist 권한 설정
**Info.plist에 다음 권한 추가** (프로젝트 설정 > Info 탭):

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>물건 사진을 등록하기 위해 사진 라이브러리 접근이 필요합니다.</string>

<key>NSCameraUsageDescription</key>
<string>물건 사진을 촬영하기 위해 카메라 접근이 필요합니다.</string>
```

### 4. 빌드 설정
- **Deployment Target**: iOS 15.0
- **Supported Destinations**: iPhone, iPad
- **Orientation**: Portrait

## 🎨 디자인 컬러

- **Primary (민트 그린)**: #00D9B2
- **Danger (코랄)**: #FF6B6B
- **Success (블루)**: #4A90E2
- 다크모드 자동 지원

## 📱 테스트 방법

### 시뮬레이터 실행
```bash
# iPhone 16 시뮬레이터
Product > Destination > iPhone 16
Cmd + R (Run)
```

### 실제 기기 테스트
1. iPhone을 Mac에 연결
2. Product > Destination > 본인 기기 선택
3. Signing & Capabilities > Team 설정
4. Cmd + R 실행

### 푸시 알림 테스트
- 실제 기기에서만 푸시 알림 테스트 가능
- 시뮬레이터는 로컬 알림만 지원 (제한적)

## 📊 목표 지표

- 출시 3개월: MAU 1,000명
- 출시 6개월: MAU 5,000명
- 출시 1년: MAU 10,000명
- 평균 절약: 월 10만원/사용자
- 앱스토어 평점: 4.5+ 목표

## 🔄 다음 단계

### Phase 1: TestFlight 베타 테스트
- [ ] 앱 아이콘 디자인 (1024x1024)
- [ ] Launch Screen 설정
- [ ] 버전 1.0.0 빌드
- [ ] TestFlight 업로드
- [ ] 30명 베타 테스터 모집

### Phase 2: 앱스토어 출시
- [ ] 스크린샷 제작 (iPhone 6.7", 5.5")
- [ ] 앱 설명 작성 (한글/영문)
- [ ] 키워드 설정
- [ ] 심사 제출

### Phase 3: 기능 확장 (v1.1+)
- [ ] iCloud 동기화 (CloudKit)
- [ ] 위젯 지원
- [ ] 공유 기능 (SNS)
- [ ] 프리미엄 기능 (구독)

## 📝 라이센스

MIT License

## 👨‍💻 개발자

- **Claude** (20년차 Google 풀스택 개발자)
- Email: noreply@anthropic.com
- GitHub: https://github.com/leon0999

---

**Made with ❤️ by Claude**
