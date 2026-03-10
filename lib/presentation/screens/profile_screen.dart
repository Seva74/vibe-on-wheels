import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../domain/entities/passenger.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final Passenger _currentUser = Passenger(
    id: 'p1',
    name: 'Алексей Смирнов',
    phone: '79991234567',
    mail: 'alex.student@tsu.ru',
    rating: 4.9,
    registeredAt: DateTime(2024, 3, 10),
    isStudent: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('Профиль')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildStatsRow(),
            const SizedBox(height: 16),
            _buildVerificationCard(),
            const SizedBox(height: 16),
            _buildMenuItems(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppTheme.accent,
                child: Text(
                  _currentUser.name.substring(0, 1),
                  style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary),
                ),
              ),
              if (_currentUser.isStudent)
                Positioned(
                  bottom: 2, right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: AppTheme.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.school, color: Colors.white, size: 14),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(_currentUser.name,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 16, color: Color(0xFFFFB300)),
              const SizedBox(width: 4),
              Text('${_currentUser.rating} (отзывов 12)',
                  style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Участник с ${_currentUser.registeredAt.year}',
              style: const TextStyle(fontSize: 13, color: AppTheme.textHint)),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
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
          _statItem('83', 'Поездки'),
          _dividerV(),
          _statItem('42', 'Отзывы'),
          _dividerV(),
          _statItem('4.7', 'Рейтинг'),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _dividerV() =>
      Container(width: 1, height: 40, color: AppTheme.divider);

  Widget _buildVerificationCard() {
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
          const Text('ВЕРИФИКАЦИЯ',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textHint,
                  letterSpacing: 1)),
          const SizedBox(height: 12),
          _verifyRow('Телефон', '+7 999 123-45-67', true),
          const SizedBox(height: 8),
          _verifyRow('Почта', _currentUser.mail, true),
          if (_currentUser.isStudent) ...[
            const SizedBox(height: 8),
            _verifyRow('Студент', 'ТГУ', true),
          ],
        ],
      ),
    );
  }

  Widget _verifyRow(String label, String value, bool verified) {
    return Row(
      children: [
        Icon(verified ? Icons.verified : Icons.pending,
            size: 16,
            color: verified ? AppTheme.success : AppTheme.textHint),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: verified ? AppTheme.success.withAlpha(30) : AppTheme.accent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            verified ? 'Подтверждено' : 'Ожидание',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: verified ? AppTheme.success : AppTheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          _menuItem(Icons.directions_car_outlined, 'Мои поездки', '83'),
          const Divider(indent: 56, height: 1, color: AppTheme.divider),
          _menuItem(Icons.star_outline, 'Мои отзывы', '42'),
          const Divider(indent: 56, height: 1, color: AppTheme.divider),
          // Уведомления — встроены в профиль
          _menuItemNav(
            context,
            Icons.notifications_outlined,
            'Уведомления',
            const _NotificationSettingsPage(),
          ),
          const Divider(indent: 56, height: 1, color: AppTheme.divider),
          _menuItem(Icons.settings_outlined, 'Настройки', null),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, String? badge) {
    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: AppTheme.primarySurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: AppTheme.primary),
      ),
      title: Text(title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(badge,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary)),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: AppTheme.textHint, size: 20),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _menuItemNav(
      BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => page)),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: AppTheme.primarySurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: AppTheme.primary),
      ),
      title: Text(title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textHint, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

// ── Страница уведомлений (встроена в профиль) ─────────────────────────────────
class _NotificationSettingsPage extends StatefulWidget {
  const _NotificationSettingsPage();

  @override
  State<_NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<_NotificationSettingsPage> {
  bool _newTripsAlert = true;
  bool _statusChangesAlert = true;
  bool _chatAlert = true;
  bool _marketingAlert = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('Уведомления')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('ОСНОВНЫЕ'),
            const SizedBox(height: 8),
            _buildCard([
              _switchTile(
                icon: Icons.directions_car,
                title: 'Новые поездки',
                subtitle: 'Поездки по вашим маршрутам',
                value: _newTripsAlert,
                onChanged: (v) => setState(() => _newTripsAlert = v),
                hasDivider: true,
              ),
              _switchTile(
                icon: Icons.notifications_active,
                title: 'Статус бронирования',
                subtitle: 'Подтверждение или отклонение',
                value: _statusChangesAlert,
                onChanged: (v) => setState(() => _statusChangesAlert = v),
                hasDivider: true,
              ),
              _switchTile(
                icon: Icons.chat_bubble_outline,
                title: 'Новые сообщения',
                subtitle: 'Сообщения от водителей',
                value: _chatAlert,
                onChanged: (v) => setState(() => _chatAlert = v),
                hasDivider: false,
              ),
            ]),
            const SizedBox(height: 20),
            _sectionLabel('ДОПОЛНИТЕЛЬНО'),
            const SizedBox(height: 8),
            _buildCard([
              _switchTile(
                icon: Icons.campaign_outlined,
                title: 'Новости и акции',
                subtitle: 'Специальные предложения',
                value: _marketingAlert,
                onChanged: (v) => setState(() => _marketingAlert = v),
                hasDivider: false,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.textHint,
            letterSpacing: 1));
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(children: children),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool hasDivider,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: value ? AppTheme.primarySurface : AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                size: 18,
                color: value ? AppTheme.primary : AppTheme.textHint),
          ),
          title: Text(title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary)),
          trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.primary,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        if (hasDivider)
          const Divider(indent: 68, height: 1, color: AppTheme.divider),
      ],
    );
  }
}