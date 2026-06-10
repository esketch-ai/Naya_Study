# SECURITY, PRIVACY & BIOMETRIC COMPLIANCE SPECIFICATION
## (음성 복제 보안 인증, Secure Enclave 암호화 및 생체 데이터 개인정보 보호 설계서)

본 명세서는 "나야~" 플랫폼에서 제공하는 ElevenLabs 기반 실시간 음성 복제(Voice Cloning) 기술의 범죄 도용을 원천 차단하고, 스마트워치로부터 수신되는 민감 생체 데이터(심박수, HRV)를 안전하게 보호하기 위한 **보안, 암호화 아키텍처 및 법률 컴플라이언스 설계서**입니다.

타인의 음성을 무단 복제하여 보이스피싱, 금융 사기 등에 악용하는 딥페이크(Deepfake) 위협으로부터 사용자를 보호하고, GDPR(유럽 개인정보보호법) 및 CCPA(캘리포니아 소비자개인정보보호법)의 엄격한 가이드를 충족하기 위한 무결성 보안 프로토콜을 수립합니다.

---

## 🔒 1. 구두 서명 발화 인증 프로토콜 (Voice Signature Verbal Consent Protocol)

가족이나 제3자의 음성 동의 없는 무단 도용 복제를 차단하기 위해, 음성 복제 프로세스 가입 시 **실시간 구두 서명 발화 인증(Voice Signature Verification)**을 필수로 요구합니다.

```
[ 가입 및 음성 복제 요청 ]
          │
          ▼
┌──────────────────────────────────────────────┐
│  1단계: 실시간 동적 인증 난수 대본 생성     │
│  (Dynamic Challenge Script)                  │
└─────────────────┬────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────┐
│  2단계: 사용자 구두 서명 발화 및 실시간 녹음 │
│  "나는 나야 플랫폼의 음성 학습에 동의합니다 [난수]"  │
└─────────────────┬────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────┐
│  3단계: 단말 내 주파수/오디오 파형 1차 검증   │
│  - 실시간 라이브 발화 체크 (재생방지 Liveness)│
│  - 음성 인식 (STT 대본 일치 여부)           │
└─────────────────┬────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────┐
│  4단계: ElevenLabs API 보안 통신 & 등록      │
│  - 동의 음성 원본 전송 (Legal Consent Asset) │
│  - 음성 복제 가중치 생성 및 ID 발급          │
└──────────────────────────────────────────────┘
```

### 📝 A. 동적 서명 스크립트 발화 명세 (Dynamic Challenge Script)
- 사용자는 정해진 고정 문구와 매번 세션마다 무작위로 생성되는 **6자리 보안 난수(Challenge OTP)**를 합쳐 직접 발화해야 합니다.
- **표준 한국어 대본**:
  > *"나는 2026년 5월 31일, 나야 서비스에 내 목소리를 학습하고 인공지능 보이스 모델을 복제하여 학습용 비서로 활용하는 것을 정식으로 승인합니다. 오늘의 보안 난수는 [ **4  8  2  9  0  1** ] 입니다."*
- **표준 영어 대본 (다문화 학습자용)**:
  > *"I hereby authorize the Naya platform to learn my voice and clone it as an AI Buddy for personalized learning on this day of May 31, 2026. Today's security challenge code is [ **4  8  2  9  0  1** ]."*

### ⚙️ B. 실시간 라이브 보이스 체크 및 위협 차단 (Anti-Spoofing & Liveness Detection)
1. **오디오 녹음본 재생 차단 (Replay Attack Prevention)**:
   - 기녹음된 사운드를 스피커로 틀어 마이크에 주입하는 스푸핑 시도를 차단하기 위해, 마이크 수신 음원 스트림의 고주파 잔향 대역(18kHz 이상) 및 마이크 접촉 왜곡 특성을 고속 푸리에 변환(FFT)으로 실시간 분석합니다.
2. **Challenge-Response 매칭**:
   - 단말에서 생성한 6자리 난수와 수집된 녹음 데이터를 STT(OpenAI Whisper / On-Device STT)로 로컬 파싱하여, 난수가 100% 일치하고 묵음 없이 연속된 발화 패턴을 보였을 때만 승인 요청 패킷을 생성합니다.
