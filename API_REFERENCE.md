# Art Port API Reference

> **Base URL** `http://localhost:5000`  
> **Content-Type** `application/json`  
> **인증** Stateless JWT. `POST /users/login`으로 액세스·리프레시 토큰을 발급받는다.  
> 보호된 API는 `Authorization: Bearer <accessToken>` 헤더가 필요하다.  
> 액터(행위 주체)는 항상 JWT에서 추출한다 (`SecurityUtils.currentUserId()`).  
> `userId` / `clientId` / `artistId` / `followerId` / `adminUserId` / `reviewedBy` 등 쿼리·바디로 액터를 받지 않는다.  
> 액세스 토큰 만료 시 `POST /auth/refresh`로 갱신한다. HTTP 세션은 사용하지 않는다.

---

## 공통 응답 구조

### 성공

```json
{
  "success": true,
  "data": { }
}
```

### 실패

```json
{
  "success": false,
  "error": {
    "timestamp": "2026-06-27T09:00:00",
    "status": 404,
    "code": "USER_NOT_FOUND",
    "message": "사용자를 찾을 수 없습니다",
    "errors": []
  }
}
```

### Validation 실패 (400)

```json
{
  "success": false,
  "error": {
    "status": 400,
    "code": "INVALID_INPUT",
    "message": "입력값이 유효하지 않습니다",
    "errors": [
      { "field": "email", "value": "", "reason": "공백일 수 없습니다" }
    ]
  }
}
```

### 에러 코드 목록

| code | status | 설명 |
|---|---|---|
| `BAD_REQUEST` | 400 | 잘못된 요청 |
| `INVALID_INPUT` | 400 | 입력값 유효성 오류 (상태 전이 불가, 필수값 누락 등) |
| `INVALID_OR_EXPIRED_VERIFICATION_TOKEN` | 400 | 이메일 인증 코드가 없거나 만료·이미 사용됨 |
| `UPLOAD_INVALID` | 400 | 잘못된 업로드 요청 (빈 파일·잘못된 key 등) |
| `UPLOAD_TOO_LARGE` | 400 | 업로드 파일 용량이 purpose/발급 한도 초과 |
| `UPLOAD_TOKEN_INVALID` | 400 | 유효하지 않거나 만료·이미 사용된 업로드 토큰 |
| `UNSUPPORTED_CONTENT_TYPE` | 400 | 지원하지 않는 Content-Type |
| `WEBHOOK_SIGNATURE_INVALID` | 400 | PortOne 웹훅 서명 검증 실패 |
| `UNAUTHORIZED` | 401 | 인증 필요 (Bearer 토큰 없음·미인증) |
| `INVALID_CREDENTIALS` | 401 | 이메일 또는 비밀번호 불일치 (비밀번호 변경 시 현재 비밀번호 불일치 포함) |
| `INVALID_TOKEN` | 401 | 유효하지 않은 액세스 토큰 |
| `EXPIRED_TOKEN` | 401 | 만료된 액세스 토큰 |
| `INVALID_REFRESH_TOKEN` | 401 | 유효하지 않거나 만료·폐기된 리프레시 토큰 |
| `FORBIDDEN` | 403 | 접근 권한 없음 (참여자·소유자·관리자 검증 실패) |
| `USER_INACTIVE` | 403 | 비활성화된 계정 |
| `USER_NOT_FOUND` | 404 | 사용자 없음 |
| `ARTIST_PROFILE_NOT_FOUND` | 404 | 아티스트 프로필 없음 |
| `CLIENT_PROFILE_NOT_FOUND` | 404 | 클라이언트 프로필 없음 |
| `ARTIST_APPLICATION_NOT_FOUND` | 404 | 아티스트 신청 없음 |
| `ARTIST_NOTICE_NOT_FOUND` | 404 | 아티스트 공지 없음 |
| `ORDER_NOT_FOUND` | 404 | 주문 없음 |
| `COMMISSION_TYPE_NOT_FOUND` | 404 | 커미션 타입 없음 |
| `PORTFOLIO_IMAGE_NOT_FOUND` | 404 | 포트폴리오 이미지 없음 |
| `SOCIAL_LINK_NOT_FOUND` | 404 | 소셜 링크 없음 |
| `CHAT_ROOM_NOT_FOUND` | 404 | 채팅방 없음 |
| `CHAT_MESSAGE_NOT_FOUND` | 404 | 채팅 메시지 없음 |
| `REVIEW_NOT_FOUND` | 404 | 리뷰 없음 |
| `FOLLOW_NOT_FOUND` | 404 | 팔로우 관계 없음 |
| `SUPPORT_INQUIRY_NOT_FOUND` | 404 | 고객센터 문의 없음 |
| `PAYMENT_NOT_FOUND` | 404 | 결제 없음 |
| `RESOURCE_NOT_FOUND` | 404 | 리소스 없음 (범용) |
| `DUPLICATE_EMAIL` | 409 | 이메일 중복 |
| `DUPLICATE_RESOURCE` | 409 | 리소스 중복 |
| `EMAIL_ALREADY_VERIFIED` | 409 | 이미 이메일 인증이 완료된 계정 |
| `PAYMENT_VERIFICATION_FAILED` | 409 | PortOne 결제 검증 실패 (미완료·금액 불일치 등) |
| `INTERNAL_SERVER_ERROR` | 500 | 서버 내부 오류 |

> **권한 검증** — 주문·채팅·리뷰·고객센터 등 참여자/소유자 확인 실패 시 `403 FORBIDDEN`.  
> **아티스트 리소스 수정·삭제** — 공지·커미션·포트폴리오·소셜 링크는 JWT 사용자와 아티스트 프로필 소유자를 대조한다. 비소유자면 `403 FORBIDDEN`.  
> **관리자 API** — 고객센터 전체 목록·상태 변경, 아티스트 신청 검토 등은 JWT `isAdmin`으로 인가한다.

---

## Uploads (파일 업로드)

로컬 디스크 저장 + 직접 업로드(presign → PUT) 방식. DB에는 기존 URL 컬럼만 사용하며, 업로드 전용 테이블은 없다.  
운영에서 S3로 교체할 때는 `StorageService` 구현체만 바꾸면 된다 (`app.storage.type=local`만 현재 지원).

### 흐름

1. `POST /uploads/presign` (JWT) → `uploadUrl` / `fileUrl` 발급  
2. `PUT {uploadUrl}` 로 raw bytes 업로드 (JWT 불필요, 토큰이 권한)  
3. 기존 도메인 API에 `fileUrl` 저장 (예: `POST .../portfolio-images`의 `imageUrl`)

