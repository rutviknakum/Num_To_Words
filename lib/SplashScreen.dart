import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:num_to_words_converter/NumberToWordsScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _progressCtrl;
  late AnimationController _bgCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _subtitleFade;
  late Animation<double> _progressFade;
  late Animation<double> _bgFade;

  @override
  void initState() {
    super.initState();

    // Controllers
    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    // Background fade
    _bgFade = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeOut);

    // Logo: scale up from 0.6 + fade in + slide up
    _logoScale = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutCubic));

    // Text: fade + slide up
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut)));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut)));

    // Progress fade
    _progressFade =
        CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOut);

    // Sequence animations
    _bgCtrl.forward().then((_) {
      _logoCtrl.forward().then((_) {
        _textCtrl.forward().then((_) {
          _progressCtrl.forward();
        });
      });
    });

    // Navigate after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, anim, __) => const NumberToWordsScreen(),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(
              opacity: anim,
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const accent = Color(0xFF6C63FF);
    final bg = isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F4F0);
    final surface = isDark ? const Color(0xFF1A1D27) : Colors.white;
    final textPrimary =
        isDark ? const Color(0xFFECEBE8) : const Color(0xFF1A1814);
    final textMuted =
        isDark ? const Color(0xFF8B8FA8) : const Color(0xFF7A7870);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bg,
        body: FadeTransition(
          opacity: _bgFade,
          child: SafeArea(
            child: Stack(
              children: [
                // ── Subtle top accent decoration ────────────────────
                Positioned(
                  top: -60,
                  right: -60,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withOpacity(isDark ? 0.07 : 0.06),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -80,
                  left: -80,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withOpacity(isDark ? 0.05 : 0.04),
                    ),
                  ),
                ),

                // ── Main content ────────────────────────────────────
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ── Logo card ──────────────────────────────
                        SlideTransition(
                          position: _logoSlide,
                          child: FadeTransition(
                            opacity: _logoFade,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  color: surface,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accent.withOpacity(0.2),
                                      blurRadius: 40,
                                      offset: const Offset(0, 12),
                                    ),
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(isDark ? 0.4 : 0.08),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: Image.asset(
                                    'assets/icon.png',
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Image.asset(
                                          'assets/images/logo.png',
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // ── Title ──────────────────────────────────
                        SlideTransition(
                          position: _textSlide,
                          child: FadeTransition(
                            opacity: _textFade,
                            child: Text(
                              'Number to Words',
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.8,
                                height: 1.1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ── Subtitle ───────────────────────────────
                        FadeTransition(
                          opacity: _subtitleFade,
                          child: Text(
                            'English • Gujarati • Hindi',
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // ── Language dots ──────────────────────────
                        FadeTransition(
                          opacity: _subtitleFade,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _LangDot(
                                  flag: '🇬🇧',
                                  label: 'EN',
                                  accent: accent,
                                  surface: surface,
                                  textMuted: textMuted),
                              const SizedBox(width: 8),
                              _LangDot(
                                  flag: '🇮🇳',
                                  label: 'ગુ',
                                  accent: accent,
                                  surface: surface,
                                  textMuted: textMuted),
                              const SizedBox(width: 8),
                              _LangDot(
                                  flag: '🇮🇳',
                                  label: 'हि',
                                  accent: accent,
                                  surface: surface,
                                  textMuted: textMuted),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Bottom progress ────────────────────────────────
                Positioned(
                  bottom: 52,
                  left: 32,
                  right: 32,
                  child: FadeTransition(
                    opacity: _progressFade,
                    child: Column(children: [
                      // Thin progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 2400),
                          curve: Curves.easeInOut,
                          builder: (_, value, __) => LinearProgressIndicator(
                            value: value,
                            minHeight: 3,
                            backgroundColor: accent.withOpacity(0.12),
                            valueColor: AlwaysStoppedAnimation<Color>(accent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ]),
                  ),
                ),

                // ── Version badge ──────────────────────────────────
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _progressFade,
                    child: Text(
                      'v1.0.0',
                      style: TextStyle(
                        color: textMuted.withOpacity(0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Language dot widget ──────────────────────────────────────────────────────
class _LangDot extends StatelessWidget {
  final String flag;
  final String label;
  final Color accent;
  final Color surface;
  final Color textMuted;

  const _LangDot({
    required this.flag,
    required this.label,
    required this.accent,
    required this.surface,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.15)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(flag, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                color: textMuted, fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
