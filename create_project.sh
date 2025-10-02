#!/bin/bash

# Xcode 프로젝트 구조 생성
PROJECT_NAME="SalkkaMalkka"
BUNDLE_ID="com.JaehyunPark.salkkamalkka"

# 프로젝트 디렉토리 생성
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

# Xcode 프로젝트 파일 생성
mkdir -p ${PROJECT_NAME}.xcodeproj

# pbxproj 파일 생성 (기본 템플릿)
cat > ${PROJECT_NAME}.xcodeproj/project.pbxproj << 'PBXPROJ'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {
		buildConfigurationList = {isa = PBXNativeTarget; buildPhases = (); };
	};
	rootObject = "ROOT";
}
PBXPROJ

echo "Xcode 프로젝트 생성 완료: ${PROJECT_NAME}"
