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
                subtitle: "Cada día tenés un presupuesto de $2 dólares virtuales. Usar tu celular cuesta: cada hora equivale a $1 dólar. ¡Elegí cómo lo gastás!",
                image: "assets/imgs/onboarding/onboarding_1.png",
              ),
              OnboardingPage(
                title: "Cada app tiene su propio presupuesto",
                subtitle: "Instagram, TikTok, Netflix… asigná cuánto estás dispuesto a “gastar” por cada una. Controlá el uso y evitá los excesos sin darte cuenta.",
                image: "assets/imgs/onboarding/onboarding_2.png",
              ),
              OnboardingPage(
                title: "Tomá el control de tu atención",
                subtitle: "Visualizá en tiempo real cuánto consumiste, qué apps usás más y decidí si querés comprar más tiempo o dejarlo ahí. Tu atención, tu decisión.",
                image: "assets/imgs/onboarding/onboarding_3.png",
              ),
            ],
          ),
          Positioned(
            bottom: 10,
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
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Botón blanco (Crear cuenta)
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
                // Botón negro (Iniciar sesión)
                ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('seenOnboarding', true);
                    if (!context.mounted) return;

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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 320),
          SizedBox(height: 20),
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
