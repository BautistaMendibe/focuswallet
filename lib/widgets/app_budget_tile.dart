import 'package:flutter/material.dart';

// Modelo para apps predefinidas con iconos y colores
class PredefinedApp {
  final String name;
  final String category;
  final String? pngPath;
  final IconData? fallbackIcon;
  final Color color;

  const PredefinedApp({
    required this.name,
    required this.category,
    this.pngPath,
    this.fallbackIcon,
    required this.color,
  });
}

class AppBudgetTile extends StatefulWidget {
  final String name;
  final double hours;
  final String? icon;
  final String? category;
  final Function(double) onChanged;
  final Function(String)? onCategoryChanged;
  final VoidCallback? onDelete;

  const AppBudgetTile({
    super.key,
    required this.name,
    required this.hours,
    this.icon,
    this.category,
    required this.onChanged,
    this.onCategoryChanged,
    this.onDelete,
  });

  @override
  State<AppBudgetTile> createState() => _AppBudgetTileState();
}

class _AppBudgetTileState extends State<AppBudgetTile> with SingleTickerProviderStateMixin {
  late double _currentValue;
  bool _isExpanded = false;
  int _selectedTab = 1; // 0 for minutes, 1 for hours
  late AnimationController _animationController;
  late Animation<double> _animation;
  final _valueController = TextEditingController();
  final _valueFocusNode = FocusNode();
  final _customCategoryController = TextEditingController();
  String _selectedCategory = 'Redes sociales';
  bool _showCustomCategoryField = false;

  final List<String> _categories = [
    'Redes sociales',
    'Juegos',
    'Streaming',
    'Casino',
    'Mensajería',
    'Otro'
  ];

