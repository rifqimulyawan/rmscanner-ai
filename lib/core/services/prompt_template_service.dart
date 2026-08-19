import 'package:rmscanner/core/localization/app_localizations.dart';

enum PromptTemplate { summarize, qa, translate, extractData }

class PromptTemplateService {
  static String generatePrompt({
    required AppLocalizations loc,
    required PromptTemplate template,
    required String documentText,
  }) {
    final lang = loc.locale.languageCode;
    final instruction = _getInstruction(template, lang);
    final followUp = _getFollowUp(template, lang);

    return '$instruction\n\n---\n$documentText\n---\n\n$followUp';
  }

  static String _getInstruction(PromptTemplate template, String lang) {
    switch (template) {
      case PromptTemplate.summarize:
        return _summarize[lang] ?? _summarize['en']!;
      case PromptTemplate.qa:
        return _qa[lang] ?? _qa['en']!;
      case PromptTemplate.translate:
        return _translate[lang] ?? _translate['en']!;
      case PromptTemplate.extractData:
        return _extractData[lang] ?? _extractData['en']!;
    }
  }

  static String _getFollowUp(PromptTemplate template, String lang) {
    switch (template) {
      case PromptTemplate.summarize:
        return _summarizeFollowUp[lang] ?? _summarizeFollowUp['en']!;
      case PromptTemplate.qa:
        return _qaFollowUp[lang] ?? _qaFollowUp['en']!;
      case PromptTemplate.translate:
        return _translateFollowUp[lang] ?? _translateFollowUp['en']!;
      case PromptTemplate.extractData:
        return _extractDataFollowUp[lang] ?? _extractDataFollowUp['en']!;
    }
  }

  static const Map<String, String> _summarize = {
    'en': 'Please summarize the following document concisely, highlighting the key points:',
    'id': 'Mohon ringkas dokumen berikut secara singkat dengan menyoroti poin-poin penting:',
    'bn': 'নিম্নলিখিত দস্তাবেজটি সংক্ষেপে সারসংক্ষেপ দিন, মূল পয়েন্টগুলো তুলে ধরে:',
    'hi': 'निम्नलिखित दस्तावेज़ को संक्षेप में सारांश दें, मुख्य बिंदुओं को उजागर करते हुए:',
    'fr': 'Veuillez résumer le document suivant de manière concise, en mettant en évidence les points clés:',
    'de': 'Bitte fassen Sie das folgende Dokument prägnant zusammen und heben Sie die wichtigsten Punkte hervor:',
    'ar': 'يرجى تلخيص المستند التالي بإيجاز، مع إبراز النقاط الرئيسية:',
  };

  static const Map<String, String> _summarizeFollowUp = {
    'en': 'Provide a clear and structured summary.',
    'id': 'Berikan ringkasan yang jelas dan terstruktur.',
    'bn': 'একটি স্পষ্ট এবং কাঠামোগত সারসংক্ষেপ দিন।',
    'hi': 'एक स्पष्ट और संरचित सारांश प्रदान करें।',
    'fr': 'Fournissez un résumé clair et structuré.',
    'de': 'Geben Sie eine klare und strukturierte Zusammenfassung.',
    'ar': 'قدم ملخصاً واضحاً ومنظماً.',
  };

  static const Map<String, String> _qa = {
    'en': 'I will provide you with a document. Please read it carefully and be ready to answer questions about it.',
    'id': 'Saya akan memberikan sebuah dokumen. Silakan baca dengan teliti dan bersiap untuk menjawab pertanyaan tentang dokumen tersebut.',
    'bn': 'আমি আপনাকে একটি দস্তাবেজ দেব। অনুগ্রহ করে মনোযোগ দিয়ে পড়ুন এবং এ সম্পর্কে প্রশ্নের উত্তর দেওয়ার জন্য প্রস্তুত থাকুন।',
    'hi': 'मैं आपको एक दस्तावेज़ दूंगा। कृपया इसे ध्यान से पढ़ें और इसके बारे में प्रश्नों के उत्तर देने के लिए तैयार रहें।',
    'fr': "Je vais vous fournir un document. Veuillez le lire attentivement et être prêt à répondre à des questions à son sujet.",
    'de': 'Ich werde Ihnen ein Dokument zur Verfügung stellen. Bitte lesen Sie es sorgfältig durch und seien Sie bereit, Fragen dazu zu beantworten.',
    'ar': 'سأقدم لك مستنداً. يرجى قراءته بعناية والاستعداد للإجابة على الأسئلة حوله.',
  };

