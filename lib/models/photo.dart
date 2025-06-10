class Photo {
  final String id;
  final String? name;
  final String url;
  final int year;
  final String season;
  final String? description;
  final dynamic summaryText;
  final dynamic summaryVoice;
  final String familyId;
  final String uploadedAt;
  final String? sasUrl;
  Photo({
    required this.id,
    this.name,
    required this.url,
    required this.year,
    required this.season,
    this.description,
    this.summaryText,
    this.summaryVoice,
    required this.familyId,
    required this.uploadedAt,
    this.sasUrl, // ← 추가
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      year: json['year'],
      season: json['season'],
      description: json['description'],
      summaryText: json['summary_text'],
      summaryVoice: json['summary_voice'],
      familyId: json['family_id'],
      uploadedAt: json['uploaded_at'],
      sasUrl: json['sas_url'], // ← 추가
    );
  }
}