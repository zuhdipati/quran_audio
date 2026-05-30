class AyahModel {
  final int number;
  final String audio;
  final String text;
  final int numberInSurah;
  final int juz;
  final int manzil;
  final int page;
  final int ruku;
  final int hizbQuarter;
  final bool sajda;

  const AyahModel({
    required this.number,
    required this.audio,
    required this.text,
    required this.numberInSurah,
    required this.juz,
    required this.manzil,
    required this.page,
    required this.ruku,
    required this.hizbQuarter,
    required this.sajda,
  });

  factory AyahModel.fromJson(Map<String, dynamic> json) => AyahModel(
    number: json["number"] ?? 0,
    audio: json["audio"] ?? '',
    text: json["text"] ?? '',
    numberInSurah: json["numberInSurah"] ?? 0,
    juz: json["juz"] ?? 0,
    manzil: json["manzil"] ?? 0,
    page: json["page"] ?? 0,
    ruku: json["ruku"] ?? 0,
    hizbQuarter: json["hizbQuarter"] ?? 0,
    sajda: json["sajda"] is bool ? json["sajda"] : (json["sajda"] != null),
  );

  Map<String, dynamic> toJson() => {
    "number": number,
    "audio": audio,
    "text": text,
    "numberInSurah": numberInSurah,
    "juz": juz,
    "manzil": manzil,
    "page": page,
    "ruku": ruku,
    "hizbQuarter": hizbQuarter,
    "sajda": sajda,
  };
}
