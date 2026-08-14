# Art Port API Reference

> **Base URL** `http://localhost:8080`  
> **Content-Type** `application/json`  
> **인증** `POST /users/login`으로 로그인 후 응답의 `id`를 클라이언트에 저장한다.  
> JWT/세션은 미구현 — 이후 API 호출 시 `?userId=` 쿼리 파라미터로 사용자를 전달한다.

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
| `INVALID_CREDENTIALS` | 401 | 이메일 또는 비밀번호 불일치 |
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
| `RESOURCE_NOT_FOUND` | 404 | 리소스 없음 (범용) |
| `DUPLICATE_EMAIL` | 409 | 이메일 중복 |
| `DUPLICATE_RESOURCE` | 409 | 리소스 중복 |
| `INTERNAL_SERVER_ERROR` | 500 | 서버 내부 오류 |

> **권한 검증** — 주문·채팅·리뷰·고객센터 등 참여자/소유자 확인 실패 시 `403 FORBIDDEN`.  
> **아티스트 리소스 수정·삭제** — 공지·커미션·포트폴리오·소셜 링크는 `?userId=`로 아티스트 프로필 소유자를 확인한다.

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

## 1. Users

계정(`users`)은 한 사람이다. 의뢰자/작가는 `role` 컬럼이 아니라 프로필 존재로 구분한다.

- 의뢰자: `client_profiles` 행이 있으면 의뢰 가능 (가입 시 자동 생성)
- 작가: `artist_profiles` 행이 있으면 작가 (아티스트 신청 승인 시 생성)
- 관리자: `users.is_admin = true`

같은 사람이 의뢰자이면서 작가일 수 있다. UserResponse의 `clientProfileId` / `artistProfileId`가 `null`이면 해당 프로필이 없는 것이다.

### 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| `GET` | `/users/{id}` | 사용자 조회 |
| `POST` | `/users/login` | 로그인 |
| `POST` | `/users` | 사용자 생성 |
| `PATCH` | `/users/{id}` | 사용자 수정 |
| `DELETE` | `/users/{id}` | 사용자 비활성화 (soft delete) |

### GET `/users/{id}`

```http
GET /users/00000000-0000-0000-0000-000000000001
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

### POST `/users/login`

이메일·비밀번호로 인증하고 사용자 정보를 반환한다. 성공 시 `lastLoginAt`이 갱신된다.

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
**Error** `400 INVALID_INPUT` — 유효성 검사 실패  
**Error** `409 DUPLICATE_EMAIL` — 이메일 중복

### PATCH `/users/{id}`

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

### DELETE `/users/{id}`

**Response 204** (body 없음)

---

## 2. Client Profiles

### 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| `GET` | `/users/{userId}/client-profile` | 클라이언트 프로필 조회 |
| `PATCH` | `/users/{userId}/client-profile` | 생성 또는 수정 (upsert) |
| `DELETE` | `/users/{userId}/client-profile` | soft delete |

### GET `/users/{userId}/client-profile`

```http
GET /users/00000000-0000-0000-0000-000000000001/client-profile
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

### PATCH `/users/{userId}/client-profile`

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

**Request Body**

```json
{
  "userId": "00000000-0000-0000-0000-000000000002",
  "displayName": "서아 아트",
  "oneLineIntro": "따뜻한 감성의 일러스트레이터",
  "specialties": ["캐릭터", "팬아트"],
  "restrictedItems": ["19금"]
}
```

**Error** `404 USER_NOT_FOUND`

---

## 4. Artist Applications

### 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| `POST` | `/artist-applications` | 아티스트 신청 |
| `GET` | `/artist-applications?adminUserId=` | 전체 신청 목록 (관리자) |
| `GET` | `/artist-applications?adminUserId=&status=` | 상태별 필터 (관리자) |
| `GET` | `/artist-applications/my?userId=` | 본인 신청 조회 |
| `GET` | `/artist-applications/{id}` | 단건 조회 |
| `PATCH` | `/artist-applications/{id}/review?reviewedBy=` | 승인/거절 (관리자) |
| `DELETE` | `/artist-applications/{id}` | soft delete |

### POST `/artist-applications`

**Request Body**

