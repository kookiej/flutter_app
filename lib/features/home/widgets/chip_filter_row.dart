import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

const _kChips = ['전체', 'K-POP', '발라드', '댄스', '인디', '로파이'];

class ChipFilterRow extends StatefulWidget {
  const ChipFilterRow({super.key});

  @override
  State<ChipFilterRow> createState() => _ChipFilterRowState();
}

class _ChipFilterRowState extends State<ChipFilterRow> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _kChips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final active = i == _selected;
          return GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: active ? const LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFF4A2FA0), Color(0xFF7C3AED)],
                ) : null,
                color: active ? null : Colors.white.withOpacity(0.06),
                border: active ? null : Border.all(color: Colors.white.withOpacity(0.08)),
                boxShadow: active ? [
                  BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 4)),
                ] : [],
              ),
              child: Text(
                _kChips[i],
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                  color: active ? Colors.white : Colors.white.withOpacity(0.45),
                  fontWeight: active ? FontWeight.w500 : FontWeight.w300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
