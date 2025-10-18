# 💰 SalkkaMalkka 수익화 계획서

## 📋 Executive Summary

**목표**: 무료 사용자를 프리미엄으로 전환하여 안정적인 월간 반복 수익(MRR) 창출
**수익 모델**: Freemium + 월간 구독 (₩3,990/월)
**예상 전환율**: 5-10% (업계 평균: 2-5%)
**목표 MAU**: 1,000명 → 예상 MRR: ₩199,500 - ₩399,000

---

## 🎯 비즈니스 모델 설계

### Tier 구조

| 기능 | 무료 | 프리미엄 (₩3,990/월) |
|------|------|---------------------|
| 상품 등록 | **최대 3개** | **무제한** |
| 통계 분석 | 기본 통계 | 상세 분석 + 트렌드 |
| 알림 | 기본 알림 | 커스텀 알림 |
| 데이터 백업 | ❌ | iCloud 백업 |
| 광고 | ⚠️ 표시 (선택) | ✅ 제거 |
| 프리미엄 배지 | ❌ | ✅ 지원자 배지 |

### Value Proposition (프리미엄 가치)

1. **핵심 Pain Point 해결**: "3개로는 부족해요" → 무제한 등록
2. **시간 가치**: 월 ₩3,990 = 하루 ₩133 = 커피 1/3잔
3. **절약 효과**: 충동구매 1회 방지 = 구독료 회수
4. **프리미엄 경험**: 광고 없는 깔끔한 UX

---

## 🏗️ 기술 구현 계획

### Phase 1: 기반 구조 (1-2일)

#### 1.1 Subscription Model 생성
```swift
// Models/SubscriptionTier.swift
enum SubscriptionTier: String, Codable {
    case free = "free"
    case premium = "premium_monthly"

    var maxWishItems: Int {
        switch self {
        case .free: return 3
        case .premium: return Int.max
        }
    }

    var displayName: String {
        switch self {
        case .free: return "무료"
        case .premium: return "프리미엄"
        }
    }

    var price: String {
        switch self {
        case .free: return "₩0"
        case .premium: return "₩3,990/월"
        }
    }
}

// Models/SubscriptionStatus.swift
struct SubscriptionStatus: Codable {
    var tier: SubscriptionTier
    var expiresAt: Date?
    var isActive: Bool

    var canAddMoreItems: Bool {
        // WishListViewModel에서 체크
    }
}
```

#### 1.2 UserDefaults 확장
```swift
extension UserDefaults {
    private enum Keys {
        static let subscriptionTier = "subscriptionTier"
        static let subscriptionExpiry = "subscriptionExpiry"
    }

    var subscriptionTier: SubscriptionTier {
        get { ... }
        set { ... }
    }
}
```

### Phase 2: StoreKit 2 구현 (2-3일)

#### 2.1 StoreKitManager 생성
```swift
// Services/StoreKitManager.swift
@MainActor
class StoreKitManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []

    static let shared = StoreKitManager()

    // Product ID (App Store Connect에서 설정)
    private let productIDs = ["premium_monthly_3990"]

    func loadProducts() async throws {
        products = try await Product.products(for: productIDs)
    }

    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            return transaction

        case .userCancelled, .pending:
            return nil

        @unknown default:
            return nil
        }
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
```

#### 2.2 Transaction Listener
```swift
func observeTransactionUpdates() -> Task<Void, Never> {
    Task.detached {
        for await result in Transaction.updates {
            if let transaction = try? self.checkVerified(result) {
                await self.updateSubscriptionStatus(transaction)
                await transaction.finish()
            }
        }
    }
}
```

### Phase 3: 상품 등록 제한 로직 (1일)

