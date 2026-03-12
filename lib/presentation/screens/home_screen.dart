import 'dart:convert';
import 'dart:io';
import 'dart:math' show Point;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../viewmodels/trip_view_model.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onOpenTrips;

  const HomeScreen({super.key, this.onOpenTrips});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const LatLng _defaultCenter = LatLng(56.4977, 84.9744);
  static const double _wheelZoomStep = 0.4;

  bool _onboardingDone = false;
  int _onboardingStep = 0;
  bool _isGeocoding = false;

  final MapController _mapController = MapController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _paymentController = TextEditingController(
    text: 'Наличными',
  );
  final TextEditingController _notesController = TextEditingController();
  final FocusNode _fromFocusNode = FocusNode();
  final FocusNode _toFocusNode = FocusNode();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  int _requestedSeats = 1;

  LatLng? _fromPoint;
  LatLng? _toPoint;

  _LocationInput _activeInput = _LocationInput.from;
  _SearchStep _searchStep = _SearchStep.route;
  int _geocodeToken = 0;

  final List<Map<String, String>> _onboardingSteps = [
    {
      'text':
          'В этом разделе вы сможете искать водителей или попутчиков для ваших поездок',
    },
    {
      'text':
          'В этом разделе вы сможете просматривать поездки и находить рекомендованные вам поездки',
    },
    {
      'text':
          'В этом разделе вы сможете общаться с попутчиками. Оформите поездку и начните чат!',
    },
  ];

  _SheetLayout get _sheetLayout {
    switch (_searchStep) {
      case _SearchStep.route:
        return const _SheetLayout(
          initialSize: 0.38,
          minSize: 0.24,
          maxSize: 0.52,
          snapSizes: [0.24, 0.38, 0.52],
        );
      case _SearchStep.details:
        return const _SheetLayout(
          initialSize: 0.58,
          minSize: 0.42,
          maxSize: 0.84,
          snapSizes: [0.42, 0.58, 0.84],
        );
    }
  }

  @override
  void initState() {
    super.initState();
    _fromFocusNode.addListener(() {
      if (_fromFocusNode.hasFocus) {
        _setActiveInput(_LocationInput.from);
      }
    });
    _toFocusNode.addListener(() {
      if (_toFocusNode.hasFocus) {
        _setActiveInput(_LocationInput.to);
      }
    });
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _paymentController.dispose();
    _notesController.dispose();
    _fromFocusNode.dispose();
    _toFocusNode.dispose();
    _mapController.dispose();
    super.dispose();
  }

  DateTime get _selectedDateTime => DateTime(
    _selectedDate.year,
    _selectedDate.month,
    _selectedDate.day,
    _selectedTime.hour,
    _selectedTime.minute,
  );

  void _setActiveInput(_LocationInput input, {bool requestFocus = false}) {
    if (_activeInput != input) {
      setState(() {
        _activeInput = input;
      });
    }

    if (requestFocus) {
      final focusNode = input == _LocationInput.from
          ? _fromFocusNode
          : _toFocusNode;
      focusNode.requestFocus();
    }
  }

  void _setSearchStep(_SearchStep step) {
    if (_searchStep == step) return;
    setState(() {
      _searchStep = step;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<bool> _searchAddressFor(_LocationInput input) async {
    final controller = input == _LocationInput.from
        ? _fromController
        : _toController;
    final rawQuery = controller.text.trim();

    if (rawQuery.isEmpty) {
      _showSnackBar('Введите адрес для ${_locationLabel(input).toLowerCase()}');
      return false;
    }

    _setActiveInput(input);

    final coordinates = _tryParseCoordinates(rawQuery);
    if (coordinates != null) {
      _setLocationValue(input, coordinates, _formatCoordinates(coordinates));
      _mapController.move(coordinates, 13.5);
      return true;
    }

    final requestId = ++_geocodeToken;
    setState(() {
      _isGeocoding = true;
    });

    final result = await _NominatimApi.search(rawQuery);
    if (!mounted || requestId != _geocodeToken) return false;

    setState(() {
      _isGeocoding = false;
    });

    if (result == null) {
      _showSnackBar('Адрес не найден');
      return false;
    }

    _setLocationValue(input, result.point, result.label);
    _mapController.move(result.point, 13.5);
    return true;
  }

  Future<void> _onMapTap(LatLng point) async {
    FocusScope.of(context).unfocus();

    final input = _activeInput;
    final requestId = ++_geocodeToken;

    setState(() {
      _isGeocoding = true;
      _setPoint(input, point);
    });

    final resolvedAddress = await _NominatimApi.reverse(point);
    if (!mounted || requestId != _geocodeToken) return;

    final label = resolvedAddress == null || resolvedAddress.trim().isEmpty
        ? _formatCoordinates(point)
        : _compactAddress(resolvedAddress);

    setState(() {
      _isGeocoding = false;
      _setPoint(input, point);
      _setControllerText(input, label);
    });
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;

    final camera = _mapController.camera;
    final delta = event.scrollDelta.dy;
    if (delta == 0) return;

    final targetZoom = camera.clampZoom(
      camera.zoom + (delta < 0 ? _wheelZoomStep : -_wheelZoomStep),
    );

    if ((targetZoom - camera.zoom).abs() < 0.001) return;

    final targetCenter = camera.focusedZoomCenter(
      Point<double>(event.localPosition.dx, event.localPosition.dy),
      targetZoom,
    );

    _mapController.move(targetCenter, targetZoom);
  }

  Future<void> _goToDetailsStep() async {
    FocusScope.of(context).unfocus();

    final from = _fromController.text.trim();
    final to = _toController.text.trim();

    if (from.isEmpty || to.isEmpty) {
      _showSnackBar('Заполните поля Откуда и Куда');
      return;
    }

    final fromFound = await _searchAddressFor(_LocationInput.from);
    if (!mounted || !fromFound) return;

    final toFound = await _searchAddressFor(_LocationInput.to);
    if (!mounted || !toFound) return;

    _setSearchStep(_SearchStep.details);
  }

  Future<void> _submitSearch() async {
    FocusScope.of(context).unfocus();

    final from = _fromController.text.trim();
    final to = _toController.text.trim();

    if (from.isEmpty || to.isEmpty) {
      _showSnackBar('Заполните поля Откуда и Куда');
      _setSearchStep(_SearchStep.route);
      return;
    }

    final vm = context.read<TripViewModel>();
    await vm.fetchTrips(from: from, to: to, time: _selectedDateTime);

    if (!mounted) return;
    if (vm.searchState == ViewState.error) {
      _showSnackBar(vm.searchError);
      return;
    }

    widget.onOpenTrips?.call();
  }

  void _swapLocations() {
    FocusScope.of(context).unfocus();

    final fromText = _fromController.text;
    final toText = _toController.text;
    final fromPoint = _fromPoint;
    final toPoint = _toPoint;

    setState(() {
      _fromController.text = toText;
      _toController.text = fromText;
      _fromPoint = toPoint;
      _toPoint = fromPoint;
    });

    if (_fromPoint != null) {
      _mapController.move(_fromPoint!, 13.5);
    }
  }

  void _setLocationValue(_LocationInput input, LatLng point, String label) {
    final compact = _compactAddress(label);
    setState(() {
      _setPoint(input, point);
      _setControllerText(input, compact);
    });
  }

  void _setPoint(_LocationInput input, LatLng point) {
    if (input == _LocationInput.from) {
      _fromPoint = point;
    } else {
      _toPoint = point;
    }
  }

  void _setControllerText(_LocationInput input, String value) {
    final controller = input == _LocationInput.from
        ? _fromController
        : _toController;
    controller.text = value;
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );
  }

  String _locationLabel(_LocationInput input) {
    return input == _LocationInput.from ? 'Откуда' : 'Куда';
  }

  String _compactAddress(String rawAddress) {
    final parts = rawAddress
        .split(',')
        .map((element) => element.trim())
        .where((element) => element.isNotEmpty)
        .toList();

    if (parts.length < 2) return rawAddress.trim();
    return '${parts[0]}, ${parts[1]}';
  }

  LatLng? _tryParseCoordinates(String input) {
    final normalized = input.replaceAll(';', ',').trim();
    final match = RegExp(
      r'^(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)$',
    ).firstMatch(normalized);

    if (match == null) return null;

    final lat = double.tryParse(match.group(1) ?? '');
    final lng = double.tryParse(match.group(2) ?? '');
    if (lat == null || lng == null) return null;
    if (lat.abs() > 90 || lng.abs() > 180) return null;

    return LatLng(lat, lng);
  }

  String _formatCoordinates(LatLng point) {
    return '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
  }

  String _formatDate(DateTime date) {
    final today = DateUtils.dateOnly(DateTime.now());
    final target = DateUtils.dateOnly(date);

    if (target == today) return 'Сегодня';
    if (target == today.add(const Duration(days: 1))) return 'Завтра';

    const months = [
      '',
      'янв',
      'фев',
      'мар',
      'апр',
      'май',
      'июн',
      'июл',
      'авг',
      'сен',
      'окт',
      'ноя',
      'дек',
    ];

    return '${date.day} ${months[date.month]}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final sheetLayout = _sheetLayout;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('Найти попутчика'), centerTitle: true),
      body: Stack(
        children: [
          Positioned.fill(child: _buildMap()),
          if (_onboardingDone)
            DraggableScrollableSheet(
              key: ValueKey(_searchStep),
              initialChildSize: sheetLayout.initialSize,
              minChildSize: sheetLayout.minSize,
              maxChildSize: sheetLayout.maxSize,
              snap: true,
              snapSizes: sheetLayout.snapSizes,
              builder: (context, scrollController) {
                return _buildBottomSheet(scrollController);
              },
            ),
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

  Widget _buildMap() {
    final markers = <Marker>[];

    if (_fromPoint != null) {
      markers.add(
        Marker(
          point: _fromPoint!,
          width: 42,
          height: 42,
          child: const _MapPointMarker(
            color: AppTheme.primary,
            icon: Icons.play_arrow_rounded,
            tooltip: 'Отправление',
          ),
        ),
      );
    }

    if (_toPoint != null) {
      markers.add(
        Marker(
          point: _toPoint!,
          width: 42,
          height: 42,
          child: const _MapPointMarker(
            color: AppTheme.success,
            icon: Icons.flag,
            tooltip: 'Назначение',
          ),
        ),
      );
    }

    return Stack(
      children: [
        Listener(
          onPointerSignal: _handlePointerSignal,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 10.8,
              interactionOptions: const InteractionOptions(
                flags:
                    InteractiveFlag.all &
                    ~InteractiveFlag.rotate &
                    ~InteractiveFlag.scrollWheelZoom,
              ),
              onTap: (_, point) => _onMapTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.vaibnakolesah.app',
              ),
              if (_fromPoint != null && _toPoint != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [_fromPoint!, _toPoint!],
                      color: AppTheme.primary.withAlpha(150),
                      strokeWidth: 4,
                    ),
                  ],
                ),
              MarkerLayer(markers: markers),
            ],
          ),
        ),
        Positioned(
          top: 14,
          left: 14,
          right: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(228),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.touch_app_outlined,
                  size: 16,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Карта ->',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                _MapTargetChip(
                  label: 'Откуда',
                  selected: _activeInput == _LocationInput.from,
                  onTap: () =>
                      _setActiveInput(_LocationInput.from, requestFocus: true),
                ),
                const SizedBox(width: 6),
                _MapTargetChip(
                  label: 'Куда',
                  selected: _activeInput == _LocationInput.to,
                  onTap: () =>
                      _setActiveInput(_LocationInput.to, requestFocus: true),
                ),
                if (_isGeocoding) ...[
                  const Spacer(),
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingSteps.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == _onboardingStep ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: index == _onboardingStep
                      ? AppTheme.primary
                      : AppTheme.divider,
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
                    _onboardingStep < _onboardingSteps.length - 1
                        ? 'Далее'
                        : 'Начать',
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

  Widget _buildBottomSheet(ScrollController scrollController) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: _searchStep == _SearchStep.route
              ? _buildRouteStep()
              : _buildDetailsStep(),
        ),
      ),
    );
  }

  Widget _buildRouteStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _SheetHandle(),
        const SizedBox(height: 10),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Маршрут поездки',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _RouteComposerCard(
          fromController: _fromController,
          toController: _toController,
          fromFocusNode: _fromFocusNode,
          toFocusNode: _toFocusNode,
          activeInput: _activeInput,
          onFromTap: () => _setActiveInput(_LocationInput.from),
          onToTap: () => _setActiveInput(_LocationInput.to),
          onFromSubmit: () => _searchAddressFor(_LocationInput.from),
          onToSubmit: () => _searchAddressFor(_LocationInput.to),
          onSwap: _swapLocations,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isGeocoding ? null : _goToDetailsStep,
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: const Text('Далее'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _SheetHandle(),
        const SizedBox(height: 10),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Детали поездки',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _RouteSummaryCard(
          from: _fromController.text.trim(),
          to: _toController.text.trim(),
          onEdit: () => _setSearchStep(_SearchStep.route),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _TextInputField(
                label: 'Оплата',
                hint: 'Наличные/перевод',
                controller: _paymentController,
                icon: Icons.payments_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SeatsSelector(
                seats: _requestedSeats,
                onAdd: () {
                  if (_requestedSeats >= 6) return;
                  setState(() => _requestedSeats++);
                },
                onRemove: () {
                  if (_requestedSeats <= 1) return;
                  setState(() => _requestedSeats--);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SelectionButton(
                label: 'Дата',
                value: _formatDate(_selectedDate),
                icon: Icons.calendar_today,
                onTap: _pickDate,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SelectionButton(
                label: 'Время',
                value: _formatTime(_selectedTime),
                icon: Icons.access_time,
                onTap: _pickTime,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _TextInputField(
          label: 'Комментарий',
          hint: 'Например: багажа 2 сумки',
          controller: _notesController,
          icon: Icons.comment_outlined,
        ),
        const SizedBox(height: 14),
        Consumer<TripViewModel>(
          builder: (context, vm, _) => Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _setSearchStep(_SearchStep.route),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Назад'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: vm.searchState == ViewState.loading || _isGeocoding
                      ? null
                      : _submitSearch,
                  icon: vm.searchState == ViewState.loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.search, size: 18),
                  label: const Text('Найти поездки'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SheetLayout {
  final double initialSize;
  final double minSize;
  final double maxSize;
  final List<double> snapSizes;

  const _SheetLayout({
    required this.initialSize,
    required this.minSize,
    required this.maxSize,
    required this.snapSizes,
  });
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppTheme.divider,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _RouteComposerCard extends StatelessWidget {
  final TextEditingController fromController;
  final TextEditingController toController;
  final FocusNode fromFocusNode;
  final FocusNode toFocusNode;
  final _LocationInput activeInput;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;
  final Future<bool> Function() onFromSubmit;
  final Future<bool> Function() onToSubmit;
  final VoidCallback onSwap;

  const _RouteComposerCard({
    required this.fromController,
    required this.toController,
    required this.fromFocusNode,
    required this.toFocusNode,
    required this.activeInput,
    required this.onFromTap,
    required this.onToTap,
    required this.onFromSubmit,
    required this.onToSubmit,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              children: [
                _RouteInputRow(
                  controller: fromController,
                  focusNode: fromFocusNode,
                  hint: 'Откуда',
                  icon: Icons.radio_button_checked,
                  active: activeInput == _LocationInput.from,
                  onTap: onFromTap,
                  onSubmit: onFromSubmit,
                ),
                const Divider(height: 1, color: AppTheme.divider),
                _RouteInputRow(
                  controller: toController,
                  focusNode: toFocusNode,
                  hint: 'Куда',
                  icon: Icons.location_on,
                  active: activeInput == _LocationInput.to,
                  onTap: onToTap,
                  onSubmit: onToSubmit,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 32,
            child: IconButton(
              onPressed: onSwap,
              icon: const Icon(Icons.swap_vert, size: 18),
              color: AppTheme.primary,
              padding: EdgeInsets.zero,
              splashRadius: 18,
              visualDensity: VisualDensity.compact,
              tooltip: 'Поменять местами',
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteInputRow extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final Future<bool> Function() onSubmit;

  const _RouteInputRow({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    required this.active,
    required this.onTap,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: active ? AppTheme.primary : AppTheme.textHint,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onTap: onTap,
            onEditingComplete: onSubmit,
            onSubmitted: (_) => onSubmit(),
            textInputAction: TextInputAction.search,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              isDense: true,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        IconButton(
          onPressed: onSubmit,
          icon: const Icon(Icons.travel_explore, size: 17),
          color: AppTheme.primary,
          splashRadius: 18,
          visualDensity: VisualDensity.compact,
          tooltip: 'Показать на карте',
        ),
      ],
    );
  }
}

class _RouteSummaryCard extends StatelessWidget {
  final String from;
  final String to;
  final VoidCallback onEdit;

  const _RouteSummaryCard({
    required this.from,
    required this.to,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accent),
      ),
      child: Row(
        children: [
          const Icon(Icons.alt_route, color: AppTheme.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${from.isEmpty ? 'Не указано' : from} -> ${to.isEmpty ? 'Не указано' : to}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          TextButton(onPressed: onEdit, child: const Text('Изменить')),
        ],
      ),
    );
  }
}

class _TextInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;

  const _TextInputField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textHint,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              Icon(icon, color: AppTheme.textHint, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    filled: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectionButton extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _SelectionButton({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textHint,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
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

class _SeatsSelector extends StatelessWidget {
  final int seats;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _SeatsSelector({
    required this.seats,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Мест',
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textHint,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.remove_circle_outline, size: 19),
                color: AppTheme.primary,
                splashRadius: 18,
              ),
              Expanded(
                child: Text(
                  '$seats',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add_circle_outline, size: 19),
                color: AppTheme.primary,
                splashRadius: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapTargetChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MapTargetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _MapPointMarker extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String tooltip;

  const _MapPointMarker({
    required this.color,
    required this.icon,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

enum _LocationInput { from, to }

enum _SearchStep { route, details }

class _GeocodedPoint {
  final LatLng point;
  final String label;

  const _GeocodedPoint({required this.point, required this.label});
}

class _NominatimApi {
  static const String _baseUrl = 'nominatim.openstreetmap.org';

  static Future<_GeocodedPoint?> search(String query) async {
    final uri = Uri.https(_baseUrl, '/search', {
      'q': query,
      'format': 'json',
      'limit': '1',
      'accept-language': 'ru',
    });

    final data = await _getJsonList(uri);
    if (data == null || data.isEmpty) return null;

    final first = data.first;
    if (first is! Map<String, dynamic>) return null;

    final lat = double.tryParse('${first['lat']}');
    final lon = double.tryParse('${first['lon']}');
    if (lat == null || lon == null) return null;

    final label = (first['display_name'] as String?) ?? query;
    return _GeocodedPoint(point: LatLng(lat, lon), label: label);
  }

  static Future<String?> reverse(LatLng point) async {
    final uri = Uri.https(_baseUrl, '/reverse', {
      'lat': point.latitude.toString(),
      'lon': point.longitude.toString(),
      'format': 'json',
      'accept-language': 'ru',
      'zoom': '17',
    });

    final data = await _getJsonMap(uri);
    if (data == null) return null;

    final name = data['display_name'];
    if (name is! String || name.trim().isEmpty) return null;
    return name;
  }

  static Future<List<dynamic>?> _getJsonList(Uri uri) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.userAgentHeader, 'VaibNaKolesah/1.0');
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) return null;

      final responseBody = await utf8.decodeStream(response);
      final decoded = jsonDecode(responseBody);
      if (decoded is List<dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }

  static Future<Map<String, dynamic>?> _getJsonMap(Uri uri) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.userAgentHeader, 'VaibNaKolesah/1.0');
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) return null;

      final responseBody = await utf8.decodeStream(response);
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }
}
