import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../viewmodels/auth_view_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isProfileLoaded = false;

  bool _newTripsAlert = true;
  bool _statusChangesAlert = true;
  bool _chatAlert = true;
  bool _marketingAlert = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isProfileLoaded) return;

    final user = context.read<AuthViewModel>().currentUser;
    if (user != null) {
      final parts = user.name.trim().split(RegExp(r'\s+'));
      _firstNameController.text = parts.isNotEmpty ? parts.first : '';
      _lastNameController.text =
          parts.length > 1 ? parts.sublist(1).join(' ') : '';
      _phoneController.text = _formatPhone(user.phone);
    }

    _isProfileLoaded = true;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _formatPhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return '+7 ';

    final number = digits.startsWith('7') ? digits.substring(1) : digits;
    final buf = StringBuffer('+7 ');

    for (int i = 0; i < number.length && i < 10; i++) {
      if (i == 3) buf.write(' ');
      if (i == 6) buf.write('-');
      if (i == 8) buf.write('-');
      buf.write(number[i]);
    }
    return buf.toString();
  }

  void _onPhoneChanged(String value) {
    final formatted = _formatPhone(value);
    if (formatted == _phoneController.text) return;

    _phoneController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _saveProfile(AuthViewModel authVm) {
    final result = authVm.updateCurrentUserProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phone: _phoneController.text,
    );

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Профиль обновлен'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVm, _) {
        return Scaffold(
          backgroundColor: AppTheme.surface,
          appBar: AppBar(title: const Text('Настройки')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('ПРОФИЛЬ'),
                const SizedBox(height: 8),
                _buildCard([
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                    child: Column(
                      children: [
                        _editableField(
                          controller: _firstNameController,
                          label: 'Имя',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 10),
                        _editableField(
                          controller: _lastNameController,
                          label: 'Фамилия',
                          icon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 10),
                        _editableField(
                          controller: _phoneController,
                          label: 'Телефон',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textCapitalization: TextCapitalization.none,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[\d\+\s\-]'),
                            ),
                          ],
                          onChanged: _onPhoneChanged,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _saveProfile(authVm),
                            icon: const Icon(Icons.save_outlined, size: 18),
                            label: const Text('Сохранить изменения'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
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
      },
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

  Widget _editableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.words,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textHint),
        prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
        filled: true,
        fillColor: AppTheme.surfaceVariant,
      ),
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
        if (hasDivider)
          const Divider(indent: 68, height: 1, color: AppTheme.divider),
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
        if (hasDivider)
          const Divider(indent: 68, height: 1, color: AppTheme.divider),
      ],
    );
  }
}
