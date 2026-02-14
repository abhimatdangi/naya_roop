import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/favorites_service.dart';
import '../theme/app_theme.dart';

class HairstyleCard extends StatefulWidget {
  const HairstyleCard({
    super.key,
    required this.title,
    required this.userId,
    this.isRecommended = false,
  });

  final String title;
  final String userId;
  final bool isRecommended;

  @override
  State<HairstyleCard> createState() => _HairstyleCardState();
}

class _HairstyleCardState extends State<HairstyleCard> {
  bool _isExpanded = false;

  static const Map<String, String> _hairstyleImages = {
    'Classic Pompadour': 'assests/Classic Pompadour.webp',
    'Side Part': 'assests/Side Part.jpg',
    'Side Part with Volume': 'assests/Side Part.jpg',
    'Textured Quiff': 'assests/Textured Quiff.jpg',
    'Buzz Cut': 'assests/buzz cut.webp',
    'Long Layers': 'assests/Long Layered.jpg',
    'High Fade': 'assests/high fade.webp',
    'High Fade + Textured Top': 'assests/high fade.webp',
    'Short Quiff': 'assests/Textured Quiff.jpg',
    'Pompadour': 'assests/Pompadour.jpg',
    'Faux Hawk': 'assests/Faux Hauxk.jpg',
    'Angular Fringe': 'assests/Angular Fringe.jpg',
    'Spiky Hair': 'assests/Spiky Hair .jpg',
    'Textured Crop': 'assests/Textured crop.jpg',
    'Textured Crop + Mid Fade': 'assests/Textured crop.jpg',
    'Side Swept': 'assests/Side Swept.webp',
    'Classic Taper': 'assests/CLassic taper.jpg',
    'Medium Length Waves': 'assests/Classic Medium.jpg',
    'Slick Back': 'assests/Slick Back.jpg',
    'Fringe Styles': 'assests/Angular Fringe.jpg',
    'Medium Length': 'assests/Classic Medium.jpg',
    'Textured Layers': 'assests/Long Layered.jpg',
    'Chin-Length Bob': 'assests/Classic Medium.jpg',
    'Side Fringe': 'assests/Angular Fringe.jpg',
    'Layered Cut': 'assests/Long Layered.jpg',
    'Wavy Styles': 'assests/Classic Medium.jpg',
    'Full Bangs': 'assests/Angular Fringe.jpg',
    'Volume on Sides': 'assests/Pompadour.jpg',
    'Textured Fringe': 'assests/Angular Fringe.jpg',
    'Chin-Length Styles': 'assests/Classic Medium.jpg',
    'Wispy Bangs': 'assests/Angular Fringe.jpg',
    'Soft Layers': 'assests/Long Layered.jpg',
    'Crew Cut / Ivy League': 'assests/CLassic taper.jpg',
    'Side Part Taper': 'assests/Side Part.jpg',
    'Curtains / Medium Layered Cut': 'assests/Classic Medium.jpg',
    'Curtains': 'assests/Classic Medium.jpg',
    'Low Taper + Natural Top': 'assests/CLassic taper.jpg',
    'Side-Swept Fringe': 'assests/Side Swept.webp',
    'Low Taper + Layered Top': 'assests/Long Layered.jpg',
  };

  String? get _imagePath => _hairstyleImages[widget.title];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white54 : Colors.black26;
    final cardBackground = isDark ? kCardBackgroundDark : kCardBackgroundLight;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: kPrimaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'assests/scissor.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                  StreamBuilder<Set<String>>(
                    stream: FavoritesService.favoritesStream(),
                    builder: (context, snapshot) {
                      final favorites = snapshot.data ?? {};
                      final isFavorite = favorites.contains(widget.title);
                      return GestureDetector(
                        onTap: () {
                          FavoritesService.toggleFavorite(
                            widget.title,
                            isFavorite,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isFavorite
                                ? Colors.red.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isFavorite
                                ? CupertinoIcons.heart_fill
                                : CupertinoIcons.heart,
                            color: isFavorite ? Colors.red : subtextColor,
                            size: 22,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      CupertinoIcons.chevron_right,
                      color: subtextColor,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _imagePath != null
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              _imagePath!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 200,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(
                                        CupertinoIcons.photo,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}
