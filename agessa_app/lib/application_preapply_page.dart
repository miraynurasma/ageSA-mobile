import 'package:flutter/material.dart';

class ApplicationPreApplyPage extends StatefulWidget {
  const ApplicationPreApplyPage({super.key});

  @override
  State<ApplicationPreApplyPage> createState() => _ApplicationPreApplyPageState();
}

class _ApplicationPreApplyPageState extends State<ApplicationPreApplyPage> {
  final _formKey = GlobalKey<FormState>();

  final _productCtrl = TextEditingController(text: 'BES');
  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _advisorCtrl = TextEditingController();

  bool _kvkk = false;
  bool _eticar = false;

  @override
  void dispose() {
    _productCtrl.dispose();
    _nameCtrl.dispose();
    _surnameCtrl.dispose();
    _idCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _advisorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D47A1);
    const borderGrey = Color(0xFFE3E6EC);

    InputDecoration deco(String hint) => InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderGrey),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: primaryBlue, width: 1.5),
          ),
        );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        title: const Text('Ön Başvuru Yap'),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Ürün
            TextFormField(
              controller: _productCtrl,
              decoration: deco('Detaylı bilgi almak istediğim ürün'),
              readOnly: true,
            ),
            const SizedBox(height: 16),

            const Text('Kişisel Bilgiler', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              decoration: deco('Ad'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Zorunlu alan' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _surnameCtrl,
              decoration: deco('Soyad'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Zorunlu alan' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _idCtrl,
              keyboardType: TextInputType.number,
              decoration: deco('TC/Yabancı Kimlik/ Mavi Kart No'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: deco('E-posta Adresi'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: deco('Cep Telefonu'),
            ),

            const SizedBox(height: 20),
            const Text('Danışman Bilgileri', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _advisorCtrl,
              keyboardType: TextInputType.number,
              decoration: deco('Satış Danışmanı Sicil Numarası'),
            ),

            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _kvkk,
                  onChanged: (v) => setState(() => _kvkk = v ?? false),
                  shape: const CircleBorder(),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text("Aydınlatma Metni'ni okudum, onaylıyorum.",
                      style: TextStyle(color: Colors.black54)),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _eticar,
                  onChanged: (v) => setState(() => _eticar = v ?? false),
                  shape: const CircleBorder(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Colors.black54),
                      children: [
                        TextSpan(text:
                            'Agessa ürün ve hizmetlerine ilişkin Satış Danışmanı tarafından aranmayı onaylıyorum. '),
                        TextSpan(
                          text: 'E-ticaret izni',
                          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: "'ni okudum, onaylıyorum."),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: (_kvkk && _eticar && _formKey.currentState?.validate() == true)
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ön başvuru bilgileri kaydedildi (demo).')),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                disabledBackgroundColor: primaryBlue.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Devam Et', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
