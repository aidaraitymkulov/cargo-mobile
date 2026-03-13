# Mobile API (Flutter)

Base URL: `https://api.adesexpress.com`

## Аутентификация
- Авторизованные запросы: `Authorization: Bearer <accessToken>`
- При логине обязателен заголовок: `X-Client-Type: mobile`
- Без cookies

## Формат ошибок
```json
{
  "error": "ERROR_CODE",
  "message": "Человекочитаемое описание",
  "details": { "field": "описание" }
}
```

## Пагинация (offset-based)
```json
{ "items": [...], "page": 1, "pageSize": 20, "total": 123 }
```

---

## Модели

### User
```json
{
  "id": "uuid",
  "role": "USER",
  "email": "user@example.com",
  "firstName": "Айдар",
  "lastName": "Тестов",
  "phone": "+996777000000",
  "dateOfBirth": "1995-06-15",
  "personalCode": "AN0001",
  "branch": Branch,
  "status": "ACTIVE | INACTIVE | DELETED | PENDING_DELETION",
  "chatBanned": false,
  "createdAt": "ISO",
  "updatedAt": "ISO"
}
```

### Branch
```json
{ "id": "uuid", "address": "г. Бишкек, Анкара-10", "personalCodePrefix": "AN", "isActive": true }
```

### Product
```json
{
  "id": "uuid",
  "hatch": "YT123456",
  "status": "IN_CHINA | ON_THE_WAY | IN_KG | DELIVERED",
  "orderId": "uuid | null",
  "createdAt": "ISO",
  "updatedAt": "ISO"
}
```

### Order
```json
{
  "id": "uuid",
  "price": 5000.00,
  "weight": 3.0,
  "itemCount": 3,
  "status": "PENDING_PICKUP | DELIVERED",
  "createdAt": "ISO",
  "updatedAt": "ISO"
}
```

### ItemsSummary
```json
{
  "productsByStatus": { "IN_CHINA": 2, "ON_THE_WAY": 5, "IN_KG": 1, "DELIVERED": 10 },
  "activeOrdersCount": 2,
  "deliveredOrdersCount": 7,
  "lastUpdatedAt": "ISO"
}
```

### News
```json
{ "id": "uuid", "cover": "url | null", "title": "...", "content": "...", "createdAt": "ISO" }
```

### ChatMessage
```json
{ "id": "uuid", "senderType": "USER | MANAGER", "message": "...", "isRead": false, "createdAt": "ISO" }
```

### ProductHistoryEntry
```json
{ "id": "uuid", "status": "IN_CHINA | ON_THE_WAY | IN_KG | DELIVERED", "createdAt": "ISO" }
```

---

## Auth — `/auth/*`

### POST /auth/register
```json
// Request
{
  "login": "john_doe",
  "firstName": "Айдар",
  "lastName": "Тестов",
  "email": "user@example.com",
  "phone": "+996777000000",
  "dateOfBirth": "1995-06-15",
  "password": "StrongP@ssw0rd",
  "branchId": "uuid"
}
// Response 201 (no body)
// Errors: 400 VALIDATION_ERROR, 409 CONFLICT
```

### POST /auth/login
Заголовок `X-Client-Type: mobile` обязателен.
```json
// Request
{ "login": "john_doe", "password": "StrongP@ssw0rd" }
// Response 200
{ "accessToken": "jwt", "refreshToken": "jwt", "user": User }
// Errors: 400 VALIDATION_ERROR, 401 INVALID_CREDENTIALS, 403 EMAIL_NOT_CONFIRMED | FORBIDDEN
```

### POST /auth/refresh
```json
// Request
{ "refreshToken": "jwt" }
// Response 200
{ "accessToken": "jwt", "refreshToken": "jwt" }
// Errors: 400 VALIDATION_ERROR, 401 TOKEN_EXPIRED | INVALID_TOKEN
```

### POST /auth/logout
Требует `Authorization: Bearer`
```json
// Request
{ "refreshToken": "current-refresh-token" }
// Response 204 (no body)
```

### POST /auth/forgot-password/request
```json
// Request
{ "login": "john_doe" }
// Response 200
{ "success": true }
```

