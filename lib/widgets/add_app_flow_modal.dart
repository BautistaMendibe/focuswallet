import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Modelo para apps predefinidas con iconos y colores
class PredefinedApp {
  final String name;
  final String category;
  final String? svgPath; // Ruta del icono SVG
  final String? pngPath; // NUEVO
  final IconData? fallbackIcon; // Icono de respaldo si no hay SVG
  final Color color;

  const PredefinedApp({
    required this.name,
    required this.category,
    this.svgPath,
    this.pngPath, // NUEVO
    this.fallbackIcon,
    required this.color,
  });
}

/// Widget principal del flujo de dos pasos para agregar una app
/// Paso 1: Selección de app predefinida por categorías
/// Paso 2: Configuración de horas diarias
class AddAppFlowModal extends StatefulWidget {
  final VoidCallback onAppAdded;

  const AddAppFlowModal({
    super.key,
    required this.onAppAdded,
  });

  @override
  State<AddAppFlowModal> createState() => _AddAppFlowModalState();
}

class _AddAppFlowModalState extends State<AddAppFlowModal>
    with TickerProviderStateMixin {
  // Control del flujo de pasos
  int _currentStep = 1; // 1 = Selección, 2 = Configuración
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  
  // Datos de la app seleccionada en el paso 1
  String? _selectedAppName;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Configuración de animación para transición entre pasos
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Entra desde la derecha
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Avanza al paso 2 con la app seleccionada
  void _goToStep2(String appName, String category) {
    setState(() {
      _selectedAppName = appName;
      _selectedCategory = category;
      _currentStep = 2;
    });
    _animationController.forward();
  }

  /// Regresa al paso 1 desde el paso 2
  void _goToStep1() {
    _animationController.reverse().then((_) {
      setState(() {
        _currentStep = 1;
        _selectedAppName = null;
        _selectedCategory = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // 85% de la pantalla
      margin: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header con indicador de pasos y título
          _buildHeader(),
          
          // Contenido del paso actual con animación
          Expanded(
            child: _currentStep == 1
                ? AppSelectionStep(onAppSelected: _goToStep2)
                : SlideTransition(
                    position: _slideAnimation,
                    child: AppConfigurationStep(
                      initialAppName: _selectedAppName!,
                      initialCategory: _selectedCategory!,
                      onAppAdded: widget.onAppAdded,
                      onBack: _goToStep1,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Construye el header con indicadores de paso y título
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Barra de agarre del modal
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
          
          // Indicador de progreso (1/2, 2/2)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStepIndicator(1, _currentStep >= 1),
              Container(
                width: 40,
                height: 2,
                color: _currentStep >= 2 ? const Color(0xFF009792) : const Color(0xFFE5E7EB),
              ),
              _buildStepIndicator(2, _currentStep >= 2),
            ],
          ),
          const SizedBox(height: 16),
          
          // Título dinámico según el paso
          Text(
            _currentStep == 1 ? 'Elige una app' : 'Configurar horas',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Construye un indicador circular de paso
  Widget _buildStepIndicator(int step, bool isActive) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF009792) : const Color(0xFFE5E7EB),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          step.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

/// Paso 1: Pantalla de selección de apps predefinidas organizadas por categoría
class AppSelectionStep extends StatelessWidget {
  final Function(String appName, String category) onAppSelected;

  const AppSelectionStep({
    super.key,
    required this.onAppSelected,
  });

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Lista scrolleable de categorías con apps
          Expanded(
            child: ListView(
              children: [
                // Genera secciones para cada categoría
                ..._predefinedApps.entries.map((entry) {
                  return _buildCategorySection(entry.key, entry.value);
                }),
                const SizedBox(height: 16),
                // Opción para app personalizada
                _buildOtherAppCard(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye una sección de categoría con título y grilla de apps
  Widget _buildCategorySection(String category, List<PredefinedApp> apps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la categoría
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            category,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        // Grilla 3x3 de apps de la categoría
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: apps.length,
          itemBuilder: (context, index) {
            final app = apps[index];
            return _buildAppCard(app);
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// Construye una tarjeta individual de app con icono y nombre
  Widget _buildAppCard(PredefinedApp app) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => onAppSelected(app.name, app.category),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono de la app con color de fondo
              SizedBox(
                width: 48,
                height: 48,
                child: app.pngPath != null
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          app.pngPath!,
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                        ),
                      )
                    : app.svgPath != null
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              app.svgPath!,
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(app.color, BlendMode.srcIn),
                            ),
                          )
                        : Icon(
                            app.fallbackIcon ?? Icons.apps,
                            color: app.color,
                            size: 24,
                          ),
              ),
              const SizedBox(height: 8),
              // Nombre de la app
              Text(
                app.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye la tarjeta "Otra app..." para apps personalizadas
  Widget _buildOtherAppCard() {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => onAppSelected('', 'Otro'), // Nombre vacío para personalizar
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB), style: BorderStyle.solid),
          ),
          child: Row(
            children: [
              // Icono de agregar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF009792).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add,
                  color: Color(0xFF009792),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Texto descriptivo
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Otra app...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Agregar una app personalizada',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              // Icono de flecha
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF6B7280),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paso 2: Pantalla de configuración de horas (reutiliza el diseño actual)
class AppConfigurationStep extends StatefulWidget {
  final String initialAppName;
  final String initialCategory;
  final VoidCallback onAppAdded;
  final VoidCallback onBack;

  const AppConfigurationStep({
    super.key,
    required this.initialAppName,
    required this.initialCategory,
    required this.onAppAdded,
    required this.onBack,
  });

  @override
  State<AppConfigurationStep> createState() => _AppConfigurationStepState();
}

class _AppConfigurationStepState extends State<AppConfigurationStep> {
  // Controladores de formulario
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  final _valueFocusNode = FocusNode();
  
  // Estado del formulario
  double _hours = 1.0;
  bool _isLoading = false;
  late String _selectedCategory;
  int _selectedTab = 1; // 0 = minutos, 1 = horas
  bool _isEditingName = false; // Para mostrar/ocultar campo de edición

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
    // Pre-llena los campos con la selección del paso 1
    _nameController.text = widget.initialAppName;
    _selectedCategory = widget.initialCategory;
    _updateControllerText();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _valueFocusNode.dispose();
    super.dispose();
  }

  /// Sincroniza el texto del controlador con el valor del slider
  void _updateControllerText() {
    if (_selectedTab == 0) {
      _valueController.text = (_hours * 60).round().toString();
    } else {
      _valueController.text = _hours.toStringAsFixed(1);
    }
  }

  /// Maneja la entrada manual de valores
  void _onValueSubmitted(String value) {
    double newValue;
    if (_selectedTab == 0) {
      // Modo minutos
      final minutes = int.tryParse(value);
      if (minutes != null && minutes >= 30 && minutes <= 360) {
        newValue = minutes / 60.0;
      } else {
        _updateControllerText();
        _valueFocusNode.unfocus();
        return;
      }
    } else {
      // Modo horas
      final hours = double.tryParse(value);
      if (hours != null && hours >= 0.5 && hours <= 6.0) {
        newValue = hours;
      } else {
        _updateControllerText();
        _valueFocusNode.unfocus();
        return;
      }
    }
    
    // Asegura que el valor esté en el rango del slider
    newValue = newValue.clamp(0.5, 6.0);
    
    setState(() {
      _hours = newValue;
      _updateControllerText();
    });
    _valueFocusNode.unfocus();
  }

  /// Guarda la app en Firestore
  Future<void> _saveApp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Guarda en la colección categoryBudgets del usuario
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
      
      // Notifica que se agregó la app y cierra el modal
      widget.onAppAdded();
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error saving app: $e');
      if (!mounted) return;

      // Muestra error al usuario
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
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 0,
        left: 24,
        right: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Botón para volver al paso 1
            Row(
              children: [
                GestureDetector(
                  onTap: widget.onBack,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Volver',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Contenido scrolleable del formulario
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Campo de nombre de app (editable o solo lectura)
                    widget.initialAppName.isEmpty ? 
                    // Modo editable (para apps personalizadas)
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
                    ) :
                    // Modo solo lectura con opción de editar
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'App seleccionada',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.initialAppName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Botón para habilitar edición
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isEditingName = !_isEditingName;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF009792).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 16,
                                color: Color(0xFF009792),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Campo de edición adicional si está habilitado
                    if (_isEditingName) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Editar nombre',
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
                          fillColor: Colors.white,
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
                    ],
                    
                    const SizedBox(height: 24),

                    // Selector de categoría
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
                    
                    // Título de selección de horas
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
                    
                    // Selector de tabs (Minutos/Horas)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          // Tab de Minutos
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
                          // Tab de Horas
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
                    
                    // Display editable del valor
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
                          // Campo de texto para el valor
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
                          // Unidad (minutos/horas)
                          Text(
                            _selectedTab == 0 ? 'minutos' : 'horas',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Icono de edición
                          const Icon(
                            Icons.edit,
                            color: Color(0xFF009792),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Slider con etiquetas
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
                  ],
                ),
              ),
            ),
            
            // Botón de guardar
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
    );
  }
} 