### 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| `POST` | `/uploads/presign` | 업로드 티켓 발급 (JWT) |
| `PUT` | `/files/upload/{token}` | raw body 업로드 (토큰 인증, 204) |
| `GET` | `/files/public/**` | 공개 파일 조회 (인증 불필요) |
| `GET` | `/files/private/**` | 비공개 파일 조회 (JWT) |

### purpose → DB 컬럼

| purpose | visibility | 대상 컬럼 |
|---|---|---|
| `AVATAR` | public | `client_profiles.avatar_url`, `artist_profiles.avatar_url` |
| `BACKGROUND` | public | `artist_profiles.background_url` |
| `PORTFOLIO` | public | `portfolio_images.image_url`, `artist_applications.portfolio_image_urls` |
| `VERIFICATION` | private | `artist_applications.verification_file_urls` |
| `COMMISSION_THUMBNAIL` | public | `commission_types.thumbnail_url` |
| `COMMISSION_SAMPLE` | public | `commission_types.sample_image_urls` |
| `ORDER_REFERENCE` | public | `orders.reference_image_urls` |
| `CHAT_ATTACHMENT` | private | `chat_messages.attachment_url` |
| `REVIEW_IMAGE` | public | `reviews.image_urls` |
| `SUPPORT_ATTACHMENT` | private | `support_messages.attachment_urls` |

### 용량·Content-Type 기본값

| purpose | max | Content-Type |
|---|---|---|
| 대부분의 이미지 purpose | 10MB | `image/jpeg`, `image/png`, `image/webp`, `image/gif` |
| `ORDER_REFERENCE`, `CHAT_ATTACHMENT` | 15MB | 이미지 (+ `CHAT_ATTACHMENT`는 `application/pdf`) |
| `VERIFICATION`, `SUPPORT_ATTACHMENT` | 20MB | 이미지 + `application/pdf` |

### POST `/uploads/presign`

**Request Body**

```json
{
  "purpose": "PORTFOLIO",
  "contentType": "image/png",
  "fileName": "work.png",
  "sizeBytes": 12345
}
```

**Response 200**

```json
{
  "success": true,
  "data": {
    "key": "public/portfolio/00000000-0000-0000-0000-000000000002/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee.png",
    "uploadUrl": "http://localhost:5000/files/upload/abc123...",
    "fileUrl": "http://localhost:5000/files/public/portfolio/00000000-0000-0000-0000-000000000002/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee.png",
    "expiresAt": "2026-08-15T04:10:00Z"
  }
}
```

### PUT `/files/upload/{token}`

- Body: raw bytes (`Content-Type`은 presign 시 값과 일치)
- **Response 204** (바디 없음)
- 실패: `UPLOAD_TOKEN_INVALID`, `UPLOAD_TOO_LARGE`, `UNSUPPORTED_CONTENT_TYPE`, `UPLOAD_INVALID`

### GET `/files/public/**` / `/files/private/**`

- 성공 시 파일 바이너리 직접 반환 (ApiResponse 래퍼 없음)
- 없으면 404
- private는 JWT 없으면 `401 UNAUTHORIZED`

---

## 개발 테스트 계정 (시드 데이터)

| 이메일 | 비밀번호 | 이름 | isAdmin | 의뢰자 프로필 | 작가 프로필 | UUID |
|---|---|---|---|---|---|---|
| `client@example.com` | `password123` | 김혜린 | false | O | | `00000000-0000-0000-0000-000000000001` |
| `artist1@example.com` | `password123` | 박서아 | false | O | O | `00000000-0000-0000-0000-000000000002` |
| `artist2@example.com` | `password123` | 이주원 | false | O | O | `00000000-0000-0000-0000-000000000003` |
| `admin@example.com` | `password123` | 관리자 | true | O | | `00000000-0000-0000-0000-000000000099` |

> UUID 규칙: `00000000-0000-0000-{테이블번호}-{순번}` — 외워두면 테스트에 편리

---

## 열거형 (Enum)

| 타입 | 값 |
|---|---|
| `ApplicationStatus` | `pending` `approved` `rejected` |
| `SlotStatus` | `open` `closed` `resting` |
| `AgeRating` | `all` `15` `18` |
| `SocialLinkType` | `twitter` `instagram` `website` `other` |
| `NoticeType` | `pinned` `general` |
| `ChatMessageType` | `text` `image` `file` `system` `payment_request` `application_card` |
| `OrderStatus` | `submitted` `accepted` `rejected` `payment_requested` `paid` `working` `completed` `cancelled` `refunded` |
| `OrderStep` | `deposit` `sketch` `line_art` `coloring` `completed` |
| `UsagePurpose` | `personal` `commercial` `broadcasting` |
| `SupportInquiryCategory` | `payment` `order` `account` `artist` `etc` |
| `SupportInquiryStatus` | `open` `in_progress` `resolved` `closed` |

---

---

## 0. Auth (JWT)

세션 없이 Access Token(JWT) + Refresh Token(불투명, DB 해시 저장)을 사용한다.

| Method | Path | 인증 | 설명 |
|---|---|---|---|
| `POST` | `/users/login` | 불필요 | 로그인 · 토큰 발급 |
| `POST` | `/auth/refresh` | 불필요 | 액세스·리프레시 토큰 재발급 (회전) |
| `POST` | `/auth/logout` | 불필요 | 리프레시 토큰 폐기 |

**공개(인증 불필요)**  
`POST /users/login`, `POST /users`, 이메일 인증 관련, `POST /auth/refresh`, `POST /auth/logout`, Actuator health/info  
**그 외** 전부 `Authorization: Bearer <accessToken>` 필요

기본 TTL: Access `15m`, Refresh `14d` (`app.jwt.*`로 설정)

### POST `/auth/refresh`

**Request Body**

```json
{
  "refreshToken": "<refresh-token>"
}
```

**Response 200** — `POST /users/login`과 동일한 `AuthResponse`  
성공 시 기존 리프레시 토큰은 폐기되고 새 토큰 쌍이 발급된다(회전).

**Error** `401 INVALID_REFRESH_TOKEN`  
**Error** `403 USER_INACTIVE`

### POST `/auth/logout`

**Request Body**

```json
{
  "refreshToken": "<refresh-token>"
}
```

**Response** `204 No Content`  
이미 폐기·없는 토큰이어도 204를 반환한다.

---

## 1. Users

계정(`users`)은 한 사람이다. 의뢰자/작가는 `role` 컬럼이 아니라 프로필 존재로 구분한다.

- 의뢰자: `client_profiles` 행이 있으면 의뢰 가능 (가입 시 자동 생성)
- 작가: `artist_profiles` 행이 있으면 작가 (아티스트 신청 승인 시 생성)
- 관리자: `users.is_admin = true`

같은 사람이 의뢰자이면서 작가일 수 있다. UserResponse의 `clientProfileId` / `artistProfileId`가 `null`이면 해당 프로필이 없는 것이다.

