# COURTIFY

KoBART 기반 민사 판결문 요약 모델과 Flutter 앱, FastAPI 서버를 연결한 법률 기사형 요약 서비스 프로토타입입니다.

## 1. Project Overview

COURTIFY는 일반 사용자가 이해하기 어려운 민사 판결문을 핵심 사실과 결론 중심의 기사형 요약문으로 변환하는 AI 서비스 MVP입니다.

본 프로젝트는 정식 출시 서비스가 아니라 수업 프로젝트 기반의 프로토타입이며, 법률 문서 요약 모델의 가능성과 한계를 검증하는 것을 목표로 했습니다.

## 2. Problem

법률 판결문은 문장 구조가 복잡하고 전문 용어가 많아 일반 사용자가 직접 이해하기 어렵습니다.
또한 생성형 요약 모델은 금액, 이자율, 인용/기각 등의 결론을 누락하거나 입력에 없는 사실을 생성할 위험이 있습니다.

## 3. Features

* Firebase Auth 기반 로그인/회원가입
* 게스트 모드
* 판결/법률 이슈 기사 목록 UI
* 기사 상세 화면
* AI 기사 작성 화면
* FastAPI 서버 기반 요약 요청
* KoBART 모델 추론 결과 표시
* Swagger 기반 API 테스트

## 4. System Architecture

Flutter App
→ FastAPI Server
→ KoBART Legal Summarization Model
→ JSON Response
→ App Result View

## 5. Dataset

* AI Hub 민사법 LLM 사전학습 및 Instruction Tuning 데이터
* 주요 필드:

  * `info.doc_id`
  * `info.normalized_court`
  * `info.casenames`
  * `info.announce_date`
  * `taskinfo.sentences`
  * `taskinfo.output`

데이터 라이선스 문제로 원본 데이터는 저장소에 포함하지 않습니다.

## 6. Model

* Base model: KoBART summarization model
* Task: civil judgment summarization
* Input format:

  * `[INSTRUCTION]`
  * `[META]`
  * `[ORDER]`
  * `[TEXT]`
* Output: 일반 독자가 이해하기 쉬운 서술형 요약문

## 7. Evaluation

일반적인 ROUGE 외에 법률 문서 특성을 반영한 별도 평가 기준을 설계했습니다.

* Amount recall: 주문에 등장한 금액이 요약에 포함되었는지
* Rate recall: 이자율/퍼센트 정보가 보존되었는지
* Conclusion accuracy: 인용/기각/각하/취소/파기 결론이 일치하는지
* Complete rate: 생성 문장이 중간에 끊기지 않고 완결되었는지
* Statute hint count: 불필요한 조문 인용 또는 환각 가능성 점검

## 8. App

Flutter 기반 Android 앱 프로토타입입니다.

* 로그인 화면
* 홈 기사 목록
* 기사 상세 화면
* 닉네임 설정
* AI 기사 작성 화면
* 서버 응답 결과 표시

## 9. Server

FastAPI 서버는 앱 요청을 받아 전처리 후 KoBART 모델 추론을 수행하고, 요약 결과를 JSON으로 반환합니다.

주요 엔드포인트:

* `GET /health`
* `POST /summarize`
* `POST /summarize_input_text`

## 10. How to Run

### Server

```bash
pip install -r requirements.txt
uvicorn main:app --reload
```

### App

Android 기기에 APK를 설치한 뒤 서버 주소를 설정하고 실행합니다.
ngrok을 사용할 경우 HTTPS 터널 주소가 앱의 API base URL과 일치해야 합니다.

## 11. Limitations

* 정식 법률 자문 서비스가 아닙니다.
* 민사 판결문 일부 데이터 중심으로 실험했습니다.
* 생성 결과에 금액 누락, 문장 중단, 사실 환각 가능성이 남아 있습니다.
* 실제 서비스화를 위해서는 법률 전문가 검수와 사용자 평가가 필요합니다.

## 12. Repository

* Flutter App: COURTIFY
* FastAPI Server: courtify_server
