import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'splash_page.dart';
import 'login_page.dart';
import 'services/chatbot_service.dart';

// Brand colors
const kPrimaryBlue = Color(0xFF6C5CE7); // canlı orta ton mor
const kAccentGreen = Color(0xFF16A34A); // güven veren yeşil

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    ChatbotService().initialize();
  } catch (e) {
    print('Chatbot servisi başlatılamadı: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agessa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryBlue),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryBlue,
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kAccentGreen,
          foregroundColor: Colors.white,
          elevation: 3,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          hintStyle: const TextStyle(color: Colors.black38),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE3E6EC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE3E6EC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kPrimaryBlue, width: 1.6),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.06),
          margin: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE9EDF3),
          thickness: 1,
          space: 1,
        ),
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          side: const BorderSide(color: Color(0xFFB8C2D1)),
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return kPrimaryBlue;
            return Colors.white;
          }),
          checkColor: const WidgetStatePropertyAll(Colors.white),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return kPrimaryBlue;
            return const Color(0xFFB8C2D1);
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return kPrimaryBlue.withOpacity(0.35);
            return const Color(0xFFB8C2D1).withOpacity(0.35);
          }),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: kPrimaryBlue,
          titleTextStyle: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
          subtitleTextStyle: TextStyle(color: Colors.black54),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
      ),
      // Tüm uygulamadaki metinleri global olarak ~%10 büyüt
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.1),
          ),
          child: child!,
        );
      },
      home: SplashPage(nextBuilder: (_) => const LoginPage()),
    );
  }
}
// end of file
