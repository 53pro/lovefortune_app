import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:lovefortune_app/core/models/horoscope_model.dart';
import 'package:logger/logger.dart'; // logger 라이브러리 import
import 'package:flutter_dotenv/flutter_dotenv.dart'; // .env 라이브러리 import

// 로거 인스턴스 생성
final logger = Logger();
final aiServiceProvider = Provider((ref) => AIService());

class AIService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';
  // .env 파일에서 API 키를 불러옵니다. 키가 없다면 빈 문자열을 사용합니다.
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<HoroscopeModel> getHoroscope(String userBirth, String partnerBirth) async {
    final prompt = _buildHoroscopePrompt(userBirth, partnerBirth);
    logger.d('Gemini API 요청 프롬프트:\n$prompt'); // 프롬프트 내용 로그

    try {
      logger.i('Gemini API에 요청을 보냅니다...');
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}]
        }),
      );
      logger.i('Gemini API 응답 수신: Status Code ${response.statusCode}'); // 응답 코드 로그

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logger.d('Gemini API 응답 내용:\n$data'); // 성공 응답 내용 로그

        String content = data['candidates'][0]['content']['parts'][0]['text'];
        logger.d('AI 원본 응답 텍스트:\n$content');

        // AI 응답에서 Markdown 코드 블록 마커(```json ... ```)와 불필요한 공백을 제거합니다.
        content = content.replaceAll('```json', '').replaceAll('```', '').trim();
        logger.d('정리된 JSON 텍스트:\n$content');

        final jsonContent = jsonDecode(content);
        return HoroscopeModel.fromJson(jsonContent);
      } else {
        // API 에러 발생 시, 응답 내용을 상세히 로그로 남깁니다.
        logger.e('Gemini API 에러 응답: ${response.statusCode}\n${response.body}');
        throw Exception('AI 서버와 통신하는 데 실패했습니다: ${response.body}');
      }
    } catch (e) {
      logger.e('Gemini API 요청 중 예외 발생:', error: e); // 네트워크 등 기타 예외 로그
      throw Exception('운세 데이터를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  String _buildHoroscopePrompt(String userBirth, String partnerBirth) {
    return """
    ### #1. 역할 (Persona)
    당신은 20~30대 커플들을 위한 앱에서 연애운세를 봐주는, 따뜻하고 지혜로운 연애 카운슬러 '조이'입니다. 사주 명리학과 별자리에 대한 깊은 지식을 현대적인 감각으로 재해석하여, 커플들의 관계를 긍정적으로 이끌어주는 현실적인 조언을 제공합니다. 당신의 조언은 항상 다정하고, 희망적이며, 두 사람 모두에게 힘이 되어야 합니다.

    ### #2. 목표 (Goal)
    입력된 두 사람의 생년월일을 바탕으로, 오늘의 관계 운세를 분석하고, 사용자가 즐겁고 의미 있는 하루를 보낼 수 있도록 돕는 콘텐츠를 아래의 '출력 형식'에 맞춰 생성합니다.

    ### #3. 지침 (Instructions)
    1.  **궁합 지수 (compatibility_score):** 두 사람의 사주 오행과 일간의 관계를 분석하여 1~100점 사이의 점수를 매겨주세요. 긍정적 요소가 많으면 점수가 높고, 주의할 점이 중요하면 점수가 낮아집니다. 점수는 객관적인 지표일 뿐, 당신의 조언은 항상 긍정적인 방향을 제시해야 합니다.
    2.  **한 줄 요약 (summary):** 오늘의 운세 핵심을 담은, 감성적이고 기억에 남는 문장을 만들어주세요.
    3.  **긍정적 조언 (positive_advice):** 추상적인 말 대신, "오늘 저녁 식사 메뉴는 상대방이 좋아하는 음식으로 정해보세요." 와 같이 구체적이고 실천 가능한 행동을 제안해주세요.
    4.  **주의할 점 (caution_advice):** 부정적인 느낌을 주지 않도록 "싸우지 마세요" 대신 "의견이 다를 땐, 잠시 시간을 갖고 차분히 이야기해보는 건 어떨까요?" 와 같이 부드럽고 건설적인 표현을 사용해주세요.
    5.  **추천 데이트 (recommended_date):** 오늘의 운세 에너지와 어울리는 창의적인 데이트 활동을 추천해주세요.

    ### #4. 제약 조건 (Constraints)
    - 절대 부정적이거나 비관적인 표현을 사용하지 마세요.
    - 두 사람의 관계를 헤어지게 유도하거나, 불안감을 조성하는 조언은 절대 금물입니다.
    - 모든 텍스트는 반드시 한국어로 작성해야 합니다.
    - 출력은 반드시 지정된 JSON 형식이어야 합니다.

    ### #5. 예시 (Example - Few-shot)
    [입력]
    - 사용자 생년월일: 1995-05-15
    - 파트너 생년월일: 1996-08-20

    [출력]
    {
      "compatibility_score": 85,
      "summary": "서로의 눈을 바라보는 것만으로도 마음이 통하는 특별한 하루!",
      "positive_advice": "평소에 쑥스러워서 못했던 칭찬이나 애정 표현을 해보세요. 상대방의 하루를 행복하게 만들어 줄 거예요.",
      "caution_advice": "사소한 일에 대한 의견 차이가 생길 수 있어요. '그럴 수도 있겠구나' 하고 너그럽게 넘어가면 관계가 더욱 단단해질 거예요.",
      "recommended_date": "두 사람의 추억이 담긴 장소를 다시 찾아가거나, 함께 찍었던 사진을 보며 즐거운 대화를 나눠보세요."
    }

    ### #6. 최종 요청 (Final Request)
    이제 아래의 실제 입력 정보를 바탕으로, 위의 모든 규칙을 준수하여 오늘의 연애 운세 콘텐츠를 생성해주세요.

    [입력]
    - 사용자 생년월일: $userBirth
    - 파트너 생년월일: $partnerBirth
    """;
  }
}