import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../widgets/enhanced_ux_widgets.dart';
import '../../services/security_service.dart';

/// Main authentication screen that handles different auth states
class AuthenticationScreen extends ConsumerStatefulWidget {
  const AuthenticationScreen({super.key});
  @override
  ConsumerState<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends ConsumerState<AuthenticationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authenticationStateProvider);
    
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildAuthContent(authState),
        ),
      ),
    );
  }

  Widget _buildAuthContent(AuthenticationState authState) {
    switch (authState) {
      case AuthenticationState.authenticated:
        // Navigate to main app
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed('/home');
        });
        return const Center(child: CircularProgressIndicator());
        
      case AuthenticationState.biometricRequired:
        return BiometricAuthWidget(onFallbackToPin: () {
          ref.read(authenticationStateProvider.notifier).switchToPinAuthentication();
        });
        
      case AuthenticationState.pinRequired:
        return const PinAuthWidget();
        
      case AuthenticationState.lockedOut:
        return const LockoutWidget();
        
      case AuthenticationState.unauthenticated:
        return const SetupAuthWidget();
    }
  }
}

/// Widget for biometric authentication
class BiometricAuthWidget extends ConsumerStatefulWidget {
  final VoidCallback onFallbackToPin;

  const BiometricAuthWidget({
    super.key,
    required this.onFallbackToPin,
  });
  @override
  ConsumerState<BiometricAuthWidget> createState() => _BiometricAuthWidgetState();
}

