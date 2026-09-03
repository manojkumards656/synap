# Synap 🛡️

> **Real-Time Cognitive Duress Detection & Authorized Push Payment (APP) Fraud Interception via Behavioral Biometrics for Android**

[![Flutter](https://img.shields.io/badge/Flutter-3.41+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%207.0%2B%20(API%2024%2B)-3DDC84?logo=android&logoColor=white)](https://android.com)
[![Privacy](https://img.shields.io/badge/Privacy-Zero--PII%20By%20Design-10B981)](#zero-pii-architecture)
[![Latency](https://img.shields.io/badge/Latency-%3C%200.5ms%20On--Device-6366F1)](#the-mathematical-duress-engine)
[![Compliance](https://img.shields.io/badge/Regulatory-UK%20PSR%20%7C%20EU%20PSD3-F59E0B)](#the-regulatory-driver)

---

## 📌 The Problem

Digital banking fraud has fundamentally shifted. Criminals no longer rely solely on stolen passwords or device hijacking. Instead, they weaponize **Authorized Push Payment (APP) scams**—coercing victims (particularly seniors and first-time digital users) over live phone calls into logging into their own genuine bank accounts, entering recipient details, passing 2FA, and voluntarily transferring life savings.

Because the genuine account owner authenticates the transaction on their own device, traditional fraud detection systems (IP checks, device fingerprinting, FaceID) fail to intervene.

### The Regulatory Driver
* **UK Payment Systems Regulator (PSR)**: Under mandatory reimbursement rules, financial institutions face direct balance-sheet liability up to **£85,000 per incident** for APP fraud losses.
* **EU PSD3 & Instant Payments Regulation**: Mandates strict payee verification and heightened provider liability for spoofing and impersonation scams.
* **Global APP Losses**: Annual losses exceed **£576 million** in the UK alone and over **$4.4 billion** globally.

---

## 💡 The Solution: Synap

**Synap** monitors **interaction biometrics** rather than static identity credentials. When a user is being actively coerced over a phone call, their motor and cognitive distress alters screen interaction physics:
* **Keystroke rhythms become erratic**: Long pauses while listening to dictation, followed by frantic panic bursts.
* **Pointer trajectories lose smoothness**: High curvature entropy and wavering micro-hesitations.

Synap combines these low-level touch dynamics with an OS-level telephony state check (`is_call_active: true/false`). It computes a real-time **Cognitive Duress Index (CDI)** in **< 0.5 milliseconds** without recording raw text, keystrokes, or audio. 

If a transfer exhibits high duress during an active call, the transaction is automatically diverted into a **15-minute protective escrow hold**, breaking the fraudster's artificial urgency and saving the user's funds.

---

## 🚀 Key Features

* **Custom In-App Keypad with Pointer Event Listeners**:
  Bypasses OS soft-keyboard sandboxing to measure true key **dwell time** (hold duration) and **flight time / inter-character interval (ICI)** with microsecond resolution.
* **Sub-Millisecond Heuristic Duress Engine**:
  Executes in **< 0.5 ms** on-device using statistical physics and Shannon entropy—no heavy ML dependencies or UI thread jank.
* **Real-Time Telephony Detection**:
  Listens to Android telephony states (`READ_PHONE_STATE`) to verify whether a voice call is active during payment entry. Includes an instant tap-to-simulate toggle for stage demonstrations.
* **Animated Semicircular CDI Gauge**:
  Custom-painted visual indicator dynamically transitioning from **Green (SAFE)** $\to$ **Amber (ELEVATED)** $\to$ **Red (CRITICAL)** as the user types.
* **Collapsible Live Telemetry Panel**:
  Displays raw mathematical signals (ICI variance, dwell deviation, trajectory entropy, hesitation %, burst %, compute latency in ms) for transparency and auditability.
* **15-Minute Protective Escrow Screen**:
  Displays a live ticking countdown (14:59), an itemized breakdown of detected coercion flags, and an immediate cancel CTA to retain funds safely.

---

## 🧠 The Mathematical Duress Engine

The engine ingests raw `PointerEvent` data into a 200-event circular ring buffer and computes **6 normalized signals** ($0.0 \to 1.0$):

```
┌────────────────────────────────────────────────────────┐
│             Synap Cognitive Duress Index (CDI)         │
│                                                        │
│  CDI = 0.20 · norm(ICI Variance)                       │
│      + 0.15 · norm(Dwell Time Std Dev)                 │
│      + 0.15 · norm(Curvature Entropy)                  │
│      + 0.20 · norm(Hesitation Ratio)                   │
│      + 0.10 · norm(Burst Ratio)                        │
│      + 0.20 · (is_call_active ? 1.0 : 0.0)             │
│                                                        │
│  Output: Range [0.0, 1.0] | Execution Time: < 0.5 ms   │
└────────────────────────────────────────────────────────┘
```

| Signal | Feature | What It Detects |
| :--- | :--- | :--- |
| **ICI Variance** ($20\%$) | $\sigma^2 = \frac{1}{N-1}\sum(\Delta t_i - \bar{\Delta t})^2$ | Inconsistent typing rhythm caused by listening to phone instructions. |
| **Dwell Std Dev** ($15\%$) | $\sigma_{\text{dwell}} = \sqrt{\frac{1}{K}\sum(d_k - \bar{d})^2}$ | Inconsistent finger contact durations from motor tremor and stress. |
| **Curvature Entropy** ($15\%$) | $H = -\sum_{b=1}^{8} p_b \log_2(p_b)$ | Shannon entropy of angle transitions between consecutive taps. High entropy = erratic zigzag motion. |
| **Hesitation Ratio** ($20\%$) | $\frac{\text{Count}(\Delta t > 2000\text{ms})}{\text{Total Intervals}}$ | Dictation delays where the victim waits for the fraudster's next command. |
| **Burst Ratio** ($10\%$) | $\frac{\text{Count}(\Delta t < 120\text{ms})}{\text{Total Intervals}}$ | Rapid panic typing following dictation. |
| **Call Active Multiplier** ($20\%$) | `is_call_active ? 1.0 : 0.0` | Cellular telephony status via Android's `TelephonyCallback` / `PhoneState`. |

### Decision Matrix

| CDI Score | Call Active? | Transfer Amount | System Intervention |
| :---: | :---: | :---: | :--- |
| $< 0.30$ | Any | Any | **✅ Clear Instantly** (Normal daily banking) |
| $0.30 - 0.55$ | `false` | Any | **⚠️ Warn & Clear** (Tremor / walking user without a call) |
| $0.55 - 0.75$ | `true` | $\ge ₹10,000$ | **🛑 15-Min Protective Escrow Hold** (High-value call duress) |
| $\ge 0.75$ | `true` | Any | **🛑 15-Min Protective Escrow Hold** (Critical coercion detected) |

---

## 🔒 Zero-PII Architecture

Synap is engineered to comply strictly with **GDPR (Recital 47 / Article 6(1)(f) Legitimate Interest)** and privacy regulations:
* **No Key Logging**: Keystroke characters, entered text, and IBAN digits are never logged by the biometric engine.
* **No Audio Recording**: Microphone hardware is never accessed.
* **No Telephony Metadata**: Phone numbers, call durations, and contacts are never accessed (only the binary call state is observed).
* **Only Physics**: The engine processes only dimensionless millisecond intervals ($\Delta t$), normalized coordinates $(x, y)$, and contact pressure.

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── constants.dart              # Thresholds, weights, timing limits, decision enums
│   └── theme.dart                  # Dark obsidian banking UI, colors, typography
│
├── models/
│   ├── touch_event.dart            # Microsecond timestamp, (x, y), pressure, dwell/flight metrics
│   ├── biometric_snapshot.dart     # Normalized features, sample stats, duress flag descriptions
│   └── transaction.dart            # Transaction data model and status
│
├── biometrics/
│   ├── touch_buffer.dart           # 200-event circular ring buffer with touch down/up pairing
│   ├── feature_extractor.dart      # Real-time mathematical feature computation (< 0.5ms)
│   ├── cdi_scorer.dart             # Weighted CDI computation and tiered fraud decision rules
│   └── biometric_service.dart      # ChangeNotifier orchestrator powering the UI state
│
├── telephony/
│   └── call_state_service.dart     # phone_state listener + demo simulation override controls
│
├── widgets/
│   ├── numeric_keypad.dart         # Custom 3x4 keypad with Listener on every key
│   ├── cdi_gauge.dart              # Animated semicircular CustomPainter gauge
│   ├── call_indicator.dart         # Live status pill ("CALL ACTIVE" vs "NO CALL DETECTED")
│   ├── iban_field.dart             # Stylized recipient account field
│   ├── amount_field.dart           # Currency-formatted transfer field
│   └── telemetry_panel.dart        # Collapsible live debugger showing raw signals & latency
│
├── screens/
│   ├── home_screen.dart            # Banking dashboard (balance, cards, recent transactions)
│   ├── transfer_screen.dart        # Core demo screen (fields + gauge + keypad + CTA)
│   ├── transaction_cleared_screen.dart   # Instant green confirmation screen
│   └── escrow_hold_screen.dart     # 15-minute protective cooling-off screen
│
├── app.dart                        # MultiProvider root and route mapping
└── main.dart                       # System UI overlays and application launch
```

---

## 🛠️ Getting Started

### Prerequisites
* Flutter SDK `^3.11.0` / Flutter 3.41+
* Android SDK (API 24 or newer, supports Android 14/15/16)
* Java 17+

### Installation & Run

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/synap.git
   cd synap
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify code & run mathematical tests**:
   ```bash
   flutter analyze
   dart run test/engine_test.dart
   ```

4. **Launch on a connected Android phone or emulator**:
   ```bash
   flutter run
   ```

### Pre-Built Android Debug APK
An Android debug build is pre-compiled and ready for deployment:
```
build/app/outputs/flutter-apk/app-debug.apk
```
To install directly to a connected USB device:
```bash
flutter install
```

---

## 🎬 Live Hackathon Demo Script (3 Minutes)

| Step | Time | Action | What Judges See |
| :--- | :--- | :--- | :--- |
| **1. Hook** | 30s | Explain the problem: *"Scammers don't steal passwords anymore. They coerce victims over a phone call to voluntarily transfer life savings. Traditional 2FA lets it through. Synap checks HOW you interact, not WHO you are."* | Pitch slide or dashboard view. |
| **2. Test A: Normal Banking** | 60s | Open **Synap Guardian**, tap **Transfer Funds**. Phone call indicator is gray (`NO CALL DETECTED`). Type recipient details calmly. | **CDI Gauge stays GREEN (< 0.30)**. Expand telemetry drawer to show $< 0.5\text{ ms}$ compute time. Tap Authorize $\to$ **✅ Transfer Clears Instantly**. |
| **3. Test B: Active Phone Scam** | 90s | Return to Transfer screen. Have a teammate call your phone (or tap the call pill and select **Simulate Call ON**). Badge turns pulsing red: **`CALL ACTIVE`**. Type with hesitation pauses (being dictated to) and frantic bursts. | **CDI Gauge climbs fluidly into RED CRITICAL (0.85)**. Tap Authorize $\to$ **🛑 BLOCKED! 15-Minute Escrow Hold Screen triggers** with live countdown and coercion breakdown. |

---

## 📦 Dependencies

* [`phone_state`](https://pub.dev/packages/phone_state) — Android telephony state listening
* [`permission_handler`](https://pub.dev/packages/permission_handler) — Runtime permissions (`READ_PHONE_STATE`)
* [`provider`](https://pub.dev/packages/provider) — Reactive app-wide state management
* [`google_fonts`](https://pub.dev/packages/google_fonts) — Inter typography
* [`intl`](https://pub.dev/packages/intl) — Currency and number formatting

---

## 📄 License

This project was built for hackathon demonstration purposes. Licensed under the MIT License.
