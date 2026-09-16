import 'package:equatable/equatable.dart';

class IslamicEventEntity extends Equatable {
  final String name;
  final String description;
  final int hijriMonth;
  final int hijriDay;
  final int hijriYear;
  final DateTime gregorian;

  const IslamicEventEntity({
    required this.name,
    required this.description,
    required this.hijriMonth,
    required this.hijriDay,
    required this.hijriYear,
    required this.gregorian,
  });

  @override
  List<Object?> get props => [
    name,
    description,
    hijriMonth,
    hijriDay,
    hijriYear,
    gregorian,
  ];
}
