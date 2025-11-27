import 'package:flutter/material.dart';
import 'contact_form_page.dart';

class FundInvestmentAdvicePage extends StatelessWidget {
  const FundInvestmentAdvicePage({super.key});

  static const Color _primaryBlue = Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        title: const Text('Fon Yatırımcı Tavsiyeleri'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/herkese_fon.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.trending_up,
                        size: 64,
                        color: Colors.black38,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // FonPro Services
            _buildFonProCard(
              context,
              icon: Icons.shield_outlined,
              title: 'FonPro Uzmana Bırak',
              description: 'Fonlarınızı Ak Portföy\'ün uzman fon yönetim danışmanlarının yönetimine bırakabilir, birikimlerinizi fon değişikliği yapmanıza gerek kalmadan değişen piyasa koşullarına göre değerlendirebilirsiniz.',
            ),

            _buildFonProCard(
              context,
              icon: Icons.thumb_up_outlined,
              title: 'FonPro Tavsiye Al',
              description: 'Değişen piyasa koşullarına göre Ak Portföy tarafından size özel oluşturulan, dört farklı kategorideki fon paketlerimizden birini seçebilir, piyasa koşullarına göre fon dağılımı önerisi alarak birikimlerinizi beklentinize en uygun şekilde değerlendirebilirsiniz.',
            ),

            _buildFonProCard(
              context,
              icon: Icons.trending_up_outlined,
              title: 'FonPro Kendin Yönet',
              description: 'Geniş fon yelpazesi içinden fon seçimini siz yapabilirsiniz. Yılda 12 kez fon değişikliği hakkınızı kullanarak birikimlerinizi yönetebilir, beklentilerinizi doğrultusunda getiri elde edebilirsiniz.',
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFonProCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                  color: _primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: _primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
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
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Detaylı bilgi yakında eklenecek.')),
                  );
                },
                child: const Text(
                  'Detaylı Bilgi',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ContactFormPage(serviceTitle: title),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Bana Ulaşın',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
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
