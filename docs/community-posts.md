# Flowbar - 커뮤니티 포스팅 초안

## Reddit (r/macapps) - 영문 버전

### 제목 옵션

1. "I'm building a context-aware menu bar app. Would you use this?"
2. "What if your menu bar showed only what you need for your current task?"
3. "Feedback wanted: Building Flowbar - smart menu bar modes for macOS"

### 본문

```
Hi r/macapps 👋

I'm an indie developer working on a new macOS utility called Flowbar, and I'd love your feedback.

**The Problem**

Like many of you, I have way too many menu bar apps. Dropbox, Alfred, Battery, Timer, GitHub, Slack notifications... they're all fighting for space. On my MacBook with a notch, icons regularly disappear.

And every time I switch from coding to a meeting, I manually:
- Close my IDE
- Open calendar and notes
- Turn on Do Not Disturb
- Later, reverse everything

It's exhausting.

**What I'm Building**

Flowbar is a context-aware menu bar manager with three main features:

1. **Smart Modes** - Create "Coding", "Design", "Meeting", "Focus" modes. Each mode shows only the menu bar icons relevant to that task.

2. **Focus Guard** - Prevents apps from stealing keyboard focus. No more accidental typing into random popups.

3. **Workflow Memory** - Save your current setup (apps + windows + menu bar) and restore with one click.

**Example Workflow**

- Press `⌘+Shift+1` → Switches to "Coding" mode
- Menu bar shows: Git status, CI monitor, CPU, timer
- All other icons hidden
- Focus Guard activates (blocks interruptions)

- Press `⌘+Shift+2` → Switches to "Meeting" mode
- Menu bar shows: Calendar, notes, microphone
- Opens your meeting notes app
- Restores window layout

**Questions for You**

1. Is this something you'd actually use?
2. What features would make this a must-have for you?
3. Would you pay $19 one-time for the Pro version (unlimited modes + Focus Guard + workflows)?

**Timeline**

I'm planning to release a free beta in the next 4-6 weeks. If you're interested, you can sign up at [landing page URL] or just drop a comment below.

Thanks for reading! Happy to answer any questions.

---

*P.S. I know Bartender exists for hiding icons, and Keyboard Maestro for automation. Flowbar combines context-switching + menu bar + focus protection in one lightweight app specifically designed for this use case.*
```

---

## Hacker News - Ask HN

### 제목

"Ask HN: What's your menu bar management workflow?"

### 본문

```
I'm working on a macOS utility for context-based menu bar management, and I'm curious how others handle this.

My current pain points:
- 15+ menu bar icons, many only relevant for certain tasks
- Icons disappearing behind the notch
- Constant manual reconfiguration when switching between coding/design/meetings
- Popups stealing keyboard focus at the worst moments

I'm building Flowbar to solve this with:
1. Context modes (show different icons for different tasks)
2. Focus guard (prevent focus stealing)
3. Workflow memory (save/restore app layouts)

Before I go further, I'd love to hear:
- How do you currently manage your menu bar?
- What's your biggest friction point?
- Is this even a problem for you, or am I overthinking it?

For context, I'm aiming for a lightweight native app (~10MB), $19 one-time for Pro features.
```

---

## 클리앙 (한국 커뮤니티)

### 제목

"macOS 메뉴바 관리 앱 만들고 있는데 피드백 좀 부탁드려요"

### 본문

```
안녕하세요, 인디 개발자입니다.

macOS용 메뉴바 관리 앱을 개발 중인데 클리앙 분들의 의견을 구하고 싶습니다.

**현재 불편한 점**

1. 메뉴바 아이콘이 너무 많음 (저만 그런가요? ㅎㅎ)
2. 노치 때문에 아이콘이 잘림
3. 코딩하다가 회의하러 가면 매번 앱 껐다 켰다
4. 작업 중 팝업이 키보드 포커스 뺏어감

**만들려는 것**

"Flowbar"라는 앱인데요:

1. **모드 전환** - 코딩/디자인/회의/집중 모드별로 다른 메뉴바 아이콘 표시
2. **Focus 가드** - 팝업이 키보드 포커스 뺏지 못하게
3. **워크플로우 저장** - 현재 앱 배치 저장해뒀다가 원클릭 복원

**예시**

- `⌘+Shift+1` → 코딩 모드 (Git, CI, CPU, 타이머만 표시)
- `⌘+Shift+2` → 회의 모드 (캘린더, 노트, 마이크만 표시)

**질문**

1. 이런 앱 쓰실 의향 있으신가요?
2. 어떤 기능이 필수라고 생각하시나요?
3. Pro 버전($19 일회) 유료 결제 의향 있으신가요?

베타는 4~6주 내로 예정입니다. 관심 있으시면 댓글이나 이메일 남겨주세요!

감사합니다.
```

