# VaakKavach Architecture & Engineering Specification

## 1. Executive Summary & Design Axioms

VaakKavach (वाक्कवच) is an autonomous, on-device acoustic defense shield designed to safeguard mobile communications against state-of-the-art voice clones, synthetic speech deepfakes, and telephone-based extortion scams (such as "Digital Arrest" coercion).

### Fundamental Architectural Axioms

1. **Strict Sovereignty (100% Offline & Serverless)**:
   All feature extraction, inference scoring, and forensic logging occur on the local device. The application requires no cloud APIs, no external backend servers, and zero mandatory network credentials.
2. **Sub-15ms Real-Time Latency**:
   Acoustic frames must be captured, transformed via Fast Fourier Transform (FFT), and evaluated within 15 milliseconds to deliver immediate tactile feedback before a user is defrauded.
3. **Autonomous Agentic Self-Healing**:
   Audio recording pipelines on mobile devices are prone to OS interruptions, audio focus stealing, and hardware buffer stalls. VaakKavach implements an autonomous background watchdog daemon that detects stalls and auto-recovers monitoring state without user intervention.
4. **Decoupled Architecture with Strict LOC Limits**:
   Every code component is bounded to a maximum of 150 lines of code. Subsystems are decoupled across isolated services, repositories, and state providers.

---

## 2. System Architecture Diagram

```
+---------------------------------------------------------------------------------------+
|                                    HARDWARE LAYER                                     |
|                       Microphone / Audio Routing Hardware                             |
+---------------------------------------------------------------------------------------+
                                           |
                                           v 44.1kHz 16-bit PCM Stream
+---------------------------------------------------------------------------------------+
|                              NATIVE KOTLIN DSP ENGINE                                 |
|                                                                                       |
|   +-----------------------+     +-----------------------+     +-------------------+   |
|   |  AudioRecord Wrapper  | ==> | Lock-Free Ring Buffer | ==> | Feature Extractor |   |
|   +-----------------------+     +-----------------------+     +-------------------+   |
|               ^                                                         |             |
|               | Heartbeat & Stall Recovery                              v             |
|   +-----------------------+                         +-----------------------------+   |
|   | Watchdog Daemon (FG)  |                         | Jitter, HFER, Bi-coherence  |   |
|   +-----------------------+                         +-----------------------------+   |
+---------------------------------------------------------------------------------------+
                                           |
                                           v MethodChannel & EventChannel
+---------------------------------------------------------------------------------------+
|                                FLUTTER ENGINE (DART 3)                                |
|                                                                                       |
|   +-------------------------------------------------------------------------------+   |
|   |                           Autonomous Threat Engine                            |   |
|   |  - Bayesian Threat Fusion (Weights: Jitter=0.35, HFER=0.25, Bi-coherence=0.25)|   |
|   |  - Coercion Script Heuristics (Digital Arrest, Police/CBI Intimidation)       |   |
|   +-------------------------------------------------------------------------------+   |
|                                           |                                           |
|                     +---------------------+---------------------+                     |
|                     v                                           v                     |
|   +-----------------------------------+       +-----------------------------------+   |
|   |    Encrypted Forensic Vault       |       |    Emergency Dispatch System      |   |
|   |  - Local SQLite Database          |       |  - Dynamic Haptic Alert Shield    |   |
|   |  - SHA-256 Cryptographic Chain    |       |  - Offline Cellular SMS Dispatch  |   |
|   +-----------------------------------+       +-----------------------------------+   |
|                                           |                                           |
|                                           v                                           |
|   +-------------------------------------------------------------------------------+   |
|   |                        Presentation & UI Subsystem                            |   |
|   |  - Riverpod State Providers (ShieldNotifier, ThreatNotifier, HistoryNotifier)  |   |
|   |  - Chiseled Dark Noir Glassmorphism Visual Design Tokens                      |   |
|   |  - Real-Time Live Spectrogram & Decibel Audio Waveform Canvas                 |   |
|   +-------------------------------------------------------------------------------+   |
+---------------------------------------------------------------------------------------+
```

