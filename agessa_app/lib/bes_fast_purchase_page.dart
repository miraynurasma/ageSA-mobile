import 'package:flutter/material.dart';
import 'bes_fast_flow_page.dart';
import 'bes_self_detail_page.dart';
import 'bes_child_detail_page.dart';

class BesFastPurchasePage extends StatelessWidget {
  const BesFastPurchasePage({super.key});

  static const Color _primaryBlue = Color(0xFF0D47A1);
  static const Color _borderGrey = Color(0xFFE3E6EC);
  static const Color _chipBg = Color(0xFFF6F7FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        title: const Text('BES Hızlı Satın Al'),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _chipBg,
                  border: Border.all(color: _borderGrey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Agessa müşterimiz iseniz uygulamaya giriş yaparak daha hızlı Bireysel Emeklilik Sözleşmesi\'ni (BES) satın alabilirsiniz.',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              const SizedBox(height: 16),

              _optionCard(
                context,
                title: 'Kendim İçin',
                description:
                    'Yatırım yapmaya bugünden başlayın, %30 devlet katkısı ve fon getirisi avantajıyla birikimlerinizi üst seviyeye taşıyın!',
                icon: Icons.verified_user_outlined,
              ),

              _optionCard(
                context,
                title: 'Çocuğum İçin',
                description:
                    '%30 devlet katkısı ve fon getirisi avantajıyla çocuğunuzun geleceğine yatırım yapmaya şimdi başlayın!',
                icon: Icons.child_care_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _borderGrey),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _primaryBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  if (title == 'Kendim İçin') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BesSelfDetailPage(),
                      ),
                    );
                  } else if (title == 'Çocuğum İçin') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BesChildDetailPage(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Detaylar yakında eklenecek.')),
                    );
                  }
                },
                child: const Text(
                  'Detaylı Bilgi',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BesFastFlowPage(purpose: title),
                    ),
                  );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Devam Et'),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