### POST /auth/forgot-password/confirm
```json
// Request
{ "code": "123456", "newPassword": "NewP@ssw0rd" }
// Response 200
{ "success": true }
// Errors: 400 VALIDATION_ERROR | INVALID_CONFIRMATION_CODE
```

### POST /auth/confirm
```json
// Request
{ "login": "john_doe", "code": "123456" }
// Response 204 (no body)
// Errors: 400 VALIDATION_ERROR | INVALID_CONFIRMATION_CODE
```

### POST /auth/resend?login={login}
Без тела. Авторизация не требуется.
Защита: не чаще раз в 60 сек.
```json
// Response 204 (no body)
// Errors: 400 TOO_MANY_REQUESTS | RESEND_TOO_SOON
```

---

## Profile — `/users/me`

### GET /users/me → User

### PATCH /users/me
```json
// Request (все поля опциональные)
{ "firstName": "...", "lastName": "...", "email": "...", "phone": "..." }
// Response 200: User
// Errors: 400 VALIDATION_ERROR, 409 CONFLICT
```

### PATCH /users/me/change-password
```json
// Request
{ "currentPassword": "OldP@ssw0rd", "newPassword": "NewP@ssw0rd" }
// Response 200: { "success": true }
// Errors: 400 VALIDATION_ERROR, 401 INVALID_CREDENTIALS
```

### PATCH /users/me/branch
```json
// Request
{ "branchId": "uuid" }
// Response 200: User  (генерируется новый personalCode, старый остаётся валидным)
```

### POST /users/me/deletion-request
Без тела. Статус → PENDING_DELETION, инвалидирует все refresh-сессии кроме текущей.
```json
// Response 201
{ "success": true, "deletionDate": "2026-03-22T00:00:00Z" }
// Errors: 409 CONFLICT (уже помечен)
```

### DELETE /users/me/deletion-request
Без тела. Статус → ACTIVE.
```json
// Response 200
{ "success": true }
// Errors: 409 CONFLICT (не помечен)
```

---

## Items & Products

### GET /items/summary → ItemsSummary

### GET /products/my
Query: `status` (опционально), `page`, `pageSize`
```json
// Response 200
{ "items": [Product], "page": 1, "pageSize": 20, "total": 30 }
```

### GET /products/{productId} → Product
Errors: 404 PRODUCT_NOT_FOUND

### GET /products/{productId}/history
```json
// Response 200
{ "items": [ProductHistoryEntry], "total": 3 }
```

---

## Orders

### GET /orders
Query: `status` (опционально), `page`, `pageSize`
```json
// Response 200
{ "items": [Order], "page": 1, "pageSize": 20, "total": 5 }
```

### GET /orders/{orderId}
```json
// Response 200
{ "order": Order, "products": [Product] }
// Errors: 404 ORDER_NOT_FOUND
```

---

## News

### GET /news (без авторизации)
Query: `page`, `pageSize`
```json
// Response 200
{ "items": [News], "page": 1, "pageSize": 20, "total": 10 }
```

### GET /news/{newsId} → News
Errors: 404 NEWS_NOT_FOUND

---

## Chat

### GET /chat/messages
Query: `cursor` (id последнего сообщения, опционально), `limit` (default: 50)
```json
// Response 200
{ "items": [ChatMessage], "nextCursor": "uuid | null" }
```

### WebSocket
```
ws://api.adesexpress.com/ws/chat?token=<accessToken>
```
- Подписка: `/user/queue/messages` → получение ChatMessage
- Отправка: `/app/chat.send` → `{ "message": "текст" }`

При офлайне — сообщение сохраняется в БД, при следующем открытии подгружается через REST.
Пользователю приходит push об ответе менеджера.

---

## Push-токены

### POST /push-tokens
```json
// Request
{ "token": "FCM_TOKEN_HERE" }
// Response 200
{ "success": true }
// Errors: 400 VALIDATION_ERROR
```

---

## Branches

### GET /branches (без авторизации)
```json
// Response 200
[Branch, Branch, ...]
```
