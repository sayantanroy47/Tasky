import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/typography_constants.dart';
import '../widgets/enhanced_ux_widgets.dart';
import '../widgets/standardized_app_bar.dart';
import '../../services/security_service.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Screen for setting up or changing PIN
class PinSetupScreen extends ConsumerStatefulWidget {
  final bool isChangingPin;

  const PinSetupScreen({
    super.key,
    this.isChangingPin = false,
  });
  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final List<String> _enteredPin = [];
  final List<String> _confirmPin = [];
  final int _pinLength = 4;
  
  PinSetupStep _currentStep = PinSetupStep.enterPin;
  String? _errorMessage;
  bool _isProcessing = false;
  String? _oldPin;
  @override
  void initState() {
    super.initState();
    if (widget.isChangingPin) {
      _currentStep = PinSetupStep.enterOldPin;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardizedAppBar(
        title: widget.isChangingPin ? 'Change PIN' : 'Set up PIN',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Progress indicator
              _buildProgressIndicator(),
              
              const SizedBox(height: 48),
              
              // Title and description
              _buildTitleAndDescription(),
              
              const SizedBox(height: 48),
              
              // PIN dots
              _buildPinDots(),
              
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
              if (_isProcessing)
                const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final totalSteps = widget.isChangingPin ? 3 : 2;
    final currentStepIndex = _getCurrentStepIndex();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStepIndex;
        final isCompleted = index < currentStepIndex;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            color: isCompleted
                ? Theme.of(context).colorScheme.primary
                : isActive
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        );
      }),
    );
  }

  Widget _buildTitleAndDescription() {
    String title;
    String description;
    
    switch (_currentStep) {
      case PinSetupStep.enterOldPin:
        title = 'Enter Current PIN';
        description = 'Enter your current 4-digit PIN to continue';
        break;
      case PinSetupStep.enterPin:
        title = widget.isChangingPin ? 'Enter New PIN' : 'Create PIN';
        description = 'Choose a 4-digit PIN to secure your app';
        break;
      case PinSetupStep.confirmPin:
        title = 'Confirm PIN';
        description = 'Enter your PIN again to confirm';
        break;
    }
    
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPinDots() {
    List<String> currentPin;
    
    switch (_currentStep) {
      case PinSetupStep.enterOldPin:
      case PinSetupStep.enterPin:
        currentPin = _enteredPin;
        break;
      case PinSetupStep.confirmPin:
        currentPin = _confirmPin;
        break;
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (index) {
        final isFilled = index < currentPin.length;
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
      onPressed: _isProcessing ? null : () => _onNumberPressed(number),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      child: Text(
        number,
        style: const TextStyle(fontSize: TypographyConstants.textXL, fontWeight: TypographyConstants.medium),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    List<String> currentPin;
    
    switch (_currentStep) {
      case PinSetupStep.enterOldPin:
      case PinSetupStep.enterPin:
        currentPin = _enteredPin;
        break;
      case PinSetupStep.confirmPin:
        currentPin = _confirmPin;
        break;
    }
    
    return EnhancedButton(
      onPressed: _isProcessing || currentPin.isEmpty ? null : _onBackspacePressed,
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: const EdgeInsets.all(20),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      child: Icon(PhosphorIcons.backspace(), size: 24),
    );
  }

  void _onNumberPressed(String number) {
    List<String> currentPin;
    
    switch (_currentStep) {
      case PinSetupStep.enterOldPin:
      case PinSetupStep.enterPin:
        currentPin = _enteredPin;
        break;
      case PinSetupStep.confirmPin:
        currentPin = _confirmPin;
        break;
    }
    
    if (currentPin.length < _pinLength) {
      setState(() {
        currentPin.add(number);
        _errorMessage = null;
      });
      
      // Provide haptic feedback
      HapticFeedback.selectionClick();
      
      // Process when PIN is complete
      if (currentPin.length == _pinLength) {
        _processPinInput();
      }
    }
  }

  void _onBackspacePressed() {
    List<String> currentPin;
    
    switch (_currentStep) {
      case PinSetupStep.enterOldPin:
      case PinSetupStep.enterPin:
        currentPin = _enteredPin;
        break;
      case PinSetupStep.confirmPin:
        currentPin = _confirmPin;
        break;
    }
    
    if (currentPin.isNotEmpty) {
      setState(() {
        currentPin.removeLast();
        _errorMessage = null;
      });
      
      // Provide haptic feedback
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _processPinInput() async {
    if (_isProcessing) return;
    
    setState(() => _isProcessing = true);
    
    try {
      switch (_currentStep) {
        case PinSetupStep.enterOldPin:
          await _verifyOldPin();
          break;
        case PinSetupStep.enterPin:
          _moveToConfirmStep();
          break;
        case PinSetupStep.confirmPin:
          await _confirmAndSetupPin();
          break;
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _verifyOldPin() async {
    final oldPin = _enteredPin.join();
    final securityService = ref.read(securityServiceProvider);
    final isValid = await securityService.verifyPin(oldPin);
    
    if (isValid) {
      _oldPin = oldPin;
      setState(() {
        _currentStep = PinSetupStep.enterPin;
        _enteredPin.clear();
        _errorMessage = null;
      });
    } else {
      setState(() {
        _enteredPin.clear();
        _errorMessage = 'Incorrect PIN. Please try again.';
      });
      
      // Provide error haptic feedback
      HapticFeedback.heavyImpact();
    }
  }

  void _moveToConfirmStep() {
    setState(() {
      _currentStep = PinSetupStep.confirmPin;
      _errorMessage = null;
    });
  }

  Future<void> _confirmAndSetupPin() async {
    final newPin = _enteredPin.join();
    final confirmPin = _confirmPin.join();
    
    if (newPin != confirmPin) {
      setState(() {
        _confirmPin.clear();
        _errorMessage = 'PINs do not match. Please try again.';
      });
      
      // Provide error haptic feedback
      HapticFeedback.heavyImpact();
      return;
    }
    
    // Setup or change PIN
    final securityService = ref.read(securityServiceProvider);
    bool success;
    
    if (widget.isChangingPin && _oldPin != null) {
      success = await securityService.changePin(_oldPin!, newPin);
    } else {
      success = await securityService.setupPin(newPin);
    }
    
    if (success) {
      // Refresh security settings
      await ref.read(securitySettingsProvider.notifier).refresh();
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isChangingPin 
                ? 'PIN changed successfully' 
                : 'PIN set up successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        
        // Navigate back or to biometric setup
        if (widget.isChangingPin) {
          Navigator.of(context).pop();
        } else {
          _showBiometricSetupDialog();
        }
      }
    } else {
      setState(() {
        _errorMessage = 'Failed to set up PIN. Please try again.';
      });
    }
  }

  void _showBiometricSetupDialog() async {
    final securityService = ref.read(securityServiceProvider);
    final isBiometricAvailable = await securityService.isBiometricAvailable();
    
    if (!isBiometricAvailable) {
      return;
    }
    
    if (!mounted) {
      return;
    }
    
    Navigator.of(context).pop();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enable Biometric Authentication?'),
        content: const Text(
          'You can use fingerprint or face recognition to unlock the app more quickly.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Skip'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(securitySettingsProvider.notifier)
                  .setBiometricEnabled(true);
              if (context.mounted) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  int _getCurrentStepIndex() {
    switch (_currentStep) {
      case PinSetupStep.enterOldPin:
        return 0;
      case PinSetupStep.enterPin:
        return widget.isChangingPin ? 1 : 0;
      case PinSetupStep.confirmPin:
        return widget.isChangingPin ? 2 : 1;
    }
  }
}

/// PIN setup steps
enum PinSetupStep {
  enterOldPin,
  enterPin,
  confirmPin,
}