### 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| `GET` | `/users/me` | 내 정보 조회 (JWT) |
| `GET` | `/users/{id}` | 사용자 공개 조회 |
| `POST` | `/users/login` | 로그인 (토큰 발급) |
| `POST` | `/users` | 사용자 생성 |
| `POST` | `/users/send-verification-email` | 이메일 인증 메일 발송 (가입과 별도) |
| `POST` | `/users/resend-verification-email` | 이메일 인증 메일 재발송 |
| `POST` | `/users/verify-email` | 이메일 인증 코드 검증 |
| `PATCH` | `/users/me` | 내 정보 수정 (JWT) |
| `PATCH` | `/users/me/password` | 비밀번호 변경 (성공 시 해당 유저 리프레시 토큰 전부 폐기) |
| `DELETE` | `/users/me` | 내 계정 비활성화 (soft delete, 리프레시 토큰 전부 폐기) |

### GET `/users/me`

```http
GET /users/me
Authorization: Bearer <accessToken>
```

**Response 200** — `data`: UserResponse (아래 `GET /users/{id}`와 동일 형식)

### GET `/users/{id}`

```http
GET /users/00000000-0000-0000-0000-000000000001
Authorization: Bearer <accessToken>
```

**Response 200**

```json
{
  "success": true,
  "data": {
    "id": "00000000-0000-0000-0000-000000000001",
    "email": "client@example.com",
    "name": "김혜린",
    "phone": "010-1111-0001",
    "isAdmin": false,
    "clientProfileId": "00000000-0000-0000-0001-000000000001",
    "artistProfileId": null,
    "isEmailVerified": true,
    "isActive": true,
    "lastLoginAt": null,
    "createdAt": "2026-06-27T09:00:00Z",
    "updatedAt": "2026-06-27T09:00:00Z"
  }
}
```

작가 계정(`artist1@example.com`)은 같은 형식에서 `clientProfileId`와 `artistProfileId`가 모두 채워진다.

**Error** `401 UNAUTHORIZED` — Bearer 토큰 없음  
**Error** `401 INVALID_TOKEN` / `EXPIRED_TOKEN` — 토큰 무효·만료

### POST `/users/login`

이메일·비밀번호로 인증하고 액세스·리프레시 토큰과 사용자 정보를 반환한다. 성공 시 `lastLoginAt`이 갱신된다.

**Request Body**

```json
{
  "email": "client@example.com",
  "password": "password123"
}
```

**Response 200**

```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiJ9...",
    "refreshToken": "dGhpcy1pcy1hLXJlZnJlc2g...",
    "tokenType": "Bearer",
    "expiresIn": 900,
    "user": {
      "id": "00000000-0000-0000-0000-000000000001",
      "email": "client@example.com",
      "name": "김혜린",
      "phone": "010-1111-0001",
      "isAdmin": false,
      "clientProfileId": "00000000-0000-0000-0001-000000000001",
      "artistProfileId": null,
      "isEmailVerified": true,
      "isActive": true,
      "lastLoginAt": "2026-08-14T12:30:00Z",
      "createdAt": "2026-06-27T09:00:00Z",
      "updatedAt": "2026-08-14T12:30:00Z"
    }
  }
}
```

**Error** `401 INVALID_CREDENTIALS` — 이메일 없음 또는 비밀번호 불일치  
**Error** `403 USER_INACTIVE` — 비활성화된 계정

### POST `/users`

**Request Body**

```json
{
  "email": "newuser@example.com",
  "password": "password123",
  "name": "홍길동",
  "phone": "010-0000-0000"
}
```

**Validation**

| 필드 | 규칙 |
|---|---|
| `email` | 필수, 이메일 형식, 최대 255자 |
| `password` | 필수, 8~100자 |
| `name` | 필수, 2~100자 |
| `phone` | 선택, `01X-XXXX-XXXX` 형식 (하이픈 생략 가능) |

**Response 201** — `data`: UserResponse. 가입 시 `client_profiles`가 함께 생성되어 `clientProfileId`가 채워진다.  
`isEmailVerified`는 `false`로 시작한다. 인증 메일은 가입과 별도로 `POST /users/send-verification-email`을 호출해야 발송된다.  
**Error** `400 INVALID_INPUT` — 유효성 검사 실패  
**Error** `409 DUPLICATE_EMAIL` — 이메일 중복

### POST `/users/send-verification-email`

미인증 계정에 인증 메일을 보낸다. 기존 미사용 코드가 있으면 무효화한 뒤 새 6자리 코드를 발급하고 RabbitMQ로 발송을 큐잉한다.

**Request Body**

```json
{
  "email": "newuser@example.com"
}
```

**Validation**

| 필드 | 규칙 |
|---|---|
| `email` | 필수, 이메일 형식, 최대 255자 |

**Response 204** (body 없음)  
**Error** `400 INVALID_INPUT` — 유효성 검사 실패  
**Error** `403 USER_INACTIVE` — 비활성화된 계정  
**Error** `404 USER_NOT_FOUND` — 이메일 없음  
**Error** `409 EMAIL_ALREADY_VERIFIED` — 이미 인증된 계정

### POST `/users/resend-verification-email`

인증 메일을 다시 보낸다. 요청·응답·에러는 `POST /users/send-verification-email`과 동일하다.  
기존 미사용 코드는 무효화되고 새 6자리 코드가 발급된다.

**Request Body**

```json
{
  "email": "newuser@example.com"
}
```

**Response 204** (body 없음)  
**Error** `400 INVALID_INPUT` — 유효성 검사 실패  
**Error** `403 USER_INACTIVE` — 비활성화된 계정  
**Error** `404 USER_NOT_FOUND` — 이메일 없음  
**Error** `409 EMAIL_ALREADY_VERIFIED` — 이미 인증된 계정

### POST `/users/verify-email`

메일로 받은 6자리 인증 코드로 이메일을 인증한다. 성공 시 `isEmailVerified=true`.

**Request Body**

```json
{
  "email": "newuser@example.com",
  "code": "123456"
}
```

**Validation**

| 필드 | 규칙 |
|---|---|
| `email` | 필수, 이메일 형식, 최대 255자 |
| `code` | 필수, 숫자 6자리 |

**Response 200** — `data`: UserResponse (`isEmailVerified: true`)  
**Error** `400 INVALID_OR_EXPIRED_VERIFICATION_TOKEN` — 코드 없음·불일치·만료·이미 사용  
**Error** `403 USER_INACTIVE` — 비활성화된 계정  
**Error** `409 EMAIL_ALREADY_VERIFIED` — 이미 인증된 계정

### PATCH `/users/me`

JWT 사용자의 정보를 수정한다.

**Request Body** (모든 필드 optional)

