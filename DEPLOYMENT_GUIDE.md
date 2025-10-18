# 📱 SalkkaMalkka 인앱결제 배포 가이드

## ✅ 완료된 개발 항목

### 1. StoreKit 2 기반 구조 ✅
- [x] `SubscriptionTier.swift` - 무료/프리미엄 티어 정의
- [x] `StoreKitManager.swift` - IAP 중앙 관리자
- [x] `WishListViewModel.swift` - 상품 등록 제한 로직
- [x] `PaywallView.swift` - 프리미엄 업그레이드 UI
- [x] `SettingsView.swift` - 구독 관리 화면
- [x] `ContentView.swift` - 구독 상태 배지 통합
- [x] `SalkkaMalkka.storekit` - 로컬 테스트 설정

### 2. 비즈니스 로직 ✅
- 무료: 최대 3개 상품 등록
- 프리미엄: 무제한 상품 등록
- 4번째 상품 추가 시 자동 Paywall 표시
- 구독 상태 실시간 추적 및 UI 업데이트

---

## 🚀 다음 단계: App Store Connect 설정

### Phase 1: App Store Connect 로그인
1. https://appstoreconnect.apple.com 접속
2. Apple Developer 계정으로 로그인
3. "My Apps" → "SalkkaMalkka" 선택

### Phase 2: 인앱 구입 제품 생성

#### 1단계: 구독 그룹 생성
```
[App Store Connect] → [기능] → [인앱 구입 및 구독]
→ [구독 그룹 생성]

그룹 이름: SalkkaMalkka Premium
참조 이름: Premium Subscription Group
```

#### 2단계: 구독 제품 생성
```
[구독 그룹] → [구독 생성]

제품 ID: premium_monthly_3990
참조 이름: Premium Monthly Subscription
구독 기간: 1개월
가격: ₩3,990 (Tier 선택)
```

#### 3단계: 무료 체험 설정
```
[무료 체험 또는 소개 가격] → [무료 체험 추가]

기간: 7일
사용 자격: 신규 구독자
```

#### 4단계: 현지화 정보 입력

**한국어 (ko)**
```
표시 이름: 프리미엄 월간 구독
설명: 상품 무제한 등록, 고급 통계, iCloud 백업, 광고 제거
```

**영어 (en-US)**
```
Display Name: Premium Monthly
Description: Unlimited items, advanced stats, iCloud backup, ad-free
```

#### 5단계: 심사 정보 입력
```
스크린샷: Paywall 화면 캡처 (필수)
심사 노트:
- 무료 사용자는 3개까지 상품 등록 가능
- 4번째 상품 추가 시 Paywall 표시
- 프리미엄 구독 시 무제한 등록 가능
```

---

## 🧪 로컬 테스트 방법

### Xcode StoreKit Configuration 사용

#### 1단계: 프로젝트 설정
```
Xcode → [Product] → [Scheme] → [Edit Scheme...]
→ [Run] → [Options]
→ StoreKit Configuration: SalkkaMalkka.storekit 선택
```

#### 2단계: 테스트 시나리오
1. **무료 티어 제한 테스트**
   - 앱 실행 → 상품 3개 등록
   - 4번째 상품 추가 시도 → Paywall 표시 확인

2. **구매 플로우 테스트**
   - Paywall → "무료로 시작하기" 클릭
   - StoreKit 테스트 다이얼로그 → "구독" 선택
   - 프리미엄 배지 표시 확인

3. **무제한 등록 테스트**
   - 프리미엄 활성화 후 상품 4개 이상 등록
   - Paywall 미표시 확인

4. **구독 상태 확인**
   - 설정 → 구독 관리 화면
   - "프리미엄" 상태 및 만료일 확인

---

## 🧑‍💻 Sandbox 테스트 (App Store Connect 연동)

### 1단계: Sandbox 테스터 계정 생성
```
[App Store Connect] → [사용자 및 액세스] → [Sandbox 테스터]
→ [테스터 추가]

이메일: test@example.com
비밀번호: Test1234!
국가/지역: 대한민국
```

### 2단계: 기기에서 Sandbox 로그인
```
설정 → [App Store] → [Sandbox Account]
→ Sandbox 테스터 계정으로 로그인
```

### 3단계: 실제 구매 플로우 테스트
1. Xcode에서 Scheme 설정 변경
   - StoreKit Configuration: None (실제 App Store 사용)
2. 기기에 빌드 & 실행
3. Paywall → 구매 진행
4. Sandbox 계정으로 결제 (실제 결제 안 됨)
5. 구독 활성화 확인

---

## 📋 App Store 심사 체크리스트

### 제출 전 필수 확인 사항

- [ ] **Product ID 일치**
  ```swift
  // StoreKitManager.swift
  private let productIDs: Set<String> = ["premium_monthly_3990"]

  // App Store Connect
  제품 ID: premium_monthly_3990
  ```

- [ ] **스크린샷 준비**
  - Paywall 화면 (필수)
  - 프리미엄 기능 화면 (권장)
  - 설정 → 구독 관리 화면 (권장)