  static const Map<String, String> _qaFollowUp = {
    'en': 'Please ask me anything about the document above.',
    'id': 'Silakan tanyakan apa saja tentang dokumen di atas.',
    'bn': 'উপরের দস্তাবেজ সম্পর্কে যা খুশি জিজ্ঞাসা করুন।',
    'hi': 'उपरोक्त दस्तावेज़ के बारे में कुछ भी पूछें।',
    'fr': "N'hésitez pas à me poser des questions sur le document ci-dessus.",
    'de': 'Stellen Sie mir gerne Fragen zum obigen Dokument.',
    'ar': 'لا تتردد في طرح أي أسئلة حول المستند أعلاه.',
  };

  static const Map<String, String> _translate = {
    'en': 'Please translate the following document into English. Maintain the original meaning and tone:',
    'id': 'Mohon terjemahkan dokumen berikut ke dalam Bahasa Inggris. Pertahankan makna dan nada asli:',
    'bn': 'অনুগ্রহ করে নিম্নলিখিত দস্তাবেজটি ইংরেজিতে অনুবাদ করুন। মূল অর্থ এবং স্বর বজায় রাখুন:',
    'hi': 'कृपया निम्नलिखित दस्तावेज़ का अंग्रेजी में अनुवाद करें। मूल अर्थ और लहज़ा बनाए रखें:',
    'fr': "Veuillez traduire le document suivant en anglais. Conservez le sens et le ton d'origine:",
    'de': 'Bitte übersetzen Sie das folgende Dokument ins Englische. Behalten Sie die ursprüngliche Bedeutung und den Ton bei:',
    'ar': 'يرجى ترجمة المستند التالي إلى الإنجليزية. حافظ على المعنى والنبرة الأصلية:',
  };

  static const Map<String, String> _translateFollowUp = {
    'en': 'Provide a natural and accurate translation.',
    'id': 'Berikan terjemahan yang natural dan akurat.',
    'bn': 'একটি স্বাভাবিক এবং নির্ভুল অনুবাদ দিন।',
    'hi': 'एक स्वाभाविक और सटीक अनुवाद प्रदान करें।',
    'fr': 'Fournissez une traduction naturelle et précise.',
    'de': 'Geben Sie eine natürliche und genaue Übersetzung.',
    'ar': 'قدم ترجمة طبيعية ودقيقة.',
  };

  static const Map<String, String> _extractData = {
    'en': 'Please extract all important data from the following document, including names, dates, amounts, addresses, and any other key information:',
    'id': 'Mohon ekstrak semua data penting dari dokumen berikut, termasuk nama, tanggal, jumlah, alamat, dan informasi kunci lainnya:',
    'bn': 'অনুগ্রহ করে নিম্নলিখিত দস্তাবেজ থেকে সমস্ত গুরুত্বপূর্ণ ডেটা বের করুন, যার মধ্যে নাম, তারিখ, পরিমাণ, ঠিকানা এবং অন্যান্য মূল তথ্য রয়েছে:',
    'hi': 'निम्नलिखित दस्तावेज़ से सभी महत्वपूर्ण डेटा निकालें, जिसमें नाम, तिथियाँ, राशियाँ, पते और कोई अन्य प्रमुख जानकारी शामिल है:',
    'fr': "Veuillez extraire toutes les données importantes du document suivant, y compris les noms, les dates, les montants, les adresses et toute autre information clé:",
    'de': 'Bitte extrahieren Sie alle wichtigen Daten aus dem folgenden Dokument, einschließlich Namen, Daten, Beträge, Adressen und anderer Schlüsselinformationen:',
    'ar': 'يرجى استخراج جميع البيانات المهمة من المستند التالي، بما في ذلك الأسماء والتواريخ والمبالغ والعناوين وأي معلومات رئيسية أخرى:',
  };

  static const Map<String, String> _extractDataFollowUp = {
    'en': 'Present the extracted data in a clear, organized format.',
    'id': 'Sajikan data yang diekstrak dalam format yang jelas dan terorganisir.',
    'bn': 'নিষ্কাশিত ডেটা একটি স্পষ্ট, সুসংগঠিত বিন্যাসে উপস্থাপন করুন।',
    'hi': 'निकाले गए डेटा को एक स्पष्ट, व्यवस्थित प्रारूप में प्रस्तुत करें।',
    'fr': 'Présentez les données extraites dans un format clair et organisé.',
    'de': 'Präsentieren Sie die extrahierten Daten in einem klaren, organisierten Format.',
    'ar': 'قدم البيانات المستخرجة بتنسيق واضح ومنظم.',
  };
}