```json
{
  "name": "김혜린(수정)",
  "phone": "010-9999-0000"
}
```

**Validation**

| 필드 | 규칙 |
|---|---|
| `name` | 2~100자 |
| `phone` | `01X-XXXX-XXXX` 형식 (하이픈 생략 가능) |

**Response 200** — `data`: UserResponse  
**Error** `400 INVALID_INPUT` — 유효성 검사 실패  
**Error** `404 USER_NOT_FOUND`

### PATCH `/users/me/password`

현재 비밀번호를 검증한 뒤 새 비밀번호로 변경한다. 대상은 JWT 사용자다.

**Request Body**

```json
{
  "currentPassword": "password123",
  "newPassword": "newpassword123"
}
```

**Validation**

| 필드 | 규칙 |
|---|---|
| `currentPassword` | 필수, 8~100자 |
| `newPassword` | 필수, 8~100자 |

**Response 204** (body 없음)  
**Error** `400 INVALID_INPUT` — 유효성 검사 실패, 또는 새 비밀번호가 현재와 동일  
**Error** `401 INVALID_CREDENTIALS` — 현재 비밀번호 불일치  
**Error** `403 USER_INACTIVE` — 비활성화된 계정  
**Error** `404 USER_NOT_FOUND`

### DELETE `/users/me`

JWT 사용자를 비활성화한다.

**Response 204** (body 없음)

---

## 2. Client Profiles

본인 클라이언트 프로필만 조회·수정·삭제한다. 액터는 JWT에서 결정된다.

### 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| `GET` | `/users/me/client-profile` | 내 클라이언트 프로필 조회 |
| `PATCH` | `/users/me/client-profile` | 생성 또는 수정 (upsert) |
| `DELETE` | `/users/me/client-profile` | soft delete |

### GET `/users/me/client-profile`

```http
GET /users/me/client-profile
Authorization: Bearer <accessToken>
```

**Response 200**

```json
{
  "success": true,
  "data": {
    "id": "00000000-0000-0000-0001-000000000001",
    "userId": "00000000-0000-0000-0000-000000000001",
    "avatarUrl": "https://picsum.photos/seed/client1/200",
    "createdAt": "2026-06-27T09:00:00Z",
    "updatedAt": "2026-06-27T09:00:00Z"
  }
}
```

### PATCH `/users/me/client-profile`

**Request Body**

```json
{
  "avatarUrl": "https://example.com/avatar.png"
}
```

**Response 200** — `data`: ClientProfileResponse

---

## 3. Artist Profiles

### 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| `GET` | `/artist-profiles` | 전체 목록 |
| `GET` | `/artist-profiles/{id}` | 단건 조회 |
| `POST` | `/artist-profiles` | 생성 |
| `PATCH` | `/artist-profiles/{id}` | 수정 |
| `DELETE` | `/artist-profiles/{id}` | soft delete |

### GET `/artist-profiles/{id}`

```http
GET /artist-profiles/00000000-0000-0000-0002-000000000001
```

**Response 200**

```json
{
  "success": true,
  "data": {
    "id": "00000000-0000-0000-0002-000000000001",
    "userId": "00000000-0000-0000-0000-000000000002",
    "displayName": "서아 아트",
    "avatarUrl": "https://picsum.photos/seed/artist1/200",
    "backgroundUrl": "https://picsum.photos/seed/artist1bg/800/300",
    "oneLineIntro": "따뜻한 감성의 캐릭터 일러스트를 그립니다",
    "detailedIntro": "안녕하세요! 5년 경력의 캐릭터 일러스트레이터입니다.",
    "workingHours": "평일 10:00 ~ 22:00",
    "averageDeliveryDays": 14,
    "revisionPolicy": "스케치 1회, 채색 2회 수정 포함",
    "paymentTerms": "의뢰 수락 후 50% 선입금, 완성 후 50% 잔금",
    "specialties": ["캐릭터", "아이돌", "팬아트", "굿즈"],
    "restrictedItems": ["혐오 표현", "19금"],
    "rating": 4.80,
    "reviewCount": 23,
    "followerCount": 142,
    "completedCount": 31,
    "responseRatePercent": 95,
    "isRestMode": false,
    "slotStatus": "open",
    "statusMessage": "현재 슬롯 여유 있어요 😊",
    "isVerified": true,
    "createdAt": "2026-06-27T09:00:00Z",
    "updatedAt": "2026-06-27T09:00:00Z"
  }
}
```

### POST `/artist-profiles`

JWT 사용자에 아티스트 프로필을 생성한다. `userId`는 요청에 포함하지 않는다.

**Request Body**

```json
{
  "displayName": "서아 아트",
  "oneLineIntro": "따뜻한 감성의 일러스트레이터",
  "specialties": ["캐릭터", "팬아트"],
  "restrictedItems": ["19금"]
}
```

**Error** `404 USER_NOT_FOUND`  
**Error** `403 FORBIDDEN` — 소유자 검증 실패 (수정·삭제 시)

---

## 4. Artist Applications

### 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| `POST` | `/artist-applications` | 아티스트 신청 (JWT 사용자) |
| `GET` | `/artist-applications/my` | 본인 신청 조회 |
| `GET` | `/artist-applications/{id}` | 단건 조회 |
| `PATCH` | `/artist-applications/{id}/review` | 승인/거절 (관리자, JWT `isAdmin`) |
| `DELETE` | `/artist-applications/{id}` | soft delete |

### POST `/artist-applications`

신청자는 JWT에서 결정된다. 바디에 `userId`를 넣지 않는다.

**Request Body**

```json
{
  "artistName": "홍길동 아트",
  "bankName": "카카오뱅크",
  "accountNumber": "3333-01-0000000",
  "accountHolder": "홍길동",
  "portfolioImageUrls": ["https://example.com/port1.jpg"],
  "verificationFileUrls": ["https://example.com/id.pdf"],
  "styleTags": ["캐릭터"],
  "maxWorkDays": 14,
  "roughRevisionCount": 1,
  "finalRevisionCount": 2,
  "allowNonCommercial": true,
  "allowCommercialStreaming": false,
  "allowCopyrightTransfer": false,
  "termsAgreedAt": "2026-06-27T09:00:00Z"
}
```

**Error** `409 DUPLICATE_RESOURCE` — 이미 아티스트 프로필이 있거나, 검토 중인 신청이 있을 때

### PATCH `/artist-applications/{id}/review`

관리자만 호출 가능하다. 검토자는 JWT 사용자다.

**Request Body**

```json
{ "status": "approved" }
```
```json
{ "status": "rejected", "rejectionReason": "포트폴리오 이미지 품질 미달" }
```

승인(`approved`) 시 해당 유저에 `artist_profiles`가 없으면 신청 정보로 생성한다. 같은 유저는 의뢰자 프로필을 유지한 채 작가가 된다.

