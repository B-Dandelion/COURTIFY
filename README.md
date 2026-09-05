# COURTIFY

> 민사 판결문을 일반 독자가 이해하기 쉬운 기사형 요약으로 변환하고, **생성 결과의 금액·이자율·결론 누락과 환각 가능성을 별도로 검증한 AI 서비스 프로토타입**입니다.

**Course Project · Prototype**  
Flutter App → FastAPI → KoBART Legal Summarization Model

![COURTIFY](./Assets/Images/Logo_black.png)

## Project Overview

COURTIFY는 법률 문서의 복잡한 문장 구조와 전문 용어 때문에 일반 사용자가 판결문의 핵심 내용을 빠르게 파악하기 어렵다는 문제에서 시작한 수업 프로젝트입니다.

Flutter 앱에서 판결문 또는 법률 문서 정보를 입력하면 FastAPI 서버가 입력을 전처리하고 KoBART 기반 요약 모델의 추론 결과를 반환합니다. 앱은 응답을 기사형 결과 화면으로 보여줍니다.

이 프로젝트에서 특히 중요하게 본 부분은 **“요약문이 자연스러운가”뿐 아니라 법률 문서에서 중요한 사실이 실제로 보존되는가**였습니다.

따라서 일반적인 텍스트 생성 결과만 확인하지 않고 다음 실패 유형을 별도로 정의했습니다.

- 주문 금액 누락
- 이자율·퍼센트 정보 누락
- 인용/기각/각하 등 결론 불일치
- 생성 문장 중단
- 입력에 없는 조문·사실 생성 가능성

> 본 프로젝트는 정식 법률 자문 서비스가 아니며, 수업 프로젝트 기반의 AI 요약 프로토타입입니다.

## System Architecture

```text
Flutter App
    │
    │ HTTP / JSON
    ▼
FastAPI Server
    │
    ├─ Input shaping
    ├─ Priority sentence selection
    └─ KoBART inference
           │
           ▼
      Summary JSON
           │
           ▼
Flutter Article Preview
```

