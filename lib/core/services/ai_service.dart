import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:lovefortune_app/core/models/horoscope_model.dart';
import 'package:lovefortune_app/core/models/special_advice_model.dart';
import 'package:lovefortune_app/core/models/self_discovery_model.dart'; // 자기 발견 모델 import
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lovefortune_app/core/models/personality_report_model.dart';
import 'package:lovefortune_app/core/models/conflict_topic_model.dart';
import 'package:lovefortune_app/core/models/conflict_guide_model.dart';

final logger = Logger();
final aiServiceProvider = Provider((ref) => AIService());

class AIService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<HoroscopeModel> getHoroscope(String userBirth, String partnerBirth) async {
    final prompt = _buildHoroscopePrompt(userBirth, partnerBirth);
    logger.d('Gemini API 오늘의 운세 요청 프롬프트:\n$prompt');

    try {
      logger.i('Gemini API에 오늘의 운세 요청을 보냅니다...');
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}]
        }),
      );
      logger.i('Gemini API 오늘의 운세 응답 수신: Status Code ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logger.d('Gemini API 오늘의 운세 응답 내용:\n$data');
        String content = data['candidates'][0]['content']['parts'][0]['text'];
        content = content.replaceAll('```json', '').replaceAll('```', '').trim();
        final jsonContent = jsonDecode(content);
        return HoroscopeModel.fromJson(jsonContent);
      } else {
        logger.e('Gemini API 오늘의 운세 에러 응답: ${response.statusCode}\n${response.body}');
        throw Exception('AI 서버와 통신하는 데 실패했습니다: ${response.body}');
      }
    } catch (e) {
      logger.e('Gemini API 오늘의 운세 요청 중 예외 발생:', error: e);
      throw Exception('오늘의 운세를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  Future<SpecialAdviceModel> getSpecialAdvice(String userBirth, String partnerBirth) async {
    final prompt = _buildSpecialAdvicePrompt(userBirth, partnerBirth);
    logger.d('Gemini API 스페셜 조언 요청 프롬프트:\n$prompt');

    try {
      logger.i('Gemini API에 스페셜 조언 요청을 보냅니다...');
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}]
        }),
      );
      logger.i('Gemini API 스페셜 조언 응답 수신: Status Code ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logger.d('Gemini API 스페셜 조언 응답 내용:\n$data');
        String content = data['candidates'][0]['content']['parts'][0]['text'];
        content = content.replaceAll('```json', '').replaceAll('```', '').trim();
        final jsonContent = jsonDecode(content);
        return SpecialAdviceModel.fromJson(jsonContent);
      } else {
        logger.e('Gemini API 스페셜 조언 에러 응답: ${response.statusCode}\n${response.body}');
        throw Exception('AI 서버와 통신하는 데 실패했습니다: ${response.body}');
      }
    } catch (e) {
      logger.e('Gemini API 스페셜 조언 요청 중 예외 발생:', error: e);
      throw Exception('스페셜 조언을 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  // 자기 발견 팁을 요청하는 새로운 함수 (추가)
  Future<SelfDiscoveryModel> getSelfDiscoveryTip(String userBirth) async {
    final prompt = _buildSelfDiscoveryPrompt(userBirth);
    logger.d('Gemini API 자기 발견 팁 요청 프롬프트:\n$prompt');

    try {
      logger.i('Gemini API에 자기 발견 팁 요청을 보냅니다...');
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}]
        }),
      );
      logger.i('Gemini API 자기 발견 팁 응답 수신: Status Code ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = data['candidates'][0]['content']['parts'][0]['text'];
        content = content.replaceAll('```json', '').replaceAll('```', '').trim();
        final jsonContent = jsonDecode(content);
        return SelfDiscoveryModel.fromJson(jsonContent);
      } else {
        throw Exception('AI 서버와 통신하는 데 실패했습니다: ${response.body}');
      }
    } catch (e) {
      throw Exception('자기 발견 팁을 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  // 성향 분석 리포트를 요청하는 함수
  Future<PersonalityReportModel> getPersonalityReport(String userBirth, String partnerBirth) async {
    final prompt = _buildPersonalityReportPrompt(userBirth, partnerBirth);
    logger.d('Gemini API 관계 설명서 요청 프롬프트:\n$prompt');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = data['candidates'][0]['content']['parts'][0]['text'];
        content = content.replaceAll('```json', '').replaceAll('```', '').trim();
        final jsonContent = jsonDecode(content);
        return PersonalityReportModel.fromJson(jsonContent);
      } else {
        throw Exception('AI 서버와 통신하는 데 실패했습니다: ${response.body}');
      }
    } catch (e) {
      throw Exception('관계 설명서를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  // 이제 String 대신 ConflictGuideModel을 반환하도록 수정합니다.
  Future<ConflictGuideModel> getConflictGuide(String userBirth, String partnerBirth, String topic) async {
    final prompt = _buildConflictGuidePrompt(userBirth, partnerBirth, topic);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = data['candidates'][0]['content']['parts'][0]['text'];
        content = content.replaceAll('```json', '').replaceAll('```', '').trim();
        final jsonContent = jsonDecode(content);
        return ConflictGuideModel.fromJson(jsonContent);
      } else {
        throw Exception('AI 서버와 통신하는 데 실패했습니다: ${response.body}');
      }
    } catch (e) {
      throw Exception('갈등 해결 가이드를 불러오는 중 오류가 발생했습니다: $e');
    }
  }


  String _buildHoroscopePrompt(String userBirth, String partnerBirth) {
    return """
    ### #1. 역할 (Persona)
    당신은 20~30대 커플들을 위한 앱에서 연애운세를 봐주는, 따뜻하고 지혜로운 연애 카운슬러 '조이'입니다. 사주 명리학과 별자리에 대한 깊은 지식을 현대적인 감각으로 재해석하여, 커플들의 관계를 긍정적으로 이끌어주는 현실적인 조언을 제공합니다. 당신의 조언은 항상 다정하고, 희망적이며, 두 사람 모두에게 힘이 되어야 합니다.

    ### #2. 목표 (Goal)
    입력된 두 사람의 생년월일을 바탕으로, 오늘의 관계 운세를 분석하고, 사용자가 즐겁고 의미 있는 하루를 보낼 수 있도록 돕는 콘텐츠를 아래의 JSON 형식에 맞춰 생성합니다.

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

  String _buildSpecialAdvicePrompt(String userBirth, String partnerBirth) {
    return """
    ### #1. 역할 (Persona)
    당신은 두 사람의 관계를 깊이 통찰하는 지혜로운 운명 분석가 '스텔라'입니다. 사주와 별자리를 현대적으로 분석하여, 다른 곳에서는 볼 수 없는 특별하고 구체적인 비밀 정보를 제공합니다.

    ### #2. 목표 (Goal)
    입력된 두 사람의 생년월일을 바탕으로, '우리 둘만의 비밀 코드'와 '미래를 살짝 엿보는 타임머신'이라는 두 가지 테마의 스페셜 조언을 생성하여 아래의 JSON 형식에 맞춰 출력합니다.

    ### #3. 지침 (Instructions)
    1.  **synergy_point:** 오늘의 에너지 흐름을 분석하여, 두 사람의 시너지가 폭발할 구체적인 시간대(예: 오후 2시 ~ 4시)와 함께하면 좋은 활동을 제안해주세요.
    2.  **conflict_warning:** 오늘 두 사람 사이에 발생할 수 있는 구체적인 갈등 주제(예: 금전 문제, 약속 시간)를 예측하고, 현명하게 피할 수 있는 방법을 알려주세요.
    3.  **weekend_forecast:** 다가오는 주말의 애정운을 간략하게 예보해주세요. 긍정적이고 기대감을 주는 내용이어야 합니다.
    4.  **monthly_lucky_day:** 다음 달, 두 사람의 관계에 특히 중요한 행운의 날짜를 하나만 짚어주세요.

    ### #4. 제약 조건 (Constraints)
    - 모든 답변은 구체적이고 흥미로워야 합니다.
    - 긍정적이고 희망적인 톤을 유지해주세요.
    - 반드시 지정된 JSON 형식으로만 출력해야 합니다.

    ### #5. 최종 요청 (Final Request)
    이제 아래의 실제 입력 정보를 바탕으로, 위의 모든 규칙을 준수하여 JSON 형식의 스페셜 조언 콘텐츠만 생성해주세요. 다른 설명이나 Markdown 형식 없이 순수한 JSON 객체만 반환해야 합니다.

    [입력]
    - 사용자 생년월일: $userBirth
    - 파트너 생년월일: $partnerBirth
    """;
  }

  // 자기 발견 팁 생성을 위한 새로운 프롬프트 (추가)
  String _buildSelfDiscoveryPrompt(String userBirth) {
    return """
    ### #1. 역할 (Persona)
    당신은 사주 명리학을 기반으로 개인의 성장을 돕는 현명한 라이프 코치입니다. 사용자의 타고난 기운을 분석하여, 오늘 하루 자신을 더 깊이 이해하고 발전시킬 수 있는 통찰력 있는 조언을 제공합니다.

    ### #2. 목표 (Goal)
    입력된 사용자의 생년월일을 바탕으로, '오늘의 나'를 위한 자기 발견 콘텐츠를 아래의 JSON 형식에 맞춰 생성합니다.

    ### #3. 지침 (Instructions)
    1.  **daily_theme:** 오늘 사용자의 에너지에 가장 어울리는 키워드를 한 단어로 제시해주세요. (예: "성찰", "도전", "소통", "휴식")
    2.  **growth_tip:** 오늘의 테마와 관련하여, 사용자가 실천할 수 있는 구체적이고 긍정적인 자기 성장 팁을 한 문장으로 제안해주세요.
    3.  **reflective_question:** 하루 동안 스스로에게 던져볼 만한 깊이 있는 질문을 한 가지 만들어주세요.

    ### #4. 제약 조건 (Constraints)
    - 모든 답변은 개인의 성장에 초점을 맞춰야 합니다.
    - 긍정적이고 영감을 주는 톤을 유지해주세요.
    - 반드시 지정된 JSON 형식으로만 출력해야 합니다.

    ### #5. 최종 요청 (Final Request)
    이제 아래의 실제 입력 정보를 바탕으로, 위의 모든 규칙을 준수하여 JSON 형식의 자기 발견 팁 콘텐츠만 생성해주세요.

    [입력]
    - 사용자 생년월일: $userBirth
    """;
  }

  String _buildPersonalityReportPrompt(String userBirth, String partnerBirth) {
    return """
    ### #1. 역할 (Persona)
    당신은 사주 명리학과 현대 심리학을 결합하여 커플 관계를 분석하는 전문 카운슬러입니다.

    ### #2. 목표 (Goal)
    입력된 두 사람의 생년월일을 바탕으로, 각자의 타고난 성향과 두 사람의 관계 시너지, 그리고 주의할 점을 분석하여 아래 JSON 형식에 맞춰 심층적인 리포트를 작성합니다.

    ### #3. 지침 (Instructions)
    1.  **my_personality_title / partner_personality_title:** 각 사람의 핵심 성향을 나타내는 창의적이고 매력적인 제목을 지어주세요. (예: "따뜻한 불꽃같은 열정가", "고요한 숲을 닮은 현자")
    2.  **my_personality_description / partner_personality_description:** 각 사람의 성격, 장점, 그리고 연애 스타일을 2~3문장으로 구체적으로 설명해주세요.
    3.  **relationship_synergy:** 두 사람이 함께일 때 발휘되는 가장 큰 긍정적인 시너지 효과를 설명해주세요.
    4.  **relationship_caution:** 두 사람이 관계를 더 발전시키기 위해 서로 조심하거나 이해해야 할 부분을 조언해주세요.

    ### #4. 제약 조건 (Constraints)
    - 모든 답변은 긍정적이고 건설적인 관점에서 작성해야 합니다.
    - 반드시 지정된 JSON 형식으로만 출력해야 합니다.

    ### #5. 최종 요청 (Final Request)
    [입력]
    - 사용자 생년월일: $userBirth
    - 파트너 생년월일: $partnerBirth
    """;
  }

  // 프롬프트를 구조화된 JSON을 요청하도록 수정합니다.
  String _buildConflictGuidePrompt(String userBirth, String partnerBirth, String topic) {
    return """
    ### #1. 역할 (Persona)
    당신은 사주 명리학과 현대 심리학을 결합하여 커플의 갈등을 해결하는 전문 상담가입니다.

    ### #2. 목표 (Goal)
    입력된 정보들을 바탕으로, 주어진 갈등 상황에 대한 심층 분석 리포트를 아래 JSON 형식에 맞춰 생성합니다.

    ### #3. 지침 (Instructions)
    1.  **analysis_for_me:** 갈등 상황에서 '나'는 어떤 성향 때문에 어떻게 행동할 가능성이 높은지 1~2문장으로 분석해주세요.
    2.  **analysis_for_partner:** 갈등 상황에서 '상대방'은 어떤 성향 때문에 어떻게 행동할 가능성이 높은지 1~2문장으로 분석해주세요.
    3.  **solution_proposal:** 두 사람의 성향을 모두 고려하여, 이 갈등을 해결할 수 있는 구체적이고 현실적인 해결책을 제안해주세요.
    4.  **dialogue_example:** 해결책을 바탕으로, 실제 대화에서 사용할 수 있는 부드러운 톤의 대화 예시를 한두 문장 작성해주세요.

    ### #4. 제약 조건 (Constraints)
    - 긍정적이고 건설적인 해결책을 제시해야 합니다.
    - 반드시 지정된 JSON 형식으로만 출력해야 합니다.

    ### #5. 최종 요청 (Final Request)
    [사용자 생년월일]: $userBirth
    [파트너 생년월일]: $partnerBirth
    [갈등 주제]: $topic
    """;
  }
}
