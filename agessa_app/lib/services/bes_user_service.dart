import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/bes_user.dart';

class BESUserService {
  static const String _currentUserKey = 'current_bes_user';
  
  // Demo kullanıcıları
  static final Map<String, BESUser> _demoUsers = {
    'miraynur asma': BESUser(
      username: 'miraynur asma',
      fullName: 'Miray Nur Asma',
      currentSavings: 8500.0,
      treeLevel: 1,
      treeLevelName: 'Fide',
      motivationMessage: 'Harika başlangıç! Fideni büyütmeye devam et!',
    ),
    'melahat ucar': BESUser(
      username: 'melahat ucar',
      fullName: 'Melahat Uçar',
      currentSavings: 25000.0,
      treeLevel: 2,
      treeLevelName: 'Genç Fidan',
      motivationMessage: 'Mükemmel! Genç fidanın güçleniyor! Ağaç olmaya yaklaştın!',
    ),
    'emre karaca': BESUser(
      username: 'emre karaca',
      fullName: 'Emre Karaca',
      currentSavings: 85000.0,
      treeLevel: 3,
      treeLevelName: 'Ağaç',
      motivationMessage: 'Harika! Güçlü bir ağaç oldun! Meyve vermeye yaklaştın!',
    ),
    'yilmaz meral': BESUser(
      username: 'yilmaz meral',
      fullName: 'Yılmaz Meral',
      currentSavings: 110000.0,
      treeLevel: 4,
      treeLevelName: 'Yeşil Elma Ağacı',
      motivationMessage: 'Süper! Elmalarınız kızarmak üzere!',
    ),
    'begum tatli': BESUser(
      username: 'begum tatli',
      fullName: 'Begüm Tatlı',
      currentSavings: 180000.0,
      treeLevel: 5,
      treeLevelName: 'Kırmızı Elma Ağacı',
      motivationMessage: 'Sabırla büyüttüğünüz ağaç artık kırmızı elmalar veriyor!',
    ),
  };

  // Kullanıcı girişi doğrula
  static BESUser? validateUser(String username, String password) {
    // Kullanıcı adını küçük harfe çevir ve türkçe karakterleri normalize et
    final usernameLower = username.toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
    
    // Şifreyi küçük harfe çevir ve türkçe karakterleri normalize et
    final passwordLower = password.toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
    
    // Kullanıcı adını kontrol et (normalize edilmiş haliyle)
    final user = _demoUsers.entries.firstWhere(
      (entry) => entry.key.toLowerCase()
          .replaceAll('ı', 'i')
          .replaceAll('ğ', 'g')
          .replaceAll('ü', 'u')
          .replaceAll('ş', 's')
          .replaceAll('ö', 'o')
          .replaceAll('ç', 'c') == usernameLower,
      orElse: () => MapEntry('', _demoUsers.values.first),
    );

    if (user.key.isNotEmpty) {
      // İlk ismi al (boşluktan önceki kısım) ve türkçe karakterleri normalize et
      final firstName = user.key.split(' ')[0].toLowerCase()
          .replaceAll('ı', 'i')
          .replaceAll('ğ', 'g')
          .replaceAll('ü', 'u')
          .replaceAll('ş', 's')
          .replaceAll('ö', 'o')
          .replaceAll('ç', 'c');
          
      if (passwordLower == firstName) {
        return user.value;
      }
    }
    return null;
  }

  // Mevcut kullanıcıyı kaydet
  static Future<void> saveCurrentUser(BESUser user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = json.encode(user.toJson());
    await prefs.setString(_currentUserKey, userJson);
  }

  // Mevcut kullanıcıyı getir
  static Future<BESUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    
    if (userJson != null) {
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return BESUser.fromJson(userMap);
    }
    return null;
  }

  // Kullanıcı çıkışı
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // Tüm demo kullanıcılarını getir (test için)
  static List<BESUser> getAllDemoUsers() {
    return _demoUsers.values.toList();
  }

  // Kullanıcı birikimini güncelle (demo için)
  static Future<void> updateUserSavings(String username, double newAmount) async {
    if (_demoUsers.containsKey(username)) {
      final user = _demoUsers[username]!;
      final updatedUser = BESUser(
        username: user.username,
        fullName: user.fullName,
        currentSavings: newAmount,
        treeLevel: _calculateTreeLevel(newAmount),
        treeLevelName: _getTreeLevelName(_calculateTreeLevel(newAmount)),
        motivationMessage: getMotivationMessage(_calculateTreeLevel(newAmount)),
      );
      _demoUsers[username] = updatedUser;
      
      // Eğer bu kullanıcı şu anda giriş yapmışsa, güncelle
      final currentUser = await getCurrentUser();
      if (currentUser?.username == username) {
        await saveCurrentUser(updatedUser);
      }
    }
  }

  // Birikim miktarına göre ağaç seviyesi hesapla
  static int _calculateTreeLevel(double savings) {
    if (savings < 10000) return 1; // Fide
    if (savings < 50000) return 2; // Genç Fidan
    if (savings < 150000) return 3; // Ağaç
    if (savings < 200000) return 4; // Yeşil Elma Ağacı
    return 5; // Kırmızı Elma Ağacı
  }

  // Ağaç seviyesi adını getir
  static String _getTreeLevelName(int level) {
    switch (level) {
      case 1: return 'Fide';
      case 2: return 'Genç Fidan';
      case 3: return 'Ağaç';
      case 4: return 'Yeşil Elma Ağacı';
      case 5: return 'Kırmızı Elma Ağacı';
      default: return 'Fide';
    }
  }

  // Motivasyon mesajını getir
  static String getMotivationMessage(int level) {
    switch (level) {
      case 1: return 'Harika başlangıç! Fideni büyütmeye devam et!';
      case 2: return 'Mükemmel! Genç fidanın güçleniyor! Ağaç olmaya yaklaştın!';
      case 3: return 'Harika! Güçlü bir ağaç oldun! Meyve vermeye yaklaştın!';
      case 4: return 'Süper! Elmalarınız kızarmak üzere!';
      case 5: return 'Tebrikler! Elmalarınız kızardı! Birikimin harika! 🍎👑';
      default: return 'Birikimini büyütmeye devam et!';
    }
  }
}
