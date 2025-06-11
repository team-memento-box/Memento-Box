import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/tap_widget.dart';
import '../user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/group_bar_widget.dart';
import '../utils/styles.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

class AddPhotoScreen extends StatefulWidget {
  const AddPhotoScreen({super.key});

  @override
  State<AddPhotoScreen> createState() => _AddPhotoScreenState();
}

class _AddPhotoScreenState extends State<AddPhotoScreen> {
  final List<String> years = ['2023', '2024', '2025', '2026', '2027'];
  final List<String> seasons = ['봄', '여름', '가을', '겨울'];

  int selectedYearIndex = 2;
  int selectedSeasonIndex = 1;

  File? _selectedImage;
  final TextEditingController _descController = TextEditingController();

  bool get isAllFilled {
    return _selectedImage != null && _descController.text.trim().isNotEmpty;
  }

  String getSeasonEng(String korean) {
    switch (korean) {
      case '봄':
        return 'spring';
      case '여름':
        return 'summer';
      case '가을':
        return 'autumn';
      case '겨울':
        return 'winter';
      default:
        return '';
    }
  }

  void _showYearSeasonPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor:const Color.fromARGB(230, 255, 255, 255),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '연도 계절 선택',
                    style: maxContentStyle.copyWith(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(
                height: 240,
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedYearIndex,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedYearIndex = index;
                          });
                        },
                        children: years
                            .map((y) => Center(
                                  child: Text(
                                    y,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedSeasonIndex,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedSeasonIndex = index;
                          });
                        },
                        children: seasons
                            .map((s) => Center(
                                  child: Text(
                                    s,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  // Future<String?> _fetchAccessToken(String kakaoId) async {
  //   final baseUrl = dotenv.env['BASE_URL']!;
  //   final url = Uri.parse('$baseUrl/auth/token');
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/x-www-form-urlencoded',
  //     },
  //     body: {
  //       'username': kakaoId,
  //       'password': 'test1234',
  //       'grant_type': 'password',
  //     },
  //   );
  //   print('🔑 [Token Request] status: \\${response.statusCode}');
  //   print('🔑 [Token Request] body: \\${response.body}');
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     print('🔑 [Token Request] access_token: \\${data['access_token']}');
  //     return data['access_token'];
  //   } else {
  //     print('❌ [Token Request] Failed to get token');
  //     return null;
  //   }
  // }

  Future<void> _uploadPhoto(String accessToken) async {
    final year = int.parse(years[selectedYearIndex]);
    final season = getSeasonEng(seasons[selectedSeasonIndex]);
    final description = _descController.text.trim();
    final baseUrl = dotenv.env['BASE_URL']!;
    final uri = Uri.parse('$baseUrl/api/photos/upload');
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $accessToken';

    // 파일 확장자에 따라 contentType 지정
    String filePath = _selectedImage!.path;
    String ext = path.extension(filePath).toLowerCase();
    MediaType? mediaType;
    if (ext == '.jpg' || ext == '.jpeg') {
      mediaType = MediaType('image', 'jpeg');
    } else if (ext == '.png') {
      mediaType = MediaType('image', 'png');
    } else if (ext == '.gif') {
      mediaType = MediaType('image', 'gif');
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: mediaType,
      ),
    );
    request.fields['year'] = year.toString();
    request.fields['season'] = season;
    request.fields['description'] = description;
    // Request 내용 출력
    print('📤 Upload Request:');
    print('URL: \\${request.url}');
    print('Headers: \\${request.headers}');
    print('Fields: \\${request.fields}');
    print('Files: \\${request.files.map((f) => f.filename).toList()}');
    print('Description: \\${request.fields['description']}');

    var response = await request.send();
    print('📤 Upload Response:');
    print('Status: \\${response.statusCode}');
    print('Body: \\${await response.stream.bytesToString()}');
    
    if (response.statusCode == 200) {
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진 업로드 성공!')),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업로드 실패: \\${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String selectedText = '${years[selectedYearIndex]} ${seasons[selectedSeasonIndex]}';

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: GroupBar(
          title: Provider.of<UserProvider>(context, listen: false).familyName ?? '우리 가족',
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 연도/계절 선택
                GestureDetector(
                  onTap: _showYearSeasonPicker,
                  child: Row(
                    children: [
                      Text(
                        selectedText,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.arrow_forward_ios_rounded),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 사진 업로드 박스
                // 사진 업로드 박스
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    border: _selectedImage == null ? Border.all( // _selectedImage가 null일 때만 border 표시
                      color: const Color(0xFF00C8B8),
                      width: 3,
                    ) : null,
                    borderRadius: BorderRadius.circular(20),
                    color: _selectedImage == null ? const Color(0x1900C8B8) : null, // _selectedImage가 null일 때만 배경색 표시
                  ),
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: _selectedImage == null
                        ? Column( // _selectedImage가 null일 때만 Column 표시
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/icons/Add_fill.png',
                                width: 50,
                                height: 50,
                                color: const Color(0xFF00C8B8),
                                colorBlendMode: BlendMode.srcIn,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                '사진을 추가해주세요',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF00C8B8),
                                ),
                              ),
                            ],
                          )
                        : ClipRRect( // _selectedImage가 있을 때는 사진만 표시
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 250,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
                // 사진 설명 입력 영역
                const Text(
                  '사진 설명',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descController,
                  maxLines: 3,
                  maxLength: 100,
                  style: smallContentStyle.copyWith(color: Color(0xFF333333)),
                  decoration: InputDecoration(
                    hintText: '사진에 대해 설명하는 글을 간단하게 작성해주세요.',
                    hintStyle: smallContentStyle.copyWith(
                      color: Color(0xFF777777),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0x66999999)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0x66999999)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 사진 추가 버튼
                Center(
                  child: ElevatedButton(
                    onPressed: isAllFilled
                        ? () async {
                            final userProvider = Provider.of<UserProvider>(context, listen: false);
                            final accessToken = userProvider.accessToken;
                            if (accessToken != null && accessToken.isNotEmpty) {
                              await _uploadPhoto(accessToken);
                            } else {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('로그인에 실패했습니다.')),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAllFilled
                          ? const Color(0xFF00C8B8)
                          : const Color(0xFFDFF3F2),
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      '사진 추가하기',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Pretendard',
                        letterSpacing: 1,
                        color: isAllFilled ? Colors.white : const Color(0xFF888888),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      ),
    );
  }
}