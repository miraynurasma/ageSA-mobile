import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'markets_page.dart';
import 'products_services_page.dart';
import 'bes_fast_purchase_page.dart';
import 'application_actions_page.dart';
import 'splash_page.dart';
import 'services/bes_user_service.dart';
import 'bes_savings_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _tcController = TextEditingController();
  final _passController = TextEditingController();
  bool _agree = false;
  int _logoTapCount = 0;
  DateTime? _lastLogoTap;
  bool _isLoading = false;

  @override
  void dispose() {
    _tcController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_agree) return;
    
    final username = _tcController.text.trim().toLowerCase();
    final password = _passController.text.trim();
    
    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog('Lütfen kullanıcı adı ve şifre giriniz.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = BESUserService.validateUser(username, password);
      
      if (user != null) {
        await BESUserService.saveCurrentUser(user);
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const BESSavingsPage()),
          );
        }
      } else {
        _showErrorDialog('Geçersiz kullanıcı adı veya şifre.\n\nDemo kullanıcıları:\n• Miraynur Asma (şifre: miraynur)\n• Melahat Uçar (şifre: melahat)\n• Begüm Tatlı (şifre: begum)\n• Emre Karaca (şifre: emre)\n• Yılmaz Meral (şifre: yılmaz)');
      }
    } catch (e) {
      _showErrorDialog('Giriş sırasında bir hata oluştu: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D47A1); // Button blue close to reference
    const borderGrey = Color(0xFFE3E6EC);
    const textGrey = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top bar: Logo + Help
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            final now = DateTime.now();
                            if (_lastLogoTap == null || now.difference(_lastLogoTap!).inMilliseconds > 1000) {
                              _logoTapCount = 1;
                            } else {
                              _logoTapCount += 1;
                            }
                            _lastLogoTap = now;
                            if (_logoTapCount >= 3) {
                              _logoTapCount = 0;
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SplashPage()),
                              );
                            }
                          },
                          child: SvgPicture.asset('assets/logo.svg', height: 64),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Yardım Al',
                            style: TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ID field
                    TextField(
                      controller: _tcController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'TC/Yabancı Kimlik Numarası',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: borderGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Password field
                    TextField(
                      controller: _passController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Şifre',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: borderGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Bireysel İnternet Şube şifrenizi kullanabilirsiniz.',
                      style: TextStyle(color: textGrey),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _agree,
                          onChanged: (v) => setState(() => _agree = v ?? false),
                          shape: const CircleBorder(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black87),
                              children: const [
                                TextSpan(text: 'Agessa Müşteri Mobil Uygulama '),
                                TextSpan(
                                  text: 'Kullanıcı Sözleşmesi',
                                  style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w600),
                                ),
                                TextSpan(text: "'ni okudum, anladım."),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Login button
                    ElevatedButton(
                      onPressed: _agree ? _handleLogin : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        disabledBackgroundColor: primaryBlue.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Giriş Yap', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),

                    const SizedBox(height: 8),

                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Yeni Şifre Oluştur',
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Promo card
                    _PromoCard(),

                    const SizedBox(height: 12),

                    // Bottom quick actions
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.show_chart,
                            label: 'Piyasalar',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const MarketsPage()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.category_outlined,
                            label: 'Ürünler ve\nHizmetler',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const ProductsServicesPage()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.assignment_outlined,
                            label: 'Başvuru İşlemleri',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const ApplicationActionsPage()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AnimatedPiggy extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedPiggy({required this.controller});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D47A1);
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
          ),
          // Piggy icon
          const Icon(Icons.savings_outlined, color: primaryBlue),
          // Falling coins (three coins with phase shift)
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final t = controller.value;
              // Map t (0..1) to vertical positions; coins slightly phase-shifted
              double y(double phase) {
                final v = ((t + phase) % 1.0);
                // Visible window is first 55% of the 3s cycle; then short hidden pause
                final fallProgress = v <= 0.55 ? Curves.easeIn.transform(v / 0.55) : 1.0;
                // Longer path: -22px to +16px
                return Tween<double>(begin: -22.0, end: 16.0).transform(fallProgress);
              }
              double opacity(double phase) {
                final v = ((t + phase) % 1.0);
                // Only visible in 0..0.55; rest is an invisible pause
                if (v > 0.55) return 0.0;
                // Fade in (0..0.12), hold (0.12..0.45), fade out (0.45..0.55)
                if (v < 0.12) return v / 0.12;
                if (v < 0.45) return 1.0;
                return 1.0 - (v - 0.45) / 0.10;
              }
              return Stack(
                children: [
                  // Three coins with slight phase and horizontal offsets
                  _coin(y(0.00), opacity(0.00), -8),
                  _coin(y(0.08), opacity(0.08), 0),
                  _coin(y(0.16), opacity(0.16), 8),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _coin(double dy, double a, double dx) {
    const coinColor = Color(0xFFFFC107);
    return Positioned(
      top: 8 + dy,
      left: 22 - 6 + dx, // center minus half coin + horizontal offset
      child: Opacity(
        opacity: a.clamp(0, 1),
        child: Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: coinColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _PromoCard extends StatefulWidget {
  @override
  State<_PromoCard> createState() => _PromoCardState();
}

class _PromoCardState extends State<_PromoCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const borderGrey = Color(0xFFE3E6EC);
    const primaryBlue = Color(0xFF0D47A1);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BesFastPurchasePage()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Animated piggy-bank with falling coins
            _AnimatedPiggy(controller: _controller),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BES Hızlı Satın Al', style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 2),
                  Text('Kendiniz ve çocuğunuzun geleceği için…', style: TextStyle(color: Color(0xFF6B7280))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F2FF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('YENİ', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _QuickAction({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    const borderGrey = Color(0xFFE3E6EC);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderGrey),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFF0D47A1)),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
