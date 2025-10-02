# 🌐 GitHub 저장소 생성 가이드

## 📋 GitHub에 프로젝트 업로드하기

### 1️⃣ GitHub 저장소 생성

1. **https://github.com** 접속 후 로그인
2. 우측 상단 **+** 버튼 > **New repository** 클릭
3. 저장소 정보 입력:
   ```
   Repository name: salkkamalkka
   Description: 🛍️ 충동구매 방지 iOS 앱 - "7일 후에도 사고 싶다면, 진짜 필요한 것입니다"
   Visibility: Public (또는 Private)

   ❌ Add a README file (체크 해제)
   ❌ Add .gitignore (체크 해제)
   ❌ Choose a license (체크 해제)
   ```
4. **Create repository** 클릭

---

### 2️⃣ 로컬 저장소를 GitHub에 푸시

터미널에서 프로젝트 폴더로 이동 후 실행:

```bash
cd /Users/user/Desktop/SalkkaMalkka

# GitHub 저장소 연결 (이미 완료됨)
git remote add origin https://github.com/[본인계정]/salkkamalkka.git

# 메인 브랜치로 푸시
git push -u origin main
```

**본인 GitHub 계정으로 변경하세요!**
- 예: `https://github.com/leon0999/salkkamalkka.git`

---

### 3️⃣ GitHub 저장소 확인

푸시 완료 후 GitHub 저장소에 접속하면 다음 파일들이 보여야 합니다:

```
salkkamalkka/
├── README.md
├── XCODE_SETUP_GUIDE.md
├── GITHUB_SETUP.md
├── .gitignore
├── SalkkaMalkka/
│   ├── Models/
│   │   ├── WishItem.swift
│   │   └── UserStats.swift
│   ├── ViewModels/
│   │   └── WishListViewModel.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── AddWishItemView.swift
│   │   ├── DecisionView.swift
│   │   └── StatsView.swift
│   ├── Services/
│   │   ├── DataManager.swift
│   │   └── NotificationManager.swift
│   ├── Utilities/
│   │   └── Extensions.swift
│   └── SalkkaMalkkaApp.swift
└── create_project.sh
```

---

### 4️⃣ README 작성 (선택 사항)

GitHub 저장소 메인 페이지에 표시될 내용:
- ✅ 이미 `README.md` 파일 생성됨
- 프로젝트 개요, 기능, 기술 스택 포함
- 스크린샷 추가 (앱 완성 후)

---

### 5️⃣ GitHub Pages 설정 (선택 사항)

랜딩 페이지 또는 프로젝트 문서 호스팅:
1. Settings > Pages
2. Source: Deploy from a branch
3. Branch: main > /docs (문서 폴더 생성 후)

---

## 🔐 Private 저장소 주의사항

**Private으로 설정한 경우:**
- 베타 테스터들과 공유 시 권한 부여 필요
- Settings > Collaborators 에서 초대

**Public으로 설정한 경우:**
- 오픈소스로 공개
- 다른 개발자들이 참고 가능
- MIT License 추가 권장

---

## 🚀 지속적 배포 (CI/CD) 설정

**GitHub Actions 활용:**
1. `.github/workflows/ios.yml` 파일 생성
2. Xcode Cloud 또는 Fastlane 설정
3. 자동 빌드 및 TestFlight 배포

---

## 📊 프로젝트 관리

**GitHub 기능 활용:**
- **Issues**: 버그 추적, 기능 요청
- **Projects**: 칸반 보드로 작업 관리
- **Wiki**: 상세 문서 작성
- **Discussions**: 커뮤니티 피드백

---

**축하합니다! 🎉 GitHub 저장소 설정 완료!**