**Error**
- `400 INVALID_INPUT` — rejected인데 rejectionReason 없을 때, status가 pending일 때
- `403 FORBIDDEN` — JWT 사용자가 관리자(`isAdmin`)가 아닐 때

---

## 5. Artist Social Links

### 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| `GET` | `/artist-profiles/{profileId}/social-links` | 목록 조회 |
| `POST` | `/artist-profiles/{profileId}/social-links` | 추가 (아티스트 소유자, JWT) |
| `PATCH` | `/artist-social-links/{id}` | 수정 (아티스트 소유자, JWT) |
| `DELETE` | `/artist-social-links/{id}` | soft delete (아티스트 소유자, JWT) |

### POST `/artist-profiles/{profileId}/social-links`

**Request Body**

```json
{
  "type": "twitter",
  "label": "@my_art",
  "url": "https://twitter.com/my_art"
}
```

**Response 201**

```json
{
  "success": true,
  "data": {
    "id": "...",
    "artistProfileId": "00000000-0000-0000-0002-000000000001",
    "type": "twitter",
    "label": "@my_art",
    "url": "https://twitter.com/my_art",
    "createdAt": "2026-06-27T09:00:00Z"
  }
}
```

---

## 6. Commission Types

### 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| `GET` | `/commission-types` | 전체 목록 |
| `GET` | `/commission-types/{id}` | 단건 조회 |
| `GET` | `/artist-profiles/{profileId}/commission-types` | 아티스트별 목록 |
| `POST` | `/commission-types` | 생성 (아티스트 소유자, JWT) |
| `PATCH` | `/commission-types/{id}` | 수정 (아티스트 소유자, JWT) |
| `DELETE` | `/commission-types/{id}` | soft delete (아티스트 소유자, JWT) |

### GET `/commission-types/{id}`

```http
GET /commission-types/00000000-0000-0000-0005-000000000001
```

**Response 200**

```json
{
  "success": true,
  "data": {
    "id": "00000000-0000-0000-0005-000000000001",
    "artistProfileId": "00000000-0000-0000-0002-000000000001",
    "name": "캐릭터 반신 일러스트",
    "description": "캐릭터 반신 컷 일러스트입니다. 배경 없음 기준.",
    "thumbnailUrl": "https://picsum.photos/seed/ct1/400/500",
    "startingPriceWon": 50000,
    "workPeriodDays": 7,
    "totalSlots": 5,
    "openSlots": 3,
    "ageRating": "all",
    "tags": ["캐릭터", "반신", "단색배경"],
    "sampleImageUrls": ["https://picsum.photos/seed/sample1/400/500"],
    "priceOptions": [
      { "label": "단색 배경 추가", "priceWon": 10000 },
      { "label": "복잡한 배경 추가", "priceWon": 30000 }
    ],
    "introText": "기본 반신 컷 일러스트입니다.",
    "workScopeItems": ["러프 스케치", "선화", "채색", "후보정"],
    "revisionPolicyItems": ["스케치 1회 수정", "채색 2회 수정"],
    "noticeText": "레퍼런스 이미지는 최소 3장 이상 첨부해주세요.",
    "completedCount": 12,
    "responseRatePercent": 95,
    "isActive": true,
    "createdAt": "2026-06-27T09:00:00Z",
    "updatedAt": "2026-06-27T09:00:00Z"
  }
}
```

### POST `/commission-types`

**Request Body**

```json
{
  "artistProfileId": "00000000-0000-0000-0002-000000000001",
  "name": "캐릭터 반신 일러스트",
  "startingPriceWon": 50000,
  "workPeriodDays": 7,
  "totalSlots": 5,
  "ageRating": "all",
  "tags": ["캐릭터"],
  "priceOptions": [
    { "label": "단색 배경 추가", "priceWon": 10000 }
  ]
}
```

---

## 7. Portfolio Images

### 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| `GET` | `/artist-profiles/{profileId}/portfolio-images` | 목록 (sort_order 순) |
| `POST` | `/artist-profiles/{profileId}/portfolio-images` | 이미지 추가 (아티스트 소유자, JWT) |
| `PATCH` | `/artist-profiles/{profileId}/portfolio-images/reorder` | 순서 변경 (아티스트 소유자, JWT) |
| `DELETE` | `/portfolio-images/{id}` | soft delete (아티스트 소유자, JWT) |

### PATCH `/artist-profiles/{profileId}/portfolio-images/reorder`

**Request Body**

```json
{
  "orderedIds": [
    "00000000-0000-0000-0006-000000000003",
    "00000000-0000-0000-0006-000000000001",
    "00000000-0000-0000-0006-000000000002"
  ]
}
```

**Response 200** — `data`: `List<PortfolioImageResponse>` (재정렬된 전체 목록)

---

## 8. Artist Notices

### 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| `GET` | `/artist-profiles/{profileId}/notices` | 공개 공지 목록 |
| `GET` | `/artist-profiles/{profileId}/notices?manage=true` | 전체 공지 (관리용, 소유자 JWT) |
| `POST` | `/artist-profiles/{profileId}/notices` | 공지 생성 (아티스트 소유자, JWT) |
| `PATCH` | `/artist-notices/{id}` | 수정 (아티스트 소유자, JWT) |
| `DELETE` | `/artist-notices/{id}` | soft delete (아티스트 소유자, JWT) |

### POST `/artist-profiles/{profileId}/notices`

**Request Body**

```json
{
  "type": "pinned",
  "title": "필독! 의뢰 전 안내사항",
  "content": "의뢰 전 반드시 읽어주세요.",
  "bulletPoints": ["레퍼런스 3장 이상 필수", "비상업용 한정"],
  "isPublic": true
}
```

---

## 9. Wishlists

### 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| `GET` | `/users/me/wishlists` | 내 찜 목록 (JWT) |
| `POST` | `/wishlists/toggle` | 찜 토글 (추가/취소, JWT) |

### POST `/wishlists/toggle`

**Request Body**

```json
{ "commissionTypeId": "00000000-0000-0000-0005-000000000001" }
```

**Response 200**

```json
{
  "success": true,
  "data": {
    "wishlisted": true,
    "wishlist": {
      "id": "...",
      "commissionTypeId": "00000000-0000-0000-0005-000000000001",
      "commissionTypeName": "캐릭터 반신 일러스트",
      "createdAt": "2026-06-27T09:00:00Z"
    }
  }
}
```

> 찜 취소 시: `{ "wishlisted": false, "wishlist": null }`

---

## 10. Follows

