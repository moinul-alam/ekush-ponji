// lib/features/words/widgets/word_share_card.dart
//
// Off-screen-renderable card for sharing a word. Explicit colors, no theme
// dependency, always looks great as a PNG.

import 'package:flutter/material.dart';
import 'package:ekush_ponji/features/words/models/word.dart';

class WordShareCard extends StatelessWidget {
  final WordModel word;

  const WordShareCard({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    const bgTop = Color(0xFFF0F8FF);
    const bgBottom = Color(0xFFE8F5F0);
    const accentTeal = Color(0xFF3D6373);
    const accentGreen = Color(0xFF006B54);
    const textDark = Color(0xFF1A2535);
    const textMid = Color(0xFF4A6359);
    const chipBg = Color(0xFFD0ECF5);
    const chipText = Color(0xFF1A3D4D);
    const divider = Color(0xFFBDD8E0);

    return Container(
      width: 420,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [bgTop, bgBottom],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(32, 36, 32, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Part-of-speech chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              word.partOfSpeech,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: chipText,
                letterSpacing: 0.4,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Word
          Text(
            word.word,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: accentTeal,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 6),

          // Pronunciation
          Text(
            word.pronunciation,
            style: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: textMid,
              letterSpacing: 0.2,
            ),
          ),

          const SizedBox(height: 20),

          Container(height: 1, color: divider),

          const SizedBox(height: 20),

          // Meaning EN
          _Section(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Meaning',
            content: word.meaningEn,
            accentColor: accentTeal,
          ),

          const SizedBox(height: 14),

          // Meaning BN
          _Section(
            icon: Icons.translate_rounded,
            title: 'অর্থ',
            content: word.meaningBn,
            accentColor: accentTeal,
          ),

          const SizedBox(height: 14),

          // Example
          _Section(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Example',
            content: word.example,
            accentColor: accentTeal,
            isItalic: true,
          ),

          const SizedBox(height: 24),

          Container(height: 1, color: divider),

          const SizedBox(height: 16),

          // Footer
          Row(
            children: [
              Container(
                width: 3,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [accentTeal, accentGreen],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Word of the Day',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: accentTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: accentTeal.withValues(alpha: 0.2)),
                ),
                child: const Text(
                  'একুশ পঞ্জি',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accentTeal,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color accentColor;
  final bool isItalic;

  const _Section({
    required this.icon,
    required this.title,
    required this.content,
    required this.accentColor,
    this.isItalic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: accentColor),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: accentColor,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF1A2535),
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}