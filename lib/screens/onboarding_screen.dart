import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            children: [
              OnboardingPage(
                title: "Controla tu tiempo como si fuera dinero",
                subtitle: "Asigná un presupuesto y gastalo con conciencia",
                image: "assets/imgs/onboarding/onboarding_1.png",
                backgroundColor: Color(0xffffd1b9),
              ),
              OnboardingPage(
                title: "Alertas inteligentes",
                subtitle: "Recibí notificaciones cuando estés por excederte",
                image: "assets/imgs/onboarding/onboarding_2.png",
                backgroundColor: Color(0xfffffdf3),
              ),
              OnboardingPage(
                title: "Ganá recompensas",
                subtitle: "Ahorrá tiempo de pantalla y subí de nivel",
                image: "assets/imgs/onboarding/onboarding_3.png",
                backgroundColor: Color(0xffb2dcc4),
              ),
            ],
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: 3,
                effect: WormEffect(dotHeight: 10, dotWidth: 10),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Botón blanco (Crear cuenta)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 4,
                    shadowColor: Colors.black26,
                    shape: const StadiumBorder(),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Crear una cuenta"),
                ),
                const SizedBox(height: 10),
                // Botón negro (Iniciar sesión)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.black26,
                    shape: const StadiumBorder(),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Iniciar sesión"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final Color backgroundColor;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 350),
          SizedBox(height: 40),
          Text(title.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Text(subtitle,
              textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
