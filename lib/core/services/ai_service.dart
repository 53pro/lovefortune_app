import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:lovefortune_app/core/models/horoscope_model.dart';
import 'package:lovefortune_app/core/models/special_advice_model.dart';
import 'package:lovefortune_app/core/models/self_discovery_model.dart';
import 'package:lovefortune_app/core/models/personality_report_model.dart';
import 'package:lovefortune_app/core/models/conflict_guide_model.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final logger = Logger();
final aiServiceProvider = Provider((ref) => AIService());

class AIService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  // 공통 API 호출 로직을 만들어 코드를 재사용합니다.
  Future<Map<String, dynamic>> _callApi(String prompt) async {
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
      return jsonDecode(content);
    } else {
      logger.e('Gemini API 에러 응답: ${response.statusCode}\n${response.body}');
      throw Exception('AI 서버와 통신하는 데 실패했습니다.');
    }
  }

  // --- 점진적 로딩을 위한 함수들 (추가) ---
  Future<Map<String, dynamic>> getCompatibilityScore(String userBirth, String partnerBirth) async {
    final prompt = "두 사람의 생년월일($userBirth, $partnerBirth)을 바탕으로, 오늘의 궁합 지수(compatibility_score)와 한 줄 요약(summary)을 JSON 형식으로 생성해줘.";
    return await _callApi(prompt);
  }

  Future<Map<String, dynamic>> getDetailedAdvice(String userBirth, String partnerBirth) async {
    final prompt = "두 사람의 생년월일($userBirth, $partnerBirth)을 바탕으로, 오늘의 긍정적인 조언(positive_advice)과 주의할 점(caution_advice)을 JSON 형식으로 생성해줘.";
    return await _callApi(prompt);
  }

  Future<Map<String, dynamic>> getDateRecommendation(String userBirth, String partnerBirth) async {
    final prompt = "두 사람의 생년월일($userBirth, $partnerBirth)을 바탕으로, 오늘의 추천 데이트(recommended_date)를 JSON 형식으로 생성해줘.";
    return await _callApi(prompt);
  }

  // --- 기존의 전체 운세 요청 함수 (캐싱용) ---
  Future<HoroscopeModel> getHoroscope(String userBirth, String partnerBirth) async {
    final prompt = _buildHoroscopePrompt(userBirth, partnerBirth);
    final jsonContent = await _callApi(prompt);
    return HoroscopeModel.fromJson(jsonContent);
  }

  // --- 스페셜 조언 ---
  Future<SpecialAdviceModel> getSpecialAdvice(String userBirth, String partnerBirth) async {
    final prompt = _buildSpecialAdvicePrompt(userBirth, partnerBirth);
    final jsonContent = await _callApi(prompt);
    return SpecialAdviceModel.fromJson(jsonContent);
  }

  // --- 자기 발견 팁 ---
  Future<SelfDiscoveryModel> getSelfDiscoveryTip(String userBirth) async {
    final prompt = _buildSelfDiscoveryPrompt(userBirth);
    final jsonContent = await _callApi(prompt);
    return SelfDiscoveryModel.fromJson(jsonContent);
  }

  // --- 관계 설명서 ---
  Future<PersonalityReportModel> getPersonalityReport(String userBirth, String partnerBirth) async {
    final prompt = _buildPersonalityReportPrompt(userBirth, partnerBirth);
    final jsonContent = await _callApi(prompt);
    return PersonalityReportModel.fromJson(jsonContent);
  }

  // --- 갈등 해결 가이드 ---
  Future<ConflictGuideModel> getConflictGuide(String userBirth, String partnerBirth, String topic) async {
    final prompt = _buildConflictGuidePrompt(userBirth, partnerBirth, topic);
    final jsonContent = await _callApi(prompt);
    return ConflictGuideModel.fromJson(jsonContent);
  }

  // 오늘의 질문을 요청하는 새로운 함수 (추가)
  Future<String> getTodaysQuestion(String userBirth, String partnerBirth) async {
    final prompt = _buildTodaysQuestionPrompt(userBirth, partnerBirth);
    final jsonContent = await _callApi(prompt);
    return jsonContent['todays_question'] as String? ?? '서로의 첫인상에 대해 이야기해보세요.';
  }

  // 오늘의 갈등 해결 주제 생성 API
  Future<List<Map<String, dynamic>>> getTodaysConflictTopics(String userBirth, String partnerBirth) async {
    final prompt = _buildConflictTopicsPrompt(userBirth, partnerBirth);
    final jsonContent = await _callApi(prompt);
    final List<dynamic> topicsJson = jsonContent['topics'] as List<dynamic>? ?? [];
    return topicsJson.map((t) => Map<String, dynamic>.from(t)).toList();
  }

  // 추가적인 갈등 해결 주제 생성 API
  Future<Map<String, dynamic>> getAdditionalConflictTopic(String userBirth, String partnerBirth, List<String> existingTopics) async {
    final prompt = _buildAdditionalConflictTopicPrompt(userBirth, partnerBirth, existingTopics);
    final jsonContent = await _callApi(prompt);
    return Map<String, dynamic>.from(jsonContent);
  }

  // --- 각 기능별 프롬프트 생성 함수들 ---

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

  // 스페셜 조언 프롬프트를 더 명확하고 엄격하게 수정합니다.
  // 스페셜 조언 프롬프트를 영어 키를 사용하도록 수정합니다.
  String _buildSpecialAdvicePrompt(String userBirth, String partnerBirth) {
    return """
    ### #1. 역할 (Persona)
    당신은 두 사람의 관계를 깊이 통찰하는 지혜로운 운명 분석가 '스텔라'입니다. 사주와 별자리를 현대적으로 분석하여, 다른 곳에서는 볼 수 없는 특별하고 구체적인 비밀 정보를 제공합니다.

    ### #2. 목표 (Goal)
    입력된 두 사람의 생년월일을 바탕으로, '우리 둘만의 비밀 코드'와 '미래를 살짝 엿보는 타임머신'이라는 두 가지 테마의 스페셜 조언을 생성하여 아래의 JSON 형식에 맞춰 출력합니다.

    ### #3. 지침 (Instructions)
    1.  **synergy_point:** 오늘의 에너지 흐름을 분석하여, 두 사람의 시너지가 폭발할 구체적인 시간대와 함께하면 좋은 활동을 하나의 문장으로 합쳐서 제안해주세요.
    2.  **conflict_warning:** 오늘 두 사람 사이에 발생할 수 있는 구체적인 갈등 주제와 현명하게 피할 수 있는 방법을 하나의 문장으로 합쳐서 알려주세요.
    3.  **weekend_forecast:** 다가오는 주말의 애정운을 간략하게 한 문장으로 예보해주세요.
    4.  **monthly_lucky_day:** 다음 달, 두 사람의 관계에 특히 중요한 행운의 날짜를 하나의 문장으로 짚어주세요.

    ### #4. 제약 조건 (Constraints)
    - 모든 답변은 구체적이고 흥미로워야 합니다.
    - 긍정적이고 희망적인 톤을 유지해주세요.
    - **반드시 지정된 JSON 형식으로만 출력해야 하며, 모든 키(key)는 반드시 영어(secret_code, future_peek 등)로 작성해야 합니다.**

    ### #5. JSON 출력 형식 예시 (Example)
    {
      "secret_code": {
        "synergy_point": "...",
        "conflict_warning": "..."
      },
      "future_peek": {
        "weekend_forecast": "...",
        "monthly_lucky_day": "..."
      }
    }

    ### #6. 최종 요청 (Final Request)
    이제 아래의 실제 입력 정보를 바탕으로, 위의 모든 규칙을 준수하여 JSON 형식의 스페셜 조언 콘텐츠만 생성해주세요.

    [입력]
    - 사용자 생년월일: $userBirth
    - 파트너 생년월일: $partnerBirth
    """;
  }
  String _buildSelfDiscoveryPrompt(String userBirth) {
    return """
    ### #1. 역할 (Persona)
    당신은 사주 명리학을 기반으로 개인의 성장을 돕는 현명한 라이프 코치입니다. 사용자의 타고난 기운을 분석하여, 오늘 하루 자신을 더 깊이 이해하고 발전시킬 수 있는 통찰력 있고 구체적인 조언을 제공합니다.

    ### #2. 목표 (Goal)
    입력된 사용자의 생년월일을 바탕으로, '오늘의 나'를 위한 구체적이고 깊이 있는 자기 발견 콘텐츠를 아래의 JSON 형식에 맞춰 생성합니다.

    ### #3. 지침 (Instructions)
    1.  **daily_theme:** 오늘 사용자의 에너지에 가장 어울리는 핵심 키워드를 한 단어로 제시해주세요. (예: "성찰", "도전", "소통", "휴식")
    2.  **detailed_analysis:** 사용자의 타고난 성향과 오늘의 기운을 바탕으로, 왜 오늘 이 테마가 중요한지 2~3문장으로 심층 분석해주세요.
    3.  **growth_tip:** 오늘의 테마와 관련하여, 사용자가 실천할 수 있는 긍정적인 자기 성장 팁을 한 문장으로 제안해주세요.
    4.  **actionable_steps:** 'growth_tip'을 바로 행동으로 옮길 수 있는 구체적인 실천 가이드를 2~3단계의 리스트(배열)로 제시해주세요. (예: ["아침에 일어나서 물 한 잔 마시기", "5분간 명상하기"])
    5.  **recommended_habit:** 오늘 하루 실천해보면 좋을 작고 구체적인 습관을 하나 제안해주세요.
    6.  **reflective_question:** 하루 동안 스스로에게 던져볼 만한 깊이 있는 질문을 한 가지 만들어주세요.

    ### #4. 제약 조건 (Constraints)
    - 모든 답변은 개인의 구체적인 행동 변화와 긍정적인 성장에 초점을 맞춰야 합니다.
    - 너무 추상적인 말보다는, 현실에서 바로 적용할 수 있는 구체적인 내용을 포함하세요.
    - 반드시 지정된 JSON 형식으로만 출력해야 합니다.

    ### #5. JSON 출력 형식 예시 (Example)
    {
      "daily_theme": "...",
      "detailed_analysis": "...",
      "growth_tip": "...",
      "actionable_steps": ["...", "..."],
      "recommended_habit": "...",
      "reflective_question": "..."
    }

    ### #6. 최종 요청 (Final Request)
    이제 아래의 실제 입력 정보를 바탕으로, 위의 모든 규칙을 준수하여 JSON 형식의 자기 발견 팁 콘텐츠만 생성해주세요.

    [입력]
    - 사용자 생년월일: \$userBirth
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
  // 오늘의 질문 생성을 위한 새로운 프롬프트
  String _buildTodaysQuestionPrompt(String userBirth, String partnerBirth) {
    return """
    ### #1. 역할 (Persona)
    당신은 커플 관계 분석가이자 사주 명리학 지식을 활용하는 센스 있는 대화 상담사입니다.

    ### #2. 목표 (Goal)
    입력된 두 사람의 생년월일($userBirth, $partnerBirth) 사주 정보를 바탕으로, 오늘 두 사람이 함께 나누면 좋을 흥미진진한 대화 주제를 **자극적이고 호기심을 유발하는 딱 한 문장의 짧은 질문**으로 생성하여 아래 JSON 형식에 맞춰 출력합니다.

    ### #3. 지침 (Instructions)
    - 질문은 연인끼리 서로에게 편하게 물어볼 수 있는 친근하고 다정한 반말 구어체 형식이어야 합니다.
    - 문장은 여러 문장으로 이어지지 않는 **짧은 단 한 문장(문장 하나)**으로만 구성해야 합니다.
    - 사주 성향(예: 화 기운의 강렬함 vs 수 기운의 차분함)이나 연애 트렌드, MBTI, 연인 사이의 미묘한 갈등/질투 요소 등을 결합하여 다소 자극적이고 호기심 넘치는 매운맛 연애 밸런스/가치관 질문을 디자인해 주세요.
    - 예시:
      * "솔직히 나 말고 다른 사람한테 심장 쿵 내려앉아 본 적 있어?"
      * "내가 다른 이성하고 웃으면서 길게 통화하면 질투 나, 아니면 쿨한 척 참을 거야?"
      * "사주 궁합으로 볼 때 우리 기운이 가장 뜨겁게 불타오르는 순간은 언제라고 생각해?"
      * "만약 내가 아무 말 없이 연락 끊기면, 바람피운다고 먼저 생각할 거야?"
      * "나랑 헤어지면 너 다음 사람 만날 때 내 생각이 전혀 안 날 것 같아?"

    ### #4. 제약 조건 (Constraints)
    - 반드시 하나의 완벽한 물음표(?)로 끝나는 단일 질문이어야 합니다. 두 문장 이상 결합하거나 접속사로 길게 연결하지 마세요.
    - 너무 비관적이거나 파국을 조장하는 무거운 수위보다는, 연인끼리 장난치며 진지하게 대화할 수 있는 정도의 '자극적이고 흥미진진한' 수준으로 맞춰주세요.
    - 반드시 지정된 JSON 형식으로만 출력해야 합니다.

    ### #5. JSON 출력 형식
    {
      "todays_question": "(생성된 질문)"
    }

    ### #6. 최종 요청 (Final Request)
    [사용자 생년월일]: $userBirth
    [파트너 생년월일]: $partnerBirth
    """;
  }

  // 오늘의 갈등 해결 주제 생성을 위한 프롬프트
  String _buildConflictTopicsPrompt(String userBirth, String partnerBirth) {
    return """
    ### #1. 역할 (Persona)
    당신은 커플 관계 분석가이자 사주 명리학 지식을 활용하는 갈등 상담사입니다.

    ### #2. 목표 (Goal)
    입력된 두 사람의 생년월일($userBirth, $partnerBirth) 사주 정보를 분석하여, 두 사람의 타고난 사주 오행/성향적 차이(상생상극 관계)에서 비롯될 수 있는 갈등 주제 3가지를 생성하여 아래 지정된 JSON 형식으로 출력합니다.

    ### #3. 지침 (Instructions)
    1. 두 사람의 사주 오행적 상극이나 성향적 불균형(예: 화 기운의 급함 vs 수 기운의 차분함, 목 기운의 추진력 vs 금 기운의 꼼꼼함 등)에서 기인할 수 있는 현실적인 갈등 주제 3가지를 선별하세요.
    2. 각 주제는 다음과 같은 요소들을 가져야 합니다:
       - id: "1", "2", "3" 등 고유 식별자 (문자열)
       - category: 갈등의 카테고리 (예: "소통", "연락", "가치관", "데이트", "생활 습관", "애정 표현")
       - topic: 두 사람의 성향 차이를 자극적이고 호기심을 유발하도록 빗댄 **짧은 질문 형식** (예: "연락 안 되면 바람피운다고 의심하는 성향?", "갑자기 데이트 약속을 깨는 상대방, 참아야 할까?", "내 사주의 불 기운과 너의 물 기운 차이로 인한 소통 단절?"). 절대 설명조로 길어지지 않게 한눈에 들어오는 짧고 자극적이며 호기심을 유발하는 질문으로 작성하세요.

    ### #4. 제약 조건 (Constraints)
    - 갈등 주제의 제목(`topic`) 속에 두 사람의 사주 오행 또는 사주 성향적 특징(예: 화 기운, 금 기운, 물과 불의 성향 등)이 은유적이든 직접적이든 자연스럽게 녹아있어야 합니다.
    - 반드시 하나의 완벽한 물음표(?)로 끝나는 짧은 질문 형태여야 합니다.
    - 반드시 지정된 JSON 형식으로만 출력해야 합니다.
    - 너무 비관적이거나 헤어짐을 종용하는 주제는 피하고, 서로 이해하고 맞춰갈 수 있는 현실적인 질문으로 선정하세요.

    ### #5. JSON 출력 형식
    {
      "topics": [
        {
          "id": "1",
          "category": "연락",
          "topic": "화(火)와 수(水) 성향 차이로 인한 연락 의심, 이대로 괜찮을까?"
        },
        ...
      ]
    }
    """;
  }

  // 추가적인 갈등 해결 주제 생성을 위한 프롬프트
  String _buildAdditionalConflictTopicPrompt(String userBirth, String partnerBirth, List<String> existingTopics) {
    final existingTopicsStr = existingTopics.join(", ");
    return """
    ### #1. 역할 (Persona)
    당신은 커플 관계 분석가이자 사주 명리학 지식을 활용하는 갈등 상담사입니다.

    ### #2. 목표 (Goal)
    입력된 두 사람의 생년월일($userBirth, $partnerBirth) 사주 정보를 분석하여, 두 사람의 타고난 사주 오행/성향적 차이에서 비롯될 수 있는 새로운 갈등 주제 1가지를 생성하여 아래 지정된 JSON 형식으로 출력합니다.

    ### #3. 지침 (Instructions)
    1. 다음 리스트는 이미 생성된 갈등 주제들입니다. 이 주제들과 **전혀 겹치지 않고 유사하지 않은 새로운 갈등 주제 1가지**를 선정해 주세요:
       - 이미 생성된 주제: [$existingTopicsStr]
    2. 생성할 주제는 다음과 같은 요소들을 가져야 합니다:
       - category: 갈등의 카테고리 (예: "소통", "연락", "가치관", "데이트", "생활 습관", "애정 표현")
       - topic: 두 사람의 성향 차이를 자극적이고 호기심을 유발하도록 빗댄 **짧은 질문 형식** (예: "연락 안 되면 바람피운다고 의심하는 성향?", "갑자기 데이트 약속을 깨는 상대방, 참아야 할까?", "내 사주의 불 기운과 너의 물 기운 차이로 인한 소통 단절?"). 절대 설명조로 길어지지 않게 한눈에 들어오는 짧고 자극적이며 호기심을 유발하는 질문으로 작성하세요.

    ### #4. 제약 조건 (Constraints)
    - 기존 주제 [$existingTopicsStr]와 내용 및 소재 면에서 명확히 차이가 있어야 합니다.
    - 갈등 주제의 제목(`topic`) 속에 두 사람의 사주 오행 또는 사주 성향적 특징(예: 화 기운, 금 기운, 물과 불의 성향 등)이 은유적이든 직접적이든 자연스럽게 녹아있어야 합니다.
    - 반드시 하나의 완벽한 물음표(?)로 끝나는 짧은 질문 형태여야 합니다.
    - 반드시 지정된 JSON 형식으로만 출력해야 합니다.
    - 너무 비관적이거나 헤어짐을 종용하는 주제는 피하고, 서로 이해하고 맞춰갈 수 있는 현실적인 질문으로 선정하세요.

    ### #5. JSON 출력 형식
    {
      "category": "연락",
      "topic": "화(火)와 수(水) 성향 차이로 인한 연락 의심, 이대로 괜찮을까?"
    }
    """;
  }
}
