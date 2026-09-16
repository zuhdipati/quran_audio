class IslamicEventModel {
  final int month;
  final int day;
  final String name;
  final String description;

  const IslamicEventModel({
    required this.month,
    required this.day,
    required this.name,
    required this.description,
  });

  factory IslamicEventModel.fromJson(Map<String, dynamic> json) =>
      IslamicEventModel(
        month: json['month'] ?? 1,
        day: json['day'] ?? 1,
        name: json['name'] ?? '',
        description: json['description'] ?? '',
      );

  Map<String, dynamic> toJson() => {
    'month': month,
    'day': day,
    'name': name,
    'description': description,
  };
}
