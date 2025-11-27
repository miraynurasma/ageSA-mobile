import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatbotService {
  static final ChatbotService _instance = ChatbotService._internal();
  factory ChatbotService() => _instance;
  ChatbotService._internal();

  late final GenerativeModel _model;
  Map<String, dynamic>? _productsData;

  void initialize() {
    // Web için doğrudan API anahtarı kullanımı
    const apiKey = 'AIzaSyBR56jRPMNr-To4HHu-tM53Ha02ewjrq5M';
    
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  Future<void> _loadProductsData() async {
    if (_productsData != null) return;
    
    try {
      final String response = await rootBundle.loadString('assets/products.json');
      _productsData = json.decode(response);
    } catch (e) {
      print('Ürün verileri yüklenirken hata: $e');
      _productsData = {};
    }
  }

  String _getRelevantContext(String question) {
    if (_productsData == null) return '';
    
    final lowercaseQuestion = question.toLowerCase();
    final details = _productsData!['details'] as Map<String, dynamic>? ?? {};
    
    // Anahtar kelimelere göre ilgili ürünleri bul
    final relevantProducts = <String>[];
    
    for (final productName in details.keys) {
      final productData = details[productName] as Map<String, dynamic>;
      final productNameLower = productName.toLowerCase();
      final shortDesc = (productData['kisaAciklama'] as String? ?? '').toLowerCase();
      final longDesc = (productData['uzunAciklama'] as String? ?? '').toLowerCase();
      
      // Gelişmiş anahtar kelime eşleştirmesi
      bool isRelevant = false;
      
      // Ferdi kaza sigortası için
      if (lowercaseQuestion.contains('ferdi') || lowercaseQuestion.contains('kaza')) {
        if (productNameLower.contains('ferdi') || productNameLower.contains('kaza')) {
          isRelevant = true;
        }
      }
      
      // Hayat sigortası için
      if (lowercaseQuestion.contains('hayat')) {
        if (productNameLower.contains('hayat')) {
          isRelevant = true;
        }
      }
      
      // BES ve emeklilik için
      if (lowercaseQuestion.contains('bes') || lowercaseQuestion.contains('emeklilik') || lowercaseQuestion.contains('birikim')) {
        if (productNameLower.contains('bes') || productNameLower.contains('emeklilik') || 
            shortDesc.contains('emeklilik') || shortDesc.contains('bes') || shortDesc.contains('birikim')) {
          isRelevant = true;
        }
      }
      
      // Genel sigorta sorguları için
      if (lowercaseQuestion.contains('sigorta') && !lowercaseQuestion.contains('ferdi') && !lowercaseQuestion.contains('hayat')) {
        if (productNameLower.contains('sigorta')) {
          isRelevant = true;
        }
      }
      
      if (isRelevant) {
        relevantProducts.add(productName);
      }
    }
    
    // Eğer hiç ürün bulunamadıysa, tüm ürünleri dahil et
    if (relevantProducts.isEmpty) {
      relevantProducts.addAll(details.keys);
    }
    
    // İlgili ürün bilgilerini birleştir
    final contextParts = <String>[];
    for (final productName in relevantProducts.take(4)) { // En fazla 4 ürün
      final productData = details[productName] as Map<String, dynamic>;
      final shortDesc = productData['kisaAciklama'] as String? ?? '';
      final longDesc = productData['uzunAciklama'] as String? ?? '';
      
      contextParts.add('ÜRÜN: $productName\nKISA AÇIKLAMA: $shortDesc\nDETAYLI AÇIKLAMA: $longDesc');
    }
    
    return contextParts.join('\n\n---\n\n');
  }

  Future<String> getResponse(String question) async {
    try {
      await _loadProductsData();
      
      final context = _getRelevantContext(question);
      
      final prompt = '''
Sen Agessa sigorta şirketinin müşteri danışmanısın. Sadece Agessa'nın ürünleri hakkında bilgi veriyorsun.

AGESSA'NIN ÜRÜN PORTFÖYÜ:
$context

ÖNEMLİ KURALLAR:
1. Sadece yukarıda verilen Agessa ürünleri hakkında konuş
2. Başka sigorta şirketlerinden bahsetme
3. Agessa'da olmayan ürünler için "Bu ürünü sunmuyoruz" deme
4. Ürün detaylarını verilen bilgilerden al
5. Fiyat sorularında "Detaylı fiyat bilgisi için müşteri hizmetlerimizle iletişime geçin" de

KULLANICI SORUSU: $question

Agessa ürünlerine odaklanarak, samimi ve profesyonel bir şekilde Türkçe yanıtla:''';

      final content = [Content.text(prompt)];
      
      // Retry mekanizması ile API çağrısı
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          final response = await _model.generateContent(content);
          final responseText = response.text;
          
          if (responseText != null && responseText.isNotEmpty) {
            return responseText;
          }
        } catch (e) {
          print('API çağrısı $attempt. deneme başarısız: $e');
          
          if (attempt == 3) {
            // Son deneme de başarısızsa alternatif model dene
            return await _tryAlternativeModel(content);
          }
          
          // Kısa bekleme süresi
          await Future.delayed(Duration(seconds: attempt));
        }
      }
      
      return 'Üzgünüm, şu anda yanıt oluşturamıyorum. Lütfen tekrar deneyin.';
      
    } catch (e) {
      print('Chatbot genel hatası: $e');
      rethrow;
    }
  }

  Future<String> _tryAlternativeModel(List<Content> content) async {
    try {
      // Alternatif model ile deneme
      final altModel = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: 'AIzaSyBR56jRPMNr-To4HHu-tM53Ha02ewjrq5M',
      );
      
      final response = await altModel.generateContent(content);
      final responseText = response.text;
      
      if (responseText != null && responseText.isNotEmpty) {
        return responseText;
      }
    } catch (e) {
      print('Alternatif model de başarısız: $e');
    }
    
    return 'API servisi şu anda yoğun. Lütfen birkaç dakika sonra tekrar deneyin.';
  }
}