### 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| `POST` | `/follows` | 팔로우 (팔로워=JWT) |
| `DELETE` | `/follows/{followingId}` | 언팔로우 (팔로워=JWT) |
| `GET` | `/users/{userId}/followings` | 팔로잉 목록 (공개 리소스 스코프) |
| `GET` | `/users/{userId}/followers` | 팔로워 목록 (공개 리소스 스코프) |

### POST `/follows`

팔로워는 JWT에서 결정된다. 바디의 `followingId`는 팔로우 대상 리소스다.

**Request Body**

```json
{ "followingId": "00000000-0000-0000-0000-000000000002" }
```

**Response 201**

```json
{
  "success": true,
  "data": {
    "id": "...",
    "followingId": "00000000-0000-0000-0000-000000000002",
    "createdAt": "2026-06-27T09:00:00Z"
  }
}
```

**Error** `400 BAD_REQUEST` — 자기 자신 팔로우 시도  
**Error** `409 DUPLICATE_RESOURCE` — 이미 팔로우 중

---

## 11. Chat Rooms

### 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| `GET` | `/chat-rooms` | 내 채팅방 목록 (JWT) |
| `GET` | `/chat-rooms/{id}` | 단건 조회 (참여자만) |
| `POST` | `/chat-rooms` | 채팅방 생성 (이미 있으면 기존 반환) |
| `PATCH` | `/chat-rooms/{id}/read` | 읽음 처리 |
| `DELETE` | `/chat-rooms/{id}` | soft delete |

### GET `/chat-rooms`

```http
GET /chat-rooms
Authorization: Bearer <accessToken>
```

**Response 200**

```json
{
  "success": true,
  "data": [
    {
      "id": "00000000-0000-0000-0010-000000000001",
      "clientId": "00000000-0000-0000-0000-000000000001",
      "artistId": "00000000-0000-0000-0000-000000000002",
      "lastMessagePreview": "확인했습니다! 스케치 시작할게요 🎨",
      "unreadCount": 1,
      "lastMessageAt": "2026-06-26T09:10:00Z"
    }
  ]
}
```

### POST `/chat-rooms`

호출자는 JWT에서 결정되며, 방 참여자(`clientId` / `artistId`) 중 한 명이어야 한다.

**Request Body**

```json
{
  "clientId": "00000000-0000-0000-0000-000000000001",
  "artistId": "00000000-0000-0000-0000-000000000002"
}
```

**Error** `403 FORBIDDEN` — JWT 사용자가 방 참여자가 아닐 때

---

## 12. Chat Messages

### 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| `GET` | `/chat-rooms/{roomId}/messages` | 메시지 목록 (시간순, 참여자 JWT) |
| `POST` | `/chat-rooms/{roomId}/messages` | 메시지 전송 (발신자=JWT) |
| `DELETE` | `/messages/{id}` | soft delete (발신자/참여자 JWT) |

### POST `/chat-rooms/{roomId}/messages`

**Request Body**

```json
{
  "type": "text",
  "content": "안녕하세요! 반신 일러스트 의뢰 가능한가요?"
}
```

이미지/파일 첨부 시:

```json
{
  "type": "image",
  "content": null,
  "attachmentUrl": "https://example.com/reference.jpg"
}
```

**Response 201**

```json
{
  "success": true,
  "data": {
    "id": "...",
    "chatRoomId": "00000000-0000-0000-0010-000000000001",
    "senderId": "00000000-0000-0000-0000-000000000001",
    "type": "text",
    "content": "안녕하세요! 반신 일러스트 의뢰 가능한가요?",
    "attachmentUrl": null,
    "attachmentName": null,
    "isRead": false,
    "readAt": null,
    "createdAt": "2026-06-27T09:00:00Z"
  }
}
```

---

## 13. Orders

### 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| `GET` | `/orders/{id}` | 주문 단건 조회 (참여자만, 이력 포함) |
| `GET` | `/orders/my/client` | 내 클라이언트 주문 목록 (JWT) |
| `GET` | `/orders/my/artist` | 내 아티스트 주문 목록 (JWT) |
| `POST` | `/orders` | 주문 접수 (클라이언트=JWT) |
| `PATCH` | `/orders/{id}/accept` | 수락 (아티스트=JWT) |
| `PATCH` | `/orders/{id}/reject` | 거절 (아티스트=JWT) |
| `PATCH` | `/orders/{id}/step` | 작업 단계 변경 (참여자 JWT) |
| `DELETE` | `/orders/{id}` | 취소 (soft delete, 참여자 JWT) |

### GET `/orders/{id}`

```http
GET /orders/00000000-0000-0000-0011-000000000001
Authorization: Bearer <accessToken>
```

**Error**
- `403 FORBIDDEN` — JWT 사용자가 client/artist 참여자가 아닐 때
- `404 ORDER_NOT_FOUND`

**Response 200**

```json
{
  "success": true,
  "data": {
    "id": "00000000-0000-0000-0011-000000000001",
    "commissionTypeId": "00000000-0000-0000-0005-000000000001",
    "clientId": "00000000-0000-0000-0000-000000000001",
    "artistId": "00000000-0000-0000-0000-000000000002",
    "chatRoomId": "00000000-0000-0000-0010-000000000001",
    "requestContent": "오리지널 캐릭터 반신 일러스트 의뢰합니다.",
    "referenceImageUrls": ["https://picsum.photos/seed/ref1/300/400"],
    "usagePurpose": "personal",
    "desiredDeadline": "2026-07-11",
    "selectedOption": { "label": "단색 배경 추가", "priceWon": 10000 },
    "baseAmountWon": 50000,
    "additionalAmountWon": 10000,
    "serviceFeeWon": 3000,
    "totalAmountWon": 63000,
    "status": "working",
    "currentStep": "coloring",
    "projectName": "핑크 교복 캐릭터 반신",
    "deadlineAt": "2026-07-11T00:00:00Z",
    "completedAt": null,
    "cancelledAt": null,
    "cancelReason": null,
    "histories": [
      {
        "id": "...",
        "orderId": "00000000-0000-0000-0011-000000000001",
        "changedBy": "00000000-0000-0000-0000-000000000001",
        "previousStatus": null,
        "newStatus": "submitted",
        "previousStep": null,
        "newStep": null,
        "note": "의뢰 접수",
        "createdAt": "2026-06-22T09:00:00Z"
      }
    ],
    "createdAt": "2026-06-22T09:00:00Z",
    "updatedAt": "2026-06-26T09:00:00Z"
  }
}
```

### POST `/orders`

클라이언트는 JWT에서 결정된다.

**Request Body**

```json
{
  "commissionTypeId": "00000000-0000-0000-0005-000000000001",
  "requestContent": "오리지널 캐릭터 반신 일러스트 의뢰합니다.",
  "referenceImageUrls": ["https://example.com/ref1.jpg"],
  "usagePurpose": "personal",
  "desiredDeadline": "2026-07-11",
  "selectedOption": { "label": "단색 배경 추가", "priceWon": 10000 },
  "baseAmountWon": 50000,
  "additionalAmountWon": 10000,
  "serviceFeeWon": 3000,
  "totalAmountWon": 63000
}
```