  // Apps predefinidas organizadas por categoría con iconos y colores
  static const Map<String, List<PredefinedApp>> _predefinedApps = {
    'Redes sociales': [
      PredefinedApp(
        name: 'Instagram',
        category: 'Redes sociales',
        pngPath: 'assets/apps-icons/social-media/instagram.png',
        color: Color(0xFFE4405F),
      ),
      PredefinedApp(
        name: 'Facebook',
        category: 'Redes sociales',
        pngPath: 'assets/apps-icons/social-media/facebook.png',
        color: Color(0xFF1877F2),
      ),
      PredefinedApp(
        name: 'Snapchat',
        category: 'Redes sociales',
        pngPath: 'assets/apps-icons/social-media/snapchat.png',
        color: Color(0xFFFFFC00),
      ),
      PredefinedApp(
        name: 'TikTok',
        category: 'Redes sociales',
        pngPath: 'assets/apps-icons/social-media/tiktok.png',
        color: Color(0xFF000000)
      ),
      PredefinedApp(
        name: 'Twitter',
        category: 'Redes sociales',
        pngPath: 'assets/apps-icons/social-media/twitter.png',
        color: Color(0xFF1DA1F2)
      ),
      PredefinedApp(
        name: 'LinkedIn',
        category: 'Redes sociales',
        pngPath: 'assets/apps-icons/social-media/linkedin.png',
        color: Color(0xFF0A66C2)
      ),
    ],
    'Streaming': [
      PredefinedApp(name: 'YouTube', category: 'Streaming', pngPath: 'assets/apps-icons/streaming/youtube.png', color: Color(0xFFFF0000)),
      PredefinedApp(name: 'Netflix', category: 'Streaming', pngPath: 'assets/apps-icons/streaming/netflix.png', color: Color(0xFFE50914)),
      PredefinedApp(name: 'Spotify', category: 'Streaming', pngPath: 'assets/apps-icons/streaming/spotify.png', color: Color(0xFF1DB954)),
      PredefinedApp(name: 'Disney+', category: 'Streaming', pngPath: 'assets/apps-icons/streaming/disneyplus.png', color: Color(0xFF113CCF)),
      PredefinedApp(name: 'Prime Video', category: 'Streaming', pngPath: 'assets/apps-icons/streaming/prime-video.png', color: Color(0xFF00A8E1)),
      PredefinedApp(name: 'Twitch', category: 'Streaming', pngPath: 'assets/apps-icons/streaming/twitch.png', color: Color(0xFF9146FF)),
    ],
    'Juegos': [
      PredefinedApp(name: 'PUBG Mobile', category: 'Juegos', pngPath: 'assets/apps-icons/juegos/pubg.png', fallbackIcon: Icons.sports_esports, color: Color(0xFFFF6900)),
      PredefinedApp(name: 'Call of Duty', category: 'Juegos', pngPath: 'assets/apps-icons/juegos/cod.png', fallbackIcon: Icons.gps_fixed, color: Color(0xFF000000)),
      PredefinedApp(name: 'Clash Royale', category: 'Juegos', pngPath: 'assets/apps-icons/juegos/clash.png', fallbackIcon: Icons.castle, color: Color(0xFF3CDCF0)),
      PredefinedApp(name: 'Among Us', category: 'Juegos', pngPath: 'assets/apps-icons/juegos/amongus.png', fallbackIcon: Icons.person, color: Color(0xFFFF0000)),
      PredefinedApp(name: 'Candy Crush', category: 'Juegos', pngPath: 'assets/apps-icons/juegos/candycrush.png', fallbackIcon: Icons.extension, color: Color(0xFFFF69B4)),
      PredefinedApp(name: 'Minecraft', category: 'Juegos', pngPath: 'assets/apps-icons/juegos/minecraft.png', fallbackIcon: Icons.view_module, color: Color(0xFF00AA00)),
    ],
    'Mensajería': [
      PredefinedApp(name: 'WhatsApp', category: 'Mensajeria', pngPath: 'assets/apps-icons/mensajeria/whatsapp.png', fallbackIcon: Icons.chat, color: Color(0xFF25D366)),
      PredefinedApp(name: 'Telegram', category: 'Mensajeria', pngPath: 'assets/apps-icons/mensajeria/telegram.png', fallbackIcon: Icons.send, color: Color(0xFF0088CC)),
      PredefinedApp(name: 'Discord', category: 'Mensajeria', pngPath: 'assets/apps-icons/mensajeria/discord.png', fallbackIcon: Icons.forum, color: Color(0xFF5865F2)),
      PredefinedApp(name: 'Messenger', category: 'Mensajeria', pngPath: 'assets/apps-icons/mensajeria/messeger.png', fallbackIcon: Icons.message, color: Color(0xFF0078FF)),
    ],
    'Casino': [
      PredefinedApp(name: 'PokerStars', category: 'Casino', pngPath: 'assets/apps-icons/casino/pokerstars.png', fallbackIcon: Icons.casino, color: Color(0xFFFF0000)),
      PredefinedApp(name: 'Bet365', category: 'Casino', pngPath: 'assets/apps-icons/casino/bet365.png', fallbackIcon: Icons.sports_soccer, color: Color(0xFF00A651)),
      PredefinedApp(name: 'Codere', category: 'Casino', pngPath: 'assets/apps-icons/casino/codere.png', fallbackIcon: Icons.diamond, color: Color(0xFFFFD700)),
      PredefinedApp(name: 'Spin Palace', category: 'Casino', pngPath: 'assets/apps-icons/casino/spinpalace.png', fallbackIcon: Icons.refresh, color: Color(0xFF800080)),
    ],
  };

  // Método para buscar una app predefinida por nombre
  static PredefinedApp? _findPredefinedApp(String appName) {
    for (var category in _predefinedApps.values) {
      for (var app in category) {
        if (app.name.toLowerCase() == appName.toLowerCase()) {
          return app;
        }
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _currentValue = widget.hours.clamp(0.5, 6.0); // Ensure initial value is valid
    _updateControllerText();
    
    // Initialize category
    if (widget.category != null) {
      if (_categories.contains(widget.category)) {
        _selectedCategory = widget.category!;
      } else {
        _selectedCategory = 'Otro';
        _showCustomCategoryField = true;
        _customCategoryController.text = widget.category!;
      }
    }
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _valueController.dispose();
    _valueFocusNode.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AppBudgetTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hours != widget.hours) {
      _currentValue = widget.hours.clamp(0.5, 6.0); // Ensure updated value is valid
      _updateControllerText();
    }
  }

  void _updateControllerText() {
    if (_selectedTab == 0) {
      _valueController.text = (_currentValue * 60).round().toString();
    } else {
      _valueController.text = _currentValue.toStringAsFixed(1);
    }
  }

  void _onValueSubmitted(String value) async {
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
      _currentValue = newValue;
      _updateControllerText(); // Update controller with clamped value
    });
    widget.onChanged(newValue);
    _valueFocusNode.unfocus();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _onCategoryChanged(String newCategory) {
    if (widget.onCategoryChanged != null) {
      String categoryToSave = newCategory;
      if (newCategory == 'Otro' && _customCategoryController.text.isNotEmpty) {
        categoryToSave = _customCategoryController.text;
      }
      widget.onCategoryChanged!(categoryToSave);
    }
  }

