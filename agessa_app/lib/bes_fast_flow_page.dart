import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BesFastFlowPage extends StatefulWidget {
  final String purpose; // 'Kendim İçin' | 'Çocuğum İçin'
  const BesFastFlowPage({super.key, required this.purpose});

  @override
  State<BesFastFlowPage> createState() => _BesFastFlowPageState();
}

class _BesFastFlowPageState extends State<BesFastFlowPage> {
  static const Color _primaryBlue = Color(0xFF0D47A1);
  final _formKey = GlobalKey<FormState>();

  final _tcknCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  DateTime? _birthDate;
  bool _kvkk = false;
  bool _eula = false;

  int _step = 1; // 1..4

  // Step 2 state
  final _startCtrl = TextEditingController();
  final _monthlyCtrl = TextEditingController();
  String? _term; // 120 Ay, 180 Ay, 240 Ay
  int _paymentDay = 1; // 1..28

  // Step 3 state
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();

  // Step 4 state
  bool _finalConsent = false;

  @override
  void dispose() {
    _tcknCtrl.dispose();
    _phoneCtrl.dispose();
    _startCtrl.dispose();
    _monthlyCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _districtCtrl.dispose();
    super.dispose();
  }

  bool _step1Valid() {
    final t = _tcknCtrl.text.trim();
    final p = _phoneCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    final tOk = t.length == 11 && int.tryParse(t) != null;
    final pOk = p.length >= 10;
    return tOk && pOk && _birthDate != null && _kvkk && _eula;
  }

  bool _step2Valid() {
    final start = double.tryParse(_startCtrl.text.replaceAll(',', '.')) ?? 0;
    final monthly = double.tryParse(_monthlyCtrl.text.replaceAll(',', '.')) ?? 0;
    final dayOk = _paymentDay >= 1 && _paymentDay <= 28;
    return monthly > 0 && start >= 0 && _term != null && dayOk;
  }

  bool _step3Valid() {
    return _addressCtrl.text.trim().isNotEmpty &&
        _cityCtrl.text.trim().isNotEmpty &&
        _districtCtrl.text.trim().isNotEmpty;
  }

