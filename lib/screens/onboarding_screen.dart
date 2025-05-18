import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            children: [
              OnboardingPage(
                title: loc.onboarding1Title,
                subtitle: loc.onboarding1Subtitle,
                image: "assets/imgs/onboarding/onboarding_1.png",
              ),
              OnboardingPage(
                title: loc.onboarding2Title,
                subtitle: loc.onboarding2Subtitle,
                image: "assets/imgs/onboarding/onboarding_2.png",
              ),
              OnboardingPage(
                title: loc.onboarding3Title,
                subtitle: loc.onboarding3Subtitle,
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
                  effect: WormEffect(
                    dotHeight: 10,
                    dotWidth: 10,
                    dotColor: const Color.fromARGB(255, 217, 217, 217),
                    activeDotColor: const Color(0xFF009792),
                  ),
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
                  child: Text(loc.createAccount),
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
                    backgroundColor: const Color(0xFF009792),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0xFF009792),
                    shape: const StadiumBorder(),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(loc.login),
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
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 300),
          const SizedBox(height: 20),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