#### 3.1 WishListViewModel 수정
```swift
class WishListViewModel: ObservableObject {
    @Published var subscriptionStatus: SubscriptionStatus = .init(
        tier: .free,
        expiresAt: nil,
        isActive: false
    )

    var canAddWishItem: Bool {
        let currentCount = wishItems.filter { $0.status == .waiting }.count
        return currentCount < subscriptionStatus.tier.maxWishItems
    }

    var remainingSlots: Int {
        let currentCount = wishItems.filter { $0.status == .waiting }.count
        let max = subscriptionStatus.tier.maxWishItems
        return max == Int.max ? Int.max : max - currentCount
    }

    func addWishItem(...) {
        guard canAddWishItem else {
            // 프리미엄 업그레이드 프롬프트 표시
            showUpgradePrompt = true
            return
        }

        // 기존 로직
        ...
    }
}
```

### Phase 4: UI/UX 구현 (2-3일)

#### 4.1 Paywall Screen
```swift
// Views/PaywallView.swift
struct PaywallView: View {
    @StateObject private var storeManager = StoreKitManager.shared
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 24) {
            // 헤더
            VStack(spacing: 8) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)

                Text("프리미엄으로 업그레이드")
                    .font(.title)
                    .fontWeight(.bold)
            }

            // 기능 비교
            FeatureComparisonView()

            // 가격 및 구매 버튼
            if let product = storeManager.products.first {
                VStack(spacing: 12) {
                    Text("₩3,990/월")
                        .font(.system(size: 32, weight: .bold))

                    Text("첫 7일 무료 체험")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Button("무료로 시작하기") {
                        Task {
                            await purchase(product)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }

            // 약관
            LegalLinksView()
        }
        .padding()
    }
}
```

#### 4.2 Upgrade Prompt
```swift
// Views/Components/UpgradePromptView.swift
struct UpgradePromptView: View {
    var remainingSlots: Int
    var onUpgrade: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("무료 플랜: \(remainingSlots)개 남음")
                .font(.caption)
                .foregroundColor(.secondary)

            if remainingSlots == 0 {
                Button {
                    onUpgrade()
                } label: {
                    HStack {
                        Image(systemName: "crown.fill")
                        Text("프리미엄으로 무제한 등록")
                    }
                }
                .buttonStyle(.bordered)
                .tint(.yellow)
            }
        }
    }
}
```

#### 4.3 Settings 탭 추가
```swift
// Views/SettingsView.swift
struct SettingsView: View {
    @EnvironmentObject var viewModel: WishListViewModel
    @State private var showPaywall = false

    var body: some View {
        List {
            Section("구독") {
                HStack {
                    Text("현재 플랜")
                    Spacer()
                    Text(viewModel.subscriptionStatus.tier.displayName)
                        .foregroundColor(.secondary)
                }

                if viewModel.subscriptionStatus.tier == .free {
                    Button("프리미엄으로 업그레이드") {
                        showPaywall = true
                    }
                } else {
                    Button("구독 관리", role: .destructive) {
                        // Open App Store subscriptions
                        openSubscriptionManagement()
                    }
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(isPresented: $showPaywall)
        }
    }
}
```

### Phase 5: App Store Connect 설정 (1일)

#### 5.1 In-App Purchase 생성
1. **App Store Connect** → 내 앱 → SalkkaMalkka 선택
2. **기능** → **앱 내 구입** → **+** 버튼
3. **자동 갱신 구독** 선택
4. 구독 그룹 생성: "SalkkaMalkka Premium"
5. 제품 정보:
   - **참조 이름**: Premium Monthly Subscription
   - **제품 ID**: `premium_monthly_3990`
   - **구독 기간**: 1개월
   - **가격**: ₩3,990 (Tier 2)
   - **무료 체험**: 7일

#### 5.2 메타데이터 설정
```
구독 표시 이름: 프리미엄 플랜
설명: 무제한 상품 등록 + 광고 제거 + 프리미엄 기능

혜택:
• 상품 무제한 등록
• 광고 완전 제거
• 상세 통계 분석
• iCloud 자동 백업
• 프리미엄 지원자 배지
```

#### 5.3 스크린샷 (구독 홍보)
- Paywall 스크린샷
- 기능 비교 스크린샷
- 무제한 등록 화면

