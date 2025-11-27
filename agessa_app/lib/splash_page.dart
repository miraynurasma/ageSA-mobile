import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashPage extends StatefulWidget {
  final WidgetBuilder? nextBuilder; // if null, will just pop after delay
  const SplashPage({super.key, this.nextBuilder});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Short transition: 800 ms
    Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final builder = widget.nextBuilder;
      if (builder != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: builder),
        );
      } else {
        Navigator.of(context).maybePop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SvgPicture.asset(
          'assets/logo.svg',
          height: 96,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
