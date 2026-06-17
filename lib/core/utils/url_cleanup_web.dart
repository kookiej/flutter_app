import 'package:web/web.dart' as web;

// OAuth 콜백 처리 후 주소창에 남은 ?code=...&state=... 제거
void clearUrlQuery() {
  web.window.history.replaceState(null, '', Uri.base.path);
}
