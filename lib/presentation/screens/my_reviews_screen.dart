import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  static final List<_ReviewRecord> _mockReviews = [
    _ReviewRecord(
      authorName: 'Михаил Иванов',
      text: 'Отличный попутчик! Ехал спокойно, был пунктуален. Рекомендую.',
      rating: 5,
      date: DateTime(2026, 3, 10),
      isIncoming: true,
    ),
    _ReviewRecord(
      authorName: 'Елена Соколова',
      text: 'Всё хорошо, приятная поездка.',
      rating: 5,
      date: DateTime(2026, 3, 5),
      isIncoming: true,
    ),
    _ReviewRecord(
      authorName: 'Сергей Попов',
      text: 'Водитель опоздал на 15 минут, но в остальном нормально.',
      rating: 3,
      date: DateTime(2026, 2, 28),
      isIncoming: false,
    ),
    _ReviewRecord(
      authorName: 'Анна Кузнецова',
      text: 'Приятный водитель, чисто, комфортно.',
      rating: 5,
      date: DateTime(2026, 2, 20),
      isIncoming: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final incoming = _mockReviews.where((r) => r.isIncoming).toList();
    final outgoing = _mockReviews.where((r) => !r.isIncoming).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(
          title: const Text('Мои отзывы'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Обо мне'),
              Tab(text: 'Мои отзывы'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ReviewsList(reviews: incoming),
            _ReviewsList(reviews: outgoing),
          ],
        ),
      ),
    );
  }
}

class _ReviewsList extends StatelessWidget {
  final List<_ReviewRecord> reviews;

  const _ReviewsList({required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_border, size: 64, color: AppTheme.textHint),
            SizedBox(height: 16),
            Text(
              'Отзывов пока нет',
              style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _ReviewCard(review: reviews[i]),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final _ReviewRecord review;

  const _ReviewCard({required this.review});

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
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.accent,
                child: Text(
                  review.authorName.substring(0, 1),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      _formatDate(review.date),
                      style: const TextStyle(fontSize: 12, color: AppTheme.textHint),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating ? Icons.star : Icons.star_border,
                    size: 14,
                    color: i < review.rating
                        ? const Color(0xFFFFB300)
                        : AppTheme.textHint,
                  ),
                ),
              ),
            ],
          ),
          if (review.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.text,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      '', 'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }
}

class _ReviewRecord {
  final String authorName;
  final String text;
  final int rating;
  final DateTime date;
  final bool isIncoming;

  const _ReviewRecord({
    required this.authorName,
    required this.text,
    required this.rating,
    required this.date,
    required this.isIncoming,
  });
}
