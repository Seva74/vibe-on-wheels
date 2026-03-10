import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
          // Реальная интерактивная карта на весь экран
          const Positioned.fill(child: _RealMapWidget()),

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
              const Expanded(
                child: _SearchField(label: 'Откуда', hint: 'Место отправления'),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: _SearchField(label: 'Куда', hint: 'Место назначения'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: _SearchField(label: 'Оплата', hint: 'Переводом/наличными'),
              ),
              const SizedBox(width: 10),
              const Expanded(
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
          width: double.infinity,
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

// ── Реальная карта ────────────────────────────────────────────────────────────
class _RealMapWidget extends StatelessWidget {
  const _RealMapWidget();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(56.4977, 84.9744), // Координаты Томска
            initialZoom: 13.0,
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate, // Отключаем вращение для удобства
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.vaibnakolesah.app', // Укажи свой package name
            ),
          ],
        ),
        // Центральный маркер (пин), который остается по центру при свайпе карты
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 36), // Смещение вверх, чтобы острие указывало в центр
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withAlpha(100),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
                Container(
                  width: 4,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.textPrimary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  width: 12,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(60),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
