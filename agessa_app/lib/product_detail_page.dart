import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'bes_calculator_page.dart';
import 'bes_fast_purchase_page.dart';

class ProductDetailPage extends StatelessWidget {
  final String productName;

  const ProductDetailPage({super.key, required this.productName});

  static const Color _primaryBlue = Color(0xFF0D47A1);

  Future<Map<String, dynamic>?> _loadDetails() async {
    final jsonStr = await rootBundle.loadString('assets/products.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final details = data['details'] as Map<String, dynamic>?;
    if (details == null) return null;
    final entry = details[productName];
    if (entry is Map<String, dynamic>) return entry;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        title: const Text('Ürün Detayları'),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _loadDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Detaylar yüklenemedi: ${snapshot.error}',
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final details = snapshot.data;
          final kisa = details?['kisaAciklama']?.toString();
          final uzun = details?['uzunAciklama']?.toString();
          final imageAsset = details?['imageAsset']?.toString();

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Optional header image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 180,
                          width: double.infinity,
                          child: imageAsset != null && imageAsset.isNotEmpty
                              ? Image.asset(
                                  imageAsset,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _placeholderHeader();
                                  },
                                )
                              : _placeholderHeader(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        productName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      if (kisa != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          kisa,
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                      const SizedBox(height: 12),
                      if (uzun != null)
                        Text(
                          uzun,
                          style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
                        )
                      else
                        const Text(
                          'Bu ürün için detay metni henüz eklenmedi.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _buildBottomButtons(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    // BES ile ilgili ürünlerde iki buton göster
    final isBESProduct = productName == 'BES Planları' || productName == 'Emeklilik Gelir Planı';
    
    if (isBESProduct) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BesCalculatorPage()),
                );
              },
              child: const Text('Birikim Hesaplama Aracı', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _primaryBlue, width: 1.5),
                      foregroundColor: _primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Talebiniz alındı. Sizinle en kısa sürede iletişime geçeceğiz.')),
                      );
                    },
                    child: const Text('Bana Ulaşın', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BesFastPurchasePage()),
                      );
                    },
                    child: const Text('BES Hızlı Satın Al', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Diğer ürünlerde tek buton
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Talebiniz alındı. Sizinle en kısa sürede iletişime geçeceğiz.')),
            );
          },
          child: const Text('Bana Ulaşın', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      );
    }
  }
}

Widget _placeholderHeader() {
  return Container(
    color: Colors.grey.shade200,
    alignment: Alignment.center,
    child: const Icon(Icons.family_restroom, size: 56, color: Colors.black38),
  );
}