  Widget _getAppIcon() {
    // Buscar si existe una app predefinida con ícono
    final predefinedApp = _findPredefinedApp(widget.name);
    
    if (predefinedApp?.pngPath != null) {
      // Si existe un ícono PNG, mostrarlo
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            predefinedApp!.pngPath!,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Si hay error al cargar la imagen, mostrar la letra
              return _buildLetterIcon();
            },
          ),
        ),
      );
    }
    
    // Si no hay ícono PNG, mostrar la letra
    return _buildLetterIcon();
  }

  Widget _buildLetterIcon() {
    // Generate a consistent color based on the app name
    final nameHash = widget.name.hashCode;
    final color = Color.fromARGB(
      255,
      (nameHash & 0xFF0000) >> 16,
      (nameHash & 0x00FF00) >> 8,
      nameHash & 0x0000FF,
    ).withValues(alpha: 0.85);

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center, // Centra la inicial
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Text(
        widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatTime(double hours) {
    if (hours >= 1) {
      return '${hours.toStringAsFixed(hours % 1 == 0 ? 0 : 1)} horas';
    } else {
      int minutes = (hours * 60).round();
      return '$minutes min';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        children: [
          // Main tile content
          InkWell(
            onTap: _toggleExpanded,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  _getAppIcon(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (widget.category != null) ...[
                          Text(
                            widget.category!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF009792),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          _formatTime(_currentValue),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Delete button
                  if (widget.onDelete != null)
                    GestureDetector(
                      onTap: widget.onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.red.shade600,
                          size: 20,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded content
          SizeTransition(
            sizeFactor: _animation,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 16),
                  
                  // Category section
                  if (widget.onCategoryChanged != null) ...[
                    Row(
                      children: [
                        Text(
                          'Categoría: ',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xFFF9FAFB),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              dropdownColor: Colors.white,
                              style: const TextStyle(
                                fontSize: 14,
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
                                    _showCustomCategoryField = newValue == 'Otro';
                                    if (!_showCustomCategoryField) {
                                      _customCategoryController.clear();
                                    }
                                  });
                                  _onCategoryChanged(newValue);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Custom category field
                    if (_showCustomCategoryField) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _customCategoryController,
                        decoration: InputDecoration(
                          labelText: 'Categoría personalizada',
                          labelStyle: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF009792), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1A1A1A),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            _onCategoryChanged('Otro');
                          }
                        },
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                  ],
                  
                  // Tab selector
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
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
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
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
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
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
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
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
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _selectedTab == 1 ? const Color(0xFF1A1A1A) : const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IntrinsicWidth(
                          child: TextField(
                            controller: _valueController,
                            focusNode: _valueFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textInputAction: TextInputAction.done,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
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
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.edit,
                          color: Color(0xFF009792),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Slider
                  Row(
                    children: [
                      Text(
                        _selectedTab == 0 ? '0' : '0.5',
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
                            value: _currentValue.clamp(0.5, 6.0),
                            min: 0.5,
                            max: 6.0,
                            divisions: 11, // (6.0 - 0.5) / 0.5 = 11
                            onChanged: (value) {
                              setState(() {
                                _currentValue = value;
                              });
                            },
                            onChangeEnd: (value) {
                              widget.onChanged(value);
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 