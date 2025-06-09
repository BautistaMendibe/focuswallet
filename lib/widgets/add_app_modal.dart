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
  final _valueController = TextEditingController();
  final _valueFocusNode = FocusNode();
  double _hours = 1.0;
  bool _isLoading = false;
  String _selectedCategory = 'Redes sociales';
  int _selectedTab = 1; // 0 for minutes, 1 for hours

  final List<String> _categories = [
    'Redes sociales',
    'Juegos',
    'Streaming',
    'Casino',
    'Mensajería',
    'Otro'
  ];

  @override
  void initState() {
    super.initState();
    _updateControllerText();
  }

  @override
  void dispose() {
    _valueController.dispose();
    _valueFocusNode.dispose();
    super.dispose();
  }

  void _updateControllerText() {
    if (_selectedTab == 0) {
      _valueController.text = (_hours * 60).round().toString();
    } else {
      _valueController.text = _hours.toStringAsFixed(1);
    }
  }

  void _onValueSubmitted(String value) {
    double newValue;
    if (_selectedTab == 0) {
      // Minutes tab
      final minutes = int.tryParse(value);
      if (minutes != null && minutes >= 30 && minutes <= 360) { // Min 30 minutes (0.5 hours)
        newValue = minutes / 60.0;
      } else {
        _updateControllerText();
        _valueFocusNode.unfocus();
        return;
      }
    } else {
      // Hours tab
      final hours = double.tryParse(value);
      if (hours != null && hours >= 0.5 && hours <= 6.0) {
        newValue = hours;
      } else {
        _updateControllerText();
        _valueFocusNode.unfocus();
        return;
      }
    }
    
    // Ensure value is within slider range
    newValue = newValue.clamp(0.5, 6.0);
    
    setState(() {
      _hours = newValue;
      _updateControllerText(); // Update controller with clamped value
    });
    _valueFocusNode.unfocus();
  }

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
        'category': _selectedCategory,
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
          behavior: SnackBarBehavior.floating,
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
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                loc.addNewApp,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // App name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: loc.appName,
                  labelStyle: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF009792), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1A1A1A),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.requiredField;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Category selection
              Text(
                'Categoría',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFF9FAFB),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  dropdownColor: Colors.white,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1A1A1A),
                  ),
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              // Hours selection
              Text(
                loc.hoursPerDay,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Tab selector
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTab = 0;
                            _updateControllerText();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _selectedTab == 0 ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ] : [],
                          ),
                          child: Text(
                            'Minutos',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _selectedTab == 0 ? const Color(0xFF1A1A1A) : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTab = 1;
                            _updateControllerText();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _selectedTab == 1 ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ] : [],
                          ),
                          child: Text(
                            'Horas',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _selectedTab == 1 ? const Color(0xFF1A1A1A) : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Value display - editable
              GestureDetector(
                onTap: () {
                  _valueController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _valueController.text.length,
                  );
                  _valueFocusNode.requestFocus();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IntrinsicWidth(
                      child: TextField(
                        controller: _valueController,
                        focusNode: _valueFocusNode,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.done,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: _onValueSubmitted,
                        onEditingComplete: () {
                          _onValueSubmitted(_valueController.text);
                        },
                        onTapOutside: (event) {
                          _onValueSubmitted(_valueController.text);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedTab == 0 ? 'minutos' : 'horas',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.edit,
                      color: Color(0xFF009792),
                      size: 20,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Slider
              Row(
                children: [
                  Text(
                    _selectedTab == 0 ? '30' : '0.5',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF009792),
                        inactiveTrackColor: const Color(0xFFE5E7EB),
                        thumbColor: const Color(0xFF009792),
                        overlayColor: const Color(0xFF009792).withValues(alpha: 0.2),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: _hours.clamp(0.5, 6.0),
                        min: 0.5,
                        max: 6.0,
                        divisions: 11,
                        onChanged: (value) {
                          setState(() {
                            _hours = value;
                            _updateControllerText();
                          });
                        },
                      ),
                    ),
                  ),
                  Text(
                    _selectedTab == 0 ? '360' : '6',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Save button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009792),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
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
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 