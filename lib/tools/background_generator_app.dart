import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

// Import all theme files
import '../core/theme/themes/artist_palette_theme.dart';
import '../core/theme/themes/autumn_forest_theme.dart';
import '../core/theme/themes/citrus_fresh_theme.dart';
import '../core/theme/themes/cyberpunk_2077_theme.dart';
import '../core/theme/themes/demon_slayer_flame_theme.dart';
import '../core/theme/themes/dracula_ide_theme.dart';
import '../core/theme/themes/executive_platinum_theme.dart';
import '../core/theme/themes/expressive_theme.dart';
import '../core/theme/themes/goku_ultra_instinct_theme.dart';
import '../core/theme/themes/hollow_knight_shadow_theme.dart';
import '../core/theme/themes/koi_mystic_theme.dart';
import '../core/theme/themes/matrix_theme.dart';
import '../core/theme/themes/midnight_ghost_theme.dart';
import '../core/theme/themes/starfield_cosmic_theme.dart';
import '../core/theme/themes/unicorn_dream_theme.dart';
import '../core/theme/themes/vampire_gothic_theme.dart';
import '../core/theme/themes/vegeta_blue_theme.dart';

import '../core/theme/app_theme_data.dart' as app_theme_data;
import '../core/theme/models/theme_effects.dart';
import '../core/theme/models/theme_colors.dart';

class BackgroundGeneratorApp extends StatelessWidget {
  const BackgroundGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Theme Background Generator',
      home: const BackgroundGeneratorScreen(),
    );
  }
}

class BackgroundGeneratorScreen extends StatefulWidget {
  const BackgroundGeneratorScreen({super.key});

  @override
  State<BackgroundGeneratorScreen> createState() => _BackgroundGeneratorScreenState();
}

class _BackgroundGeneratorScreenState extends State<BackgroundGeneratorScreen> {
  final List<String> _logs = [];
  bool _isGenerating = false;
  int _totalGenerated = 0;

  void _addLog(String message) {
    setState(() {
      _logs.add(message);
    });
    print(message);
  }

  Future<void> _generateBackgrounds() async {
    setState(() {
      _isGenerating = true;
      _logs.clear();
      _totalGenerated = 0;
    });

    _addLog('🎨 Starting theme background PNG generation...');

    // Create assets/backgrounds directory
    final backgroundsDir = Directory('assets/backgrounds');
    if (!backgroundsDir.existsSync()) {
      backgroundsDir.createSync(recursive: true);
      _addLog('📁 Created assets/backgrounds directory');
    }

    // Define all themes with their creation functions
    final themes = <String, List<app_theme_data.AppThemeData Function()>>{
      'artist_palette': [
        () => ArtistPaletteTheme.createDark(),
        () => ArtistPaletteTheme.createLight(),
      ],
      'autumn_forest': [
        () => AutumnForestTheme.createDark(),
        () => AutumnForestTheme.createLight(),
      ],
      'citrus_fresh': [
        () => CitrusFreshTheme.createDark(),
        () => CitrusFreshTheme.createLight(),
      ],
      'cyberpunk_2077': [
        () => Cyberpunk2077Theme.createDark(),
        () => Cyberpunk2077Theme.createLight(),
      ],
      'demon_slayer_flame': [
        () => DemonSlayerFlameTheme.createDark(),
        () => DemonSlayerFlameTheme.createLight(),
      ],
      'dracula_ide': [
        () => DraculaIDETheme.createDark(),
        () => DraculaIDETheme.createLight(),
      ],
      'executive_platinum': [
        () => ExecutivePlatinumTheme.createDark(),
        () => ExecutivePlatinumTheme.createLight(),
      ],
      'expressive': [
        () => ExpressiveTheme.createDark(),
        () => ExpressiveTheme.createLight(),
      ],
      'goku_ultra_instinct': [
        () => GokuUltraInstinctTheme.createDark(),
        () => GokuUltraInstinctTheme.createLight(),
      ],
      'hollow_knight_shadow': [
        () => HollowKnightShadowTheme.createDark(),
        () => HollowKnightShadowTheme.createLight(),
      ],
      'koi_mystic': [
        () => KoiMysticTheme.createDark(),
        () => KoiMysticTheme.createLight(),
      ],
      'matrix': [
        () => MatrixTheme.createDark(),
        () => MatrixTheme.createLight(),
      ],
      'midnight_ghost': [
        () => MidnightGhostTheme.createDark(),
        () => MidnightGhostTheme.createLight(),
      ],
      'starfield_cosmic': [
        () => StarfieldCosmicTheme.createDark(),
        () => StarfieldCosmicTheme.createLight(),
      ],
      'unicorn_dream': [
        () => UnicornDreamTheme.createDark(),
        () => UnicornDreamTheme.createLight(),
      ],
      'vampire_gothic': [
        () => VampireGothicTheme.createDark(),
        () => VampireGothicTheme.createLight(),
      ],
      'vegeta_blue': [
        () => VegetaBlueTheme.createDark(),
        () => VegetaBlueTheme.createLight(),
      ],
    };

    // Generate backgrounds for each theme
    for (final themeEntry in themes.entries) {
      final themeName = themeEntry.key;
      final themeCreators = themeEntry.value;

      _addLog('\n🎨 Processing theme: $themeName');

      // Generate dark variant
      try {
        final darkTheme = themeCreators[0]();
        await _generateBackgroundPNG(
          theme: darkTheme,
          filename: '${themeName}_dark.png',
          backgroundsDir: backgroundsDir,
        );
        setState(() {
          _totalGenerated++;
        });
        _addLog('  ✅ Generated ${themeName}_dark.png');
      } catch (e) {
        _addLog('  ❌ Failed to generate ${themeName}_dark.png: $e');
      }

      // Generate light variant
      try {
        final lightTheme = themeCreators[1]();
        await _generateBackgroundPNG(
          theme: lightTheme,
          filename: '${themeName}_light.png',
          backgroundsDir: backgroundsDir,
        );
        setState(() {
          _totalGenerated++;
        });
        _addLog('  ✅ Generated ${themeName}_light.png');
      } catch (e) {
        _addLog('  ❌ Failed to generate ${themeName}_light.png: $e');
      }
    }

    _addLog('\n🎉 Background generation complete!');
    _addLog('📊 Generated $_totalGenerated PNG files in assets/backgrounds/');
    _addLog('💡 You can now use these PNGs instead of computing gradients at runtime');

    setState(() {
      _isGenerating = false;
    });
  }

