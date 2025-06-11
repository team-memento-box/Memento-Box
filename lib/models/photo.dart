class Photo {
  final String id;
  final String? name;
  final String url;
  final int year;
  final String season;
  final String? description;
  final String familyId;
  final String uploadedAt;
  final String? sasUrl;
  final Map<String, dynamic>? user;

  Photo({
    required this.id,
    this.name,
    required this.url,
    required this.year,
    required this.season,
    this.description,
    required this.familyId,
    required this.uploadedAt,
    this.sasUrl,
    this.user,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      year: json['year'],
      season: json['season'],
      description: json['description'],
      familyId: json['family_id'],
      uploadedAt: json['uploaded_at'],
      sasUrl: json['sas_url'],
      user: json['user'],
    );
  }

  String get formattedUploadedAt {
    try {
      final date = DateTime.parse(uploadedAt);
      return '${date.year}년 ${date.month.toString().padLeft(2, '0')}월 ${date.day.toString().padLeft(2, '0')}일';
    } catch (e) {
      return uploadedAt; // 파싱 실패 시 원본 반환
    }
  }
}