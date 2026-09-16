import 'package:equatable/equatable.dart';

class HijriDateEntity extends Equatable {
  final int day;
  final int month;
  final int year;
  final String monthName;
  final String monthNameArabic;

  const HijriDateEntity({
    required this.day,
    required this.month,
    required this.year,
    required this.monthName,
    required this.monthNameArabic,
  });

  String get formatted => '$day $monthName $year H';

  @override
  List<Object?> get props => [day, month, year, monthName, monthNameArabic];
}
