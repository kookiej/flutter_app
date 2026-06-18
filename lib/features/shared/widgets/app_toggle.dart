import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 설정용 토글 스위치. html/Home.html 의 Toggle 재현.
/// 노브 이동은 transform(Align) 기반 + 스프링 이징, 노브 그림자 포함.
class AppToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AppToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: const Cubic(0.4, 0, 0.2, 1),
        width: 46,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: value ? AppColors.accent : Colors.white.withOpacity(0.12),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 320),
          curve: const Cubic(0.34, 1.56, 0.64, 1), // 스프링(오버슈트)
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
