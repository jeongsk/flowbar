# Flowbar - 프로젝트 요약

## 📁 프로젝트 구조

```
projects/flowbar/
├── docs/
│   ├── PRD.md                    # 제품 요구사항 문서
│   ├── technical-spec.md         # 기술 스펙
│   └── community-posts.md        # 커뮤니티 포스팅 초안
├── landing/
│   └── index.html                # 랜딩 페이지
└── src/
    ├── FlowbarApp.swift          # 앱 진입점
    ├── AppDelegate.swift         # 메뉴바 아이콘, 상태 관리
    ├── Models/
    │   ├── Mode.swift            # 모드 데이터 모델
    │   ├── MenuBarItem.swift     # 메뉴바 아이템 모델
    │   └── Workflow.swift        # 워크플로우 모델
    ├── Controllers/
    │   ├── ModeManager.swift     # 모드 관리
    │   ├── MenuBarController.swift # 메뉴바 제어
    │   ├── FocusGuard.swift      # 포커스 가드
    │   └── WorkflowEngine.swift  # 워크플로우 엔진
    ├── Views/
    │   ├── ModePickerView.swift  # 모드 선택 팝업
    │   ├── SettingsView.swift    # 설정 윈도우
    │   └── ModeEditorView.swift  # 모드 편집기
    ├── Info.plist                # 앱 정보
    └── Flowbar.entitlements      # 권한 설정
```

---

## ✅ 완료된 작업

| 항목 | 상태 | 비고 |
|-----|------|------|
| 제품 기획 (PRD) | ✅ | 기능, 타겟, 비즈니스 모델 정의 |
| 기술 스펙 | ✅ | 아키텍처, API, 성능 목표 |
| 랜딩 페이지 | ✅ | HTML/CSS 완성, 이메일 수집 폼 |
| 커뮤니티 포스팅 | ✅ | Reddit, HN, 클리앙, IH 초안 |
| Swift 코드 | ✅ | 핵심 모듈 구현 |
| UI 뷰 | ✅ | SwiftUI 뷰 3개 |

---

## ⚠️ 검토 필요 사항

### 1. 랜딩 페이지

**파일:** `landing/index.html`

**확인 포인트:**
- [ ] 가격 ($19) 괜찮은지
- [ ] 문구/톤앤매너
- [ ] 스크린샷/목업 이미지 추가 필요 (현재 `[Flowbar App Screenshot]` 텍스트)
- [ ] 이메일 수집 서비스 연동 (현재 `<form action="#">`)
  - 추천: ConvertKit, Mailchimp, 또는 직접 구현

### 2. 커뮤니티 포스팅

**파일:** `docs/community-posts.md`

**확인 포인트:**
- [ ] 내용이 너무 길지 않은지
- [ ] 톤이 적절한지
- [ ] 링크 삽입할 곳 (랜딩 페이지 URL)

### 3. 기술 스펙

**파일:** `docs/technical-spec.md`

**확인 포인트:**
- [ ] SwiftUI + AppKit 하이브리드 접근 동의하는지
- [ ] Accessibility API 의존 괜찮은지
- [ ] 샌드박스 비활성화 (App Store 등록 제약) 괜찮은지

### 4. Swift 코드

**폴더:** `src/`

**확인 포인트:**
- [ ] 코드 스타일/구조 괜찮은지
- [ ] 누락된 기능 없는지
- [ ] 실제 Xcode 프로젝트 생성 후 파일 복사 필요

---

## 🚀 다음 단계

### 즉시 진행 가능

1. **랜딩 페이지 배포**
   - Vercel, Netlify, GitHub Pages 중 선택
   - 이메일 수집 서비스 연동
   - URL 확보 후 커뮤니티 포스팅 수정

2. **커뮤니티 포스팅**
   - r/macapps에 "이런 거 만들면 쓰실?" 포스팅
   - HN Ask HN 포스팅
   - 피드백 수집

### 개발 착수 (검증 후)

3. **Xcode 프로젝트 생성**
   ```bash
   # Mac App 프로젝트 생성
   # src/ 파일들 복사
   # SwiftData 설정
   # Signing & Capabilities 설정
   ```

4. **실제 디바이스 테스트**
   - Accessibility API 실제 동작 확인
   - 다양한 macOS 버전 테스트

---

## 📊 KPI

### 검증 단계 (2주)

| 지표 | 목표 | 현재 |
|-----|------|------|
| 이메일 등록 | 100개 | 0 |
| 랜딩 페이지 방문 | 1,000 | 0 |
| 피드백 응답 | 20개 | 0 |

### 출시 후 (1개월)

| 지표 | 목표 |
|-----|------|
| 다운로드 | 500 |
| 유료 전환 | 25건 (5%) |
| 매출 | $475 |

---

## 🔗 주요 링크 (작성 필요)

| 항목 | URL |
|-----|-----|
| 랜딩 페이지 | TBD |
| 이슈 트래커 | TBD |
| 코드 저장소 | TBD |
| 디자인 파일 | TBD |

---

## 💬 질문 사항

정석님이 검토 후 결정해주셔야 할 것들:

1. **가격 정책**
   - Pro $19 일회 구매 괜찮은지?
   - 구독 모델도 고려할지?

2. **판매 채널**
   - 직접 판매 vs Mac App Store?
   - 결제: Paddle vs Gumroad vs Stripe?

3. **브랜딩**
   - "Flowbar" 이름 괜찮은지?
   - 로고/아이콘 디자인 누가 할지?

4. **개발 일정**
   - 직접 개발 vs 외주?
   - 예상 출시 시점?

---

_생성일: 2025-02-17_