### Phase 6: 테스트 (1-2일)

#### 6.1 Sandbox 테스트
```swift
// App Store Connect → 사용자 및 액세스 → Sandbox 테스터
테스터 계정 생성:
- Email: test+salkkamalkka@icloud.com
- 비밀번호: TestPass1234!
```

#### 6.2 테스트 시나리오
```
✅ 무료 사용자: 3개까지 등록 가능
✅ 4번째 등록 시 Paywall 표시
✅ 구독 구매 성공
✅ 프리미엄: 무제한 등록
✅ 구독 취소 → 무료로 다운그레이드
✅ 구독 복원 (Restore Purchase)
```

---

## 📊 예상 수익 분석

### Conversion Funnel
```
MAU 1,000명
 ↓ 20% Paywall 도달
200명
 ↓ 10% 구독 전환
20명 유료 구독자
 × ₩3,990
= ₩79,800/월 MRR
```

### 성장 시나리오
| 월 | MAU | 전환율 | 구독자 | MRR |
|----|-----|--------|--------|-----|
| 1개월 | 500 | 5% | 25 | ₩99,750 |
| 3개월 | 1,000 | 8% | 80 | ₩319,200 |
| 6개월 | 2,000 | 10% | 200 | ₩798,000 |
| 12개월 | 5,000 | 12% | 600 | ₩2,394,000 |

---

## 🚀 실행 타임라인

### Week 1 (1-2일)
- [x] 계획 수립
- [ ] Subscription 모델 구현
- [ ] StoreKit 2 기반 구조

### Week 2 (3-4일)
- [ ] 상품 제한 로직
- [ ] Paywall UI 구현
- [ ] Settings 탭 추가

### Week 3 (1-2일)
- [ ] App Store Connect 구독 설정
- [ ] Sandbox 테스트
- [ ] 버그 수정

### Week 4 (배포)
- [ ] 프로덕션 빌드
- [ ] TestFlight 배포
- [ ] 앱 업데이트 제출

**총 소요 기간**: 약 2주 (파트타임 기준)

---

## 📝 필요한 공식 문서

### Apple 공식 문서 (필수)
1. ✅ **StoreKit 2 공식 가이드**
   - URL: https://developer.apple.com/documentation/storekit
   - 이유: 구독 구현 표준 방법

2. ✅ **In-App Purchase 가이드**
   - URL: https://developer.apple.com/in-app-purchase/
   - 이유: App Store Connect 설정

3. ✅ **Auto-Renewable Subscriptions**
   - URL: https://developer.apple.com/documentation/storekit/in-app_purchase/original_api_for_in-app_purchase/subscriptions_and_offers
   - 이유: 구독 갱신 로직

### 참고 문서 (권장)
- SwiftUI StoreKit Views (iOS 17+)
- Transaction Listener Best Practices
- Subscription Offers & Promotions

---

## ⚠️ 주의사항

### 법적/정책
1. **앱 심사 가이드라인 준수**
   - 구독 취소 방법 명시
   - 자동 갱신 안내 필수
   - 약관 및 개인정보처리방침 링크

2. **환불 정책**
   - Apple이 관리
   - 구독 관리 링크 제공

### 기술적
1. **Transaction 검증** 필수 (서버 검증 권장)
2. **Offline 상태** 고려
3. **구독 복원** 기능 필수

---

## 🎯 Success Metrics (KPI)

- **전환율**: 5% 이상
- **Churn Rate**: 20% 이하
- **LTV (Lifetime Value)**: ₩23,940 (평균 6개월 구독)
- **CAC (Customer Acquisition Cost)**: ₩5,000 이하

---

## 📞 다음 단계

**즉시 시작 가능합니다!**

필요한 공식 문서가 있으면 요청하세요. 그렇지 않으면:
1. Phase 1부터 순차적으로 코드 구현 시작
2. Xcode 프로젝트에 Models/Services 추가
3. StoreKit 2 통합

**준비 완료 - 지시만 주세요!** 🚀
