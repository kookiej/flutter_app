import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../shared/icons/app_icons.dart';

class SearchInput extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const SearchInput({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: _focused ? AppColors.accent.withOpacity(0.044) : Colors.white.withOpacity(0.05),
        border: Border.all(
          color: _focused ? AppColors.accent.withOpacity(0.3) : Colors.transparent,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Row(
              children: [
                const SizedBox(width: 12),
                AppIcons.search(color: AppColors.textTertiary),
                const SizedBox(width: 10),
                Expanded(
                  child: Focus(
                    onFocusChange: (v) => setState(() => _focused = v),
                    child: TextField(
                      controller: widget.controller,
                      onChanged: widget.onChanged,
                      onSubmitted: widget.onSubmitted,
                      style: AppTextStyles.body.copyWith(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: '아티스트, 곡, 앨범 검색',
                        hintStyle: AppTextStyles.bodyLight,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                if (widget.controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: widget.onClear,
                    child: Container(
                      width: 22, height: 22, margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                      alignment: Alignment.center,
                      child: AppIcons.close(color: AppColors.textSecondary),
                    ),
                  ),
              ],
            ),
            // focus bottom line
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
    );
  }
}
