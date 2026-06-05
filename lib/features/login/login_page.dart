import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../shared/icons/app_icons.dart';
import '../shared/widgets/noise_overlay.dart';
import '../home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _showPw = false;
  bool _loading = false;
  String _error = '';
  late final AnimationController _mountCtrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _translate;

  @override
  void initState() {
    super.initState();
    _mountCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _mountCtrl, curve: Curves.easeOut));
    _translate = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _mountCtrl, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 80), () => _mountCtrl.forward());
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('login_email') ?? '';
    if (saved.isNotEmpty) setState(() => _emailCtrl.text = saved);
  }

  Future<void> _handleLogin() async {
    if (_emailCtrl.text.isEmpty || _pwCtrl.text.isEmpty) {
      setState(() => _error = '이메일과 비밀번호를 입력해 주세요.');
      return;
    }
    setState(() { _error = ''; _loading = true; });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('login_email', _emailCtrl.text);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _mountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -1.2),
                radius: 1.0,
                colors: [Color(0xCC4A2FA0), Color(0x552D1B6E), Color(0xFF0D0A18), Color(0xFF060608)],
                stops: [0, 0.35, 0.65, 1.0],
              ),
            ),
          ),
          // ambient glow
          Positioned(
            top: -120, left: 0, right: 0,
            child: Center(
              child: Container(
                width: 400, height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [const Color(0xFF7C3AED).withOpacity(0.13), Colors.transparent],
                    stops: const [0, 0.7],
                  ),
                ),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(color: Colors.transparent),
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
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    _LogoArea(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('로그인', style: AppTextStyles.loginSubtitle),
                            const SizedBox(height: 28),
                            _InputField(
                              label: '이메일', controller: _emailCtrl,
                              placeholder: 'hello@example.com',
                              keyboardType: TextInputType.emailAddress,
                            ),
                            _InputField(
                              label: '비밀번호', controller: _pwCtrl,
                              placeholder: '••••••••',
                              obscure: !_showPw,
                              rightEl: GestureDetector(
                                onTap: () => setState(() => _showPw = !_showPw),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: _showPw
                                      ? AppIcons.eyeOpen(color: AppColors.textTertiary)
                                      : AppIcons.eyeClosed(color: AppColors.textTertiary),
                                ),
                              ),
                            ),
                            if (_error.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: AppColors.errorBg,
                                  border: Border.all(color: const Color(0x33EF4444)),
                                ),
                                child: Text(_error, style: AppTextStyles.bodyLight.copyWith(color: AppColors.error, fontSize: 13)),
                              ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text('비밀번호 찾기',
                                style: AppTextStyles.monoTime.copyWith(color: AppColors.accent.withOpacity(0.6))),
                            ),
                            const SizedBox(height: 28),
                            // login button
                            _LoginButton(loading: _loading, onTap: _handleLogin),
                            const SizedBox(height: 28),
                            // OR divider
                            Row(children: [
                              Expanded(child: Divider(color: Colors.white.withOpacity(0.07))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text('OR', style: AppTextStyles.monoLabel.copyWith(letterSpacing: 2)),
                              ),
                              Expanded(child: Divider(color: Colors.white.withOpacity(0.07))),
                            ]),
                            const SizedBox(height: 28),
                            _SocialButton(
                              label: '카카오로 계속하기', bg: AppColors.kakaoYellow,
                              textColor: AppColors.kakaoText,
                              icon: AppIcons.kakao(),
                            ),
                            const SizedBox(height: 12),
                            _SocialButton(
                              label: 'Apple로 계속하기',
                              bg: Colors.white.withOpacity(0.06),
                              textColor: Colors.white,
                              icon: AppIcons.apple(),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            const SizedBox(height: 36),
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  style: AppTextStyles.bodyLight.copyWith(fontSize: 13, color: AppColors.textTertiary),
                                  children: [
                                    const TextSpan(text: '아직 계정이 없으신가요? '),
                                    TextSpan(text: '가입하기', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF1A0A2E), Color(0xFF4A2FA0), Color(0xFF7C3AED)],
            ),
            border: Border.all(color: const Color(0xFF4444FF).withOpacity(0.15)),
            boxShadow: [
              BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.2), blurRadius: 48, offset: const Offset(0, 16)),
              BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 16, offset: const Offset(0, 4)),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [const Color(0xE6000000), const Color(0xFF7C3AED).withOpacity(0.33)],
                    stops: const [0.25, 0.7],
                  ),
                  border: Border.all(color: const Color(0xFFa78bfa).withOpacity(0.3)),
                ),
              ),
              Container(
                width: 7, height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0a0a0f),
                  border: Border.all(color: const Color(0xFFa78bfa).withOpacity(0.5), width: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('._.',
          style: AppTextStyles.loginTitle.copyWith(fontSize: 26, letterSpacing: -0.5)),
        const SizedBox(height: 6),
        Text('MUSIC FOR FANS',
          style: AppTextStyles.monoLabel.copyWith(letterSpacing: 3, color: AppColors.textMuted)),
        const SizedBox(height: 48),
      ],
    );
  }
}

