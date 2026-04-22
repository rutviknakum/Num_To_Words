import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:num_to_words_converter/number_to_english.dart';
import 'package:num_to_words_converter/number_to_gujarati.dart';
import 'package:num_to_words_converter/number_to_hindi.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class NumberToWordsScreen extends StatefulWidget {
  const NumberToWordsScreen({super.key});

  @override
  State<NumberToWordsScreen> createState() => _NumberToWordsScreenState();
}

class _NumberToWordsScreenState extends State<NumberToWordsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late stt.SpeechToText _speech;

  bool _isListening = false;
  String _output = '';
  String _selectedLanguage = 'English';
  bool _hasInput = false;
  bool _isFocused = false;

  late AnimationController _micPulseController;
  late AnimationController _outputFadeController;
  late AnimationController _inputFocusController;
  late Animation<double> _micPulse;
  late Animation<double> _outputFade;
  late Animation<Offset> _outputSlide;
  late Animation<double> _inputBorderAnim;

  // ── Language data ──────────────────────────────────────────────────
  static const _languages = [
    {'code': 'English', 'label': 'English', 'native': 'EN', 'flag': '🇬🇧'},
    {'code': 'Gujarati', 'label': 'Gujarati', 'native': 'ગુ', 'flag': '🇮🇳'},
    {'code': 'Hindi', 'label': 'Hindi', 'native': 'हि', 'flag': '🇮🇳'},
  ];

  String _t(String en, String gu, String hi) => switch (_selectedLanguage) {
        'Gujarati' => gu,
        'Hindi' => hi,
        _ => en,
      };

  String get _appBarTitle =>
      _t('Number to Words', 'નંબર થી શબ્દ', 'संख्या से शब्द');
  String get _inputLabel => _t('NUMBER', 'નંબર', 'संख्या');
  String get _resultLabel => _t('RESULT', 'પરિણામ', 'परिणाम');
  String get _examplesLabel =>
      _t('QUICK EXAMPLES', 'ઝડપી ઉદાહરણ', 'त्वरित उदाहरण');
  String get _emptyHint => _t(
      'Type a number above to see it in words',
      'ઉપર નંબર ટાઈપ કરો, શબ્દ અહીં દેખાશે',
      'ऊपर संख्या लिखें, शब्द यहाँ दिखेंगे');
  String get _copiedMsg =>
      _t('Copied to clipboard!', 'કૉપિ થઈ ગઈ!', 'कॉपी हो गया!');
  String get _errorMsg => _t('Please enter a valid number',
      'કૃપા કરીને માન્ય નંબર દાખલ કરો', 'कृपया एक मान्य संख्या दर्ज करें');

  // ── Init ───────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    _micPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _outputFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _inputFocusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _micPulse = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _micPulseController, curve: Curves.easeInOut),
    );
    _outputFade = CurvedAnimation(
      parent: _outputFadeController,
      curve: Curves.easeOut,
    );
    _outputSlide = Tween<Offset>(
      begin: const Offset(0, 0.07),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _outputFadeController, curve: Curves.easeOut));
    _inputBorderAnim = CurvedAnimation(
      parent: _inputFocusController,
      curve: Curves.easeOut,
    );

    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
      _isFocused
          ? _inputFocusController.forward()
          : _inputFocusController.reverse();
    });
  }

  @override
  void dispose() {
    _micPulseController.dispose();
    _outputFadeController.dispose();
    _inputFocusController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Logic ──────────────────────────────────────────────────────────
  void _convertToWords() {
    final text = _controller.text.trim();
    setState(() {
      _hasInput = text.isNotEmpty;
      if (text.isEmpty) {
        _output = '';
        _outputFadeController.reset();
        return;
      }
      final number = int.tryParse(text);
      if (number != null) {
        _output = switch (_selectedLanguage) {
          'Gujarati' => numberToGujaratiWords(number),
          'Hindi' => numberToHindiWords(number),
          _ => numberToEnglishWords(number),
        };
        _outputFadeController
          ..reset()
          ..forward();
      } else {
        _output = '';
        _outputFadeController.reset();
        _showErrorSnackbar();
      }
    });
  }

  void _showErrorSnackbar() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(
            child: Text(_errorMsg,
                style: const TextStyle(fontWeight: FontWeight.w500))),
      ]),
      backgroundColor: const Color(0xFFB5294E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      duration: const Duration(seconds: 2),
    ));
  }

  Future<void> _toggleListening() async {
    HapticFeedback.mediumImpact();
    if (!_isListening) {
      final available = await _speech.initialize(
        onStatus: (s) {
          if (s == 'done' || s == 'notListening')
            setState(() => _isListening = false);
        },
        onError: (_) => setState(() => _isListening = false),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: switch (_selectedLanguage) {
            'Hindi' => 'hi_IN',
            'Gujarati' => 'gu_IN',
            _ => 'en_US',
          },
          onResult: (result) {
            _controller.text = result.recognizedWords;
            _controller.selection =
                TextSelection.collapsed(offset: _controller.text.length);
            _convertToWords();
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _clearInput() {
    HapticFeedback.lightImpact();
    _controller.clear();
    setState(() {
      _output = '';
      _hasInput = false;
    });
    _outputFadeController.reset();
  }

  // ── Build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const accent = Color(0xFF6C63FF);
    const accentDark = Color(0xFF9F99FF);
    final accentLight = isDark ? accentDark : accent;
    final bg = isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F4F0);
    final surface = isDark ? const Color(0xFF1A1D27) : Colors.white;
    final border = isDark ? const Color(0xFF2A2D3E) : const Color(0xFFE4E2DC);
    final textPrimary =
        isDark ? const Color(0xFFECEBE8) : const Color(0xFF1A1814);
    final textMuted =
        isDark ? const Color(0xFF8B8FA8) : const Color(0xFF7A7870);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: bg,
          appBar: _buildAppBar(
              isDark, bg, surface, border, accentLight, textMuted, textPrimary),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputCard(surface, border, textMuted, textPrimary,
                      accentLight, isDark),
                  const SizedBox(height: 12),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeInOut,
                    child: _output.isEmpty
                        ? _buildEmptyCard(surface, border, textMuted)
                        : _buildResultCard(surface, border, accent, accentLight,
                            textPrimary, textMuted, isDark),
                  ),
                  const SizedBox(height: 28),
                  _buildSectionLabel(_examplesLabel, textMuted),
                  const SizedBox(height: 10),
                  _buildChips(
                      surface, border, accent, accentLight, textPrimary),
                  const SizedBox(height: 26),
                  _buildSectionLabel(_t('LANGUAGE', 'ભાષા', 'भाषा'), textMuted),
                  const SizedBox(height: 10),
                  _buildLanguageSelector(surface, border, accent, accentLight,
                      textPrimary, textMuted, isDark),
                ],
              ),
            ),
          ),
          floatingActionButton: _buildMicFAB(accent),
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(bool isDark, Color bg, Color surface,
      Color border, Color accentLight, Color textMuted, Color textPrimary) {
    return AppBar(
      backgroundColor: bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      titleSpacing: 18,
      title: Row(children: [
        // Logo with white bg container
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/logo.png',
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.tag_rounded,
                color: Color(0xFF6C63FF),
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_appBarTitle,
              style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4)),
          Text(_t('Converter', 'રૂપાંતરક', 'कन्वर्टर'),
              style: TextStyle(
                  color: textMuted, fontSize: 11, fontWeight: FontWeight.w500)),
        ]),
      ]),
      actions: [
        // Language popup
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: PopupMenuButton<String>(
            onSelected: (v) => setState(() {
              _selectedLanguage = v;
              _output = '';
              _outputFadeController.reset();
            }),
            color: surface,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: border),
            ),
            itemBuilder: (_) => _languages
                .map((l) => PopupMenuItem<String>(
                      value: l['code'],
                      child: Row(children: [
                        Text(l['flag']!, style: const TextStyle(fontSize: 17)),
                        const SizedBox(width: 10),
                        Text(l['label']!,
                            style: TextStyle(
                              fontWeight: _selectedLanguage == l['code']
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: _selectedLanguage == l['code']
                                  ? accentLight
                                  : null,
                            )),
                        if (_selectedLanguage == l['code']) ...[
                          const Spacer(),
                          Icon(Icons.check_rounded,
                              size: 16, color: accentLight),
                        ],
                      ]),
                    ))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.language_rounded, size: 15, color: textMuted),
                const SizedBox(width: 5),
                Text(
                  _languages.firstWhere(
                      (l) => l['code'] == _selectedLanguage)['native']!,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: accentLight),
                ),
                const SizedBox(width: 3),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16, color: textMuted),
              ]),
            ),
          ),
        ),
      ],
    );
  }

  // ── Input Card ─────────────────────────────────────────────────────
  Widget _buildInputCard(Color surface, Color border, Color textMuted,
      Color textPrimary, Color accentLight, bool isDark) {
    return AnimatedBuilder(
      animation: _inputBorderAnim,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Color.lerp(border, accentLight, _inputBorderAnim.value)!,
            width: 1.0 + _inputBorderAnim.value * 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isFocused
                  ? accentLight.withOpacity(0.12)
                  : Colors.black.withOpacity(isDark ? 0.25 : 0.05),
              blurRadius: _isFocused ? 20 : 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 14, 0),
            child: Row(children: [
              // Badge
              _buildBadge(_inputLabel.toUpperCase(), accentLight),
              const Spacer(),
              // Character count
              if (_hasInput)
                Text('${_controller.text.length} digits',
                    style: TextStyle(
                        color: textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
              if (_hasInput) const SizedBox(width: 8),
              // Clear
              AnimatedOpacity(
                opacity: _hasInput ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 180),
                child: GestureDetector(
                  onTap: _clearInput,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        Icon(Icons.close_rounded, size: 14, color: textMuted),
                  ),
                ),
              ),
            ]),
          ),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              color: textPrimary,
              fontSize: 50,
              fontWeight: FontWeight.w900,
              letterSpacing: -2.2,
              height: 1.1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                color: textMuted.withOpacity(0.22),
                fontSize: 50,
                fontWeight: FontWeight.w900,
                letterSpacing: -2.2,
                height: 1.1,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
            ),
            onChanged: (_) => _convertToWords(),
          ),
        ]),
      ),
    );
  }

  // ── Empty Card ─────────────────────────────────────────────────────
  Widget _buildEmptyCard(Color surface, Color border, Color textMuted) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 24),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Column(children: [
        Icon(Icons.article_outlined,
            size: 34, color: textMuted.withOpacity(0.28)),
        const SizedBox(height: 12),
        Text(
          _emptyHint,
          style: TextStyle(
              color: textMuted.withOpacity(0.52), fontSize: 14, height: 1.6),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }

  // ── Result Card ────────────────────────────────────────────────────
  Widget _buildResultCard(Color surface, Color border, Color accent,
      Color accentLight, Color textPrimary, Color textMuted, bool isDark) {
    return FadeTransition(
      opacity: _outputFade,
      child: SlideTransition(
        position: _outputSlide,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color.lerp(surface, accent, isDark ? 0.08 : 0.04),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accent.withOpacity(isDark ? 0.3 : 0.18)),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(isDark ? 0.15 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _buildBadge(_resultLabel.toUpperCase(), accentLight),
              const Spacer(),
              // Copy button with label
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _output));
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Row(children: [
                      const Icon(Icons.check_circle_outline_rounded,
                          color: Colors.white, size: 17),
                      const SizedBox(width: 8),
                      Text(_copiedMsg,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ]),
                    backgroundColor: accent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    duration: const Duration(seconds: 2),
                  ));
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accent.withOpacity(0.2)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.copy_rounded, size: 13, color: accentLight),
                    const SizedBox(width: 5),
                    Text(_t('Copy', 'કૉપિ', 'कॉपी'),
                        style: TextStyle(
                            color: accentLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            // Divider
            Divider(height: 1, color: accent.withOpacity(0.15)),
            const SizedBox(height: 14),
            Text(
              _output,
              style: TextStyle(
                  color: textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  letterSpacing: -0.2),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Quick Chips ────────────────────────────────────────────────────
  Widget _buildChips(Color surface, Color border, Color accent,
      Color accentLight, Color textPrimary) {
    const examples = ['42', '100', '999', '10000', '100000', '1000000'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: examples.map((n) {
        final active = _controller.text == n;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            _controller.text = n;
            _controller.selection = TextSelection.collapsed(offset: n.length);
            _convertToWords();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: active ? accent.withOpacity(0.1) : surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? accent.withOpacity(0.5) : border,
                width: active ? 1.5 : 1.0,
              ),
            ),
            child: Text(n,
                style: TextStyle(
                  color: active ? accentLight : textPrimary,
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                )),
          ),
        );
      }).toList(),
    );
  }

  // ── Language Selector ──────────────────────────────────────────────
  Widget _buildLanguageSelector(Color surface, Color border, Color accent,
      Color accentLight, Color textPrimary, Color textMuted, bool isDark) {
    return Row(
      children: _languages.asMap().entries.map((entry) {
        final i = entry.key;
        final l = entry.value;
        final active = _selectedLanguage == l['code'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedLanguage = l['code']!;
                _output = '';
                _outputFadeController.reset();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: i < _languages.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: active ? accent : surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: active ? accent : border,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                            color: accent.withOpacity(0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4)),
                      ]
                    : [],
              ),
              child: Column(children: [
                Text(l['flag']!, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 6),
                Text(l['code']!,
                    style: TextStyle(
                      color: active ? Colors.white : textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 2),
                Text(l['native']!,
                    style: TextStyle(
                      color: active ? Colors.white.withOpacity(0.7) : textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    )),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Mic FAB ────────────────────────────────────────────────────────
  Widget _buildMicFAB(Color accent) {
    final fab = FloatingActionButton.large(
      onPressed: _toggleListening,
      backgroundColor: _isListening ? const Color(0xFFB5294E) : accent,
      elevation: _isListening ? 8 : 4,
      shape: const CircleBorder(),
      child: Icon(
        _isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
        color: Colors.white,
        size: 30,
      ),
    );
    return _isListening ? ScaleTransition(scale: _micPulse, child: fab) : fab;
  }

  // ── Shared Helpers ─────────────────────────────────────────────────
  Widget _buildBadge(String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: accent,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8)),
    );
  }

  Widget _buildSectionLabel(String label, Color textMuted) {
    return Text(label,
        style: TextStyle(
            color: textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8));
  }
}
