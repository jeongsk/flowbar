# Flowbar Technical Design

## Context

Flowbar는 macOS 메뉴바 환경을 개선하기 위한 유틸리티 앱입니다. 현재 PRD가 작성되었으며, 스펙이 정의되었습니다. 이제 실제 구현을 위한 기술 설계가 필요합니다.

### 현재 상태
- PRD 완료 (docs/PRD.md)
- OpenSpec 스펙 정의 완료 (6개 기능)
- 프로젝트 구조 초기화 필요

### 제약사항
- macOS 13.0 Ventura 이상 지원
- Apple Silicon + Intel 호환
- 메모리 사용량 < 50MB
- 번들 크기 < 10MB
- Accessibility 권한 필수

### 이해관계자
- 개발자: 유지보수 가능한 코드베이스
- 사용자: 안정적이고 빠른 성능
- macOS: 시스템 API 호환성

## Goals / Non-Goals

**Goals:**
- 메뉴바 아이콘 필터링 메커니즘 구현
- 모드 관리 시스템 구축
- 포커스 도용 방지 기능 구현
- 미니 런처 개발
- 온보딩 플로우 구현
- SwiftData 기반 데이터 지속성
- SwiftUI + AppKit 하이브리드 UI

**Non-Goals:**
- 클라우드 동기화 (v2.0 고려)
- AI 기반 모드 추천 (v2.0)
- 팀 워크플로우 공유 (v2.0)
- iOS/iPadOS 지원

## Decisions

### 1. 아키텍처: MVVM + Coordinator 패턴

**결정:** SwiftUI 기반 MVVM 패턴에 Coordinator를 추가하여 네비게이션 관리

**이유:**
- SwiftUI가 선언적 UI에 최적화
- MVVM은 테스트 가능성과 계층 분리 제공
- Coordinator가 복잡한 모드 전환 로직을 중앙화
- Apple이 권장하는 modern macOS app 패턴

**대안:**
- UIKit + AppKit: SwiftUI가 더 빠른 개발 가능
- Pure Redux: 오버엔지니어링 위험

### 2. 메뉴바 아이콘 제어: Accessibility API

**결정:** AXUIElement와 AXObserver를 사용하여 메뉴바 아이콘 조작

**이유:**
- macOS에서 메뉴바 아이콘 숨김의 유일한 방법
- 실시간 이벤트 감지 가능
- Apple이 공식 지원 (비록 권한 필요)

**대안:**
- private API: 안정성 위험, App Store 거부 가능성

**구현:**
```swift
// AXObserver를 통한 메뉴바 모니터링
// Accessibility API로 아이콘 위치 파악
// CGEvent로 키보드 이벤트 필터링 (포커스 가드)
```

### 3. 데이터 저장: SwiftData

**결정:** SwiftData를 사용하여 모든 설정과 모드 저장

**이유:**
- macOS 14+에서 Core Data의 현대적 대체재
- Swift-native, 코드 적음
- 자동 UI 바인딩 지원
- 마이그레이션 간단

**대안:**
- Core Data: 더 많은 보일러플레이트
- UserDefaults: 복잡한 데이터 구조에 부적합
- 파일 기반: 동시성 처리 어려움

### 4. 포커스 가드: CGEvent Tap

**결정:** CGEvent Tap으로 키보드/마우스 이벤트 필터링

**이유:**
- 시스템 레벨 이벤트 인터셉트 가능
- 새 창 포커스 방지에 효과적
- 이미 Accessibility API 사용 중이므로 권한 문제 없음

**구현:**
```swift
let eventMask = (1 << CGEventType.keyDown.rawValue)
CGEvent.tapCreate(tap: .cgSessionEventTap,
                 place: .headInsertEventTap,
                 options: .defaultTap,
                 eventsOfInterest: CGEventMask(eventMask),
                 callback: { ... },
                 userInfo: nil)
```

### 5. UI 프레임워크: SwiftUI + AppKit 하이브리드

**결정:** 메인 UI는 SwiftUI, 메뉴바는 NSStatusItem (AppKit)

**이유:**
- SwiftUI로 빠른 UI 개발
- NSStatusItem이 메뉴바 앱에 필수적
- NSHostingView로 SwiftUI ↔ AppKit 브릿지
- 시스템 설정 창은 SwiftUI

**하이브리드 예시:**
```swift
// AppKit: 메뉴바 아이템
let statusItem = NSStatusBar.system.statusItem(withLength: NSVariableStatusItemLength)

// SwiftUI: 팝오버 UI
let popover = NSPopover()
popover.contentViewController = NSHostingController(rootView: ModeSwitcherView())
```

### 6. 프로젝트 구조

**결정:** 기능별 모듈화

