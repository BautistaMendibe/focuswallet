import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/app_budget_tile.dart';
import '../widgets/add_app_modal.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  double _pricePerHour = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final settingsDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (settingsDoc.exists) {
        setState(() {
          _pricePerHour = (settingsDoc.data()?['settings']?['pricePerHour'] ?? 0.0).toDouble();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _updateAppBudget(String appId, double hours) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('categoryBudgets')
          .doc(appId)
          .update({'amount': hours});
    } catch (e) {
      debugPrint('Error updating app budget: $e');
    }
  }

  void _showAddAppModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddAppModal(
        onAppAdded: () {
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser?.uid;
    final loc = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.budgetTitle),
        backgroundColor: const Color(0xFF009792),
      ),
      body: Column(
        children: [
          // Price per hour card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${loc.pricePerHour}: \$${_pricePerHour.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Apps list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(userId)
                  .collection('categoryBudgets')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text(loc.errorLoadingData));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final apps = snapshot.data!.docs;
                double totalHours = 0;
                
                for (var app in apps) {
                  totalHours += (app.data() as Map<String, dynamic>)['amount'] ?? 0.0;
                }

                return Column(
                  children: [
                    // Total hours card
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${loc.totalHoursPerDay}: ${totalHours.toStringAsFixed(1)}h',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: apps.length,
                        itemBuilder: (context, index) {
                          final app = apps[index];
                          final appData = app.data() as Map<String, dynamic>;
                          
                          return AppBudgetTile(
                            name: appData['name'] ?? '',
                            hours: (appData['amount'] ?? 0.0).toDouble(),
                            icon: appData['icon'],
                            onChanged: (newHours) {
                              _updateAppBudget(app.id, newHours);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAppModal,
        backgroundColor: const Color(0xFF009792),
        child: const Icon(Icons.add),
      ),
    );
  }
} 