### PATCH `/orders/{id}/reject`

아티스트는 JWT에서 결정된다.

**Request Body**

```json
{ "reason": "일정이 맞지 않아 수락이 어렵습니다." }
```

### PATCH `/orders/{id}/step`

**Request Body**

```json
{ "newStep": "line_art" }
```

### DELETE `/orders/{id}`

**Request Body** (optional)

```json
{ "reason": "개인 사정으로 의뢰를 취소합니다." }
```

**Error**
- `403 FORBIDDEN` — JWT 사용자가 주문 참여자가 아닐 때
- `400 INVALID_INPUT` — 취소 불가 상태
- `404 ORDER_NOT_FOUND`

---

## 13b. Payments (PortOne)

카카오페이 등 PortOne V2 채널로 주문 결제를 준비·확인한다.  
클라이언트(주문자)만 호출할 수 있다.

### 플로우

1. `POST /payments/prepare` — `accepted` 주문이면 `payment_requested`로 전환 후 PortOne SDK용 파라미터 반환
2. 프론트에서 `PortOne.requestPayment({ storeId, channelKey, paymentId, totalAmount, ... })` 호출
3. `POST /payments/confirm` — PortOne 결제 단건 조회로 `PAID`·금액 검증 후 주문 `paid`  
   (브라우저 응답이 유실돼도 `POST /webhooks/portone` 웹훅으로 동일하게 `paid` 반영)

### 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| `POST` | `/payments/prepare` | 결제 준비 (클라이언트=JWT, PortOne SDK 파라미터 반환) |
| `POST` | `/payments/confirm` | 결제 확인 (PortOne 검증 → 주문 `paid`) |
| `GET` | `/payments/unsettled` | 미정산 결제 목록 (관리자, JWT `isAdmin`) |
| `PATCH` | `/payments/{id}/settle` | 단건 정산 완료 표시 (관리자) |
| `PATCH` | `/payments/settle` | 다건 정산 완료 표시 (관리자) |
| `POST` | `/webhooks/portone` | PortOne 웹훅 (JWT 불필요, Standard Webhooks 서명 검증) |

### POST `/payments/prepare`

**Request Body**

```json
{ "orderId": "00000000-0000-0000-0011-000000000002" }
```

**Response 200**

```json
{
  "success": true,
  "data": {
    "id": "…",
    "orderId": "00000000-0000-0000-0011-000000000002",
    "storeId": "store-…",
    "channelKey": "channel-key-…",
    "paymentId": "payment-…",
    "orderName": "판타지 성 배경",
    "totalAmountWon": 84000,
    "currency": "CURRENCY_KRW",
    "status": "pending"
  }
}
```

> `paymentId`는 PortOne SDK에 그대로 넘기고, confirm 시에도 동일 값을 보낸다.  
> 동일 주문에 pending 결제가 있으면 재사용한다.

**Error**
- `403 FORBIDDEN` — JWT 사용자가 해당 주문의 클라이언트가 아닐 때
- `400 INVALID_INPUT` — 주문 상태가 `accepted` / `payment_requested`가 아닐 때
- `404 ORDER_NOT_FOUND`

### POST `/payments/confirm`

**Request Body**

```json
{ "paymentId": "payment-…" }
```

**Response 200**

```json
{
  "success": true,
  "data": {
    "id": "…",
    "orderId": "00000000-0000-0000-0011-000000000002",
    "paymentId": "payment-…",
    "portonePaymentId": "payment-…",
    "pgProvider": "kakaopay",
    "paymentMethod": "easy_pay",
    "requestedAmountWon": 84000,
    "paidAmountWon": 84000,
    "status": "paid",
    "paidAt": "2026-08-15T04:00:00Z",
    "settledAt": null,
    "createdAt": "2026-08-15T03:59:00Z",
    "updatedAt": "2026-08-15T04:00:00Z"
  }
}
```

**Error**
- `403 FORBIDDEN` — JWT 사용자가 해당 주문의 클라이언트가 아닐 때
- `404 PAYMENT_NOT_FOUND` — 준비되지 않은 `paymentId`
- `409 PAYMENT_VERIFICATION_FAILED` — PortOne 상태가 `PAID`가 아니거나 금액 불일치
- `400 INVALID_INPUT` — 주문/결제 상태가 확인 불가

### GET `/payments/unsettled`

관리자만. `status=paid` 이고 `settledAt`이 null인 결제를 작가별로 정렬해 반환한다.  
수동 이체 후 `PATCH .../settle`로 완료 표시한다.

**Response 200**

```json
{
  "success": true,
  "data": [
    {
      "id": "…",
      "orderId": "00000000-0000-0000-0011-000000000002",
      "artistId": "00000000-0000-0000-0000-000000000003",
      "paymentId": "payment-…",
      "paidAmountWon": 84000,
      "serviceFeeWon": 4000,
      "artistPayoutWon": 80000,
      "paidAt": "2026-08-15T04:00:00Z",
      "settledAt": null
    }
  ]
}
```

> `artistPayoutWon` = `paidAmountWon - serviceFeeWon`

**Error** `403 FORBIDDEN` — 관리자가 아닐 때

### PATCH `/payments/{id}/settle`

이체 완료 후 호출. 이미 정산된 건은 idempotent.

**Response 200** — `SettlementPaymentResponse` (`settledAt` 세팅됨)

**Error**
- `403 FORBIDDEN` — 관리자가 아닐 때
- `404 PAYMENT_NOT_FOUND`
- `400 INVALID_INPUT` — `paid`가 아닌 결제

### PATCH `/payments/settle`

**Request Body**

```json
{ "paymentIds": ["…", "…"] }
```

**Response 200** — 정산된 `SettlementPaymentResponse` 배열

### POST `/webhooks/portone`

PortOne 관리자 콘솔 → 결제 연동 → 결제알림(Webhook) 관리에 등록한다.

| 콘솔 설정 | 값 |
|---|---|
| Endpoint URL | `https://{공개호스트}/webhooks/portone` |
| Content-Type | `application/json` |
| 웹훅 버전 | 결제모듈 V2 (`2024-04-25`) |
| 시크릿 env | `PORTONE_WEBHOOK_SECRET` (`whsec_…`) |

로컬 테스트는 ngrok 등으로 `https://xxxx.ngrok.io/webhooks/portone`를 등록한다.

처리 이벤트: `Transaction.Paid`(결제 완료 → 주문 `paid`), `Transaction.Failed`(pending → failed).  
그 외 type은 무시하고 200. 서명 검증 후 PortOne 결제 단건 조회로 재확인한다(웹훅 body만 신뢰하지 않음).