```
Flowbar/
├── App/
│   ├── FlowbarApp.swift          # 앱 진입점
│   └── AppDelegate.swift         # AppKit 위임
├── Core/
│   ├── Models/                   # SwiftData 모델
│   ├── Persistence/              # 데이터 저장소
│   └── Extensions/               # Swift 확장
├── Features/
│   ├── MenuBar/                  # 메뉴바 아이콘 관리
│   ├── ModeSwitcher/             # 모드 전환
│   ├── FocusGuard/               # 포커스 가드
│   ├── Launcher/                 # 미니 런처
│   └── Onboarding/               # 온보딩
├── Shared/
│   ├── Views/                    # 공통 UI 컴포넌트
│   ├── ViewModels/               # 공통 뷰모델
│   └── Utils/                    # 유틸리티
└── Resources/
    ├── Assets.xcassets           # 이미지 리소스
    └── Localizable.xcstrings     # 현지화
```

### 7. 의존성 관리: Swift Package Manager

**결정:** SPM으로 외부 의존성 관리

**사용 패키지:**
- (예정) KeyboardShortcuts: 단축키 관리
- (예정) Sparkle: 자동 업데이트
- (예정) Sauce: 자동화 테스트

## Risks / Trade-offs

### 1. Accessibility API 거부
**위험:** 사용자가 Accessibility 권한 거부 시 핵심 기능 작동 불가

**완화:**
- 온보딩에서 권한의 중요성 명확히 설명
- 권한 없이도 기본 기능 (모드 전환) 작동하게 설계
- 권한 설정 바로가기 제공

### 2. macOS 업데이트 호환성
**위험:** macOS 업데이트로 API 변경 시 기능 파손

**완화:**
- 공식 API만 사용 (private API 피하기)
- 베타 테스트로 새 macOS 버전 검증
- 최소한 2개의 최신 macOS 버전 지원

### 3. 성능 저하
**위험:** 메뉴바 모니터링이 CPU 사용량 증가

**완화:**
- AXObserver 이벤트 기반 (폴링 아님)
- 변경 시에만 아이콘 업데이트
- 프로파일링으로 병목 발견 및 최적화

### 4. App Store 거부
**위험:** Accessibility API 사용으로 심사 거부 가능성

**완화:**
- Privacy Policy 명확화
- 권한 사용 이유 상세 설명
- Accessibility 가이드라인 준수
- 우선 직접 판매로 검증

### 5. 데이터 마이그레이션
**위험:** SwiftData 스키마 변경 시 기존 데이터 손실

**완화:**
- SwiftData의 자동 마이그레이션 활용
- 주요 업데이트 전 백업 프롬프트
- 마이그레이션 실패 시 복구 메커니즘

## Migration Plan

### 단계 1: 개발 환경 설정 (1주)
- Xcode 프로젝트 생성
- SwiftData 모델 정의
- 기본 프로젝트 구조 설정

### 단계 2: 핵심 기능 개발 (4주)
- 주차 1: 메뉴바 아이콘 감지 및 필터링
- 주차 2: 모드 관리 시스템
- 주차 3: 포커스 가드
- 주차 4: 미니 런처

### 단계 3: UI/UX 완성 (2주)
- 온보딩 플로우
- 설정 UI
- 애니메이션 및 세부 사항

### 단계 4: 테스트 및 최적화 (2주)
- 단위 테스트
- UI 테스트
- 성능 프로파일링
- 버그 수정

### 단계 5: 베타 출시 (1주)
- TestFlight/직접 배포
- 피드백 수집
- 주요 이슈 수정

### 단계 6: 정식 출시
- 랜딩 페이지 연동
- Product Hunt 출시
- 문서 완성

### 롤백 전략
- 이전 버전 dmg 유지
- SwiftData 마이그레이션 실패 시 복구 UI
- 자동 업데이트 롤백 메커니즘

## Open Questions

1. **단축키 기본값:** ⌘+Space가 Spotlight와 충돌. 대안?
   - 옵션: ⌘+⌥+Space, ⌘+⌃+Space
   - 해결: 온보딩에서 충돌 감지 및 대안 제안

2. **시스템 아이콘 숨김:** Control Center 같은 시스템 아이콘 숨김 가능?
   - 해결: 테스트 필요, 불가능 시 경고 표시

3. **다중 모니터:** 메뉴바가 각 디스플레이에 다를 때 처리?
   - 해결: 주 디스플레이만 모니터링 (MVP)

4. **라이선스 검증:** 일회성 구매 vs 구독 모델?
   - 해결: Paddle/Gumroad로 라이선스 키 검증 (MVP 후)

5. **앱 심사:** Accessibility API 사용 설명을 어느 정도로?
   - 해결: App Store Review Notes에 상세 기술 문서 포함

## 성능 목표

| 메트릭 | 목표 | 측정 방법 |
|--------|------|-----------|
| 메뉴바 아이콘 필터링 | < 100ms | Instruments Time Profiler |
| 모드 전환 | < 200ms | UI 반응성 측정 |
| 메모리 사용 | < 50MB | Instruments Allocations |
| CPU 사용 (idle) | < 1% | Instruments CPU Profiler |
| 앱 시작 시간 | < 2초 | Launch time 측정 |
