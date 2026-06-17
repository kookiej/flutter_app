import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home/home_page.dart';
import '../shared/widgets/noise_overlay.dart';
import '../../core/utils/url_cleanup_stub.dart'
    if (dart.library.js_interop) '../../core/utils/url_cleanup_web.dart';
import '../../data/models/app_user.dart';
import '../../providers/user_provider.dart';
import '../../services/spotify_auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  String _error = '';
  late final AnimationController _mountCtrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _translate;

  final _service = SpotifyAuthService();

  @override
  void initState() {
    super.initState();
    _mountCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mountCtrl, curve: Curves.easeOut),
    );
    _translate = Tween<Offset>(
      begin: const Offset(0, 0.065),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _mountCtrl, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _mountCtrl.forward();
    });

    if (kIsWeb && Uri.base.queryParameters.containsKey('code')) {
      _handleSpotifyWebCallback();
    } else {
      _tryAutoLogin();
    }
  }

  // 세션 JWT가 살아있으면 로그인 화면을 건너뛰고 바로 홈으로
  void _tryAutoLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      setState(() => _loading = true);
      final loggedIn = await context.read<UserProvider>().restore();
      if (!mounted) return;
      if (loggedIn) {
        _goHome();
      } else {
        setState(() => _loading = false);
      }
    });
  }

  void _handleSpotifyWebCallback() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      setState(() => _loading = true);
      try {
        final user = await _service.handleWebCallback(Uri.base);
        clearUrlQuery();
        if (!mounted) return;
        if (user != null) {
          await _onLoginSuccess(user);
        } else {
          setState(() {
            _loading = false;
            _error = 'Spotify 인증에 실패했습니다.';
          });
        }
      } catch (e) {
        clearUrlQuery();
        if (mounted) {
          setState(() {
            _loading = false;
            _error = 'Spotify 로그인 실패: $e';
          });
        }
      }
    });
  }

  Future<void> _handleSpotify() async {
    if (_loading) return;
    setState(() {
      _error = '';
      _loading = true;
    });
    try {
      final user = await _service.login();
      if (!mounted) return;
      await _onLoginSuccess(user);
    } on SpotifyWebRedirectException {
      // Web: browser redirected to Spotify — keep spinner until page reloads
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Spotify 로그인 실패: $e';
        });
      }
    }
  }

  Future<void> _onLoginSuccess(AppUser user) async {
    await context.read<UserProvider>().setUser(user);
    if (!mounted) return;
    _goHome();
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  void dispose() {
    _mountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0f),
      body: Stack(
        children: [
          // gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -1.3),
                radius: 1.1,
                colors: [
                  Color(0xCC4a2fa0),
                  Color(0x552d1b6e),
                  Color(0xFF0d0a18),
                  Color(0xFF060608),
                ],
                stops: [0.0, 0.35, 0.65, 1.0],
              ),
            ),
          ),
          // ambient glow
          Positioned(
            top: -120,
            left: 0,
            right: 0,
            child: Center(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF7c3aed).withValues(alpha:0.13),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.7],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const NoiseOverlay(),
          // content
          FadeTransition(
            opacity: _opacity,
            child: SlideTransition(
              position: _translate,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    children: [
                      // Brand section
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _LogoMark(),
                              const SizedBox(height: 24),
                              const Text(
                                '._.',
                                style: TextStyle(
                                  fontFamily: 'Noto Serif KR',
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'MUSIC FOR FANS',
                                style: TextStyle(
                                  fontFamily: 'DM Mono',
                                  fontSize: 10,
                                  letterSpacing: 3,
                                  color: Colors.white.withValues(alpha:0.25),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Action section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(32, 0, 32, 56),
                        child: Column(
                          children: [
                            _SpotifyButton(
                              loading: _loading,
                              onTap: _handleSpotify,
                            ),
                            if (_error.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color:
                                      const Color(0xFFEF4444).withValues(alpha:0.1),
                                  border: Border.all(
                                    color: const Color(0xFFEF4444)
                                        .withValues(alpha:0.2),
                                  ),
                                ),
                                child: Text(
                                  _error,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        const Color(0xFFEF4444).withValues(alpha:0.9),
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 22),
                            Text.rich(
                              TextSpan(
                                text: '계속하면 ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white.withValues(alpha:0.32),
                                  height: 1.6,
                                ),
                                children: [
                                  TextSpan(
                                    text: '이용약관',
                                    style: TextStyle(
                                        color: Colors.white.withValues(alpha:0.5)),
                                  ),
                                  const TextSpan(text: ' 및 '),
                                  TextSpan(
                                    text: '개인정보 처리방침',
                                    style: TextStyle(
                                        color: Colors.white.withValues(alpha:0.5)),
                                  ),
                                  const TextSpan(
                                      text: '에\n동의하는 것으로 간주됩니다.'),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logo mark ─────────────────────────────────────────────────────────────────

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1a0a2e), Color(0xFF4a2fa0), Color(0xFF7c3aed)],
        ),
        border: Border.all(
          color: const Color(0xFFa78bfa).withValues(alpha:0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7c3aed).withValues(alpha:0.2),
            blurRadius: 48,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha:0.6),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xE6000000),
                  const Color(0xFF7c3aed).withValues(alpha:0.33),
                ],
                stops: const [0.25, 0.7],
              ),
              border: Border.all(
                color: const Color(0xFFa78bfa).withValues(alpha:0.3),
              ),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0a0a0f),
              border: Border.all(
                color: const Color(0xFFa78bfa).withValues(alpha:0.5),
                width: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Spotify button ────────────────────────────────────────────────────────────

class _SpotifyButton extends StatefulWidget {
  final bool loading;
  final VoidCallback onTap;

  const _SpotifyButton({required this.loading, required this.onTap});

  @override
  State<_SpotifyButton> createState() => _SpotifyButtonState();
}

class _SpotifyButtonState extends State<_SpotifyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1ED760);
    const greenDark = Color(0xFF1aa34a);

    return GestureDetector(
      onTapDown: (_) {
        if (!widget.loading) setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: widget.loading ? greenDark : green,
            boxShadow: widget.loading
                ? []
                : [
                    BoxShadow(
                      color: green.withValues(alpha:0.32),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.loading)
                const _Spinner(color: Color(0xFF191414))
              else ...[
                const _SpotifyIcon(),
                const SizedBox(width: 12),
                const Text(
                  'Spotify로 계속하기',
                  style: TextStyle(
                    fontFamily: 'Noto Sans KR',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF191414),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Spotify SVG icon (official brand mark) ────────────────────────────────────

class _SpotifyIcon extends StatelessWidget {
  const _SpotifyIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _SpotifyPainter()),
    );
  }
}

class _SpotifyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF191414)
      ..style = PaintingStyle.fill;

    final s = size.width / 24.0;
    final path = Path();
    // Spotify logo path (official)
    path.addOval(Rect.fromCircle(
        center: Offset(12 * s, 12 * s), radius: 12 * s));
    canvas.drawPath(path, paint);

    final white = Paint()
      ..color = const Color(0xFF1ED760)
      ..style = PaintingStyle.fill;

    // Draw the three arcs as simplified bezier curves
    final p2 = Path();
    // top arc
    p2.moveTo(6.0 * s, 8.76 * s);
    p2.cubicTo(9.92 * s, 6.44 * s, 15.28 * s, 5.88 * s, 19.8 * s, 7.56 * s);
    p2.cubicTo(20.34 * s, 7.74 * s, 20.52 * s, 8.46 * s, 20.22 * s, 8.94 * s);
    p2.cubicTo(19.98 * s, 9.3 * s, 19.56 * s, 9.42 * s, 19.2 * s, 9.24 * s);
    p2.cubicTo(15.12 * s, 7.68 * s, 9.72 * s, 8.22 * s, 6.36 * s, 10.44 * s);
    p2.cubicTo(6.06 * s, 10.62 * s, 5.64 * s, 10.5 * s, 5.46 * s, 10.2 * s);
    p2.cubicTo(5.28 * s, 9.84 * s, 5.4 * s, 9.36 * s, 6.0 * s, 8.76 * s);
    p2.close();
    // middle arc
    p2.moveTo(5.88 * s, 12.54 * s);
    p2.cubicTo(9.24 * s, 10.44 * s, 13.68 * s, 9.84 * s, 17.4 * s, 11.16 * s);
    p2.cubicTo(17.88 * s, 11.28 * s, 18.12 * s, 11.82 * s, 18.0 * s, 12.3 * s);
    p2.cubicTo(17.88 * s, 12.72 * s, 17.4 * s, 12.9 * s, 16.98 * s, 12.78 * s);
    p2.cubicTo(13.68 * s, 11.58 * s, 9.72 * s, 12.12 * s, 6.78 * s, 14.04 * s);
    p2.cubicTo(6.42 * s, 14.28 * s, 5.94 * s, 14.16 * s, 5.7 * s, 13.8 * s);
    p2.cubicTo(5.46 * s, 13.44 * s, 5.58 * s, 12.96 * s, 5.88 * s, 12.54 * s);
    p2.close();
    // bottom arc
    p2.moveTo(6.6 * s, 16.2 * s);
    p2.cubicTo(9.36 * s, 14.46 * s, 12.96 * s, 14.1 * s, 15.96 * s, 15.24 * s);
    p2.cubicTo(16.38 * s, 15.42 * s, 16.56 * s, 15.9 * s, 16.38 * s, 16.32 * s);
    p2.cubicTo(16.2 * s, 16.68 * s, 15.72 * s, 16.86 * s, 15.36 * s, 16.68 * s);
    p2.cubicTo(12.72 * s, 15.66 * s, 9.6 * s, 15.96 * s, 7.2 * s, 17.52 * s);
    p2.cubicTo(6.9 * s, 17.7 * s, 6.48 * s, 17.64 * s, 6.3 * s, 17.34 * s);
    p2.cubicTo(6.12 * s, 17.04 * s, 6.18 * s, 16.56 * s, 6.6 * s, 16.2 * s);
    p2.close();

    canvas.drawPath(p2, white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Spinner ───────────────────────────────────────────────────────────────────

class _Spinner extends StatefulWidget {
  final Color color;
  const _Spinner({required this.color});

  @override
  State<_Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<_Spinner> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: widget.color,
          backgroundColor: widget.color.withValues(alpha:0.25),
        ),
      ),
    );
  }
}