관련 서버 저장소: [courtify_server](https://github.com/B-Dandelion/courtify_server)

## AI Pipeline

### 1. Input Shaping

서버에서 모델 입력을 다음 구조로 정리합니다.

```text
[INSTRUCTION]
[META]
[ORDER]
[TEXT]
```

`[INSTRUCTION]`에는 다음과 같은 제약을 명시합니다.

- 판결의 결론을 누락하지 않기
- 주문의 금액·이자율을 보존하기
- 입력에 없는 사실·인물·금액을 생성하지 않기
- 불필요한 조문 인용을 만들지 않기

단순히 원문 전체를 모델에 전달하기보다 **도메인에서 중요한 정보의 보존 조건을 입력 단계에 포함**하도록 구성했습니다.

### 2. Priority Sentence Selection

긴 판결문에서 중요한 문장이 입력 길이 제한 때문에 잘리지 않도록 결론·금액과 관련된 문장을 우선 선택합니다.

서버의 sentence scoring은 다음 정보를 우선적으로 반영합니다.

- `기각`, `인용`, `각하`, `파기`, `취소`, `지급`, `배상` 등의 결론 키워드
- `원`, `%`, `퍼센트` 등 금액·비율 정보
- 숫자가 포함된 문장

```text
Judgment sentences
      │
      ├─ first sentences
      └─ high-score sentences
              │
              ▼
        selected context
```

### 3. Generation

모델 추론 시 결과 변동을 줄이고 반복 생성을 억제하기 위해 다음과 같은 decoding 설정을 사용합니다.

```text
num_beams = 4
do_sample = false
no_repeat_ngram_size = 4
repetition_penalty = 1.15
```

이 설정은 같은 입력에 대한 출력 변동성을 줄여 결과를 비교·검증하기 쉽게 만드는 방향으로 사용했습니다.

## Output Validation

일반적인 ROUGE 계열 지표만으로는 법률 요약에서 치명적인 정보 누락을 충분히 확인하기 어렵다고 보고, 도메인 실패 유형을 기준으로 별도의 평가 항목을 정의했습니다.

| Metric | What it checks |
| --- | --- |
| **Amount Recall** | 주문에 등장한 금액이 요약에 보존되는지 |
| **Rate Recall** | 이자율·퍼센트 정보가 보존되는지 |
| **Conclusion Accuracy** | 인용/기각/각하/취소/파기 등의 결론이 일치하는지 |
| **Complete Rate** | 생성 문장이 중간에 끊기지 않고 완결되는지 |
| **Statute Hint Count** | 불필요한 조문 인용·환각 가능성이 있는지 |

핵심은 **AI 출력을 그대로 신뢰하지 않고, 실제 사용 목적에서 문제가 되는 실패 유형을 먼저 정의한 뒤 입력·생성 설정·평가 기준으로 검증한 것**입니다.

## App Features

Flutter 기반 Android 앱 프로토타입으로 다음 기능을 구현했습니다.

- Firebase Auth 로그인 / 회원가입
- Google Sign-In
- 게스트 모드
- 법률 이슈·기사 목록 UI
- 기사 상세 화면
- 닉네임 설정
- AI 기사 작성 화면
- FastAPI 요약 요청
- 서버 응답 결과 표시

## Server API

FastAPI 서버는 모델을 시작 시 로드하고 앱 요청에 따라 전처리와 추론을 수행합니다.

주요 엔드포인트:

```text
GET  /health
POST /summarize
POST /summarize_input_text
```

- `/summarize`: 법원·사건명·선고일·문장 배열을 받아 서버에서 모델 입력을 구성
- `/summarize_input_text`: 미리 구성한 input text를 직접 전달해 추론
- `/health`: 실행 장치, CUDA 사용 여부, 모델 로드 상태 확인

## Dataset

실험에는 **AI Hub 민사법 LLM 사전학습 및 Instruction Tuning 데이터**를 사용했습니다.

주요 필드 예시:

```text
info.doc_id
info.normalized_court
info.casenames
info.announce_date
taskinfo.sentences
taskinfo.output
```

데이터 라이선스 문제로 **원본 학습 데이터와 모델 가중치는 저장소에 포함하지 않습니다.**

## Tech Stack

| Area | Technology |
| --- | --- |
| Client | Flutter, Dart |
| Authentication | Firebase Auth, Google Sign-In |
| Server | FastAPI, Python |
| Model | KoBART, Hugging Face Transformers, PyTorch |
| Communication | HTTP, JSON |
| API Test | Swagger / OpenAPI |

## Repository Structure

```text
COURTIFY/
├─ lib/                 # Flutter application source
├─ Assets/
│  ├─ Images/
│  └─ Fonts/
├─ android/
├─ ios/
└─ pubspec.yaml
```

AI inference server is separated into another repository:

```text
courtify_server/
├─ server_v1.py
├─ requirements.in
└─ requirements.txt
```

## How to Run

### Flutter App

API 주소는 소스 코드에 개인 개발용 URL을 고정하지 않고 `--dart-define`으로 전달합니다.

```bash
flutter pub get
flutter run --dart-define=COURTIFY_API_BASE_URL=http://127.0.0.1:8000
```

실기기에서 실행할 경우 `COURTIFY_API_BASE_URL`에는 기기에서 접근 가능한 FastAPI 서버 주소를 지정해야 합니다.

### FastAPI Server

서버의 모델 경로 역시 환경 변수로 전달합니다.

```bash
pip install -r requirements.txt
export MODEL_DIR=/path/to/kobart-legal-summary-model
uvicorn server_v1:app --host 127.0.0.1 --port 8000
```

## Limitations

- 정식 출시 서비스가 아닌 **수업 프로젝트 프로토타입**입니다.
- 민사 판결문 일부 데이터 중심으로 실험했습니다.
- 모델 파일과 원본 데이터는 저장소에 포함하지 않습니다.
- 생성 결과에는 여전히 정보 누락과 환각 가능성이 존재합니다.
- 실제 법률 서비스로 사용하려면 법률 전문가 검수, 더 넓은 데이터 평가, 사용자 검증이 필요합니다.

## What I Learned

이 프로젝트를 통해 생성형·요약 모델을 서비스에 연결할 때는 모델 자체의 성능만 보는 것이 아니라,

1. **어떤 정보를 반드시 보존해야 하는지 정의하고**
2. **입력 구조와 생성 설정으로 실패 가능성을 줄이며**
3. **도메인에 맞는 평가 기준으로 실제 결과를 검증하는 과정**

이 함께 필요하다는 점을 경험했습니다.

## Related Repository

- **Flutter App**: [B-Dandelion/COURTIFY](https://github.com/B-Dandelion/COURTIFY)
- **FastAPI Server**: [B-Dandelion/courtify_server](https://github.com/B-Dandelion/courtify_server)
