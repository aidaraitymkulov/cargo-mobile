# Архитектура Mobile — Flutter AdesExpress

## Стек

| Категория | Технология |
|---|---|
| Платформа | Flutter (Dart) |
| Стейт-менеджмент | Riverpod (riverpod_generator) |
| Навигация | GoRouter |
| HTTP-клиент | Dio |
| Локальное хранилище токенов | flutter_secure_storage |
| WebSocket (чат) | stomp_dart_client |
| Push-уведомления | firebase_messaging (FCM) |
| Кэш изображений | cached_network_image |
| Бесконечная прокрутка | infinite_scroll_pagination |
| Модели | freezed + json_serializable |
| Кодогенерация | build_runner |

---

## Структура папок

```
lib/
├── main.dart                        # Точка входа, Firebase.initializeApp
├── app.dart                         # ProviderScope + MaterialApp.router
│
├── core/
│   ├── api/
│   │   ├── dio_client.dart          # Dio instance + interceptors
│   │   ├── auth_api.dart
│   │   ├── user_api.dart
│   │   ├── product_api.dart
│   │   ├── order_api.dart
│   │   ├── news_api.dart
│   │   ├── chat_api.dart
│   │   └── branch_api.dart
│   ├── storage/
│   │   └── token_storage.dart       # flutter_secure_storage: save/get/clear токенов
│   ├── router/
│   │   └── app_router.dart          # GoRouter + redirect (auth guard)
│   └── constants/
│       └── app_constants.dart       # Base URL, статусы, роли, pageSize
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── auth_repository.dart
│   │   ├── domain/
│   │   │   └── auth_provider.dart   # StateNotifierProvider<AuthState>
│   │   └── presentation/
│   │       ├── login_screen.dart
│   │       ├── register_screen.dart
│   │       ├── confirm_email_screen.dart
│   │       └── forgot_password_screen.dart
│   │
│   ├── dashboard/
│   │   ├── data/
│   │   │   └── summary_repository.dart
│   │   ├── domain/
│   │   │   └── summary_provider.dart
│   │   └── presentation/
│   │       └── dashboard_screen.dart
│   │
│   ├── products/
│   │   ├── data/
│   │   │   └── product_repository.dart
│   │   ├── domain/
│   │   │   └── product_provider.dart
│   │   └── presentation/
│   │       ├── products_screen.dart
│   │       └── product_detail_screen.dart
│   │
│   ├── orders/
│   │   ├── data/
│   │   │   └── order_repository.dart
│   │   ├── domain/
│   │   │   └── order_provider.dart
│   │   └── presentation/
│   │       ├── orders_screen.dart
│   │       └── order_detail_screen.dart
│   │
│   ├── news/
│   │   ├── data/
│   │   │   └── news_repository.dart
│   │   ├── domain/
│   │   │   └── news_provider.dart
│   │   └── presentation/
│   │       ├── news_screen.dart
│   │       └── news_detail_screen.dart
│   │
│   ├── chat/
│   │   ├── data/
│   │   │   ├── chat_repository.dart  # REST: история сообщений (cursor-based)
│   │   │   └── chat_socket.dart      # STOMP WebSocket подключение
│   │   ├── domain/
│   │   │   └── chat_provider.dart
│   │   └── presentation/
│   │       └── chat_screen.dart
│   │
│   └── profile/
│       ├── data/
│       │   └── profile_repository.dart
│       ├── domain/
│       │   └── profile_provider.dart
│       └── presentation/
│           ├── profile_screen.dart
│           ├── edit_profile_screen.dart
│           ├── change_password_screen.dart
│           ├── change_branch_screen.dart
│           └── delete_account_screen.dart
│
├── models/                           # Freezed-модели из API контракта
│   ├── user.dart
│   ├── branch.dart
│   ├── product.dart
│   ├── order.dart
│   ├── news.dart
│   ├── chat_message.dart
│   ├── items_summary.dart
│   └── product_history_entry.dart
│
└── shared/
    ├── widgets/
    │   ├── status_badge.dart          # Бейдж статуса товара/заказа
    │   ├── product_status_timeline.dart
    │   ├── paginated_list.dart
    │   └── error_view.dart
    └── utils/
        ├── date_formatter.dart
        └── status_helpers.dart        # Статус → текст / цвет
```

---

## Аутентификация и токены

Мобилка использует **JWT: accessToken + refreshToken**.

Токены хранятся в **`flutter_secure_storage`** (Keychain на iOS, Keystore на Android).

### Dio — interceptors

```dart
// core/api/dio_client.dart

dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    final token = await tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['X-Client-Type'] = 'mobile';
    return handler.next(options);
  },
  onError: (error, handler) async {
    if (error.response?.statusCode == 401) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        return handler.resolve(await _retry(error.requestOptions));
      } else {
        await tokenStorage.clear();
        router.go('/auth/login');
      }
    }
    return handler.next(error);
  },
));
```

---

## Навигация — GoRouter

Auth guard через `redirect`:

```dart
// core/router/app_router.dart

final router = GoRouter(
  redirect: (context, state) {
    final isLoggedIn = ref.read(authProvider).isLoggedIn;
    final isAuthRoute = state.uri.path.startsWith('/auth');

    if (!isLoggedIn && !isAuthRoute) return '/auth/login';
    if (isLoggedIn && isAuthRoute) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/auth/login', ...),
    GoRoute(path: '/auth/register', ...),
    GoRoute(path: '/auth/confirm-email', ...),
    GoRoute(path: '/auth/forgot-password', ...),

    ShellRoute(
      builder: (_, __, child) => MainShell(child: child), // bottom nav bar
      routes: [
        GoRoute(path: '/'),            // dashboard
        GoRoute(path: '/products', routes: [GoRoute(path: ':id')]),
        GoRoute(path: '/orders', routes: [GoRoute(path: ':id')]),
        GoRoute(path: '/news', routes: [GoRoute(path: ':id')]),
        GoRoute(path: '/profile'),
      ],
    ),

    GoRoute(path: '/chat'),
  ],
);
```

