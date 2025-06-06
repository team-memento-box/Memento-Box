# 프론트엔드 코드
현재 안드로이드만 가능

## 초기 설정
### 백엔드
1. tts vm에 접속
2. /mnt/fastapi-backup-hongwon/fastapi-app 디렉토리 접속
3. `docker-compose up ` 을 통해 컨테이너 실행
### 프론트엔드
1. `git clone`으로 브랜치 클론
2. `flutter pub get` 라이브러리 다운
3. `flutter clean` 캐시파일 삭제
4. `flutter run` 으로 실행
    - `build\app\outputs\apk\debug\app-debug.apk` 파일을 통해 실제 앱 배포 가능
    - usb로 연결해서 테스트 가능

## 주의사항
- **백엔드 서버 열려있어야함**
- **안드로이드 스튜디오 필수**
