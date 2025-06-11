class PhotoInfo {
  final String id;
  final String name;
  final String url;

  PhotoInfo({required this.id, required this.name, required this.url});

  factory PhotoInfo.fromJson(Map<String, dynamic> json) {
    return PhotoInfo(id: json['id'], name: json['name'], url: json['url']);
  }
}

class ConversationResponse {
  final String status;
  final String conversationId;
  final String question;
  final String audioUrl;
  final PhotoInfo photoInfo;
  final bool isContinuation;

  ConversationResponse({
    required this.status,
    required this.conversationId,
    required this.question,
    required this.audioUrl,
    required this.photoInfo,
    required this.isContinuation,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    return ConversationResponse(
      status: json['status'],
      conversationId: json['conversation_id'],
      question: json['question'],
      audioUrl: json['audio_url'],
      photoInfo: PhotoInfo.fromJson(json['photo_info']),
      isContinuation: json['is_continuation'],
    );
  }
}
