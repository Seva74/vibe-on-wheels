import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../viewmodels/trip_view_model.dart';

class MyTripsScreen extends StatelessWidget {
  const MyTripsScreen({super.key});

  static final List<_TripRecord> _mockTrips = [
    _TripRecord(
      from: 'Томск, ул. Ленина, 24',
      to: 'Новосибирск, Красный пр., 53',
      date: DateTime(2026, 3, 10, 9, 0),
      price: 800,
      status: _TripStatus.completed,
      driverName: 'Михаил Иванов',
    ),
    _TripRecord(
      from: 'Томск, пр. Кирова, 14',
      to: 'Кемерово, ул. Весенняя, 18',
      date: DateTime(2026, 3, 5, 13, 30),
      price: 650,
      status: _TripStatus.completed,
      driverName: 'Елена Соколова',
    ),
    _TripRecord(
      from: 'Томск, пр. Ленина, 36',
      to: 'Новосибирск, Академгородок, ул. Терешковой, 12',
      date: DateTime(2026, 2, 28, 8, 0),
      price: 900,
      status: _TripStatus.cancelled,
      driverName: 'Сергей Попов',
    ),
    _TripRecord(
      from: 'Томск, ул. Транспортная, 1',
      to: 'Северск, ул. Ленина, 40',
      date: DateTime(2026, 2, 20, 17, 0),
      price: 250,
      status: _TripStatus.completed,
      driverName: 'Анна Кузнецова',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('Мои поездки')),
      body: Consumer<TripViewModel>(
        builder: (context, vm, _) {
          final confirmedTrips = vm.myTrips.map((trip) {
            final driver = vm.getDriverForTrip(trip.driverId);
            return _TripRecord(
              from: trip.startLocation.address,
              to: trip.endLocation.address,
              date: trip.startTime,
              price: trip.price.toInt(),
              status: _TripStatus.confirmed,
              driverName: driver?.name ?? 'Водитель',
            );
          }).toList();

          final trips = [...confirmedTrips, ..._mockTrips];
          return trips.isEmpty ? _buildEmpty() : _buildList(trips);
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.directions_car_outlined, size: 64, color: AppTheme.textHint),
          SizedBox(height: 16),
          Text(
            'Поездок пока нет',
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<_TripRecord> trips) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _TripCard(trip: trips[i]),
    );
  }
}

class _TripCard extends StatelessWidget {
  final _TripRecord trip;

  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _routeRow(Icons.radio_button_checked, trip.from),
                    const SizedBox(height: 4),
                    _routeRow(Icons.location_on, trip.to),
                  ],
                ),
              ),
              _StatusChip(status: trip.status),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppTheme.divider),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: AppTheme.textHint),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  trip.driverName,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
              ),
              const Icon(Icons.calendar_today, size: 14, color: AppTheme.textHint),
              const SizedBox(width: 6),
              Text(
                _formatDate(trip.date),
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(width: 12),
              Text(
                '${trip.price} ₽',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _routeRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    final hour = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '${d.day}.${d.month.toString().padLeft(2, '0')}.${d.year} $hour:$min';
  }
}

class _StatusChip extends StatelessWidget {
  final _TripStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      _TripStatus.confirmed => ('Подтверждена', AppTheme.primary),
      _TripStatus.completed => ('Завершена', AppTheme.success),
      _TripStatus.cancelled => ('Отменена', AppTheme.error),
      _TripStatus.upcoming => ('Предстоит', AppTheme.primary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _TripRecord {
  final String from;
  final String to;
  final DateTime date;
  final int price;
  final _TripStatus status;
  final String driverName;

  const _TripRecord({
    required this.from,
    required this.to,
    required this.date,
    required this.price,
    required this.status,
    required this.driverName,
  });
}

enum _TripStatus { confirmed, completed, cancelled, upcoming }
