import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddAppModal extends StatefulWidget {
  final VoidCallback onAppAdded;

  const AddAppModal({
    super.key,
    required this.onAppAdded,
  });

  @override
  State<AddAppModal> createState() => _AddAppModalState();
}

class _AddAppModalState extends State<AddAppModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  double _hours = 1.0;
  bool _isLoading = false;

  Future<void> _saveApp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('categoryBudgets')
          .add({
        'name': _nameController.text,
        'amount': _hours,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      
      widget.onAppAdded();
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error saving app: $e');
      if (!mounted) return;

      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.errorSavingData),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc.addNewApp,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: loc.appName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return loc.requiredField;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              '${loc.hoursPerDay}: ${_hours.toStringAsFixed(1)}h',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            Slider(
              value: _hours,
              min: 0,
              max: 24,
              divisions: 48,
              activeColor: const Color(0xFF009792),
              onChanged: (value) {
                setState(() {
                  _hours = value;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveApp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009792),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      loc.save,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
} 