  bool _step4Valid() {
    return _finalConsent;
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        title: const Text('BES Hızlı Satın Al'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _StepperHeader(current: _step),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: _buildStep(),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canContinue() ? _primaryBlue : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _canContinue() ? _onContinue : null,
                child: Text(_step < 4 ? 'Devam Et' : 'Başvuruyu Tamamla',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canContinue() {
    switch (_step) {
      case 1:
        return _step1Valid();
      case 2:
        return _step2Valid();
      case 3:
        return _step3Valid();
      case 4:
        return _step4Valid();
      default:
        return false;
    }
  }

  void _onContinue() {
    if (_step < 4) {
      setState(() => _step += 1);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başvurunuz alındı. En kısa sürede sizinle iletişime geçeceğiz.')),
      );
      Navigator.of(context).pop();
    }
  }

  Widget _buildStep() {
    switch (_step) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      case 4:
        return _buildStep4();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Katılımcı Bilgileri',
          style: TextStyle(color: _primaryBlue, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text(
          'Bireysel emeklilik hesabınızı açabilmemiz için öncelikle aşağıdaki bilgileri giriniz.',
          style: TextStyle(color: Colors.black87),
        ),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tcknCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'TC Kimlik Numarası',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Cep Telefonu',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
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
                    labelText: 'Doğum Tarihi',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _birthDate == null
                            ? 'Seçiniz'
                            : '${_birthDate!.day.toString().padLeft(2, '0')}.${_birthDate!.month.toString().padLeft(2, '0')}.${_birthDate!.year}',
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const Icon(Icons.event, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Lütfen TC. Kimlik Numaranız ile doğum tarihinizin doğruluğundan emin olunuz.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Theme(
                data: Theme.of(context).copyWith(
                  checkboxTheme: CheckboxThemeData(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    side: MaterialStateBorderSide.resolveWith(
                      (states) => BorderSide(color: Colors.grey.shade400, width: 1.4),
                    ),
                    fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.selected)) return _primaryBlue;
                      return Colors.white;
                    }),
                    checkColor: MaterialStateProperty.all<Color>(Colors.white),
                    visualDensity: VisualDensity.compact,
                  ),
                  listTileTheme: const ListTileThemeData(
                    contentPadding: EdgeInsets.zero,
                    horizontalTitleGap: 8,
                  ),
                ),
                child: Column(
                  children: [
                    CheckboxListTile(
                      value: _kvkk,
                      onChanged: (v) => setState(() => _kvkk = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text('Kişisel Verilerin İşlenmesi Hakkında Aydınlatma Metni\'ni okudum, onaylıyorum. '),
                          GestureDetector(
                            onTap: () => _openUrl('https://www.mevzuat.gov.tr/mevzuat?MevzuatNo=6698&MevzuatTur=1&MevzuatTertip=5'),
                            child: const Text('Metni aç', style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    CheckboxListTile(
                      value: _eula,
                      onChanged: (v) => setState(() => _eula = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text('Agessa Müşteri Mobil Uygulama Kullanıcı Sözleşmesi\'ni okudum, anladım. '),
                          GestureDetector(
                            onTap: () => _openUrl('https://www.google.com'),
                            child: const Text('Sözleşmeyi aç', style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Step 2: Katkı Tutarı ve Tercihler
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Katkı Tutarı ve Tercihler',
          style: TextStyle(color: _primaryBlue, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text('Aylık katkınızı, varsa başlangıç tutarınızı ve vade seçiminizi belirleyin.'),
        const SizedBox(height: 16),
        TextFormField(
          controller: _monthlyCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Aylık Katkı (₺)',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _startCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Toplu Başlangıç (₺) - opsiyonel',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _term,
          items: const [
            DropdownMenuItem(value: '120 Ay', child: Text('120 Ay')),
            DropdownMenuItem(value: '180 Ay', child: Text('180 Ay')),
            DropdownMenuItem(value: '240 Ay', child: Text('240 Ay')),
          ],
          onChanged: (v) => setState(() => _term = v),
          decoration: const InputDecoration(
            labelText: 'Vade (Ay)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Ödeme Günü',
            border: OutlineInputBorder(),
          ),
          child: Row(
            children: [
              Expanded(
                child: Slider(
                  min: 1,
                  max: 28,
                  divisions: 27,
                  value: _paymentDay.toDouble(),
                  label: _paymentDay.toString(),
                  onChanged: (v) => setState(() => _paymentDay = v.round()),
                ),
              ),
              SizedBox(
                width: 40,
                child: Text('$_paymentDay', textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Step 3: Sözleşme Bilgileri
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sözleşme Bilgileri',
          style: TextStyle(color: _primaryBlue, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text('Sözleşme ve tebligat için adres bilgilerinizi giriniz.'),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Açık Adres',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityCtrl,
                decoration: const InputDecoration(
                  labelText: 'Şehir',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _districtCtrl,
                decoration: const InputDecoration(
                  labelText: 'İlçe',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Step 4: Özet ve Onay
  Widget _buildStep4() {
    final start = double.tryParse(_startCtrl.text.replaceAll(',', '.')) ?? 0;
    final monthly = double.tryParse(_monthlyCtrl.text.replaceAll(',', '.')) ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Özet ve Onay',
          style: TextStyle(color: _primaryBlue, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7FB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE3E6EC)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryRow('Amaç', widget.purpose),
              _summaryRow('Aylık Katkı', '${monthly.toStringAsFixed(0)} ₺'),
              _summaryRow('Toplu Başlangıç', '${start.toStringAsFixed(0)} ₺'),
              _summaryRow('Vade', _term ?? '-'),
              _summaryRow('Ödeme Günü', '$_paymentDay'),
              const Divider(),
              _summaryRow('Adres', _addressCtrl.text.trim()),
              _summaryRow('Şehir/İlçe', '${_cityCtrl.text.trim()} / ${_districtCtrl.text.trim()}'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: _finalConsent,
          onChanged: (v) => setState(() => _finalConsent = v ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Bilgilerimin doğruluğunu onaylıyorum ve başvuruyu tamamlamak istiyorum.'),
        ),
      ],
    );
  }

  Widget _summaryRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 150, child: Text(k, style: const TextStyle(color: Colors.black54))),
          Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

}

class _StepperHeader extends StatelessWidget {
  final int current; // 1..4
  const _StepperHeader({required this.current});

  @override
  Widget build(BuildContext context) {
    const Color primary = _BesColors.primaryBlue;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final step = i + 1;
        final active = step <= current;
        return Row(
          children: [
            _Circle(number: step, active: active),
            if (i < 3)
              Container(
                width: 36,
                height: 2,
                color: active ? primary : Colors.grey.shade300,
              ),
          ],
        );
      }),
    );
  }
}

class _Circle extends StatelessWidget {
  final int number;
  final bool active;
  const _Circle({required this.number, required this.active});

  @override
  Widget build(BuildContext context) {
    const Color primary = _BesColors.primaryBlue;
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? primary : Colors.white,
        border: Border.all(color: active ? primary : Colors.grey.shade300),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$number',
        style: TextStyle(
          color: active ? Colors.white : Colors.black54,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BesColors {
  static const Color primaryBlue = Color(0xFF0D47A1);
}
