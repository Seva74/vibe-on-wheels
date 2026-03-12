import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/trip_repository_impl.dart';
import 'data/booking_repository_impl.dart';
import 'domain/use_cases/search_trips_use_case.dart';
import 'domain/use_cases/join_trip_use_case.dart';
import 'presentation/viewmodels/trip_view_model.dart';
import 'presentation/viewmodels/auth_view_model.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/trips_screen.dart';
import 'presentation/screens/message_screen.dart';
import 'presentation/screens/profile_screen.dart';

void main() {
  runApp(const VaibNaKolesahApp());
}

class VaibNaKolesahApp extends StatelessWidget {
  const VaibNaKolesahApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tripRepo = TripRepositoryImpl();
    final bookingRepo = BookingRepositoryImpl();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(
          create: (_) => TripViewModel(
            searchUseCase: SearchTripsUseCase(tripRepo),
            joinUseCase: JoinTripUseCase(bookingRepo),
            tripRepository: tripRepo,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'ВайбНаКолёсах',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const _RootScreen(),
      ),
    );
  }
}

class _RootScreen extends StatelessWidget {
  const _RootScreen();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        if (auth.isLoggedIn) return const MainNavigationScreen();
        return const LoginScreen();
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _onboardingDone = false;
  int _onboardingStep = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(onOpenTrips: _openTripsTab),
      const TripsScreen(),
      const MessagesScreen(),
      ProfileScreen(),
    ];
  }

  void _openTripsTab() {
    if (!mounted) return;
    setState(() => _currentIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    final displayIndex = _onboardingDone ? _currentIndex : _onboardingStep;

    return Scaffold(
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: !_onboardingDone,
            child: IndexedStack(index: displayIndex, children: _screens),
          ),
          if (!_onboardingDone) ...[
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(color: Colors.black.withAlpha(130)),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: _buildOnboardingCard(),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.divider)),
        ),
        child: BottomNavigationBar(
          currentIndex: displayIndex,
          onTap: _onboardingDone
              ? (i) => setState(() => _currentIndex = i)
              : null,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on_outlined),
              activeIcon: Icon(Icons.location_on),
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car_outlined),
              activeIcon: Icon(Icons.directions_car),
              label: 'Поездки',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Сообщения',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingCard() {
    final step = _OnboardingItem.items[_onboardingStep];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
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
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(step.icon, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                step.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            step.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _onboardingDone = true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.accent),
                    backgroundColor: AppTheme.primarySurface,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Пропустить',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_onboardingStep < 3) {
                      setState(() => _onboardingStep++);
                    } else {
                      setState(() => _onboardingDone = true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: Text(
                    _onboardingStep < 3 ? 'Далее' : 'Начать',
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
}

class _OnboardingItem {
  final IconData icon;
  final String label;
  final String text;

  const _OnboardingItem({
    required this.icon,
    required this.label,
    required this.text,
  });

  static const List<_OnboardingItem> items = [
    _OnboardingItem(
      icon: Icons.location_on,
      label: 'Главная',
      text: 'Введите откуда и куда — найдём попутчиков по вашему маршруту прямо на карте',
    ),
    _OnboardingItem(
      icon: Icons.directions_car,
      label: 'Поездки',
      text: 'Просматривайте доступные поездки, бронируйте места и следите за статусом',
    ),
    _OnboardingItem(
      icon: Icons.chat_bubble,
      label: 'Сообщения',
      text: 'Общайтесь с попутчиками прямо в приложении после оформления поездки',
    ),
    _OnboardingItem(
      icon: Icons.person,
      label: 'Профиль',
      text: 'Настраивайте профиль, просматривайте историю поездок и отзывы',
    ),
  ];
}