**Request Headers** (PortOne이 전송)

```
webhook-id: …
webhook-timestamp: …
webhook-signature: v1,…
Content-Type: application/json
```

**Response** `200` (바디 없음, 성공·무시 모두)

**Error** `400 WEBHOOK_SIGNATURE_INVALID` — 서명/타임스탬프 검증 실패 (PortOne이 재시도)

---

## 14. Reviews

### 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| `GET` | `/reviews/artist/{artistId}` | 아티스트 리뷰 목록 (`artistId`는 대상 리소스) |
| `GET` | `/reviews/my` | 내가 작성한 리뷰 목록 (JWT) |
| `POST` | `/reviews?orderId=` | 리뷰 작성 (작성자=JWT, `orderId`는 대상 주문) |
| `PATCH` | `/reviews/{id}` | 리뷰 수정 (작성자=JWT) |
| `DELETE` | `/reviews/{id}` | soft delete (작성자=JWT) |

### POST `/reviews?orderId={orderId}`

작성자(클라이언트)는 JWT에서 결정된다. `orderId`는 리뷰 대상 주문 리소스다.

**Request Body**

```json
{
  "rating": 4.5,
  "content": "소통도 잘 되고 결과물도 너무 예뻐요!"
}
```

**Response 201**

```json
{
  "success": true,
  "data": {
    "id": "00000000-0000-0000-0014-000000000001",
    "orderId": "00000000-0000-0000-0011-000000000001",
    "commissionTypeId": "00000000-0000-0000-0005-000000000001",
    "artistId": "00000000-0000-0000-0000-000000000002",
    "clientId": "00000000-0000-0000-0000-000000000001",
    "rating": 4.5,
    "content": "소통도 잘 되고 결과물도 너무 예뻐요!",
    "imageUrls": [],
    "isPublic": true,
    "createdAt": "2026-06-27T09:00:00Z",
    "updatedAt": "2026-06-27T09:00:00Z"
  }
}
```

**Error** `409 DUPLICATE_RESOURCE` — 동일 주문에 이미 리뷰 존재  
**Error** `400 INVALID_INPUT` — rating이 1.0~5.0 범위 외  
**Error** `403 FORBIDDEN` — JWT 사용자가 해당 주문의 클라이언트(작성자)가 아닐 때

---

## 15. Support (고객센터)

### 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| `GET` | `/support/my` | 내 문의 목록 (JWT) |
| `GET` | `/support/inquiries` | 전체 문의 목록 (관리자, JWT `isAdmin`) |
| `GET` | `/support/inquiries?status=` | 상태별 필터 (관리자) |
| `GET` | `/support/inquiries/{id}` | 문의 단건 조회 (본인 또는 관리자) |
| `POST` | `/support/inquiries` | 문의 생성 (작성자=JWT) |
| `POST` | `/support/inquiries/{id}/messages` | 메시지 추가 (작성자=JWT) |
| `PATCH` | `/support/inquiries/{id}/status` | 상태 변경 (관리자) |

### POST `/support/inquiries`

문의 작성자는 JWT에서 결정된다.

**Request Body**

```json
{
  "category": "order",
  "title": "주문 취소 관련 문의",
  "content": "진행 중인 주문을 취소하고 싶은데 어떻게 해야 하나요?"
}
```

**Response 201**

```json
{
  "success": true,
  "data": {
    "id": "00000000-0000-0000-0015-000000000001",
    "userId": "00000000-0000-0000-0000-000000000001",
    "category": "order",
    "title": "주문 취소 관련 문의",
    "status": "open",
    "lastMessagePreview": "진행 중인 주문을 취소하고 싶은데 어떻게 해야 하나요?",
    "lastMessageAt": "2026-06-27T09:00:00Z",
    "unreadCount": 0,
    "createdAt": "2026-06-27T09:00:00Z",
    "updatedAt": "2026-06-27T09:00:00Z",
    "messages": [
      {
        "id": "...",
        "inquiryId": "00000000-0000-0000-0015-000000000001",
        "senderId": "00000000-0000-0000-0000-000000000001",
        "isAdmin": false,
        "content": "진행 중인 주문을 취소하고 싶은데 어떻게 해야 하나요?",
        "attachmentUrls": [],
        "isRead": false,
        "createdAt": "2026-06-27T09:00:00Z"
      }
    ]
  }
}
```

### POST `/support/inquiries/{id}/messages`

**Request Body**

```json
{ "content": "추가로 문의드립니다. 환불은 얼마나 걸리나요?" }
```

**Error** `403 FORBIDDEN` — 문의 소유자·관리자가 아닐 때

### PATCH `/support/inquiries/{id}/status`

관리자만 호출 가능하다 (JWT `isAdmin`).

**Request Body**

```json
{ "status": "in_progress" }
```

**Error** `403 FORBIDDEN` — 관리자가 아닐 때

---

## 빠른 테스트 시나리오

> 아래 보호 API는 모두 `Authorization: Bearer <accessToken>`이 필요하다. 액터는 토큰에서 결정된다.

### 시나리오 A: 커미션 탐색 → 찜 → 의뢰

```
1. GET  /artist-profiles                                  # 아티스트 목록
2. GET  /artist-profiles/00000000-0000-0000-0002-000000000001  # 아티스트 상세
3. GET  /artist-profiles/{id}/commission-types            # 커미션 타입 목록
4. POST /wishlists/toggle                                 # 찜 (클라이언트 토큰)
5. POST /chat-rooms                                       # 채팅방 생성
6. POST /chat-rooms/{roomId}/messages                     # 메시지 전송
7. POST /orders                                           # 의뢰 접수
```

### 시나리오 B: 아티스트 의뢰 처리

```
1. GET  /orders/my/artist                                 # 받은 의뢰 목록 (아티스트 토큰)
2. GET  /orders/{id}                                      # 주문 상세 (참여자)
3. PATCH /orders/{id}/accept                              # 수락
4. POST /payments/prepare                                 # 결제 준비 (클라이언트 토큰) → payment_requested
5. (프론트) PortOne.requestPayment(...)
6. POST /payments/confirm                                 # 결제 확인 → paid
7. PATCH /orders/{id}/step  {"newStep":"sketch"}          # 단계 업데이트
8. PATCH /orders/{id}/step  {"newStep":"coloring"}
9. PATCH /orders/{id}/step  {"newStep":"completed"}
```

### 시나리오 C: 리뷰 작성

```
1. GET  /orders/my/client
2. POST /reviews?orderId={orderId}                        # 리뷰 작성 (클라이언트 토큰)
3. GET  /reviews/artist/00000000-0000-0000-0000-000000000002            # 아티스트 리뷰 확인
```
