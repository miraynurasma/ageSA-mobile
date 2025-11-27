import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'services/market_service.dart';

class MarketsPage extends StatefulWidget {
  const MarketsPage({super.key});

  @override
  State<MarketsPage> createState() => _MarketsPageState();
}

class _MarketsPageState extends State<MarketsPage> {
  static const primaryBlue = Color(0xFF0D47A1);
  late Future<List<MarketItem>> _future;
  Timer? _timer;
  DateTime? _lastUpdate;
  List<MarketItem>? _lastItems;

  Future<List<MarketItem>> _load() async {
    final data = await MarketService.fetchMarkets();
    return data;
  }

  @override
  void initState() {
    super.initState();
    // 1) Önce cache'i deneyelim: varsa anında göster, yoksa network'e düş
    _future = MarketService.loadCached().then((cached) {
      if (cached != null) {
        // Cache'i hemen göster
        if (mounted) {
          _lastItems = cached;
          _lastUpdate = DateTime.now();
        }
        // Arka planda taze veri çek ve sadece anlamlı fark varsa UI'ı güncelle
        _load().then((fresh) {
          if (!mounted) return;
          if (_hasMeaningfulChange(_lastItems, fresh)) {
            setState(() {
              _future = Future.value(fresh);
              _lastItems = fresh;
              _lastUpdate = DateTime.now();
            });
          }
        });
        return cached;
      }
      // Cache yoksa normal network yüklemesi
      return _load();
    });
    // Her 60 sn'de bir kontrol et; sadece anlamlı değişim varsa UI'ı güncelle
    _timer = Timer.periodic(const Duration(seconds: 60), (_) async {
      if (!mounted) return;
      final data = await _load();
      if (!_hasMeaningfulChange(_lastItems, data)) return;
      setState(() {
        _future = Future.value(data); // bekleme ekranına düşmeden güncelle
        _lastItems = data;
        _lastUpdate = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final res = await _load();
    setState(() {
      _future = Future.value(res);
      _lastItems = res;
      _lastUpdate = DateTime.now();
    });
  }

  // Yeni verinin gerçekten değişip değişmediğini kontrol et
  bool _hasMeaningfulChange(List<MarketItem>? oldList, List<MarketItem> newList) {
    if (oldList == null) return true;
    if (oldList.length != newList.length) return true;
    // Kod bazında eşleştirip last ve changePct'te küçük farkları yoksay
    const eps = 0.001; // fiyat için ~0.1 kuruş tolerans
    final Map<String, MarketItem> oldByCode = {for (final e in oldList) e.code: e};
    for (final n in newList) {
      final o = oldByCode[n.code];
      if (o == null) return true;
      if ((o.last - n.last).abs() > eps) return true;
      final changeEps = n.code == 'ALTIN' ? 0.00005 : 0.001; // ALTIN için daha hassas eşik
      if ((o.changePct - n.changePct).abs() > changeEps) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Piyasalar'),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: FutureBuilder<List<MarketItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingList();
            }
            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                        const SizedBox(height: 12),
                        Text('Veri alınamadı: ${snapshot.error}', textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => setState(() => _future = _load()),
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            final items = snapshot.data ?? [];
            final df = NumberFormat('###,##0.00');
            final updateText = _lastUpdate == null
                ? ''
                : 'Son Güncelleme Tarihi: ${DateFormat('dd.MM.yyyy HH:mm').format(_lastUpdate!)}';

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Döviz / Altın Bilgileri',
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ...items.map((e) {
                  final isGold = e.code == 'ALTIN';
                  final ap = e.changePct.abs();
                  final isTinyGoldMove = isGold && ap > 0 && ap < 0.01;
                  final up = e.changePct > 0;
                  final isZero = isTinyGoldMove ? false : e.changePct == 0;
                  return _MarketCard(
                    emoji: _emojiFor(e.code),
                    title: e.code,
                    subtitle: _nameFor(e.code, e.name),
                    lastText: df.format(e.last),
                    changeText: _formatChange(e.code, e.changePct),
                    changeUp: up,
                    changeZero: isZero,
                    debugText: isGold ? MarketService.goldDebug : null,
                  );
                }),
                const SizedBox(height: 16),
                Text(updateText, style: const TextStyle(color: Colors.black54)),
              ],
            );
          },
        ),
      ),
    );
  }

  // Yüzde değişim formatı: tüm kalemlerde 2 hane.
  // ALTIN için: çok küçük ama sıfır olmayan değişimleri 0.01/−0.01 olarak göster (kullanıcıya canlılık hissettirmek için)
  String _formatChange(String code, double pct) {
    final nf = NumberFormat('##0.00');
    if (code == 'ALTIN') {
      final ap = pct.abs();
      // 0.00'a yuvarlanacak kadar küçük ama sıfır olmayan durumlarda alt sınır uygula
      if (ap > 0 && ap < 0.01) {
        return pct > 0 ? '0.01' : '-0.01';
      }
    }
    return nf.format(pct);
  }

  static String _emojiFor(String code) {
    switch (code) {
      case 'USD':
        return '🇺🇸';
      case 'EUR':
        return '🇪🇺';
      case 'GBP':
        return '🇬🇧';
      case 'ALTIN':
        return '🥇';
      default:
        return '💱';
    }
  }

  static String _nameFor(String code, String fallback) {
    switch (code) {
      case 'USD':
        return 'Dolar';
      case 'EUR':
        return 'Euro';
      case 'GBP':
        return 'Sterlin';
      case 'ALTIN':
        return 'Gram Altın';
      default:
        return fallback;
    }
  }
}

class _MarketCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String lastText;
  final String changeText;
  final bool changeUp;
  final bool changeZero;
  final String? debugText;

  const _MarketCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.lastText,
    required this.changeText,
    required this.changeUp,
    required this.changeZero,
    this.debugText,
  });

  @override
  Widget build(BuildContext context) {
    const borderGrey = Color(0xFFE3E6EC);
    final arrowColor = changeZero ? Colors.grey : (changeUp ? Colors.green : Colors.red);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFF2F4F7),
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          Icon(changeZero ? Icons.remove : (changeUp ? Icons.arrow_drop_up : Icons.arrow_drop_down), color: arrowColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('En Son', style: TextStyle(color: Colors.black54)),
              Text(lastText, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Değişim', style: TextStyle(color: Colors.black54)),
              Text('% $changeText',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: changeZero ? Colors.grey : (changeUp ? Colors.green : Colors.red),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 6,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemBuilder: (context, i) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 76,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE3E6EC)),
          ),
        );
      },
    );
  }
}