  Future<void> _generateBackgroundPNG({
    required app_theme_data.AppThemeData theme,
    required String filename,
    required Directory backgroundsDir,
  }) async {
    // Use common mobile screen size
    const width = 390.0;
    const height = 844.0;

    // Create the gradient based on theme configuration
    final gradient = _createThemeGradient(theme);

    // Create a picture recorder to capture the drawing
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Create paint with the gradient
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, width, height),
      );

    // Fill the entire canvas with the gradient
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      paint,
    );

    // End recording and create image
    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());

    // Convert to PNG bytes
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // Write to file
    final file = File('${backgroundsDir.path}/$filename');
    await file.writeAsBytes(pngBytes);

    // Clean up
    image.dispose();
    picture.dispose();
  }

  Gradient _createThemeGradient(app_theme_data.AppThemeData theme) {
    final backgroundEffects = theme.effects?.backgroundEffects;
    final themeColors = theme.colors;

    if (backgroundEffects != null && backgroundEffects.enableGradientMesh) {
      // Use geometric patterns with theme colors
      return _createGeometricGradient(backgroundEffects, themeColors);
    } else {
      // Create theme-specific background from color palette
      return _createThemeSignatureBackground(themeColors);
    }
  }

  /// Create gradient based on geometric pattern configuration
  Gradient _createGeometricGradient(BackgroundEffectConfig config, ThemeColors themeColors) {
    // Use theme accent colors or generate from theme palette
    final colors = config.accentColors.isNotEmpty
        ? config.accentColors
        : _getThemeAccentColors(themeColors);

    // Make patterns MUCH more prominent and visible
    final adjustedColors = colors.map((color) {
      double baseAlpha = color.a;
      // Boost alpha significantly for visibility
      double alpha = (baseAlpha * config.effectIntensity * 3.0).clamp(0.4, 0.9); // 3x multiplier, 40-90% alpha
      return color.withValues(alpha: alpha);
    }).toList();

    // Create gradient based on geometric pattern
    switch (config.geometricPattern) {
      case BackgroundGeometricPattern.linear:
        return _createLinearGradient(adjustedColors, config.patternAngle, config.patternDensity);
      case BackgroundGeometricPattern.radial:
        return _createRadialGradient(adjustedColors, config.patternDensity);
      case BackgroundGeometricPattern.diamond:
        return _createDiamondGradient(adjustedColors, config.patternAngle, config.patternDensity);
      case BackgroundGeometricPattern.mesh:
      default:
        return _createMeshGradient(adjustedColors, config.patternAngle, config.patternDensity);
    }
  }

  /// Create linear gradient with angle and density
  Gradient _createLinearGradient(List<Color> colors, double angle, double density) {
    // Convert angle to alignment
    final radians = angle * (math.pi / 180);
    final alignment = Alignment(math.cos(radians), math.sin(radians));

    return LinearGradient(
      begin: -alignment,
      end: alignment,
      colors: colors,
      stops: _createStops(colors.length, density),
    );
  }

  /// Create radial gradient with density
  Gradient _createRadialGradient(List<Color> colors, double density) {
    return RadialGradient(
      center: Alignment.center,
      radius: 0.8 + (density * 0.4), // Density affects radius
      colors: colors,
      stops: _createStops(colors.length, density),
    );
  }

  /// Create diamond-like sweep gradient
  Gradient _createDiamondGradient(List<Color> colors, double angle, double density) {
    return SweepGradient(
      center: Alignment.center,
      startAngle: angle * (math.pi / 180),
      endAngle: (angle + 360) * (math.pi / 180),
      colors: [...colors, colors.first], // Complete the sweep
      stops: _createStops(colors.length + 1, density),
      transform: GradientRotation(angle * (math.pi / 180)),
    );
  }

  /// Create mesh-like gradient (using linear with offset)
  Gradient _createMeshGradient(List<Color> colors, double angle, double density) {
    final radians = angle * (math.pi / 180);
    final alignment = Alignment(math.cos(radians), math.sin(radians));

    // Create a more complex mesh pattern by layering
    return LinearGradient(
      begin: Alignment.topLeft.add(alignment * 0.3),
      end: Alignment.bottomRight.add(alignment * -0.3),
      colors: colors,
      stops: _createStops(colors.length, density),
      tileMode: TileMode.mirror, // Creates mesh-like repetition
    );
  }

  /// Create gradient stops based on color count and density
  List<double> _createStops(int colorCount, double density) {
    if (colorCount <= 1) return [0.0];

    final stops = <double>[];
    final densityFactor = (1.0 / density).clamp(0.5, 2.0); // Density affects spread

    for (int i = 0; i < colorCount; i++) {
      final stop = (i / (colorCount - 1)) * densityFactor;
      stops.add(stop.clamp(0.0, 1.0));
    }

    return stops;
  }

  /// Generate theme-specific accent colors from theme palette
  List<Color> _getThemeAccentColors(ThemeColors themeColors) {
    return [
      themeColors.primary.withValues(alpha: 0.6),    // Much higher base alpha
      themeColors.secondary.withValues(alpha: 0.5),  // Much higher base alpha
      themeColors.tertiary.withValues(alpha: 0.4),   // Much higher base alpha
    ];
  }

  /// Create theme signature background from color palette
  Gradient _createThemeSignatureBackground(ThemeColors themeColors) {
    final isLight = themeColors.background.computeLuminance() > 0.5;

    // Create unique gradient using theme's primary colors
    if (isLight) {
      return RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          themeColors.background,
          themeColors.primaryContainer.withValues(alpha: 0.3),
          themeColors.secondaryContainer.withValues(alpha: 0.2),
          themeColors.background,
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      );
    } else {
      return RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          themeColors.background,
          themeColors.primary.withValues(alpha: 0.15),
          themeColors.secondary.withValues(alpha: 0.1),
          themeColors.background,
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Background Generator'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Theme Background PNG Generator',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This tool generates PNG background images for all 17 themes (34 total with light/dark variants).',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isGenerating ? null : _generateBackgrounds,
                          icon: _isGenerating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.palette),
                          label: Text(_isGenerating ? 'Generating...' : 'Generate Backgrounds'),
                        ),
                        const SizedBox(width: 16),
                        if (_totalGenerated > 0)
                          Chip(
                            label: Text('Generated: $_totalGenerated'),
                            backgroundColor: Colors.green.shade100,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Generation Log',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              log,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: log.contains('❌')
                                    ? Colors.red
                                    : log.contains('✅')
                                        ? Colors.green
                                        : log.contains('🎨')
                                            ? Colors.blue
                                            : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}