- [ ] **심사 노트 작성**
  ```
  테스트 계정: test@example.com / Test1234!

  테스트 절차:
  1. 앱 실행 후 상품 3개 등록
  2. 4번째 상품 추가 시도 → Paywall 자동 표시
  3. "무료로 시작하기" 클릭하여 구독 진행
  4. 프리미엄 활성화 후 무제한 등록 가능

  주의사항:
  - Sandbox 테스터 계정으로 테스트 필요
  - 7일 무료 체험 제공
  ```

- [ ] **개인정보처리방침 및 이용약관 URL**
  ```swift
  // SettingsView.swift 수정 필요
  Link(destination: URL(string: "https://YOUR_ACTUAL_DOMAIN/terms")!)
  Link(destination: URL(string: "https://YOUR_ACTUAL_DOMAIN/privacy")!)
  ```

- [ ] **복원 기능 테스트**
  - 앱 삭제 → 재설치 → "구매 복원" 클릭
  - 프리미엄 상태 정상 복원 확인

---

## 🐛 문제 해결 가이드

### 1. "Invalid Product ID" 에러
```
원인: App Store Connect 제품 ID와 코드 불일치
해결:
1. App Store Connect에서 제품 ID 확인
2. StoreKitManager.swift의 productIDs 수정
3. 클린 빌드 후 재실행
```

### 2. 제품이 로드되지 않음
```
원인:
- App Store Connect 제품 승인 대기 중
- Sandbox 로그인 안 됨

해결:
1. App Store Connect에서 제품 상태 확인 ("Ready to Submit")
2. 설정 → App Store → Sandbox 계정 로그인 확인
3. 네트워크 연결 확인
```

### 3. 거래 검증 실패
```
원인:
- 앱 서명 문제
- JWS 검증 실패

해결:
1. Xcode → Signing & Capabilities 확인
2. 개발자 계정 로그인 상태 확인
3. Provisioning Profile 재생성
```

### 4. 구독 상태가 업데이트 안 됨
```
원인: Transaction Listener 미작동

해결:
1. 앱 완전 종료 후 재시작
2. StoreKitManager 초기화 확인
3. 로그 확인: "🔔 Transaction update: ..."
```

---

## 📊 KPI 모니터링 (배포 후)

### 추적할 지표
1. **전환율 (Conversion Rate)**
   - Paywall 노출 → 구독 시작
   - 목표: 5-10%

2. **무료 체험 → 유료 전환**
   - 7일 체험 종료 → 결제 유지
   - 목표: 40-60%

3. **이탈률 (Churn Rate)**
   - 월간 구독 해지율
   - 목표: < 5%

4. **ARPU (Average Revenue Per User)**
   - 사용자당 평균 수익
   - 목표: ₩2,000+

### Analytics 이벤트 추가 (권장)
```swift
// PaywallView.swift
Analytics.logEvent("paywall_shown")
Analytics.logEvent("paywall_purchase_started")
Analytics.logEvent("paywall_purchase_success")
Analytics.logEvent("paywall_purchase_failed")
```

---

## 🎯 론칭 로드맵

### Week 1: 테스트 및 검증
- [ ] StoreKit Configuration 로컬 테스트
- [ ] Sandbox 계정 생성 및 테스트
- [ ] 모든 구매 플로우 검증
- [ ] UI/UX 최종 점검

### Week 2: App Store Connect 설정
- [ ] 인앱 구입 제품 생성
- [ ] 스크린샷 및 메타데이터 준비
- [ ] 심사 노트 작성
- [ ] 제출

### Week 3: 심사 대기
- [ ] Apple 심사 피드백 대응
- [ ] 버그 수정 (필요 시)
- [ ] 재제출

### Week 4: 출시
- [ ] 앱 승인 후 출시
- [ ] 성과 모니터링
- [ ] 사용자 피드백 수집

---

## 📞 지원 문서

### Apple 공식 문서
- [StoreKit 2 Overview](https://developer.apple.com/documentation/storekit)
- [In-App Purchase](https://developer.apple.com/in-app-purchase/)
- [Auto-Renewable Subscriptions](https://developer.apple.com/app-store/subscriptions/)
- [Testing In-App Purchase](https://developer.apple.com/documentation/storekit/in-app_purchase/testing_in-app_purchases_in_xcode)

### 문제 발생 시
1. Xcode Console 로그 확인
2. App Store Connect → Activity 확인
3. Apple Developer Forums 검색
4. support@salkkamalkka.com으로 문의

---

## ✅ 최종 점검 사항

출시 전 아래 항목을 모두 확인하세요:

- [ ] Product ID가 코드와 App Store Connect에서 일치
- [ ] 무료 체험 7일 설정 완료
- [ ] Paywall UI 완성 및 테스트
- [ ] 3개 제한 로직 작동 확인
- [ ] 설정 화면 구독 관리 기능 작동
- [ ] 구매 복원 기능 작동
- [ ] Sandbox 테스트 완료
- [ ] 개인정보처리방침 URL 업데이트
- [ ] 이용약관 URL 업데이트
- [ ] 스크린샷 3장 이상 준비
- [ ] 심사 노트 작성 완료

---

**🎉 축하합니다! 프리미엄 구독 시스템이 준비되었습니다!**

이제 App Store Connect에서 제품을 설정하고 심사를 제출하면 됩니다.
수익화 성공을 기원합니다! 🚀
