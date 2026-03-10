import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _onboardingDone = false;
  int _onboardingStep = 0;

  final List<Map<String, String>> _onboardingSteps = [
    {
      'text': 'В этом разделе вы сможете искать водителей или попутчиков для ваших поездок',
    },
    {
      'text': 'В этом разделе вы сможете просматривать поездки и находить рекомендованные вам поездки',
    },
    {
      'text': 'В этом разделе вы сможете общаться с попутчиками. Оформите поездку и начните чат!',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Найти попутчика'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Заглушка карты на весь экран
          Positioned.fill(child: _MockMapWidget()),

          // Форма поиска снизу
          if (_onboardingDone)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildSearchForm(context),
            ),

          // Онбординг-оверлей
          if (!_onboardingDone)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildOnboarding(context),
            ),
        ],
      ),
    );
  }

  Widget _buildOnboarding(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Индикатор шагов
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingSteps.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _onboardingStep ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == _onboardingStep ? AppTheme.primary : AppTheme.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _onboardingSteps[_onboardingStep]['text']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _onboardingDone = true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.accent),
                    backgroundColor: AppTheme.primarySurface,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Пропустить',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_onboardingStep < _onboardingSteps.length - 1) {
                      setState(() => _onboardingStep++);
                    } else {
                      setState(() => _onboardingDone = true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    _onboardingStep < _onboardingSteps.length - 1 ? 'Далее' : 'Начать',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Хэндл
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Откуда / Куда
          Row(
            children: [
              Expanded(
                child: _SearchField(label: 'Откуда', hint: 'Место отправления'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SearchField(label: 'Куда', hint: 'Место назначения'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SearchField(label: 'Оплата', hint: 'Переводом/наличными'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SearchField(label: 'Дата', hint: 'дд.мм.гггг'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('Найти поездки'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.person_search, size: 18),
                  label: const Text('Найти попутчиков'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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

class _SearchField extends StatelessWidget {
  final String label;
  final String hint;
  const _SearchField({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textHint,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(hint,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary)),
        ),
      ],
    );
  }
}

// ── Заглушка карты ────────────────────────────────────────────────────────────
class _MockMapWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8EDF2),
      child: CustomPaint(
        painter: _FullMapPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _FullMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFCFD8DC)
      ..strokeWidth = 1.0;

    // Сетка кварталов
    for (double y = 0; y < size.height; y += 36) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (double x = 0; x < size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Магистрали
    final road = Paint()
      ..color = const Color(0xFFB0BEC5)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, size.height * 0.35), Offset(size.width, size.height * 0.35), road);
    canvas.drawLine(Offset(0, size.height * 0.6), Offset(size.width, size.height * 0.6), road);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), road);
    canvas.drawLine(Offset(size.width * 0.65, 0), Offset(size.width * 0.65, size.height), road);

    // Дороги потоньше
    final road2 = Paint()
      ..color = const Color(0xFFCFD8DC)
      ..strokeWidth = 4;
    canvas.drawLine(Offset(0, size.height * 0.2), Offset(size.width, size.height * 0.2), road2);
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), road2);
    canvas.drawLine(Offset(0, size.height * 0.75), Offset(size.width, size.height * 0.75), road2);
    canvas.drawLine(Offset(size.width * 0.15, 0), Offset(size.width * 0.15, size.height), road2);
    canvas.drawLine(Offset(size.width * 0.5, 0), Offset(size.width * 0.5, size.height), road2);
    canvas.drawLine(Offset(size.width * 0.8, 0), Offset(size.width * 0.8, size.height), road2);

    // Метка
    final cx = size.width * 0.5;
    final cy = size.height * 0.42;

    final shadowPaint = Paint()..color = Colors.black.withAlpha(40)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(cx, cy + 6), 14, shadowPaint);

    final pinPaint = Paint()..color = const Color(0xFF7C5CBF);
    canvas.drawCircle(Offset(cx, cy), 14, pinPaint);

    final whitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), 6, whitePaint);
  }

  @override
  bool shouldRepaint(_) => false;
}