```json
{
  "userId": "00000000-0000-0000-0000-000000000001",
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

### PATCH `/artist-applications/{id}/review?reviewedBy={adminId}`

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
- `403 FORBIDDEN` — reviewedBy가 관리자(`isAdmin`)가 아닐 때

---

## 5. Artist Social Links

### 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| `GET` | `/artist-profiles/{profileId}/social-links` | 목록 조회 |
| `POST` | `/artist-profiles/{profileId}/social-links` | 추가 |
| `PATCH` | `/artist-social-links/{id}?userId=` | 수정 (아티스트 소유자) |
| `DELETE` | `/artist-social-links/{id}?userId=` | soft delete (아티스트 소유자) |

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
| `POST` | `/commission-types` | 생성 |
| `PATCH` | `/commission-types/{id}?userId=` | 수정 (아티스트 소유자) |
| `DELETE` | `/commission-types/{id}?userId=` | soft delete (아티스트 소유자) |

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
| `POST` | `/artist-profiles/{profileId}/portfolio-images` | 이미지 추가 |
| `PATCH` | `/artist-profiles/{profileId}/portfolio-images/reorder?userId=` | 순서 변경 (아티스트 소유자) |
| `DELETE` | `/portfolio-images/{id}?userId=` | soft delete (아티스트 소유자) |

### PATCH `/artist-profiles/{profileId}/portfolio-images/reorder?userId={userId}`

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
| `GET` | `/artist-profiles/{profileId}/notices?manage=true` | 전체 공지 (관리용) |
| `POST` | `/artist-profiles/{profileId}/notices` | 공지 생성 |
| `PATCH` | `/artist-notices/{id}?userId=` | 수정 (아티스트 소유자) |
| `DELETE` | `/artist-notices/{id}?userId=` | soft delete (아티스트 소유자) |

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
| `GET` | `/users/{userId}/wishlists` | 찜 목록 |
| `POST` | `/wishlists/toggle?userId=` | 찜 토글 (추가/취소) |

### POST `/wishlists/toggle?userId={userId}`

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
| `POST` | `/follows?followerId=` | 팔로우 |
| `DELETE` | `/follows/{followingId}?followerId=` | 언팔로우 |
| `GET` | `/users/{userId}/followings` | 팔로잉 목록 |
| `GET` | `/users/{userId}/followers` | 팔로워 목록 |

### POST `/follows?followerId={followerId}`

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
| `GET` | `/chat-rooms?userId=` | 내 채팅방 목록 |
| `GET` | `/chat-rooms/{id}?userId=` | 단건 조회 |
| `POST` | `/chat-rooms?userId=` | 채팅방 생성 (이미 있으면 기존 반환) |
| `PATCH` | `/chat-rooms/{id}/read?userId=` | 읽음 처리 |
| `DELETE` | `/chat-rooms/{id}?userId=` | soft delete |

### GET `/chat-rooms?userId={userId}`

```http
GET /chat-rooms?userId=00000000-0000-0000-0000-000000000001
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

### POST `/chat-rooms?userId={userId}`

**Request Body**

```json
{
  "clientId": "00000000-0000-0000-0000-000000000001",
  "artistId": "00000000-0000-0000-0000-000000000002"
}
```

---

## 12. Chat Messages

### 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| `GET` | `/chat-rooms/{roomId}/messages?userId=` | 메시지 목록 (시간순) |
| `POST` | `/chat-rooms/{roomId}/messages?userId=` | 메시지 전송 |
| `DELETE` | `/messages/{id}?userId=` | soft delete |

### POST `/chat-rooms/{roomId}/messages?userId={userId}`

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
| `GET` | `/orders/{id}?userId=` | 주문 단건 조회 (참여자만, 이력 포함) |
| `GET` | `/orders/my/client?userId=` | 클라이언트 주문 목록 |
| `GET` | `/orders/my/artist?userId=` | 아티스트 주문 목록 |
| `POST` | `/orders?clientId=` | 주문 접수 |
| `PATCH` | `/orders/{id}/accept?artistId=` | 수락 |
| `PATCH` | `/orders/{id}/reject?artistId=` | 거절 |
| `PATCH` | `/orders/{id}/step?userId=` | 작업 단계 변경 |
| `DELETE` | `/orders/{id}?userId=` | 취소 (soft delete) |

### GET `/orders/{id}?userId={userId}`

```http
GET /orders/00000000-0000-0000-0011-000000000001?userId=00000000-0000-0000-0000-000000000001
```