3. **법적 증빙 자산 보관 (Legal Consent Asset)**:
   - 본인이 서명한 동의 음성 원본은 별도의 15초 보안 오디오 파일(`consent_signature_[UUID].wav`)로 저장되어 백엔드 AWS S3 Glacier 암호화 S3 Glacier 암호화 스토리지에 법적 증빙 자산으로 최소 5년간 보관됩니다.

---

## 🔑 2. Secure Enclave / Keystore 하드웨어 암호화 (Asymmetric Key Cryptography)

기기 내에 저장되는 로컬 SQLite 캐시 데이터베이스와 ElevenLabs로부터 내려받은 음성 모델 매개변수/가중치 파일의 물리적 탈취(루팅, 탈옥 기기를 통한 메모리 덤프)를 방지하기 위해 iOS와 Android의 하드웨어 보안 칩을 활용합니다.

```
       [ MOBILE DEVICE (iOS / Android) ]
┌──────────────────────────────────────────────┐
│  Hardware-backed Secure Environment          │
│  - iOS: Secure Enclave                       │
│  - Android: Android Keystore System (TEE)    │
│                                              │
│     (1) 256-bit 비대칭 키 쌍 생성 및 보호     │
│     (2) 복호화 키의 메모리 외부 노출 완전 차단│
└──────────────────────┬───────────────────────┘
                       │
       AES-256-GCM 복호화 (메모리 내 스트림 처리)
                       ▼
┌──────────────────────────────────────────────┐
│  Local Sandboxed Directory                   │
│  - [Encrypted SQL Cipher Cache DB]           │
│  - [Encrypted Voice Models / Weights]        │
└──────────────────────────────────────────────┘
```

### 🍏 A. iOS: Secure Enclave 및 Keychain Services 바인딩
- **비대칭 키 생성**:
  - `kSecAttrTokenIDSecureEnclave` 속성을 사용하여 Secure Enclave 내에 **256비트 Elliptic Curve 비대칭 키 쌍(ECC P-256)**을 생성합니다. 개인 키는 칩 밖으로 절대로 유출될 수 없으며, 모든 서명 및 암호화 연산은 보안 하드웨어 내부에서 안전하게 실행됩니다.
- **생체 인식 요구 사항(Biometrics Constraint)**:
  - 기기의 `LocalAuthentication` 프레임워크와 결합하여 사용자가 학습 카드를 열거나 음성을 업데이트할 때 **Face ID / Touch ID 인증을 무조건 강제(Authentication Bound)**하도록 키 접근 정책(`kSecAccessControlBiometryAny`)을 적용합니다.

### 🤖 B. Android: Keystore 및 TEE (Trusted Execution Environment)
- **Android Keystore System API**:
  - `KeyGenParameterSpec.Builder`를 활용해 하드웨어 백킹 암호화 키를 생성합니다.
  ```kotlin
  val keyGenerator = KeyGenerator.getInstance(
      KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore"
  )
  keyGenerator.init(
      KeyGenParameterSpec.Builder(
          "NayaLocalEncryptionKeyAlias",
          KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
      )
      .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
      .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
      .setKeySize(256)
      .setUserAuthenticationRequired(true) // 생체 인식 강제
      .setUserAuthenticationValidityDurationSeconds(-1) // 매 접근마다 인증 요구
      .build()
  )
  ```
- **SQLite Database 암호화 (SQLCipher)**:
  - SQLite 캐시 디비는 일반 텍스트가 아닌 `SQLCipher` 드라이버를 통해 **AES-256-GCM** 방식으로 암호화되어 디바이스 플래시 메모리에 기록되며, 위의 Keystore에서 승인받은 대칭 키를 전달받아 런타임에 메모리 내부에서만 투명하게 해독(Transparent Decryption)됩니다.

---

## 📊 3. 생체 데이터 프라이버시 및 GDPR/CCPA 컴플라이언스 (Biometric Telemetry compliance)

스마트워치로부터 획득하는 심박수(BPM) 및 R-R 간격 RMSSD 값은 사용자의 건강 정보에 해당하는 초민감 생체 정보입니다. 이를 처리하기 위한 4대 개인정보 보호 아키텍처 규칙을 수립합니다.

