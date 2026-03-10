import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/trip_view_model.dart';
import '../theme/app_theme.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/driver.dart';
import '../../domain/enums.dart';

class TripDetailsScreen extends StatefulWidget {
  final Trip trip;
  final Driver driver;

  const TripDetailsScreen({super.key, required this.trip, required this.driver});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  bool _showBookedBanner = false;

  String _formatDateTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    const days = ['','пн','вт','ср','чт','пт','сб','вс'];
    const months = ['','янв','фев','мар','апр','май','июн','июл','авг','сен','окт','ноя','дек'];
    return '${days[dt.weekday]}, ${dt.day} ${months[dt.month]} в $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TripViewModel>(
      builder: (context, vm, _) {
        // Когда водитель принял — показываем экран встречи
        if (vm.confirmationStatus == BookingConfirmationStatus.driverAccepted &&
            vm.confirmedTrip?.tripId == widget.trip.tripId) {
          return _buildDriverAcceptedScreen(context, vm);
        }

        return Scaffold(
          backgroundColor: AppTheme.surface,
          appBar: AppBar(
            title: const Text('Детали поездки'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildRouteCard(),
                    const SizedBox(height: 16),
                    _buildDriverCard(),
                    const SizedBox(height: 16),
                    _buildDetailsCard(),
                  ],
                ),
              ),
              // Баннер "Поездка забронирована"
              if (_showBookedBanner)
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: _BookedBanner(
                    onDismiss: () => setState(() => _showBookedBanner = false),
                  ),
                ),
              // Баннер "Водитель принял"
              if (vm.confirmationStatus == BookingConfirmationStatus.booked &&
                  vm.confirmedTrip?.tripId == widget.trip.tripId)
                Positioned(
                  top: _showBookedBanner ? 76 : 12,
                  left: 16,
                  right: 16,
                  child: _DriverAcceptingBanner(),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBookingButton(context, vm),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRouteCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accent, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.radio_button_checked, color: AppTheme.primary, size: 18),
            const SizedBox(width: 10),
            Text(widget.trip.startLocation.address,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ]),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Container(width: 2, height: 24, color: AppTheme.primaryLight),
          ),
          Row(children: [
            const Icon(Icons.location_on, color: AppTheme.primary, size: 18),
            const SizedBox(width: 10),
            Text(widget.trip.endLocation.address,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 14),
          const Divider(color: AppTheme.divider),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.schedule, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text(_formatDateTime(widget.trip.startTime),
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
          ]),
        ],
      ),
    );
  }

  Widget _buildDriverCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ВОДИТЕЛЬ',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textHint, letterSpacing: 1)),
          const SizedBox(height: 14),
          Row(
            children: [
              Stack(children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.accent,
                  child: Text(widget.driver.name.substring(0, 1),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                ),
                if (widget.driver.isVerified)
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.verified, color: AppTheme.primary, size: 16),
                    ),
                  ),
              ]),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.driver.name,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(children: [
                    ...List.generate(5, (i) => Icon(
                      i < widget.driver.driverRating.round() ? Icons.star : Icons.star_border,
                      size: 14, color: const Color(0xFFFFB300),
                    )),
                    const SizedBox(width: 4),
                    Text(widget.driver.driverRating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ]),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.divider),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.directions_car, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 8),
            Text(widget.driver.carModel,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant, borderRadius: BorderRadius.circular(8)),
              child: Text(widget.driver.carPlate,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    final seats = widget.trip.getAvailableSeats();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ИНФОРМАЦИЯ О ПОЕЗДКЕ',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textHint, letterSpacing: 1)),
          const SizedBox(height: 14),
          _infoRow(Icons.event_seat, 'Свободных мест', '$seats'),
          const SizedBox(height: 10),
          _infoRow(Icons.payments_outlined, 'Стоимость', '${widget.trip.price.toInt()} ₽'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: 18, color: AppTheme.primary),
      const SizedBox(width: 10),
      Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
      const Spacer(),
      Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
    ]);
  }

  Widget _buildBookingButton(BuildContext context, TripViewModel vm) {
    final alreadyBooked = vm.confirmationStatus != BookingConfirmationStatus.none &&
        vm.confirmedTrip?.tripId == widget.trip.tripId;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: (vm.bookingState == ViewState.loading || alreadyBooked)
              ? null
              : () async {
                  final success = await vm.handleJoinRequest(widget.trip);
                  if (!context.mounted) return;
                  if (success) {
                    setState(() => _showBookedBanner = true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(vm.bookingError),
                      backgroundColor: AppTheme.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ));
                  }
                },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: alreadyBooked ? AppTheme.textHint : null,
          ),
          child: vm.bookingState == ViewState.loading
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(
                  alreadyBooked
                      ? 'Ожидаем водителя...'
                      : 'Забронировать за ${widget.trip.price.toInt()} ₽',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
        ),
      ),
    );
  }

  // ── Экран встречи (водитель принял) ────────────────────────────────────────
  Widget _buildDriverAcceptedScreen(BuildContext context, TripViewModel vm) {
    final driver = vm.confirmedDriver ?? widget.driver;
    final trip = vm.confirmedTrip ?? widget.trip;
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Поездка подтверждена'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () {
              vm.resetBookingState();
              Navigator.pop(context);
            },
            child: const Text('Закрыть'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Статус — подтверждено
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.success.withAlpha(80)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.success.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle, color: AppTheme.success, size: 40),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Водитель принял поездку!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.success),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Выходите к месту отправления',
                    style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Место встречи
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('МЕСТО ВСТРЕЧИ',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textHint, letterSpacing: 1)),
                  const SizedBox(height: 14),
                  // Заглушка карты
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 160,
                      color: const Color(0xFFE8EDF2),
                      child: Stack(
                        children: [
                          // Сетка — имитация карты
                          CustomPaint(
                            size: const Size(double.infinity, 160),
                            painter: _MockMapPainter(),
                          ),
                          // Метка водителя
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(color: AppTheme.primary.withAlpha(80), blurRadius: 8, offset: const Offset(0, 3)),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.directions_car, color: Colors.white, size: 16),
                                      const SizedBox(width: 6),
                                      Text(driver.name,
                                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 10, height: 10,
                                  decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                                ),
                              ],
                            ),
                          ),
                          // Метка пользователя
                          Positioned(
                            bottom: 30, right: 60,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.primary, width: 2),
                              ),
                              child: const Icon(Icons.person, color: AppTheme.primary, size: 14),
                            ),
                          ),
                          // Надпись
                          Positioned(
                            bottom: 8, left: 0, right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(220),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('Макет карты • реальная карта через Google Maps SDK',
                                    style: TextStyle(fontSize: 9, color: AppTheme.textHint)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    const Icon(Icons.location_on, color: AppTheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        trip.startLocation.address,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Данные водителя
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.accent,
                    child: Text(driver.name.substring(0, 1),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(driver.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        Text('${driver.carModel} · ${driver.carPlate}',
                            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  // Кнопка звонка (заглушка)
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primarySurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.phone, color: AppTheme.primary, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  vm.resetBookingState();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check),
                label: const Text('Готово', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Баннер "Забронировано" ────────────────────────────────────────────────────
class _BookedBanner extends StatelessWidget {
  final VoidCallback onDismiss;
  const _BookedBanner({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      color: AppTheme.success,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Поездка успешно забронирована!',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Баннер "Ожидаем водителя" ─────────────────────────────────────────────────
class _DriverAcceptingBanner extends StatelessWidget {
  const _DriverAcceptingBanner();

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      color: AppTheme.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Ожидаем подтверждения водителя...',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Художник заглушки карты ───────────────────────────────────────────────────
class _MockMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD0DAE4)
      ..strokeWidth = 1.2;

    // Горизонтальные линии
    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Вертикальные линии
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Широкие "улицы"
    final road = Paint()..color = const Color(0xFFC4CDD6)..strokeWidth = 5;
    canvas.drawLine(const Offset(0, 80), Offset(size.width, 80), road);
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), road);
  }

  @override
  bool shouldRepaint(_) => false;
}