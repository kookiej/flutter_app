import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/avatar_palette.dart';
import '../../../providers/user_provider.dart';
import '../icons/app_icons.dart';
import 'panel_sub_header.dart';

/// 프로필 보기/편집 — 기본 읽기 전용, 헤더 연필 버튼으로 편집 모드 진입.
class ProfileEditView extends StatefulWidget {
  final VoidCallback onBack;
  const ProfileEditView({super.key, required this.onBack});

  @override
  State<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<ProfileEditView> {
  bool _editing = false;
  late String _name;
  Uint8List? _photo;
  late int _colorIdx;

  @override
  void initState() {
    super.initState();
    _loadFromProvider();
  }

  void _loadFromProvider() {
    final u = context.read<UserProvider>();
    _name = u.effectiveName;
    _photo = u.localPhotoBytes;
    _colorIdx = u.colorIdx;
  }

  void _handleBack() {
    if (_editing) {
      // 편집 취소 — 드래프트 리셋 후 읽기 모드로
      setState(() {
        _loadFromProvider();
        _editing = false;
      });
    } else {
      widget.onBack();
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, imageQuality: 85);
    if (x == null) return;
    final bytes = await x.readAsBytes();
    if (mounted) setState(() => _photo = bytes);
  }

  void _save() {
    final name = _name.trim();
    context.read<UserProvider>().saveLocalProfile(
      name: name.isEmpty ? context.read<UserProvider>().effectiveName : name,
      photoBytes: _photo,
      colorIdx: _colorIdx,
    );
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final pal = kAvatarPalette[_colorIdx % kAvatarPalette.length];
    final initial = _name.isNotEmpty ? _name.characters.first.toUpperCase() : '?';

    return Column(
      children: [
        PanelSubHeader(
          title: '프로필 보기',
          onBack: _handleBack,
          right: _editing
              ? null
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _editing = true),
                  child: SizedBox(
                    width: 40, height: 40,
                    child: Center(child: AppIcons.pencil()),
                  ),
                ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
            children: [
              // 아바타
              Center(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 104, height: 104,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: _photo == null
                                ? LinearGradient(
                                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                                    colors: pal)
                                : null,
                            image: _photo != null
                                ? DecorationImage(image: MemoryImage(_photo!), fit: BoxFit.cover)
                                : null,
                            border: Border.all(color: AppColors.accent.withOpacity(0.35), width: 2),
                            boxShadow: [
                              BoxShadow(color: AppColors.accentDeep.withOpacity(0.3), blurRadius: 28, offset: const Offset(0, 8)),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: _photo == null
                              ? Text(initial, style: AppTextStyles.songTitleLarge.copyWith(fontSize: 40))
                              : null,
                        ),
                        if (_editing)
                          Positioned(
                            right: -2, bottom: -2,
                            child: GestureDetector(
                              onTap: _pickPhoto,
                              child: Container(
                                width: 34, height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.accent,
                                  border: Border.all(color: const Color(0xFF15121F), width: 3),
                                ),
                                child: Center(child: AppIcons.camera(color: const Color(0xFF15121F))),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (_editing && _photo != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: GestureDetector(
                          onTap: () => setState(() => _photo = null),
                          child: Text('사진 제거',
                            style: AppTextStyles.caption.copyWith(fontSize: 11, color: Colors.white.withOpacity(0.4))),
                        ),
                      ),
                  ],
                ),
              ),
              // 프로필 색상 (편집 모드)
              if (_editing) ...[
                const SizedBox(height: 22),
                Text('프로필 색상', style: AppTextStyles.monoLabel),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12, runSpacing: 12,
                  children: List.generate(kAvatarPalette.length, (i) {
                    final p = kAvatarPalette[i];
                    final selected = _colorIdx == i && _photo == null;
                    return GestureDetector(
                      onTap: () => setState(() { _colorIdx = i; _photo = null; }),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft, end: Alignment.bottomRight, colors: p),
                          border: Border.all(
                            color: selected ? Colors.white : Colors.transparent, width: 2.5),
                          boxShadow: selected
                              ? [BoxShadow(color: AppColors.accent, blurRadius: 0, spreadRadius: 2)]
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
              ],
              // 닉네임
              const SizedBox(height: 26),
              Text('닉네임', style: AppTextStyles.monoLabel),
              const SizedBox(height: 10),
              if (_editing)
                TextFormField(
                  initialValue: _name,
                  maxLength: 20,
                  onChanged: (v) => _name = v,
                  style: AppTextStyles.body.copyWith(fontSize: 15),
                  cursorColor: AppColors.accent,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '닉네임 입력',
                    hintStyle: AppTextStyles.bodyLight.copyWith(fontSize: 15, color: Colors.white.withOpacity(0.3)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.accent.withOpacity(0.5)),
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white.withOpacity(0.03),
                    border: Border.all(color: Colors.white.withOpacity(0.07)),
                  ),
                  child: Text(_name, style: AppTextStyles.body.copyWith(fontSize: 15)),
                ),
            ],
          ),
        ),
        // 저장 버튼 (편집 모드)
        if (_editing)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 26),
            child: GestureDetector(
              onTap: _save,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [AppColors.accentDeeper, AppColors.accentDeep]),
                  boxShadow: [
                    BoxShadow(color: AppColors.accentDeep.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 8)),
                  ],
                ),
                alignment: Alignment.center,
                child: Text('저장', style: AppTextStyles.body.copyWith(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
      ],
    );
  }
}
