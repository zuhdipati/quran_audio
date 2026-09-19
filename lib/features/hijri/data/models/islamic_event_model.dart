class IslamicEventModel {
  final int month;
  final int day;
  final String name;
  final String description;
  final String nameEn;
  final String descriptionEn;

  const IslamicEventModel({
    required this.month,
    required this.day,
    required this.name,
    required this.description,
    this.nameEn = '',
    this.descriptionEn = '',
  });

  factory IslamicEventModel.fromJson(Map<String, dynamic> json) =>
      IslamicEventModel(
        month: json['month'] ?? 1,
        day: json['day'] ?? 1,
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        nameEn: json['nameEn'] ?? '',
        descriptionEn: json['descriptionEn'] ?? '',
      );

  Map<String, dynamic> toJson() => {
    'month': month,
    'day': day,
    'name': name,
    'description': description,
    'nameEn': nameEn,
    'descriptionEn': descriptionEn,
  };
}
