import 'package:flutter/material.dart';
import 'models/bes_user.dart';
import 'services/bes_user_service.dart';
import 'login_page.dart';

class BESSavingsPage extends StatefulWidget {
  const BESSavingsPage({super.key});

  @override
  State<BESSavingsPage> createState() => _BESSavingsPageState();
}

class _BESSavingsPageState extends State<BESSavingsPage>
    with TickerProviderStateMixin {
  BESUser? _currentUser;
  late AnimationController _treeAnimationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    
    // Ağaç büyüme animasyonu
    _treeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Nabız animasyonu
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _treeAnimationController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Animasyonları başlat
    _treeAnimationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _treeAnimationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final user = await BESUserService.getCurrentUser();
    if (user != null) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D47A1);
    const lightBlue = Color(0xFFE6F2FF);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        title: const Text(
          'Birikimim',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Karşılama mesajı
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Merhaba ${_currentUser!.fullName}! 👋',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'BES Birikimin',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _currentUser!.getFormattedSavings(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Ağaç görselleştirme
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Seviye: ${_currentUser!.treeLevelName}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Animasyonlu ağaç
                        AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseAnimation.value,
                                    child: _buildTreeDisplay(),
                                  );
                                },
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // İlerleme çubuğu
                        _buildProgressBar(),

                        const SizedBox(height: 20),

                        // Motivasyon mesajı
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: lightBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _currentUser!.motivationMessage,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Seviye bilgileri
                  _buildLevelInfo(),

                  const SizedBox(height: 20),

                  // Çıkış butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await BESUserService.logout();
                          if (mounted) {
                            // Navigate to login page and remove all previous routes
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Çıkış yapılırken bir hata oluştu'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        'Çıkış Yap',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildTreeDisplay() {
    const greenGradient = [Color(0xFF4CAF50), Color(0xFF8BC34A)];
    
    // Meyve ağacı için özel tasarım
    if (_currentUser!.currentSavings >= 90000) {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF8BC34A), Color(0xFFFFD700)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0xFF4CAF50).withOpacity(0.4),
              blurRadius: 25,
              spreadRadius: 8,
            ),
            BoxShadow(
              color: Color(0xFFFFD700).withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Center(
          child: Text(
            _currentUser!.getTreeEmoji(),
            style: const TextStyle(fontSize: 80),
          ),
        ),
      );
    } else {
      // Normal ağaç tasarımı
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: greenGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: greenGradient[0].withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Text(
            _currentUser!.getTreeEmoji(),
            style: const TextStyle(fontSize: 60),
          ),
        ),
      );
    }
  }

  Widget _buildProgressBar() {
    double progress = 0.0;
    String nextLevelText = '';
    
    switch (_currentUser!.treeLevel) {
      case 1:
        progress = _currentUser!.currentSavings / 10000;
        nextLevelText = 'Genç Fidan olmak için ${(10000 - _currentUser!.currentSavings).toStringAsFixed(0)} TL kaldı!';
        break;
      case 2:
        progress = (_currentUser!.currentSavings - 10000) / 40000;
        nextLevelText = 'Ağaç olmak için ${(50000 - _currentUser!.currentSavings).toStringAsFixed(0)} TL kaldı!';
        break;
      case 3:
        progress = (_currentUser!.currentSavings - 50000) / 50000;
        nextLevelText = 'Yeşil Elma Ağacı olmak için ${(100000 - _currentUser!.currentSavings).toStringAsFixed(0)} TL kaldı!';
        break;
      case 4:
        progress = (_currentUser!.currentSavings - 100000) / 50000;
        nextLevelText = 'Kırmızı Elma Ağacı olmak için ${(150000 - _currentUser!.currentSavings).toStringAsFixed(0)} TL kaldı!';
        break;
      case 5:
        progress = 1.0;
        nextLevelText = BESUserService.getMotivationMessage(5);
        break;
    }

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            _currentUser!.treeLevel == 5 ? const Color(0xFFFFD700) : const Color(0xFF4CAF50),
          ),
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        Text(
          nextLevelText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0D47A1),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLevelInfo() {
    const levels = [
      {'emoji': '🌱', 'name': 'Fide', 'range': '0 - 10.000 TL'},
      {'emoji': '🌿', 'name': 'Genç Fidan', 'range': '10.000 - 50.000 TL'},
      {'emoji': '🌳', 'name': 'Ağaç', 'range': '50.000 - 100.000 TL'},
      {'emoji': '🍏', 'name': 'Yeşil Elma Ağacı', 'range': '100.000 - 150.000 TL'},
      {'emoji': '🍎', 'name': 'Kırmızı Elma Ağacı', 'range': '150.000+ TL'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seviye Rehberi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(height: 16),
          ...levels.map((level) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(
                  level['emoji']!,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level['name']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _currentUser!.treeLevelName == level['name']
                              ? const Color(0xFF4CAF50)
                              : Colors.black87,
                        ),
                      ),
                      Text(
                        level['range']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_currentUser!.treeLevelName == level['name'])
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
