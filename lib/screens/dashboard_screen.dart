import 'package:flutter/material.dart';
import 'package:focuswallet/components/budget_summary.dart';
import 'package:focuswallet/components/today_use_card.dart';
import 'package:focuswallet/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _getUserDisplayName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return '';
    if (user.displayName != null) return user.displayName!;
    // Extract name from email (everything before @)
    return user.email?.split('@')[0] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final displayName = _getUserDisplayName();
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Today'),
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Overview'),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Budget'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      authService.logout();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const CircleAvatar(
                        radius: 24,
                        child: Text(
                          '👨🏼',
                          style: TextStyle(fontSize: 25),
                        )),
                  ),
                  const SizedBox(width: 12),
                  Text("${loc.hello},\n$displayName!",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Row(
                    children: const [
                      Text(
                        '🔥',
                        style: TextStyle(fontSize: 25),
                      ),
                      SizedBox(width: 4),
                      Text('3',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Balance
              Center(
                child: Text("\$1",
                    style:
                        TextStyle(fontSize: 46, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 25),

              // Progress bar
              BudgetSummary(
                spentAmount: 1,
                spentHours: 1,
                budgetAmount: 2,
                budgetHours: 2,
                segments: [
                  BudgetSegment(
                      fraction: 0.25, color: Colors.deepOrange), // Spotify
                  BudgetSegment(
                      fraction: 0.25, color: Colors.lightBlue), // TikTok
                  BudgetSegment(
                      fraction: 0.25, color: Colors.deepPurple), // Instagram
                ],
              ),

              const SizedBox(height: 25),

              const Text("Today use",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              Expanded(
                child: ListView(
                  children: [
                    TodayUseCard(
                      icon: Icons.groups,
                      color: Colors.purple,
                      title: "Social media",
                      totalAmount: 1.5,
                      totalTime: 1.5,
                      apps: [
                        AppUsage(
                            name: "Instagram",
                            amount: 1,
                            progress: 0.8,
                            left: 186),
                        AppUsage(
                            name: "TikTok",
                            amount: 0.5,
                            progress: 0.4,
                            left: 120),
                      ],
                    ),
                    TodayUseCard(
                      icon: Icons.movie,
                      color: Colors.deepOrange,
                      title: "Streaming",
                      totalAmount: 0.5,
                      totalTime: 0.5,
                      apps: [
                        AppUsage(
                            name: "Spotify",
                            amount: 1.0,
                            progress: 1.0,
                            left: 0),
                        AppUsage(
                            name: "Netflix",
                            amount: 4.0,
                            progress: 0.8,
                            left: 100),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
