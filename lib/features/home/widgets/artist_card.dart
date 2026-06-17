import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/artist.dart';

class ArtistCard extends StatelessWidget {
  final Artist artist;
  final VoidCallback? onTap;

  const ArtistCard({super.key, required this.artist, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.2, -0.3),
                  colors: [artist.color.withOpacity(0.53), artist.color.withOpacity(0.13)],
                ),
                border: Border.all(color: artist.color.withOpacity(0.27), width: 1.5),
                boxShadow: [BoxShadow(color: artist.color.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 4))],
              ),
              alignment: Alignment.center,
              child: artist.imageUrl != null
                  // 실제 아티스트 사진 — 로드 실패 시 이니셜로 폴백
                  ? ClipOval(
                      child: Image.network(
                        artist.imageUrl!,
                        width: 70, height: 70, fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(child: _initial()),
                      ),
                    )
                  : _initial(),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 70,
              child: Text(
                artist.name,
                style: AppTextStyles.artistLabel.copyWith(color: Colors.white.withOpacity(0.6)),
                maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initial() => Text(
        artist.name[0],
        style: AppTextStyles.sectionTitle.copyWith(fontSize: 22, fontWeight: FontWeight.w900),
      );
}
