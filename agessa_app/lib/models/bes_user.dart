class BESUser {
  final String username;
  final String fullName;
  final double currentSavings;
  final int treeLevel;
  final String motivationMessage;
  final String treeLevelName;

  BESUser({
    required this.username,
    required this.fullName,
    required this.currentSavings,
    required this.treeLevel,
    required this.motivationMessage,
    required this.treeLevelName,
  });

  // JSON'dan BESUser oluştur
  factory BESUser.fromJson(Map<String, dynamic> json) {
    return BESUser(
      username: json['username'],
      fullName: json['fullName'],
      currentSavings: json['currentSavings'].toDouble(),
      treeLevel: json['treeLevel'],
      motivationMessage: json['motivationMessage'],
      treeLevelName: json['treeLevelName'],
    );
  }

  // BESUser'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'fullName': fullName,
      'currentSavings': currentSavings,
      'treeLevel': treeLevel,
      'motivationMessage': motivationMessage,
      'treeLevelName': treeLevelName,
    };
  }

  // Ağaç emoji'sini getir
  String getTreeEmoji() {
    if (currentSavings < 10000) {
      return '🌱'; // Fide
    } else if (currentSavings < 50000) {
      return '🌿'; // Genç Fidan
    } else if (currentSavings < 100000) {
      return '🌳'; // Ağaç
    } else if (currentSavings < 150000) {
      return '🍏'; // Yeşil Elma Ağacı
    } else {
      return '🍎'; // Kırmızı Elma Ağacı
    }
  }

  // Birikim miktarını formatla
  String getFormattedSavings() {
    return '${currentSavings.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )} TL';
  }
}