**Error**
- `403 FORBIDDEN` — client/artist 참여자가 아닐 때
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

### POST `/orders?clientId={clientId}`

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

### PATCH `/orders/{id}/reject?artistId={artistId}`

**Request Body**

```json
{ "reason": "일정이 맞지 않아 수락이 어렵습니다." }
```

### PATCH `/orders/{id}/step?userId={userId}`

**Request Body**

```json
{ "newStep": "line_art" }
```

### DELETE `/orders/{id}?userId={userId}`

**Request Body** (optional)

```json
{ "reason": "개인 사정으로 의뢰를 취소합니다." }
```

**Error**
- `403 FORBIDDEN` — 주문 참여자가 아닐 때
- `400 INVALID_INPUT` — 취소 불가 상태
- `404 ORDER_NOT_FOUND`

---

## 14. Reviews

### 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| `GET` | `/reviews/artist/{artistId}` | 아티스트 리뷰 목록 |
| `GET` | `/reviews/my?clientId=` | 내가 작성한 리뷰 목록 |
| `POST` | `/reviews?orderId=&clientId=` | 리뷰 작성 |
| `PATCH` | `/reviews/{id}?clientId=` | 리뷰 수정 |
| `DELETE` | `/reviews/{id}?clientId=` | soft delete |

### POST `/reviews?orderId={orderId}&clientId={clientId}`

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

---

## 15. Support (고객센터)

### 엔드포인트

| Method | Path | 설명 |
|---|---|---|
| `GET` | `/support/my?userId=` | 내 문의 목록 |
| `GET` | `/support/inquiries?adminUserId=` | 전체 문의 목록 (관리자) |
| `GET` | `/support/inquiries?adminUserId=&status=` | 상태별 필터 (관리자) |
| `GET` | `/support/inquiries/{id}?userId=` | 문의 단건 조회 (메시지 포함) |
| `POST` | `/support/inquiries?userId=` | 문의 생성 |
| `POST` | `/support/inquiries/{id}/messages?userId=` | 메시지 추가 |
| `PATCH` | `/support/inquiries/{id}/status?adminUserId=` | 상태 변경 (관리자) |

### POST `/support/inquiries?userId={userId}`

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

### POST `/support/inquiries/{id}/messages?userId={userId}`

**Request Body**

```json
{ "content": "추가로 문의드립니다. 환불은 얼마나 걸리나요?" }
```

### PATCH `/support/inquiries/{id}/status?adminUserId={adminId}`

**Request Body**

```json
{ "status": "in_progress" }
```

---

## 빠른 테스트 시나리오

### 시나리오 A: 커미션 탐색 → 찜 → 의뢰

```
1. GET  /artist-profiles                                  # 아티스트 목록
2. GET  /artist-profiles/00000000-0000-0000-0002-000000000001  # 아티스트 상세
3. GET  /artist-profiles/{id}/commission-types            # 커미션 타입 목록
4. POST /wishlists/toggle?userId=00000000-0000-0000-0000-000000000001   # 찜
5. POST /chat-rooms?userId=00000000-0000-0000-0000-000000000001         # 채팅방 생성
6. POST /chat-rooms/{roomId}/messages?userId=...          # 메시지 전송
7. POST /orders?clientId=00000000-0000-0000-0000-000000000001           # 의뢰 접수
```

### 시나리오 B: 아티스트 의뢰 처리

```
1. GET  /orders/my/artist?userId=00000000-0000-0000-0000-000000000002   # 받은 의뢰 목록
2. GET  /orders/{id}?userId=00000000-0000-0000-0000-000000000002        # 주문 상세 (참여자)
3. PATCH /orders/{id}/accept?artistId=...                # 수락
4. PATCH /orders/{id}/step?userId=...  {"newStep":"sketch"}  # 단계 업데이트
5. PATCH /orders/{id}/step?userId=...  {"newStep":"coloring"}
6. PATCH /orders/{id}/step?userId=...  {"newStep":"completed"}
```

### 시나리오 C: 리뷰 작성

```
1. GET  /orders/my/client?userId=00000000-0000-0000-0000-000000000001
2. POST /reviews?orderId={orderId}&clientId={clientId}   # 리뷰 작성
3. GET  /reviews/artist/00000000-0000-0000-0000-000000000002            # 아티스트 리뷰 확인
```
