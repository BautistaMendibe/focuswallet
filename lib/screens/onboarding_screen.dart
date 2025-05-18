import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
                title: "Gasta tu tiempo como dinero",
                subtitle:
                    "Cada día tenés un presupuesto de \$2 dólares virtuales. Usar tu celular cuesta: cada hora equivale a \$1 dólar. ¡Elegí cómo lo gastás!",
                image: "assets/imgs/onboarding/onboarding_1.png",
              ),
              OnboardingPage(
                title: "Cada app tiene su propio presupuesto",
                subtitle:
                    "Instagram, TikTok, Netflix… asigná cuánto estás dispuesto a “gastar” por cada una. Controlá el uso y evitá los excesos sin darte cuenta.",
                image: "assets/imgs/onboarding/onboarding_2.png",
              ),
              OnboardingPage(
                title: "Tomá el control de tu atención",
                subtitle:
                    "El único método comprobado para dejar de usar tanto el celular. Tu atención, tu libertadf.",
                image: "assets/imgs/onboarding/onboarding_3.png",
              ),
            ],
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: WormEffect(dotHeight: 10, dotWidth: 10,dotColor: Color.fromARGB(255, 217, 217, 217), activeDotColor: Colors.indigoAccent),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('seenOnboarding', true);
                    if (!context.mounted) return;
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
                ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('seenOnboarding', true);
                    if (!context.mounted) return;
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.indigoAccent,
                    shape: const StadiumBorder(),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Iniciar sesión"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 300),
          SizedBox(height: 20),
          Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
