// 사용자 전체 앱 제목
const user_title = '화목한 우리 가족^~^';

/// 회상 대화 데이터 모델 리스트
/// 각 사진당 1개의 대화가 저장됨
/// assistantText: 챗봇이 서버에서 받아온 질문
/// userSpeechText: 사용자가 말한 응답 (STT 결과)
/// photoPath: 표시되는 사진 경로
final List<PhotoConversation> photoConversations = [
  PhotoConversation(
    assistantText: '이날 바닷바람을 맞으며 어떤 기분이 드셨나요?',
    userSpeechText: '콧수염에 따뜻한 바람이 느껴졌지.',
    photoPath: 'assets/photos/3.png',
  ),
  // 필요하면 여러 대화를 이어 붙일 수 있음
];

/// 하나의 회상 대화에 대한 정보를 담는 데이터 모델 클래스
class PhotoConversation {
  final String assistantText; // LLM이 제공한 질문
  final String userSpeechText; // 사용자의 음성 응답 (STT 결과)
  final String photoPath; // 이미지 경로

  const PhotoConversation({
    required this.assistantText,
    required this.userSpeechText,
    required this.photoPath,
  });
}