---

## 3. Subsystem Breakdown

### 3.1 Native Ingestion & DSP Subsystem (`android/`)
* **AudioRecord Ingestion**: Streams uncompressed mono audio at 44,100 Hz, 16-bit PCM.
* **Lock-Free Circular Ring Buffer**: Prevents audio frame drops during thread transitions between native audio threads and the Flutter UI thread.
* **Acoustic Feature Extraction**:
  * Micro-pitch jitter extraction via zero-crossing rate and peak autocorrelation.
  * High-Frequency Energy Ratio (HFER) calculated via 512-point FFT windowing with Hanning smoothing.
  * Temporal energy variance and kurtosis measurement to flag vocoder clamping.

### 3.2 Autonomous Threat Engine (`lib/services/`)
* Operates as a reactive state machine:
  * **IDLE**: Microphone dormant, system on standby.
  * **MONITORING**: Normal voice conversation, transient telemetry collected.
  * **SUSPICIOUS**: Vocoder spectral anomaly or pitch jitter anomaly detected.
  * **THREAT_DETECTED**: High-confidence voice clone or coercion script confirmed.
* Bayesian threat fusion scores incoming frames across multiple acoustic indicators and updates the active threat score $P(\text{Clone} \mid X) \in [0, 1]$.

### 3.3 Autonomous Agentic Watchdog Daemon
* Runs as an Android Foreground Service with continuous low-overhead heartbeat monitoring.
* If audio stream frames stop flowing for more than 1.5 seconds during an active call, the watchdog triggers `recoverPipeline()`:
  1. Safely releases stalled `AudioRecord` instance.
  2. Reallocates the circular ring buffer.
  3. Reinitializes native audio routing.
  4. Restores active shield state transparently.

### 3.4 Encrypted Forensic Vault (`lib/services/database_service.dart`)
* Stores all detected incident telemetry in local SQLite tables (`threat_events` and `call_records`).
* Chained SHA-256 cryptographic hashes ensure integrity: each event record incorporates the hash of the preceding event, creating an immutable audit trail for legal evidentiary use.

### 3.5 Emergency Guardian Triangulation Subsystem
* When a threat reaches critical confidence ($P \ge 0.65$), the system triggers an emergency protocol:
  1. Haptic alert engine delivers distinct, high-intensity vibration pulses to alert the user without alerting the caller.
  2. The background SMS dispatcher formats and sends an emergency alert to designated emergency guardians with call timestamp, threat category, and incident severity.

---

## 4. Platform Channels & Hardware Interfacing

| Channel | Method / Event | Payload | Function |
| :--- | :--- | :--- | :--- |
| `com.vaakkavach.aegis/audio` | `startMonitoring` | `{ sensitivity: double }` | Spawns native `AudioRecord` thread and allocates ring buffers |
| `com.vaakkavach.aegis/audio` | `stopMonitoring` | None | Flushes buffers and releases native audio hardware |
| `com.vaakkavach.aegis/telemetry` | Stream `listen` | `Map<String, dynamic>` | Emits real-time dB levels, pitch jitter, and vocoder detection status |
| `com.vaakkavach.aegis/watchdog` | `pingWatchdog` | None | Returns watchdog health status and self-healing telemetry |
| `com.vaakkavach.aegis/sms` | `sendAlert` | `{ phone: String, msg: String }` | Dispatches SMS via Android Telephony Manager |

---

## 5. Architectural Quality Standards & LOC Governance

To ensure enterprise-grade code cleanliness, readability, and long-term maintainability:
* Every source file in `lib/`, `android/`, and `website/` is strictly constrained to **<= 150 lines of code**.
* Any component exceeding 150 LOC is immediately refactored into focused, single-responsibility modules.
* 100% of state transitions are managed using declarative Riverpod providers.
* Zero external cloud services, analytics SDKs, or proprietary third-party tracking libraries are included.
