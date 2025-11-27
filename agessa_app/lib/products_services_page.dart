import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'chat_bot_page.dart';
import 'product_detail_page.dart';
import 'fund_investment_advice_page.dart';
import 'bes_calculator_page.dart';

class ProductsServicesPage extends StatelessWidget {
  const ProductsServicesPage({super.key});

  static const Color _primaryBlue = Color(0xFF0D47A1);
  static const Color _borderGrey = Color(0xFFE3E6EC);
  static const Color _chipBg = Color(0xFFF6F7FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürünler ve Hizmetler'),
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              // Section Title
              const Text(
                'Agessa Çözümleri',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),

              // Big primary card (Test)
              _SolutionCard(
                icon: Icons.edit,
                title: 'Bana En Uygun Ürünler Hangileri',
                subtitle: "Chatbot'a sor",
                subtitleIcon: Icons.smart_toy_outlined,
                subtitleIconColor: Colors.orange,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChatBotPage()),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Two small cards side by side
              Row(
                children: [
                  Expanded(
                    child: _SolutionCard.small(
                      icon: Icons.thumb_up,
                      title: 'Fon Yatırımcı Tavsiyeleri',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const FundInvestmentAdvicePage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SolutionCard.small(
                      icon: Icons.calculate,
                      title: 'Birikim Hesaplama Aracı',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const BesCalculatorPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // All Products section title (primary blue)
              Text(
                'Tüm Agessa Ürünleri',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ).copyWith(color: _primaryBlue),
              ),
              const SizedBox(height: 8),
              const _AllProductsSection(),
            ],
          ),
        ),
      ),
    );
  }

}

class _AllProductsSection extends StatelessWidget {
  const _AllProductsSection();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: rootBundle.loadString('assets/products.json'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ProductsServicesPage._chipBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ProductsServicesPage._borderGrey),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Ürünler yükleniyor...'),
              ],
            ),
          );
        }
        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.04),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              'Ürün verisi yüklenemedi: ${snapshot.error}',
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        try {
          final data = json.decode(snapshot.data!) as Map<String, dynamic>;
          final List categories = (data['categories'] as List?) ?? [];

          if (categories.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ProductsServicesPage._chipBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ProductsServicesPage._borderGrey),
              ),
              child: const Text(
                'Henüz ürün bulunamadı.',
                style: TextStyle(color: Colors.black54),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final cat in categories)
                () {
                  final map = cat as Map<String, dynamic>;
                  final title = map['name']?.toString() ?? 'Kategori';
                  final items = (map['items'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];
                  return _CategoryBlock(title: title, items: items);
                }(),
            ],
          );
        } catch (e) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.04),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              'Beklenmeyen veri biçimi: $e',
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }
      },
    );
  }
}

class _CategoryBlock extends StatelessWidget {
  final String title;
  final List<String> items;

  const _CategoryBlock({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header - small, grey, uppercase
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black54,
                letterSpacing: 0.3,
              ),
            ),
          ),

          // Product rows as cards
          Column(
            children: [
              for (final item in items)
                _ProductRow(
                  title: item,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailPage(productName: item),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _ProductRow({required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ProductsServicesPage._borderGrey),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SolutionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool compact;
  final String? subtitle;
  final IconData? subtitleIcon;
  final Color? subtitleIconColor;

  const _SolutionCard({
    required this.icon,
    required this.title,
    this.onTap,
    this.subtitle,
    this.subtitleIcon,
    this.subtitleIconColor,
  }) : compact = false;

  const _SolutionCard.small({
    required this.icon,
    required this.title,
    this.onTap,
    this.subtitle,
    this.subtitleIcon,
    this.subtitleIconColor,
  }) : compact = true;

  static const Color _primaryBlue = Color(0xFF0D47A1);
  static const Color _borderGrey = Color(0xFFE3E6EC);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          constraints: BoxConstraints(
            minHeight: compact ? 76 : 0,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderGrey),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryBlue.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: _primaryBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (compact)
                      Text(
                        title,
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          color: Colors.black87,
                          height: 1.22,
                        ),
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              softWrap: false,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Colors.black87,
                                height: 1.22,
                              ),
                            ),
                          ),
                          // Question icon intentionally removed per request
                        ],
                      ),
                    if (subtitle != null && !compact) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (subtitleIcon != null)
                            Icon(
                              subtitleIcon,
                              size: 18,
                              color: subtitleIconColor ?? Colors.orange,
                            ),
                          if (subtitleIcon != null) const SizedBox(width: 6),
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (!compact) const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}
