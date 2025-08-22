import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design_system/design_tokens.dart';
import 'dart:math' as math;
import 'dart:async';
import 'glassmorphism_container.dart';
import '../../core/theme/typography_constants.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';


// Define rainbow colors and gold color
const List<Color> _rainbowColors = [
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
];

const Color _goldColor = Color(0xFFFFD700);

/// Delightful easter eggs and surprise interactions with glassmorphism
class GlassEasterEggs extends StatefulWidget {
  final Widget child;
  final bool enableKonamiCode;
  final bool enableShakeToSurprise;
  final bool enableLongPressSecrets;
  final bool enableThemeSecrets;
  final VoidCallback? onSecretUnlocked;
  
  const GlassEasterEggs({
    super.key,
    required this.child,
    this.enableKonamiCode = true,
    this.enableShakeToSurprise = true,
    this.enableLongPressSecrets = true,
    this.enableThemeSecrets = true,
    this.onSecretUnlocked,
  });

  @override
  State<GlassEasterEggs> createState() => _GlassEasterEggsState();
}

class _GlassEasterEggsState extends State<GlassEasterEggs>
    with TickerProviderStateMixin {
  late AnimationController _surpriseController;
  late AnimationController _konamiController;
  late AnimationController _secretController;
  
  late Animation<double> _surpriseAnimation;
  late Animation<double> _konamiAnimation;
  late Animation<double> _secretAnimation;
  
  // final List<LogicalKeyboardKey> _konamiSequence = [
  //   LogicalKeyboardKey.arrowUp,
  //   LogicalKeyboardKey.arrowUp,
  //   LogicalKeyboardKey.arrowDown,
  //   LogicalKeyboardKey.arrowDown,
  //   LogicalKeyboardKey.arrowLeft,
  //   LogicalKeyboardKey.arrowRight,
  //   LogicalKeyboardKey.arrowLeft,
  //   LogicalKeyboardKey.arrowRight,
  //   LogicalKeyboardKey.keyB,
  //   LogicalKeyboardKey.keyA,
  // ];
  
  // final List<LogicalKeyboardKey> _currentSequence = [];
  int _tapCount = 0;
  DateTime _lastTap = DateTime.now();
  Timer? _tapTimer;
  bool _isSecretMode = false;
  final List<_FloatingEmoji> _floatingEmojis = [];
  Timer? _emojiTimer;
  
  final List<String> _secretMessages = [
    '🎉 You found a secret!',
    '✨ Glassmorphism magic activated!',
    '🚀 Easter egg discovered!',
    '👀 You\'re a UI explorer!',
    '💎 Hidden gem unlocked!',
    '🌟 Secret mode engaged!',
    '🔮 Mystery revealed!',
    '🎭 Behind the glass curtain!',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupKeyboardListener();
  }

  void _setupAnimations() {
    _surpriseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _konamiController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _secretController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _surpriseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _surpriseController,
      curve: Curves.elasticOut,
    ));

    _konamiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _konamiController,
      curve: Curves.bounceOut,
    ));

    _secretAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _secretController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupKeyboardListener() {
    if (widget.enableKonamiCode) {
      // In a real app, you'd use RawKeyboardListener or similar
      // This is a simplified version
    }
  }

  @override
  void dispose() {
    _surpriseController.dispose();
    _konamiController.dispose();
    _secretController.dispose();
    _tapTimer?.cancel();
    _emojiTimer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    final now = DateTime.now();
    
    if (now.difference(_lastTap).inMilliseconds < 500) {
      _tapCount++;
    } else {
      _tapCount = 1;
    }
    
    _lastTap = now;
    
    // Reset tap count after delay
    _tapTimer?.cancel();
    _tapTimer = Timer(const Duration(milliseconds: 1000), () {
      _tapCount = 0;
    });
    
    // Check for special tap sequences
    if (_tapCount == 7) {
      _triggerSecretTapSequence();
    } else if (_tapCount == 10) {
      _triggerRainbowExplosion();
    }
  }

  void _handleLongPress() {
    if (!widget.enableLongPressSecrets) return;
    
    _triggerSecretLongPress();
  }

  void _triggerSecretTapSequence() {
    setState(() => _isSecretMode = !_isSecretMode);
    
    HapticFeedback.heavyImpact();
    _surpriseController.forward().then((_) {
      _surpriseController.reverse();
    });
    
    _showSecretMessage(_secretMessages[math.Random().nextInt(_secretMessages.length)]);
    widget.onSecretUnlocked?.call();
  }

  void _triggerRainbowExplosion() {
    HapticFeedback.heavyImpact();
    _konamiController.forward().then((_) {
      _konamiController.reverse();
    });
    
    _createFloatingEmojis();
    _showSecretMessage('🌈 RAINBOW EXPLOSION! 🌈');
    widget.onSecretUnlocked?.call();
  }

  void _triggerSecretLongPress() {
    _secretController.forward().then((_) {
      Timer(const Duration(seconds: 2), () {
        _secretController.reverse();
      });
    });
    
    _showSecretMessage('🔐 Secret long press detected!');
    widget.onSecretUnlocked?.call();
  }

  void _createFloatingEmojis() {
    final emojis = ['🎉', '✨', '🚀', '💫', '💎', '🌟', '🔮', '🎭', '🦄', '🌈'];
    final random = math.Random();
    
    setState(() {
      _floatingEmojis.clear();
      for (int i = 0; i < 15; i++) {
        _floatingEmojis.add(_FloatingEmoji(
          emoji: emojis[random.nextInt(emojis.length)],
          startPosition: Offset(
            random.nextDouble(),
            random.nextDouble(),
          ),
          velocity: Offset(
            (random.nextDouble() - 0.5) * 2,
            -random.nextDouble() * 2,
          ),
          rotation: random.nextDouble() * 2 * math.pi,
          rotationSpeed: (random.nextDouble() - 0.5) * 0.1,
          scale: 0.5 + random.nextDouble() * 1.5,
          lifespan: 2.0 + random.nextDouble() * 2.0,
        ));
      }
    });
    
    _emojiTimer?.cancel();
    _emojiTimer = Timer(const Duration(seconds: 4), () {
      setState(() {
        _floatingEmojis.clear();
      });
    });
  }

  void _showSecretMessage(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(PhosphorIcons.star(), color: Colors.yellow, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: TypographyConstants.textSM,
                  fontWeight: TypographyConstants.medium,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onLongPress: _handleLongPress,
      child: Stack(
        children: [
          // Main content with potential effects
          AnimatedBuilder(
            animation: Listenable.merge([
              _surpriseAnimation,
              _konamiAnimation,
              _secretAnimation,
            ]),
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_surpriseAnimation.value * 0.1),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: _isSecretMode
                        ? [
                            BoxShadow(
                              color: _rainbowColors[
                                (DateTime.now().millisecondsSinceEpoch ~/ 100) % _rainbowColors.length
                              ].withValues(alpha: 0.3 * _secretAnimation.value),
                              blurRadius: 20 * _secretAnimation.value,
                              spreadRadius: 5 * _secretAnimation.value,
                            ),
                          ]
                        : null,
                  ),
                  child: widget.child,
                ),
              );
            },
          ),
          
          // Konami code effect overlay
          if (_konamiAnimation.value > 0)
            _buildKonamiOverlay(),
          
          // Secret mode overlay
          if (_secretAnimation.value > 0)
            _buildSecretOverlay(),
          
          // Floating emojis
          ..._floatingEmojis.map((emoji) => _buildFloatingEmoji(emoji)),
          
          // Secret achievement notification
          if (_isSecretMode)
            _buildSecretAchievement(),
        ],
      ),
    );
  }

  Widget _buildKonamiOverlay() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _konamiAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.purple.withValues(alpha: 0.3 * _konamiAnimation.value),
                  Colors.blue.withValues(alpha: 0.2 * _konamiAnimation.value),
                  Colors.cyan.withValues(alpha: 0.1 * _konamiAnimation.value),
                  Colors.transparent,
                ],
              ),
            ),
            child: CustomPaint(
              painter: _KonamiEffectPainter(progress: _konamiAnimation.value),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSecretOverlay() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _secretAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _goldColor.withValues(alpha: 0.1 * _secretAnimation.value),
                  Colors.orange.withValues(alpha: 0.05 * _secretAnimation.value),
                  Colors.red.withValues(alpha: 0.02 * _secretAnimation.value),
                  Colors.transparent,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingEmoji(_FloatingEmoji emoji) {
    return AnimatedBuilder(
      animation: _konamiAnimation,
      builder: (context, child) {
        // Update emoji position
        emoji.update();
        
        if (emoji.alpha <= 0) return const SizedBox.shrink();
        
        final screenSize = MediaQuery.of(context).size;
        
        return Positioned(
          left: emoji.currentPosition.dx * screenSize.width,
          top: emoji.currentPosition.dy * screenSize.height,
          child: Transform.rotate(
            angle: emoji.currentRotation,
            child: Transform.scale(
              scale: emoji.scale,
              child: Opacity(
                opacity: emoji.alpha,
                child: Text(
                  emoji.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecretAchievement() {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
        padding: const EdgeInsets.all(16),
        glassTint: Colors.purple.withValues(alpha: 0.2),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(gradient: LinearGradient(
                  colors: [_goldColor, Colors.orange],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.star(),
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Secret Mode Activated!',
                    style: TextStyle(
                      fontSize: TypographyConstants.textSM,
                      fontWeight: TypographyConstants.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'You\'ve unlocked the hidden glassmorphism effects',
                    style: TextStyle(
                      fontSize: TypographyConstants.textXS,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating emoji animation data
class _FloatingEmoji {
  final String emoji;
  Offset startPosition;
  Offset velocity;
  double rotation;
  double rotationSpeed;
  double scale;
  double lifespan;
  double age = 0.0;
  
  Offset get currentPosition => Offset(
    startPosition.dx + velocity.dx * age,
    startPosition.dy + velocity.dy * age,
  );
  
  double get currentRotation => rotation + rotationSpeed * age * 60; // 60 FPS assumption
  
  double get alpha => math.max(0, 1 - (age / lifespan));

  _FloatingEmoji({
    required this.emoji,
    required this.startPosition,
    required this.velocity,
    required this.rotation,
    required this.rotationSpeed,
    required this.scale,
    required this.lifespan,
  });

  void update() {
    age += 0.016; // ~60 FPS
    
    // Apply gravity
    velocity = Offset(velocity.dx, velocity.dy + 0.01);
    
    // Bounce off edges (simplified)
    if (currentPosition.dx < 0 || currentPosition.dx > 1) {
      velocity = Offset(-velocity.dx, velocity.dy);
    }
  }
}

/// Custom painter for Konami code effect
class _KonamiEffectPainter extends CustomPainter {
  final double progress;

  _KonamiEffectPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw expanding rings
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height);
    
    for (int i = 0; i < 5; i++) {
      final ringProgress = (progress + i * 0.1) % 1.0;
      final radius = maxRadius * ringProgress;
      final opacity = 1.0 - ringProgress;
      
      paint.color = _rainbowColors[i % _rainbowColors.length].withValues(alpha: opacity * 0.5);
      
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Extension for rainbow colors
extension on Colors {
  // static const List<Color> rainbow = [
  //   Colors.red,
  //   Colors.orange,
  //   Colors.yellow,
  //   Colors.green,
  //   Colors.blue,
  //   Colors.indigo,
  //   Colors.purple,
  // ];
}

/// Secret achievement system
class SecretAchievements {
  static final Map<String, bool> _unlockedAchievements = {};
  static final List<Achievement> _availableAchievements = [
    Achievement(
      id: 'secret_tapper',
      title: 'Secret Tapper',
      description: 'Discovered the 7-tap secret',
      icon: PhosphorIcons.hand(),
    ),
    Achievement(
      id: 'rainbow_master',
      title: 'Rainbow Master',
      description: 'Triggered the rainbow explosion',
      icon: PhosphorIcons.palette(),
    ),
    Achievement(
      id: 'long_presser',
      title: 'Patient Explorer',
      description: 'Found the long press secret',
      icon: PhosphorIcons.timer(),
    ),
    Achievement(
      id: 'konami_warrior',
      title: 'Konami Warrior',
      description: 'Entered the legendary code',
      icon: PhosphorIcons.gameController(),
    ),
  ];

  static void unlock(String achievementId) {
    if (!_unlockedAchievements.containsKey(achievementId)) {
      _unlockedAchievements[achievementId] = true;
      HapticFeedback.heavyImpact();
    }
  }

  static bool isUnlocked(String achievementId) {
    return _unlockedAchievements[achievementId] ?? false;
  }

  static List<Achievement> get unlockedAchievements {
    return _availableAchievements
        .where((achievement) => isUnlocked(achievement.id))
        .toList();
  }

  static int get unlockedCount => _unlockedAchievements.length;
  static int get totalCount => _availableAchievements.length;
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}


