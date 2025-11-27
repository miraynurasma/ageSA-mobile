import 'package:flutter/material.dart';

class ApplicationStatusPage extends StatefulWidget {
  const ApplicationStatusPage({super.key});

  @override
  State<ApplicationStatusPage> createState() => _ApplicationStatusPageState();
}

class _ApplicationStatusPageState extends State<ApplicationStatusPage> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();

  @override
  void dispose() {
    _idCtrl.dispose();
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
        title: const Text('Başvuru Durumu'),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Başvurularınızın durumunu takip etmek için lütfen kimlik bilginizi giriniz.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _idCtrl,
              onChanged: (_) => setState(() {}),
              keyboardType: TextInputType.number,
              decoration: deco('TC/Yabancı Kimlik No/Mavi Kart No'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Zorunlu alan' : null,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_idCtrl.text.trim().isNotEmpty && _formKey.currentState?.validate() == true)
                  ? () {
                      FocusScope.of(context).unfocus();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Başvurular sorgulandı (demo).')),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                disabledBackgroundColor: primaryBlue.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Başvurularımı Sorgula', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    );
  }
}