---

## Стейт-менеджмент — Riverpod

Аналогия из React:
- `Provider` = `useContext` / глобальная переменная
- `FutureProvider` = `useQuery` (один запрос)
- `StateNotifierProvider` = `useReducer` / Zustand store
- `ref.watch()` = подписка (useSelector)
- `ref.read()` = прочитать один раз без подписки

```dart
// features/products/domain/product_provider.dart

final productRepositoryProvider = Provider((ref) =>
  ProductRepository(ref.watch(dioClientProvider))
);

final productsProvider = FutureProvider.family<List<Product>, String?>((ref, status) async {
  return ref.watch(productRepositoryProvider).getProducts(status: status);
});
```

```dart
// В виджете
class ProductsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider(null));
    return productsAsync.when(
      data: (products) => ProductList(products: products),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => ErrorView(error: e),
    );
  }
}
```

---

## Auth — StateNotifier

```dart
// features/auth/domain/auth_provider.dart

class AuthState {
  final User? user;
  final bool isLoggedIn;
}

class AuthNotifier extends StateNotifier<AuthState> {
  Future<void> login(String login, String password) async {
    final result = await _authRepo.login(login, password);
    await _tokenStorage.save(result.accessToken, result.refreshToken);
    state = AuthState(user: result.user, isLoggedIn: true);
  }

  Future<void> logout() async {
    await _authRepo.logout(_tokenStorage.getRefreshToken());
    await _tokenStorage.clear();
    state = AuthState(isLoggedIn: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(authRepositoryProvider), ref.watch(tokenStorageProvider)),
);
```

---

## Модели — Freezed

```dart
// models/product.dart

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String hatch,
    required ProductStatus status,
    String? orderId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}

enum ProductStatus { IN_CHINA, ON_THE_WAY, IN_KG, DELIVERED }
```

Генерация: `dart run build_runner build`

---

## Чат — WebSocket (STOMP)

```dart
// features/chat/data/chat_socket.dart

class ChatSocket {
  late StompClient _client;

  void connect(String token, Function(ChatMessage) onMessage) {
    _client = StompClient(
      config: StompConfig(
        url: 'ws://api.cargo-app.com/ws/chat?token=$token',
        onConnect: (frame) {
          _client.subscribe(
            destination: '/user/queue/messages',
            callback: (frame) {
              final msg = ChatMessage.fromJson(jsonDecode(frame.body!));
              onMessage(msg);
            },
          );
        },
      ),
    );
    _client.activate();
  }

  void sendMessage(String text) {
    _client.send(
      destination: '/app/chat.send',
      body: jsonEncode({'message': text}),
    );
  }

  void disconnect() => _client.deactivate();
}
```

История подгружается через REST с cursor-based пагинацией (`nextCursor`).

---

## Push-уведомления (FCM)

```dart
// При входе в приложение:
final fcmToken = await FirebaseMessaging.instance.getToken();
if (fcmToken != null) {
  await pushTokenApi.registerToken(fcmToken); // POST /push-tokens
}

// При ротации токена:
FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
  pushTokenApi.registerToken(newToken);
});
```

Бэкенд сам удаляет невалидные токены при ошибке от FCM/APNS.

---

## Пагинация

**Offset-based** (товары, заказы, новости) — `infinite_scroll_pagination`:

```dart
final _pagingController = PagingController<int, Product>(firstPageKey: 1);

_pagingController.addPageRequestListener((page) async {
  final result = await productRepo.getProducts(page: page, pageSize: 20);
  final isLastPage = result.items.length < 20;
  if (isLastPage) {
    _pagingController.appendLastPage(result.items);
  } else {
    _pagingController.appendPage(result.items, page + 1);
  }
});
```

**Cursor-based** (чат) — подгрузка вверх при скролле:
- Query: `cursor` (id последнего сообщения) + `limit`
- Ответ: `{ items, nextCursor }`

---

## Экраны приложения

**Auth-флоу:**
- Splash
- Логин
- Регистрация (с выбором филиала)
- Подтверждение email
- Восстановление пароля

**Основное приложение (bottom navigation bar):**
- Dashboard — карточки статусов товаров + счётчики заказов
- Товары — список с табами по статусу, бесконечная прокрутка
- Заказы — два таба: активные / доставленные
- Новости — лента
- Профиль

**Вложенные экраны:**
- Детали товара + таймлайн истории статусов
- Детали заказа + список посылок
- Детали новости
- Чат с менеджером (REST история + WebSocket)
- Редактирование профиля
- Смена пароля
- Смена филиала (предупреждение о новом personalCode)
- Удаление аккаунта (предупреждение о 30 днях + отмена)

---

## Состояния пользователя

| Состояние | Поведение в приложении |
|---|---|
| `status = 0 (ACTIVE)` | Полный доступ |
| `status = 1 (INACTIVE)` | 403 при логине → показываем сообщение |
| `status = 3 (PENDING_DELETION)` | Баннер с датой удаления + кнопка отмены |
| `chat_banned = true` | Чат открыт, поле ввода заблокировано |
