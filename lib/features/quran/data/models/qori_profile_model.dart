/// Curated presentation data for a reciter, bundled in
/// `assets/data/qori_profiles.json`.
class QoriProfileModel {
  final String? name;
  final String? photoUrl;
  final bool hidden;

  const QoriProfileModel({this.name, this.photoUrl, this.hidden = false});

  factory QoriProfileModel.fromJson(Map<String, dynamic> json) =>
      QoriProfileModel(
        name: json['name'],
        photoUrl: json['photo'],
        hidden: json['hidden'] ?? false,
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'photo': photoUrl,
    'hidden': hidden,
  };
}
