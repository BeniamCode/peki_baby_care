import '../../../data/models/feeding_model.dart';

class FeedingSummary {
  final DateTime date;
  final int totalFeedings;
  final int breastFeedings;
  final int bottleFeedings;
  final int solidFeedings;
  final int totalBreastMinutes;
  final double totalBottleMl;
  final List<FeedingModel> entries;

  FeedingSummary({
    required this.date,
    required this.totalFeedings,
    required this.breastFeedings,
    required this.bottleFeedings,
    required this.solidFeedings,
    required this.totalBreastMinutes,
    required this.totalBottleMl,
    required this.entries,
  });

  factory FeedingSummary.fromEntries(List<FeedingModel> entries, DateTime date) {
    final breastEntries = entries.where((e) => e.type == FeedingType.breast).toList();
    final bottleEntries = entries.where((e) => e.type == FeedingType.bottle).toList();
    final solidEntries = entries.where((e) => e.type == FeedingType.solid).toList();

    final totalBreastMinutes = breastEntries.fold<int>(
      0,
      (sum, entry) => sum + (entry.duration ?? 0),
    );

    final totalBottleMl = bottleEntries.fold<double>(
      0,
      (sum, entry) => sum + (entry.amount ?? 0),
    );

    return FeedingSummary(
      date: date,
      totalFeedings: entries.length,
      breastFeedings: breastEntries.length,
      bottleFeedings: bottleEntries.length,
      solidFeedings: solidEntries.length,
      totalBreastMinutes: totalBreastMinutes,
      totalBottleMl: totalBottleMl,
      entries: entries,
    );
  }
}