class _InputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final bool obscure;
  final Widget? rightEl;
  final TextInputType? keyboardType;

  const _InputField({
    required this.label, required this.controller, required this.placeholder,
    this.obscure = false, this.rightEl, this.keyboardType,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: AppTextStyles.monoLabel.copyWith(
              color: _focused ? AppColors.accent : AppColors.textTertiary,
              letterSpacing: 2,
            ),
            child: Text(widget.label),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _focused ? AppColors.accent.withOpacity(0.27) : AppColors.borderSubtle,
              ),
              color: _focused ? AppColors.accent.withOpacity(0.03) : Colors.white.withOpacity(0.03),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Focus(
                          onFocusChange: (v) => setState(() => _focused = v),
                          child: TextField(
                            controller: widget.controller,
                            obscureText: widget.obscure,
                            keyboardType: widget.keyboardType,
                            style: AppTextStyles.bodyLight.copyWith(fontSize: 15, color: Colors.white),
                            decoration: InputDecoration(
                              hintText: widget.placeholder,
                              hintStyle: AppTextStyles.bodyLight.copyWith(fontSize: 15),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.fromLTRB(18, 15, widget.rightEl != null ? 8 : 18, 15),
                            ),
                          ),
                        ),
                      ),
                      if (widget.rightEl != null)
                        Padding(padding: const EdgeInsets.only(right: 14), child: widget.rightEl!),
                    ],
                  ),
                  // glow bottom line
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _focused ? 1 : 0,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.transparent, AppColors.accent, Colors.transparent]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginButton extends StatefulWidget {
  final bool loading;
  final VoidCallback onTap;
  const _LoginButton({required this.loading, required this.onTap});

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { if (!widget.loading) setState(() => _pressed = true); },
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: widget.loading
                ? null
                : const LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFF4A2FA0), Color(0xFF7C3AED)]),
            color: widget.loading ? AppColors.accent.withOpacity(0.3) : null,
            border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            boxShadow: widget.loading ? [] : [
              BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.4), blurRadius: 32, offset: const Offset(0, 8)),
            ],
          ),
          alignment: Alignment.center,
          child: widget.loading
              ? const _Spinner()
              : Text('로그인', style: AppTextStyles.body.copyWith(fontSize: 15, letterSpacing: 0.5)),
        ),
      ),
    );
  }
}

class _Spinner extends StatefulWidget {
  const _Spinner();

  @override
  State<_Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<_Spinner> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: SizedBox(
        width: 20, height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2, color: Colors.white,
          backgroundColor: Colors.white.withOpacity(0.25),
        ),
      ),
    );
  }
}

class _SocialButton extends StatefulWidget {
  final String label;
  final Color bg;
  final Color textColor;
  final Widget icon;
  final Border? border;

  const _SocialButton({
    required this.label, required this.bg, required this.textColor,
    required this.icon, this.border,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: widget.bg,
            border: widget.border,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.icon,
              const SizedBox(width: 10),
              Text(widget.label, style: AppTextStyles.body.copyWith(color: widget.textColor, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