---

## Indie Hackers

### 제목

"Building a macOS menu bar app - feedback wanted on pricing/features"

### 본문

```
Hey IH community 👋

I'm working on Flowbar, a context-aware menu bar manager for macOS.

**What it does:**
- Shows different menu bar icons based on your current task (coding/design/meetings/focus)
- Prevents apps from stealing keyboard focus
- Saves and restores app workflows

**Target market:**
- Developers, designers, and power users who have too many menu bar apps
- People who switch between different work contexts throughout the day

**Pricing model I'm considering:**

| Plan | Price | Features |
|------|-------|----------|
| Free | $0 | 3 modes, manual switching, basic grouping |
| Pro | $19 one-time | Unlimited modes, Focus Guard, workflows, shortcuts |

**Questions:**

1. Is one-time $19 too low for this type of utility? I see similar apps at $29-49.
2. Should I offer a subscription tier for ongoing development?
3. Any red flags in the feature set?

I'm planning to:
- Collect emails via landing page first
- Release free beta in 4-6 weeks
- Iterate based on feedback before full launch

Would love to hear from anyone who's built/sold macOS utilities before. Thanks!
```

---

## Product Hunt (출시용)

### 태그라인

"The menu bar that adapts to what you're doing"

### 설명

```
Flowbar is a context-aware menu bar manager for macOS.

**Problem:**
Your menu bar has 15+ icons. They're all fighting for space. Half of them are irrelevant to your current task. And that notch isn't helping.

**Solution:**
Create modes for different contexts (Coding, Design, Meeting, Focus). Each mode shows only the icons you need. Switch with one click or keyboard shortcut.

**Key Features:**
- 🎯 Smart Modes - Different icons for different tasks
- 🛡️ Focus Guard - Block focus-stealing popups
- 💾 Workflow Memory - Save and restore app layouts
- 🚀 Mini Launcher - Quick access to task-relevant apps

**Pricing:**
- Free: 3 modes, basic features
- Pro ($19 one-time): Unlimited modes + all features + lifetime updates

Built with love for macOS power users. Native Swift, <10MB, respects your privacy.
```

---

## 이메일 템플릿 (등록 감사)

### 제목

"Thanks! You're on the Flowbar early access list 🎉"

### 본문

```
Hi there,

Thanks for signing up for Flowbar early access!

You're now on the list to get notified when we launch the beta (expected in 4-6 weeks).

**What happens next:**
1. I'll send you an email when the beta is ready
2. You'll get early access + a special discount on the Pro version
3. Your feedback will help shape the final product

**In the meantime:**
- Follow development: [Twitter/GitHub URL]
- Questions? Just reply to this email

Thanks for your interest!

— [Your Name]
Flowbar Creator
```

---

## 소셜 미디어 (트위터/링크드인)

### 트위터 스레드

```
🧵 I'm building Flowbar - a macOS menu bar that adapts to what you're doing.

Here's why and how it works:

1/ Your menu bar has 15+ icons.
Half are irrelevant to your current task.
On MacBooks with a notch, icons literally disappear.

Sound familiar?

2/ Flowbar lets you create "modes":
- Coding mode: Git, CI, CPU, timer
- Meeting mode: Calendar, notes, mic
- Focus mode: Just a timer, nothing else

Switch with one click or keyboard shortcut.

3/ Bonus features:
- Focus Guard: Blocks focus-stealing popups
- Workflow Memory: Save app layouts, restore instantly
- Mini Launcher: Quick access to relevant apps

4/ Pricing:
- Free: 3 modes, basic features
- Pro: $19 one-time, unlimited modes + all features

No subscription. Pay once, own forever.

5/ Beta coming in 4-6 weeks.
Sign up for early access: [URL]

RT appreciated if you know Mac users who might find this useful! 🙏

#macOS #indiedev #buildinpublic
```

---

_작성일: 2025-02-17_
