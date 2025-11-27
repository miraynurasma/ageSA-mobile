import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactFormPage extends StatefulWidget {
  final String serviceTitle;
  const ContactFormPage({super.key, required this.serviceTitle});

  @override
  State<ContactFormPage> createState() => _ContactFormPageState();
}

class _ContactFormPageState extends State<ContactFormPage> {
  static const Color _primaryBlue = Color(0xFF0D47A1);
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _tcknController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedCity;
  String? _selectedDistrict;

  final List<String> _cities = <String>[
    'Adana','Adıyaman','Afyonkarahisar','Ağrı','Aksaray','Amasya','Ankara','Antalya','Ardahan','Artvin',
    'Aydın','Balıkesir','Bartın','Batman','Bayburt','Bilecik','Bingöl','Bitlis','Bolu','Burdur',
    'Bursa','Çanakkale','Çankırı','Çorum','Denizli','Diyarbakır','Düzce','Edirne','Elazığ','Erzincan',
    'Erzurum','Eskişehir','Gaziantep','Giresun','Gümüşhane','Hakkari','Hatay','Iğdır','Isparta','İstanbul',
    'İzmir','Kahramanmaraş','Karabük','Karaman','Kars','Kastamonu','Kayseri','Kırıkkale','Kırklareli','Kırşehir',
    'Kilis','Kocaeli','Konya','Kütahya','Malatya','Manisa','Mardin','Mersin','Muğla','Muş',
    'Nevşehir','Niğde','Ordu','Osmaniye','Rize','Sakarya','Samsun','Siirt','Sinop','Sivas',
    'Şanlıurfa','Şırnak','Tekirdağ','Tokat','Trabzon','Tunceli','Uşak','Van','Yalova','Yozgat','Zonguldak'
  ];
  final Map<String, List<String>> _districts = <String, List<String>>{
    'İstanbul': ['Kadıköy','Beşiktaş','Üsküdar','Bakırköy'],
    'Ankara': ['Çankaya','Keçiören','Yenimahalle'],
    'İzmir': ['Konak','Karşıyaka','Bornova'],
  };

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _tcknController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Talebiniz alındı. Sizinle en kısa sürede iletişime geçeceğiz.')),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _openKvkk() async {
    final uri = Uri.parse('https://www.mevzuat.gov.tr/mevzuat?MevzuatNo=6698&MevzuatTur=1&MevzuatTertip=5');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bağlantı açılamadı.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        title: const Text('İletişim Formu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Size ulaşabilmemiz için lütfen aşağıdaki bilgileri doldurun. En kısa sürede sizinle iletişime geçeceğiz.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration('Ad'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Lütfen ad girin' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lastNameController,
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration('Soyad'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Lütfen soyad girin' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _tcknController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration('TC Kimlik Numarası'),
                    validator: (v) {
                      final s = v?.trim() ?? '';
                      if (s.length != 11 || int.tryParse(s) == null) return '11 haneli TCKN girin';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration('E-mail Adresi'),
                    validator: (v) {
                      final s = v?.trim() ?? '';
                      final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);
                      return ok ? null : 'Geçerli bir e-posta girin';
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration('Cep Telefonu Numarası'),
                    validator: (v) {
                      final s = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                      return s.length < 10 ? 'Geçerli bir telefon girin' : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedCity,
                        decoration: _inputDecoration('Şehir'),
                        items: _cities
                            .map((c) => DropdownMenuItem<String>(
                              value: c, 
                              child: Text(
                                c,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              )
                            ))
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            _selectedCity = v;
                            _selectedDistrict = null;
                          });
                        },
                        validator: (v) => v == null ? 'Şehir seçin' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedDistrict,
                        decoration: _inputDecoration('İlçe'),
                        items: (_districts[_selectedCity ?? ''] ?? const <String>[])
                            .map((d) => DropdownMenuItem<String>(
                              value: d, 
                              child: Text(
                                d,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              )
                            ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedDistrict = v),
                        validator: (v) {
                          final list = _districts[_selectedCity ?? ''] ?? const <String>[];
                          if (list.isNotEmpty && v == null) return 'İlçe seçin';
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    readOnly: true,
                    initialValue: widget.serviceTitle,
                    decoration: _inputDecoration('Detaylı bilgi almak istediğim ürün'),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                        children: [
                          const TextSpan(text: '6698 sayılı Kişisel Verilerin Korunması Kanunu kapsamında, kişisel verilerinizin işlenmesi metnini okudum. M-Güzel Yatırım İşlemci ve Hizmetler Anonim Şirketi tarafından kişisel verilerimin işlenmesine '),
                          TextSpan(
                            text: 'tıklayınız',
                            style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()..onTap = _openKvkk,
                          ),
                          const TextSpan(text: ' için onay veriyorum.'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFormValid() ? _primaryBlue : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isFormValid() ? _submit : null,
                      child: const Text(
                        'Gönder',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isFormValid() {
    final tckn = _tcknController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final emailOk = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    final districts = _districts[_selectedCity ?? ''] ?? const <String>[];
    final districtOk = districts.isEmpty || _selectedDistrict != null;
    return _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        tckn.length == 11 && int.tryParse(tckn) != null &&
        emailOk && phone.length >= 10 &&
        _selectedCity != null && districtOk;
  }
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF0D47A1)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.red),
    ),
  );
}