### 🛡️ A. 원격 서버 비식별화 (Anonymization & Tokenization)
1. **UUID 해시 바인딩 (Zero PII Policy)**:
   - 생체 정보는 가입 시 부여된 무작위 UUID(`user_id = 'a9b8c7d6-e5f4...'`) 정보하고만 매핑되어 저장되며, 실제 사용자의 성명, 이메일, 전화번호 등의 개인식별정보(PII)와는 데이터베이스 스키마 상에서 **물리적으로 완전히 분리된 독립 인스턴스**에 저장됩니다.
2. **의사소통 채널 데이터 토큰화**:
   - 모바일 기기에서 클라우드로 HRV 및 PPG 로그를 전송하는 모든 API 페이로드(`POST /api/wearable/log`)는 전송 구간에서 **TLS 1.3 암호화 터널**을 통과하며, 아래와 같이 암호화된 토큰(Token) 형태로 마스킹 처리됩니다.

```json
{
  "device_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "telemetry_data": {
    "payload_hash": "24eb4f9cd8e34a6...",
    "metrics": {
      "bpm": 82,
      "hrv_rmssd": 48.52,
      "ts": 1779951000
    }
  }
}
```

### ⏳ B. 로컬 라이프사이클 및 파기 정책 (Local Ephemeral Lifecycle)
1. **로컬 자동 만료 디바이스 캐시 (Local Auto-Expiry)**:
   - 심박수 및 생체 노출 로그는 오늘의 최적 좀비 알림 타이밍 연산 및 츤데레 멘트 조율 목적이 달성되면, 단말기 내부에서 **최대 48시간 이상 보관되지 않고 강제 영구 삭제(Zero-overwriting)** 처리됩니다.
2. **동의 철회권 보장 (Right to be Forgotten - GDPR Art. 17)**:
   - 사용자가 설정 화면에서 "계정 삭제" 또는 "음성 복제 동의 철회"를 원터치 터치하는 즉시, 단말 내 Secure Enclave의 암호화 복호 키 쌍이 영구 삭제(Key Shredding)되어 그간 쌓인 모든 암호화 SQLite 데이터가 수학적 복구 불능 상태가 됩니다.
   - 동시에 백엔드 클라우드와 ElevenLabs의 음성 벡터 가중치 및 AWS S3의 오디오 동의 녹음본이 3초 내에 **물리적 파쇄 API(Hard Delete)**를 거쳐 영구 소멸됩니다.

---

## 📋 4. 보안 및 법률 준수 정책 체크리스트 (Verification & Compliance Audit)

개발 및 출시 시점에 반드시 확인해야 할 규제기관별 기술 보안 감사 기준 가이드라인입니다.

| 법률 규제 | 핵심 요구 사항 | Naya~ 설계 아키텍처 대응 방안 | 상태 |
| :--- | :--- | :--- | :--- |
| **GDPR Art. 9** | 민감 생체 데이터(Biometric Data) 처리 금지 규제 우회 | 사용자로부터 "생체 인식 기반 맞춤 오디오 제공 및 학습 분석 목적"의 명시적 사전 동의(Opt-in) 동의 스크립트 획득. | **설계 반영** |
| **GDPR Art. 32** | 데이터 처리의 보안성 확보 (암호화) | Secure Enclave ECC P-256 키 연동 및 로컬 캐시 DB AES-256 SQLCipher 전면 암호화 적용. | **설계 반영** |
| **CCPA Sec. 1798** | 소비자의 개인정보 수집 거부 및 즉각 삭제 요구 권리 | 설정 내 즉시 탈퇴 기능 제공, 탈퇴 API 호출 시 ElevenLabs 클라우드 모델 가중치 물리 파괴 처리. | **설계 반영** |
| **금융보안 지침** | 음성 딥페이크 금융 사기 방지 조치 | 동적 6자리 OTP 난수 챌린지 및 마이크 실시간 고주파 Replay Liveness 검사 도입. | **설계 반영** |

본 **보안, 개인정보 및 생체 컴플라이언스 명세서**의 기술적 원칙은 "나야~" 아키텍처의 핵심 헌법으로 규정되며, 향후 출시될 모든 다과목 확장 버전의 로컬 기기 데이터 관리 표준 규격으로 적용됩니다.
