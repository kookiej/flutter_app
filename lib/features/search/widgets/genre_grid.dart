import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/mock/genres.dart';
import '../../../data/models/genre.dart';

class GenreGrid extends StatelessWidget {
  const GenreGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemCount: kGenres.length,
      itemBuilder: (_, i) => _GenreCard(genre: kGenres[i]),
    );
  }
}

class _GenreCard extends StatefulWidget {
  final Genre genre;
  const _GenreCard({required this.genre});

  @override
  State<_GenreCard> createState() => _GenreCardState();
}

class _GenreCardState extends State<_GenreCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final g = widget.genre;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: g.bgGradient,
            ),
            border: Border.all(color: g.color.withOpacity(0.13)),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // decorative circles
              Positioned(
                top: -16, right: -16,
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: g.color.withOpacity(0.2),
                  ),
                ),
              ),
              Positioned(
                top: 4, right: 8,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: g.color.withOpacity(0.13),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(g.label,
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
