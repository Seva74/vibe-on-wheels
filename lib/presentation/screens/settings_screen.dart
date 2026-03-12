import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Notifications
  bool _newTripsAlert = true;
  bool _statusChangesAlert = true;
  bool _chatAlert = true;
  bool _marketingAlert = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('Настройки')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('УВЕДОМЛЕНИЯ'),
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
            _sectionLabel('МАРКЕТИНГ'),
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
            const SizedBox(height: 20),
            _sectionLabel('ПРИЛОЖЕНИЕ'),
            const SizedBox(height: 8),
            _buildCard([
              _infoTile(
                icon: Icons.info_outline,
                title: 'Версия',
                value: '1.0.0',
                hasDivider: true,
              ),
              _infoTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Политика конфиденциальности',
                value: '',
                hasDivider: true,
              ),
              _infoTile(
                icon: Icons.gavel_outlined,
                title: 'Пользовательское соглашение',
                value: '',
                hasDivider: false,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppTheme.textHint,
        letterSpacing: 1,
      ),
    );
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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: value ? AppTheme.primarySurface : AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: value ? AppTheme.primary : AppTheme.textHint,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.primary,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        if (hasDivider) const Divider(indent: 68, height: 1, color: AppTheme.divider),
      ],
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
    required bool hasDivider,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppTheme.textHint),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value.isNotEmpty)
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textHint,
                  ),
                ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: AppTheme.textHint, size: 20),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        if (hasDivider) const Divider(indent: 68, height: 1, color: AppTheme.divider),
      ],
    );
  }
}
