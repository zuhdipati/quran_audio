import 'package:equatable/equatable.dart';

class IslamicEventEntity extends Equatable {
  /// Indonesian, as bundled.
  final String name;
  final String description;

  /// English equivalents; empty when none has been written yet.
  final String nameEn;
  final String descriptionEn;

  final int hijriMonth;
  final int hijriDay;
  final int hijriYear;
  final DateTime gregorian;

  const IslamicEventEntity({
    required this.name,
    required this.description,
    this.nameEn = '',
    this.descriptionEn = '',
    required this.hijriMonth,
    required this.hijriDay,
    required this.hijriYear,
    required this.gregorian,
  });

  @override
  List<Object?> get props => [
    name,
    description,
    nameEn,
    descriptionEn,
    hijriMonth,
    hijriDay,
    hijriYear,
    gregorian,
  ];
}
