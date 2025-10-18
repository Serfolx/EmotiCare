import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  static const String _apiKey ='*';
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const List<String> availableModels = ['llama-3.1-8b-instant'];

  static final List<String> _emergencyTriggers = [
    'suicide',
    'kill myself',
    'end my life',
    'want to die',
    'harm myself',
    'self harm',
    'hurting myself',
    'can\'t go on',
    'give up',
    'no reason to live',
    'better off dead',
    'suicidal',
    'overdose',
    'cutting',
    'bleeding',
    'emergency',
    'crisis',
    'breakdown',
    'psychotic',
    'hallucinations',
    'paranoid',
    'mania',
    'manic',
    'panic attack',
    'losing control',
    'magpakamatay',
    'patayin ang sarili',
    'wakasan ang buhay',
    'gusto ko nang mamatay',
    'saktan ang sarili',
    'pagpapakamatay',
    'naghihirap',
    'di na kaya',
    'suko na',
    'walang silbi',
    'malungkot na malungkot',
    'nawawalan ng pag-asa',
    'nag-iisa',
    'walang makausap',
    'krisis',
    'atake',
    'nawawala sa sarili',
    'baliw',
    'hindi na kontrolado',
    'panic',
    'takot na takot'
  ];

  // Filipino/Tagalog keywords for language detection
  static final List<String> _filipinoKeywords = [
    'po',
    'opo',
    'salamat',
    'kamusta',
    'kumusta',
    'paano',
    'bakit',
    'saan',
    'kailan',
    'sino',
    'ano',
    'masaya',
    'malungkot',
    'galit',
    'takot',
    'pagod',
    'problema',
    'pamilya',
    'kaibigan',
    'trabaho',
    'paaralan',
    'pera',
    'pag-ibig',
    'kalusugan',
    'isip',
    'damdamin',
    'nararamdaman',
    'nag-aalala',
    'nag-iisa',
    'nawawala',
    'hirap',
    'lungkot',
    'saya',
    'takut',
    'inis',
    'hinanakit',
    'pangarap',
    'layunin',
    'buhay',
    'kamay',
    'puso',
    'ulo',
    'katawan',
    'oras',
    'araw',
    'gabi',
    'umaga',
    'hapon',
    'gabi',
    'bukas',
    'kahapon',
    'ngayon',
    'mamaya',
    'sandali',
    'palagi'
  ];

  static Future<String> getTherapeuticResponse(String userMessage) async {
    try {
      if (!await _checkInternetConnection()) {
        throw Exception(
            'No internet connection. Please check your network and try again.');
      }

      // Detect user's language
      final String userLanguage = _detectLanguage(userMessage);

      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({
              'model': availableModels[0],
              'messages': [
                {
                  'role': 'system',
                  'content': '''
CRITICAL INSTRUCTIONS - YOU MUST FOLLOW THESE STRICTLY:

YOU ARE: EmotiCare - a mental health support assistant ONLY.

LANGUAGE INSTRUCTION:
- Detect the user's language from their message
- If user writes in FILIPINO/TAGALOG, respond ONLY in FILIPINO
- If user writes in ENGLISH, respond ONLY in ENGLISH
- NEVER mix languages in the same response
- NEVER code-switch between English and Filipino
- Choose one language and stick to it for the entire response

FILIPINO RESPONSE GUIDELINES:
- Use warm, compassionate Filipino language
- Be culturally appropriate for Filipino users
- Use "po" and "opo" when appropriate for respect
- Focus on emotional support in Filipino context

ENGLISH RESPONSE GUIDELINES:
- Use warm, compassionate English language
- Be professional yet empathetic
- Focus on emotional support and validation

STRICT TOPIC BOUNDARIES:
- ONLY respond to: emotions, feelings, mental health, relationships, coping strategies, self-care
- ALWAYS redirect non-therapy topics back to emotional support

REDIRECTION PROTOCOL:
- If NOT therapy-related, gently redirect to emotional topics
- Do NOT engage with or answer non-therapy questions

EMERGENCY PROTOCOL:
- If emergency triggers detected, provide crisis resources immediately
- Always prioritize safety and direct to professional help

REMEMBER: You are NOT a general AI assistant. You are ONLY for mental health support.'''
                },
                {'role': 'user', 'content': userMessage},
              ],
              'temperature': 0.7,
              'max_tokens': 1024,
              'top_p': 0.9,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        String aiResponse = jsonDecode(response.body)['choices'][0]['message']
                ['content']
            .toString()
            .trim();

        // Append emergency resources if triggers detected (in detected language)
        if (_checkForEmergencyTriggers(userMessage)) {
          final emergencyMessage = userLanguage == 'filipino'
              ? '\n\n⚠️ **MAHALAGA: Kung ikaw ay nasa krisis, mangyaring makipag-ugnayan sa mga emergency resources na ito agad:**\n\n'
              : '\n\n⚠️ **IMPORTANT: If you\'re in crisis, please contact these emergency resources immediately:**\n\n';

          aiResponse += emergencyMessage +
              getEmergencyResourcesList().join('\n') +
              (userLanguage == 'filipino'
                  ? '\n\nHindi ka nag-iisa. Mangyaring humingi ng propesyonal na tulong.'
                  : '\n\nYou are not alone. Please reach out for professional help.');
        }

        return aiResponse;
      } else {
        throw Exception(
            'Unable to connect to therapy services. Please try again.');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable')) {
        throw Exception(
            'No internet connection. Please check your network and try again.');
      } else if (e.toString().contains('timeout')) {
        throw Exception(
            'Request timeout. Please check your connection and try again.');
      } else {
        throw Exception(
            'Service temporarily unavailable. Please try again in a moment.');
      }
    }
  }

  static String _detectLanguage(String message) {
    final lowerMessage = message.toLowerCase();

    // Count Filipino keywords in the message
    int filipinoKeywordCount = _filipinoKeywords
        .where((keyword) => lowerMessage.contains(keyword.toLowerCase()))
        .length;

    // Count English words (simple heuristic)
    final englishWordCount = lowerMessage
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 2)
        .length;

    // If message contains clear Filipino markers or has more Filipino keywords, use Filipino
    if (lowerMessage.contains('po') ||
        lowerMessage.contains('salamat') ||
        lowerMessage.contains('kamusta') ||
        lowerMessage.contains('kumusta') ||
        filipinoKeywordCount > 2 ||
        filipinoKeywordCount > englishWordCount * 0.3) {
      return 'filipino';
    }

    // Default to English
    return 'english';
  }

  static bool _checkForEmergencyTriggers(String message) {
    final lowerMessage = message.toLowerCase();
    return _emergencyTriggers
        .any((trigger) => lowerMessage.contains(trigger.toLowerCase()));
  }

  static Future<bool> _checkInternetConnection() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.gstatic.com/generate_204'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  static List<String> getEmergencyResourcesList() {
    return [
      '🇵🇭 National Center for Mental Health (NCMH): 1553 (Nationwide)',
      '🇵🇭 Hopeline Philippines: (02) 8804-4673 • 0917-558-4673 • 0918-873-4673',
      '🇵🇭 In Touch Community Services: (02) 8893-7603 • 0917-800-1123 • 0922-893-8944',
      '🇵🇭 Philippine Red Cross: 143 (Nationwide)',
      '🇵🇭 National Emergency Hotline: 911 (Nationwide)',
      '🇵🇭 DOH Mental Health Program: (02) 8651-7800 local 8325',
      '🆘 Crisis Text Line: Text "HOME" to 741741',
    ];
  }
}
