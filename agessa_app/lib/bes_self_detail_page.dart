import 'package:flutter/material.dart';
import 'bes_fast_flow_page.dart';

class BesSelfDetailPage extends StatelessWidget {
  const BesSelfDetailPage({super.key});

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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _chipBg,
                        border: Border.all(color: _borderGrey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Kendim İçin',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Hayalinizdeki yaşam standartını yakalamak ve birikim hedefinize ulaşmak için tek tıkla bireysel emeklilik başlatma zamanı! Agessa BES\'in bir çok fon seçeneği ve %30 devlet katkısı avantajı ile birikim hedefine güvenle ulaşabilirsiniz.',
                      style: TextStyle(color: Colors.black87, height: 1.4),
                    ),
                    const SizedBox(height: 12),

                    // Bullet list inside a light card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _chipBg,
                        border: Border.all(color: _borderGrey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const _Bullets(),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const BesFastFlowPage(purpose: 'Kendim İçin'),
                    ),
                  );
                },
                child: const Text('Devam Et', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets();

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        'Minimum Katkı Payı Tutarı',
        'Aylık minimum 740,00 TL ile biriktirmeye başlayın.'
      ),
      (
        'Devlet Katkısı',
        '%30 devlet katkısı avantajı kazanın.'
      ),
      (
        'Fon Getirisi',
        'Ödediğiniz katkı payı ve devlet katkısı fonlarda değerlendirilir.'
      ),
      (
        'FonPro Avantajı',
        'Yatırımcı profilinize uygun fon danışmanlığı hizmetinden faydalanın.'
      ),
      (
        'Ek Katkı Payı',
        'Ek katkı payı ödeyerek birikimlerinizi artırın.'
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (title, desc) in items) ...[
          _BulletRow(title: title, desc: desc),
          const SizedBox(height: 10),
        ]
      ],
    );
  }
}

class _BulletRow extends StatelessWidget {
  final String title;
  final String desc;
  const _BulletRow({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.circle, size: 6, color: Colors.black54),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(color: Colors.black87)),
            ],
          ),
        )
      ],
    );
  }
}
