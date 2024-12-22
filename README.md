# WaitFree - 낭비되는 시간을 최소화하자

<img src="https://github.com/user-attachments/assets/eb2fad55-911d-4c64-8ec5-cdf45b530774" width="500">

[시연 영상 (iOS)](https://youtu.be/jdMX7svvdbU?feature=shared)

<br>

---

## 👋 프로젝트 소개
WaitFree는 병원, 미용실, 음식점 등에서의 긴 대기 시간 문제를 해결하기 위해 개발된 애플리케이션입니다. 일상생활에서 긴 대기 시간은 바쁜 현대인들에게 큰 스트레스로 다가올 수 있으며, 서비스 제공자에게는 운영 효율성과 고객 만족도 저하의 원인이 됩니다. 이러한 문제에 직면한 사람들에게 실시간으로 대기 상태를 확인할 수 있는 기능을 제공하며, 간편한 예약 및 취소 기능을 통해 사용자의 일정 관리를 도와줍니다. 이 앱은 사용자와 서비스 제공자 모두에게 편의를 제공하여, 대기 시간을 효율적으로 관리하고 예측 가능하게 만드는 것을 돕습니다.


<br>

---

## 🏆 목표
- 실시간 대기 상태 제공: 사용자는 앱을 통해 현재의 대기 시간을 실시간으로 확인할 수 있습니다.
- 간편한 예약 및 취소: 앱을 통해 손쉽게 예약을 하고 필요한 경우 취소할 수 있습니다.
- 운영 효율성 향상: 서비스 제공자는 대기열 관리를 더욱 효과적으로 수행함으로써 고객 경험을 개선하고 운영 효율성을 높일 수 있습니다.
  
<br>

---

## ✨ 주요 기능

### 회원 생성
- 소셜 로그인 지원: 카카오와 구글 계정을 이용한 소셜 로그인 기능을 지원하여, 빠르고 편리하게 앱에 접속할 수 있습니다.
- Firebase 회원가입: Firebase를 활용하여 안전하고 신속한 회원가입 과정을 제공합니다.

### 대기열 관리
- 고객: 사용자는 앱을 통해 매장에 대한 예약을 하거나 취소할 수 있습니다.
- 업주: 매장 운영자는 앱을 통해 대기 중인 팀 수와 명단을 실시간으로 확인할 수 있습니다, 이를 통해 운영의 효율성을 높일 수 있습니다.

### 알림
- 실시간 알림 서비스: FCM(Firebase Cloud Messaging)을 활용한 실시간 알림을 제공하여, 예약 상태 변경 및 중요한 알림을 즉시 받아볼 수 있습니다.

### 문의 및 신고
- 이메일 문의 및 신고: 사용자는 이메일을 통해 문의사항이나 신고 내용을 관리자에게 직접 전달할 수 있습니다. 이를 통해 사용자의 피드백을 신속하게 처리할 수 있습니다.
  
### 편의 기능
- 찜: 사용자는 마음에 드는 매장을 찜하여, 찜 목록에서 별도로 확인할 수 있습니다.
- 지도: 매장 위치 정보를 제공하여 사용자가 매장을 쉽게 찾을 수 있도록 돕습니다.
- 검색: 매장명이나 주소를 검색하여 원하는 매장을 손쉽게 찾을 수 있습니다.
- QR코드: QR코드를 스캔하여 간편하게 예약 페이지에 접속할 수 있습니다.

<br>

---

## 🛠️ 개발 환경 및 아키텍처
<img width="424" alt="image" src="https://github.com/user-attachments/assets/3663895a-50e4-40eb-961a-e1f4ccb3ee21" />
<br>
<img width="446" alt="image" src="https://github.com/user-attachments/assets/2022e46f-c938-40bf-99f2-94ae9c919d01" />


### 서버 사이드
- Firebase Cloud Firestore: 데이터 저장 및 관리를 위해 사용되며, 실시간 데이터 동기화를 지원합니다.
- Firebase Cloud Messaging (FCM): 사용자에게 실시간 알림을 전송하기 위해 사용됩니다.
- Naver Cloud Platform with Flask: Notification Event Handler 서버로, FCM을 통한 알림 이벤트를 관리합니다.
  
### 클라이언트 사이드
- Flutter App에서 사용자 인터페이스를 제공하며, Firebase와 통신하여 데이터를 실시간으로 업데이트하고 받아옵니다.
  
### 인증
- Google OAuth: Google 계정을 통한 인증을 지원합니다.
- Kakao OAuth: 카카오 계정을 통한 인증을 지원합니다.
- Firebase Authentication: 사용자 인증을 관리합니다.

### 통합된 서비스
- Google Maps API: 매장의 위치를 지도에 표시합니다.
- QR Code Integration: QR 코드를 스캔하여 간편하게 예약 페이지로 연결합니다.
- Mailer: 고객 문의, 신고 내용을 관리자의 이메일로 전송합니다.
- Location: 디바이스의 현재 위치를 기반으로 주변 매장을 검색합니다.

<br>

---

## 👬 팀원 소개

<div>
  <table>
    <tr>
      <th>Profile</th>
      <th>Role</th>
    </tr>
    <tr>
      <td align="center">
        <a href="https://github.com/combikms">
          <img src="https://avatars.githubusercontent.com/u/156290648?v=4" width="100" height="80" alt=""/>
          <br/>
          <sub><b>강인석</b></sub>
        </a>
      </td>
      <td>
        - 주요 기능 개발 (예약 및 취소, 업체 등록, 대기열 관리, 찜, 내 정보 등) <br>
        - FireStore 데이터베이스 설계 <br>
        - Frontend UI 배치 <br>
        - WaitFree 기능에 OpenAPI 연동 <br>
      </td>
   </tr>
   <tr>
      <td align="center">
        <a href="https://github.com/GitgaJini">
          <img src="https://avatars.githubusercontent.com/u/112643202?v=4" width="100" height="80" alt=""/>
          <br/>
          <sub><b>김은진</b></sub>
        </a>
      </td>
      <td>
        - 모든 화면 설계 및 디자인 <br>
        - 네비바/둘러보기/FAQ 페이지 구현 <br>
        - 아이콘/애니메이션 제작 및 글귀 작성 <br>
        - 주도, 기능 제안 및 구체화
      </td>
   </tr>
   <tr>
      <td align="center">
        <a href="https://github.com/CF-SJG">
          <img src="https://avatars.githubusercontent.com/u/141010553?v=4" width="100" height="80" alt=""/>
          <br/>
          <sub><b>이민규</b></sub>
        </a>
      </td>
      <td>
        .
      </td>
   </tr>
     <tr>
      <td align="center">
        <a href="https://github.com/dhdheb">
          <img src="https://avatars.githubusercontent.com/u/144876081?v=4" width="100" height="80" alt=""/>
          <br/>
          <sub><b>이영정</b></sub>
        </a>
      </td>
      <td>
        - 주요 기능 개발: 현재 위치 기반 지도 API 통합, 주소 변환 및 거리 계산 <br>
        - QR 코드 생성 및 딥 링크 처리: 예약 시스템과 라우팅 <br>
        - 검색 정렬 및 필터링: 혼잡도/거리순 정렬과 주변 매장 필터링 구현 <br>
        - UI 및 기능 테스트: UX 개선을 위한 UI 일부 수정과 기능 테스트
      </td>
   </tr>
  </table>
</div>
