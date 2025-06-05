const user_title = '화목한 우리 가족^~^';

final List<Map<String, dynamic>> user_photo_data = [
  {
    'id': 1,
    'image': 'assets/photos/1.jpg',
    'name': '김빵빵',
    'role': '큰아들',
    'date': '2025년 5월 30일',
    'year': '2025년',
    'season': '봄',
    'description': '낭만아재들의 골프일기',
  },
  {
    'id': 2,
    'image': 'assets/photos/2.png',
    'name': '이땡땡',
    'role': '아들',
    'date': '1981년 여름',
    'year': '1981년',
    'season': '여름',
    'description': '옛날 여름날의 추억',
  },
  {
    'id': 3,
    'image': 'assets/photos/3.png',
    'name': '김땡땡',
    'role': '딸',
    'date': '2025년 5월 25일',
    'year': '2025년',
    'season': '봄',
    'description': '5월의 어느 날 콧수염 아저씨',
  },
  // 추가 사진 데이터...
];

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

// 사용자 가족 관계 구분
enum FamilyRole {
  daughter,
  son,
  grandson,
  granddaughter,
  greatGrandson,
  greatGranddaughter,
  relative,
}

// 한글 표시를 위한 확장
extension FamilyRoleExtension on FamilyRole {
  String get label {
    switch (this) {
      case FamilyRole.daughter:
        return '딸';
      case FamilyRole.son:
        return '아들';
      case FamilyRole.grandson:
        return '손자';
      case FamilyRole.granddaughter:
        return '손녀';
      case FamilyRole.greatGrandson:
        return '증손자';
      case FamilyRole.greatGranddaughter:
        return '증손녀';
      case FamilyRole.relative:
        return '친인척';
    }
  }
}

// 사용자 구분
enum UserType { guardian, elderly }

// 전역 상태로 사용할 변수 (초기엔 null)
UserType? selectedRole;
