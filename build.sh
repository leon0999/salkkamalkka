#!/bin/bash

# 🛍️ 살까말까 (SalkkaMalkka) - 빌드 스크립트
# iOS 앱 빌드 및 시뮬레이터 실행

set -e  # 에러 발생 시 즉시 종료

echo "🚀 살까말까 앱 빌드 시작..."

# 프로젝트 경로
PROJECT_PATH="$(pwd)/SalkkaMalkka.xcodeproj"
SCHEME="SalkkaMalkka"
CONFIGURATION="Debug"

# 기본 시뮬레이터 (iPhone 16)
SIMULATOR="iPhone 16"

# 색상 출력
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 함수: 에러 메시지
error() {
    echo -e "${RED}❌ 에러: $1${NC}"
    exit 1
}

# 함수: 성공 메시지
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 함수: 경고 메시지
warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 1. 프로젝트 존재 확인
if [ ! -d "$PROJECT_PATH" ]; then
    error "Xcode 프로젝트를 찾을 수 없습니다: $PROJECT_PATH"
fi

success "Xcode 프로젝트 확인 완료"

# 2. xcodebuild 확인
if ! command -v xcodebuild &> /dev/null; then
    error "xcodebuild를 찾을 수 없습니다. Xcode가 설치되어 있는지 확인하세요."
fi

# 3. 시뮬레이터 확인
echo "📱 사용 가능한 시뮬레이터 확인..."
xcrun simctl list devices available | grep "$SIMULATOR" || warning "iPhone 16 시뮬레이터를 찾을 수 없습니다. 기본 시뮬레이터를 사용합니다."

# 4. 클린 빌드 (선택 사항)
if [ "$1" == "clean" ]; then
    echo "🧹 클린 빌드 실행 중..."
    xcodebuild clean \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" || error "클린 실패"
    success "클린 완료"
fi

# 5. 빌드
echo "🔨 앱 빌드 중..."
xcodebuild build \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -sdk iphonesimulator \
    -destination "platform=iOS Simulator,name=$SIMULATOR" \
    | xcpretty || error "빌드 실패"

success "빌드 성공!"

# 6. 시뮬레이터 실행 (선택 사항)
if [ "$1" == "run" ] || [ "$2" == "run" ]; then
    echo "📲 시뮬레이터에서 앱 실행 중..."

    # 시뮬레이터 부팅
    DEVICE_ID=$(xcrun simctl list devices available | grep "$SIMULATOR" | head -1 | grep -oE '\(([A-F0-9-]+)\)' | tr -d '()')

    if [ -z "$DEVICE_ID" ]; then
        warning "시뮬레이터 ID를 찾을 수 없습니다."
    else
        xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
        open -a Simulator

        # 앱 실행
        sleep 2
        xcrun simctl install "$DEVICE_ID" "$(find ~/Library/Developer/Xcode/DerivedData -name "SalkkaMalkka.app" | head -1)" || warning "앱 설치 실패"
        xcrun simctl launch "$DEVICE_ID" com.JaehyunPark.SalkkaMalkka || warning "앱 실행 실패"

        success "시뮬레이터에서 앱이 실행되었습니다!"
    fi
fi

echo ""
echo "========================================="
echo "✨ 살까말까 앱 빌드 완료!"
echo "========================================="
echo ""
echo "다음 단계:"
echo "  1. Xcode에서 프로젝트 열기:"
echo "     open SalkkaMalkka.xcodeproj"
echo ""
echo "  2. 시뮬레이터에서 실행:"
echo "     ./build.sh run"
echo ""
echo "  3. 클린 빌드:"
echo "     ./build.sh clean"
echo ""
