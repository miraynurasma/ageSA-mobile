import 'package:flutter/material.dart';
import 'bes_fast_purchase_page.dart';
import 'contact_form_page.dart';

class BesCalculatorPage extends StatefulWidget {
  const BesCalculatorPage({super.key});

  @override
  State<BesCalculatorPage> createState() => _BesCalculatorPageState();
}

class _BesCalculatorPageState extends State<BesCalculatorPage> {
  static const Color _primaryBlue = Color(0xFF0D47A1);

  final _formKey = GlobalKey<FormState>();
  final _startAmountCtrl = TextEditingController();
  final _monthlyCtrl = TextEditingController();

  DateTime? _birthDate;
  String? _plan;
  double _targetAge = 56;

  String? _resultText;

  @override
  void dispose() {
    _startAmountCtrl.dispose();
    _monthlyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        title: const Text('Birikim Hesaplama Aracı'),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agessa ile hayalinizdeki emeklilik için bugünden birikime başlayın. Aşağıdaki bilgileri girerek basit bir simülasyon görebilirsiniz.',
                  style: TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 16),

                // Toplu Başlangıç Tutarı
                TextFormField(
                  controller: _startAmountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Toplu Başlangıç Tutarı',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Aylık Katkı Payı
                TextFormField(
                  controller: _monthlyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Aylık Katkı Payı',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Aylık katkı giriniz';
                    final val = double.tryParse(v.replaceAll(',', '.'));
                    if (val == null || val <= 0) return 'Geçerli bir tutar giriniz';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Doğum Tarihi
                InkWell(
                  onTap: () async {
                    final now = DateTime.now();
                    final initial = DateTime(now.year - 30, now.month, now.day);
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _birthDate ?? initial,
                      firstDate: DateTime(1940),
                      lastDate: DateTime(now.year, now.month, now.day),
                    );
                    if (picked != null) setState(() => _birthDate = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Doğum Tarihiniz',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _birthDate == null
                          ? 'Seçiniz'
                          : '${_birthDate!.day.toString().padLeft(2, '0')}.${_birthDate!.month.toString().padLeft(2, '0')}.${_birthDate!.year}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Emeklilik Planı
                DropdownButtonFormField<String>(
                  value: _plan,
                  items: const [
                    DropdownMenuItem(value: '120 Ay', child: Text('120 Ay')),
                    DropdownMenuItem(value: '180 Ay', child: Text('180 Ay')),
                    DropdownMenuItem(value: '240 Ay', child: Text('240 Ay')),
                  ],
                  onChanged: (v) => setState(() => _plan = v),
                  decoration: const InputDecoration(
                    labelText: 'Emeklilik Planı',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Hedef Emeklilik Yaşı
                Text('Emekli olmayı planladığınız yaş: ${_targetAge.round()} yaş'),
                Slider(
                  min: 45,
                  max: 70,
                  divisions: 25,
                  value: _targetAge,
                  onChanged: (v) => setState(() => _targetAge = v),
                ),

                const SizedBox(height: 8),

                // Hesapla Butonu
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
                      if (!_formKey.currentState!.validate()) return;
                      final start = double.tryParse(_startAmountCtrl.text.replaceAll(',', '.')) ?? 0;
                      final monthly = double.tryParse(_monthlyCtrl.text.replaceAll(',', '.')) ?? 0;

                      // Basit, temsili birikim formülü (faiz varsayımı olmadan):
                      final years = (_targetAge - _estimatedAge()).clamp(0, 80);
                      final total = start + (monthly * 12 * years);

                      setState(() {
                        _resultText = 'Tahmini birikim: ${total.toStringAsFixed(0)} ₺';
                      });
                    },
                    child: const Text('Hesapla', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),

                if (_resultText != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F7FB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE3E6EC)),
                    ),
                    child: Text(
                      _resultText!,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Alt Butonlar
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: _primaryBlue, width: 1.5),
                            foregroundColor: _primaryBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ContactFormPage(serviceTitle: 'Emeklilik Planları'),
                              ),
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
            ),
          ),
        ),
      ),
    );
  }

  double _estimatedAge() {
    if (_birthDate == null) return 30; // varsayılan
    final now = DateTime.now();
    double age = now.year - _birthDate!.year.toDouble();
    final hasHadBirthday = (now.month > _birthDate!.month) ||
        (now.month == _birthDate!.month && now.day >= _birthDate!.day);
    if (!hasHadBirthday) age -= 1;
    return age;
  }
}
