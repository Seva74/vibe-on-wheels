import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/passenger.dart';
import '../theme/app_theme.dart';
import '../viewmodels/auth_view_model.dart';
import '../viewmodels/trip_view_model.dart';
import 'my_reviews_screen.dart';
import 'my_trips_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  static const String _defaultUserId = 'p1';

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthViewModel, TripViewModel>(
      builder: (context, authVm, tripVm, _) {
        final user = authVm.currentUser;
        if (user == null) {
          return const Scaffold(
            backgroundColor: AppTheme.surface,
            body: Center(
              child: Text(
                'Пользователь не авторизован',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          );
        }

        final isDefaultUser = user.id == _defaultUserId;
        final tripsCount =
            authVm.currentBaseTripsCount + tripVm.myTripsFor(user.id).length;
        final reviewsCount = authVm.currentReviewsCount;
        final rating = isDefaultUser ? user.rating : 0.0;

        return Scaffold(
          backgroundColor: AppTheme.surface,
          appBar: AppBar(title: const Text('Профиль')),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(
                  user,
                  rating: rating,
                  reviewsCount: reviewsCount,
                ),
                _buildStatsRow(
                  tripsCount: tripsCount,
                  reviewsCount: reviewsCount,
                  rating: rating,
                ),
                const SizedBox(height: 16),
                _buildVerificationCard(user),
                const SizedBox(height: 16),
                _buildMenuItems(
                  context,
                  tripsCount: tripsCount,
                  reviewsCount: reviewsCount,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(
    Passenger user, {
    required double rating,
    required int reviewsCount,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AppTheme.accent,
            child: Text(
              user.name.substring(0, 1),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 16, color: Color(0xFFFFB300)),
              const SizedBox(width: 4),
              Text(
                '${rating.toStringAsFixed(1)} (отзывов $reviewsCount)',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Участник с ${user.registeredAt.year}',
            style: const TextStyle(fontSize: 13, color: AppTheme.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow({
    required int tripsCount,
    required int reviewsCount,
    required double rating,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          _statItem('$tripsCount', 'Поездки'),
          _dividerV(),
          _statItem('$reviewsCount', 'Отзывы'),
          _dividerV(),
          _statItem(rating.toStringAsFixed(1), 'Рейтинг'),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _dividerV() => Container(width: 1, height: 40, color: AppTheme.divider);

  Widget _buildVerificationCard(Passenger user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ВЕРИФИКАЦИЯ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textHint,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          _verifyRow('Телефон', _formatPhone(user.phone), true),
          const SizedBox(height: 8),
          _verifyRow('Почта', user.mail, true),
        ],
      ),
    );
  }

  Widget _verifyRow(String label, String value, bool verified) {
    return Row(
      children: [
        Icon(
          verified ? Icons.verified : Icons.pending,
          size: 16,
          color: verified ? AppTheme.success : AppTheme.textHint,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItems(
    BuildContext context, {
    required int tripsCount,
    required int reviewsCount,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          _menuItemNav(
            context,
            Icons.directions_car_outlined,
            'Мои поездки',
            const MyTripsScreen(),
            badge: '$tripsCount',
          ),
          const Divider(indent: 56, height: 1, color: AppTheme.divider),
          _menuItemNav(
            context,
            Icons.star_outline,
            'Мои отзывы',
            const MyReviewsScreen(),
            badge: '$reviewsCount',
          ),
          const Divider(indent: 56, height: 1, color: AppTheme.divider),
          _menuItemNav(
            context,
            Icons.settings_outlined,
            'Настройки',
            const SettingsScreen(),
          ),
        ],
      ),
    );
  }

  Widget _menuItemNav(
    BuildContext context,
    IconData icon,
    String title,
    Widget page, {
    String? badge,
  }) {
    return ListTile(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.primarySurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: AppTheme.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          const Icon(Icons.chevron_right, color: AppTheme.textHint, size: 20),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  String _formatPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 11) return phone;

    final country = digits.substring(0, 1);
    final part1 = digits.substring(1, 4);
    final part2 = digits.substring(4, 7);
    final part3 = digits.substring(7, 9);
    final part4 = digits.substring(9, 11);
    return '+$country $part1 $part2-$part3-$part4';
  }
}