class _BiometricAuthWidgetState extends ConsumerState<BiometricAuthWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isAuthenticating = false;
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Auto-trigger biometric authentication
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticateWithBiometrics();
    });
  }
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final securitySettings = ref.watch(securitySettingsProvider);
    
    return securitySettings.when(
      data: (settings) => _buildBiometricContent(settings),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildBiometricContent(SecuritySettings settings) {
    final biometricType = settings.availableBiometrics.isNotEmpty 
        ? settings.availableBiometrics.first 
        : BiometricType.fingerprint;
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.security,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Title
            Text(
              'Unlock Task Tracker',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Subtitle
            Text(
              'Use ${_getBiometricTypeName(biometricType)} to access your tasks',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 64),
            
            // Biometric icon with pulse animation
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _getBiometricIcon(biometricType),
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 64),
            
            // Authenticate button
            EnhancedButton(
              onPressed: _isAuthenticating ? null : _authenticateWithBiometrics,
              child: _isAuthenticating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Authenticate with ${_getBiometricTypeName(biometricType)}'),
            ),
            
            const SizedBox(height: 16),
            
            // Fallback to PIN
            TextButton(
              onPressed: widget.onFallbackToPin,
              child: const Text('Use PIN instead'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _authenticateWithBiometrics() async {
    if (_isAuthenticating) return;
    
    setState(() => _isAuthenticating = true);
    
    try {
      final success = await ref
          .read(authenticationStateProvider.notifier)
          .authenticateWithBiometrics();
      
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication failed. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  String _getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Biometrics';
      case BiometricType.weak:
        return 'Biometrics';
    }
  }

  IconData _getBiometricIcon(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return Icons.face;
      case BiometricType.fingerprint:
        return Icons.fingerprint;
      case BiometricType.iris:
        return Icons.visibility;
      case BiometricType.strong:
      case BiometricType.weak:
        return Icons.security;
    }
  }
}

/// Widget for PIN authentication
class PinAuthWidget extends ConsumerStatefulWidget {
  const PinAuthWidget({super.key});
  @override
  ConsumerState<PinAuthWidget> createState() => _PinAuthWidgetState();
}

class _PinAuthWidgetState extends ConsumerState<PinAuthWidget> {
  final List<String> _enteredPin = [];
  final int _pinLength = 4;
  bool _isAuthenticating = false;
  String? _errorMessage;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.lock,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Title
            Text(
              'Enter PIN',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Subtitle
            Text(
              'Enter your 4-digit PIN to access your tasks',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 48),
            
            // PIN dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pinLength, (index) {
                final isFilled = index < _enteredPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                );
              }),
            ),
            
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            const SizedBox(height: 48),
            
            // Number pad
            _buildNumberPad(),
            
            const SizedBox(height: 32),
            
            // Loading indicator
            if (_isAuthenticating)
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        // Row 1: 1, 2, 3
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('1'),
            _buildNumberButton('2'),
            _buildNumberButton('3'),
          ],
        ),
        const SizedBox(height: 16),
        
        // Row 2: 4, 5, 6
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('4'),
            _buildNumberButton('5'),
            _buildNumberButton('6'),
          ],
        ),
        const SizedBox(height: 16),
        
        // Row 3: 7, 8, 9
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('7'),
            _buildNumberButton('8'),
            _buildNumberButton('9'),
          ],
        ),
        const SizedBox(height: 16),
        
        // Row 4: empty, 0, backspace
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 64, height: 64), // Empty space
            _buildNumberButton('0'),
            _buildBackspaceButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return EnhancedButton(
      onPressed: _isAuthenticating ? null : () => _onNumberPressed(number),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      child: Text(
        number,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return EnhancedButton(
      onPressed: _isAuthenticating || _enteredPin.isEmpty ? null : _onBackspacePressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      child: const Icon(Icons.backspace, size: 24),
    );
  }

  void _onNumberPressed(String number) {
    if (_enteredPin.length < _pinLength) {
      setState(() {
        _enteredPin.add(number);
        _errorMessage = null;
      });
      
      // Provide haptic feedback
      HapticFeedback.selectionClick();
      
      // Auto-authenticate when PIN is complete
      if (_enteredPin.length == _pinLength) {
        _authenticateWithPin();
      }
    }
  }

  void _onBackspacePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin.removeLast();
        _errorMessage = null;
      });
      
      // Provide haptic feedback
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _authenticateWithPin() async {
    if (_isAuthenticating) return;
    
    setState(() => _isAuthenticating = true);
    
    try {
      final pin = _enteredPin.join();
      final success = await ref
          .read(authenticationStateProvider.notifier)
          .authenticateWithPin(pin);
      
      if (!success && mounted) {
        setState(() {
          _enteredPin.clear();
          _errorMessage = 'Incorrect PIN. Please try again.';
        });
        
        // Provide error haptic feedback
        HapticFeedback.heavyImpact();
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }
}

/// Widget shown when user is locked out
class LockoutWidget extends ConsumerStatefulWidget {
  const LockoutWidget({super.key});
  @override
  ConsumerState<LockoutWidget> createState() => _LockoutWidgetState();
}

class _LockoutWidgetState extends ConsumerState<LockoutWidget> {
  Duration? _remainingTime;
  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
  }

  void _updateRemainingTime() async {
    final securityService = ref.read(securityServiceProvider);
    final remaining = await securityService.getRemainingLockoutTime();
    
    if (mounted) {
      setState(() => _remainingTime = remaining);
      
      if (remaining != null && remaining.inSeconds > 0) {
        // Update every second
        Future.delayed(const Duration(seconds: 1), _updateRemainingTime);
      } else {
        // Lockout expired, refresh auth state
        ref.read(authenticationStateProvider.notifier).refresh();
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lock icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
              ),
              child: Icon(
                Icons.lock_clock,
                size: 60,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Title
            Text(
              'Too Many Attempts',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              'You have exceeded the maximum number of authentication attempts. Please wait before trying again.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Remaining time
            if (_remainingTime != null)
              EnhancedCard(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        'Try again in:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDuration(_remainingTime!),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
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

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}

/// Widget for setting up authentication
class SetupAuthWidget extends ConsumerWidget {
  const SetupAuthWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Security icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.security,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Title
            Text(
              'Secure Your Tasks',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              'Set up app lock to protect your personal tasks and data.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 48),
            
            // Setup PIN button
            EnhancedButton(
              onPressed: () => Navigator.of(context).pushNamed('/setup-pin'),
              child: const Text('Set up PIN'),
            ),
            
            const SizedBox(height: 16),
            
            // Skip button
            TextButton(
              onPressed: () {
                // For now, we'll need to add a method to skip authentication
                // This is a temporary workaround
                Navigator.of(context).pushReplacementNamed('/home');
              },
              child: const Text('Skip for now'),
            ),
          ],
        ),
      ),
    );
  }
}
