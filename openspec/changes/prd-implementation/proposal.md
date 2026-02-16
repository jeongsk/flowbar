# Flowbar PRD Implementation Proposal

## Why

Flowbar는 macOS 사용자가 겪는 메뉴바 혼란, 포커스 도용, 그리고 컨텍스트 스위칭 비용 문제를 해결하기 위해 기획된 앱입니다. PRD가 작성되었으나, 아직 구현이 시작되지 않았습니다. 이 변경사항은 PRD에 정의된 MVP(v1.0) 기능을 실제 작동하는 제품으로 구현하는 것을 목표로 합니다.

## What Changes

Flowbar MVP(v1.0) 구현을 위한 핵심 변경사항:

- **macOS 메뉴바 앱**: Swift + SwiftUI로 메뉴바 상주 앱 개발
- **모드 관리 시스템**: 사용자 정의 모드(코딩, 디자인, 회의, 집중 등) 생성 및 전환 기능
- **메뉴바 아이콘 필터링**: 각 모드별 표시할 메뉴바 아이콘 선택적 표시/숨김
- **Focus 가드**: 새 창의 키보드 포커스 가로채기 방지
- **미니 런처**: Launchpad 대체 기능 (현재 모드에 맞는 앱 표시 + 검색)
- **온보딩 플로우**: 기본 모드 생성, 메뉴바 아이콘 스캔, 할당 UI

## Capabilities

### New Capabilities
- `menubar-icon-management`: 메뉴바 아이콘 감지, 필터링, 표시/숨김 제어
- `mode-switching`: 모드 정의, 저장, 전환 기능
- `focus-guard`: 포커스 도용 방지, 알림 제어
- `mini-launcher`: 앱 검색, 실행, 모드별 필터링
- `onboarding`: 초기 설정 마법사, 기본 모드 생성
- `data-persistence`: 모드 설정, 아이콘 할당 저장 (SwiftData)

### Modified Capabilities
없음 (새 프로젝트)

## Impact

### 영향받는 시스템
- **macOS 시스템**: Accessibility API, NSStatusItem, NSWorkspace 사용
- **사용자 권한**: Accessibility 권한 필수

### 기술적 의존성
- Swift 5.9+
- macOS 13.0 Ventura 이상
- SwiftUI + AppKit 하이브리드
- SwiftData

### 사용자 영향
- 메뉴바 공간 효율화
- 작업 중 방해 감소
- 컨텍스트별 빠른 전환
