import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
  
}




class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller; 
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2)
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    }
    );
    super.initState();
   
  }
  
@override
  void dispose() {
    _controller.dispose();
    super.dispose();
   
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation, 
          child: Text(
            'Life is Art\nPaint your dreams 🖌️',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold,
              color: Colors.purple
            ),
          ),
          ),
      ),
     );
  }
  
}