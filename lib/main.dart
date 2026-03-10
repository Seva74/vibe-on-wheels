import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/trip_repository_impl.dart';
import 'data/booking_repository_impl.dart';
import 'domain/use_cases/search_trips_use_case.dart';
import 'domain/use_cases/join_trip_use_case.dart';
import 'presentation/viewmodels/trip_view_model.dart';
import 'presentation/theme/app_theme.dart';
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
        home: const MainNavigationScreen(),
      ),
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

  late final List<Widget> _screens = [
    const HomeScreen(),
    const TripsScreen(),
    const MessagesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.divider, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
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
}