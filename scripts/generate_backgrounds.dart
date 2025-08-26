// Enhanced theme background generator that properly extracts BOTH dark and light variants
// Run with: dart run scripts/generate_backgrounds.dart

import 'dart:io';
import 'dart:math' as math;

void main() {
  print('🎨 Enhanced Theme Background Generator');
  print('=====================================\n');

  // Create assets/backgrounds directory
  final backgroundsDir = Directory('assets/backgrounds');
  if (!backgroundsDir.existsSync()) {
    backgroundsDir.createSync(recursive: true);
    print('📁 Created assets/backgrounds directory');
  }

  // Read all theme files and extract colors properly
  final themeDir = Directory('lib/core/theme/themes');
  final themeFiles = themeDir.listSync()
      .where((file) => file.path.endsWith('.dart'))
      .cast<File>()
      .toList();

  print('Found ${themeFiles.length} theme files');

  final extractedThemes = <String, Map<String, Map<String, dynamic>>>{};

  // Process each theme file
  for (final file in themeFiles) {
    final filename = file.path.split(Platform.pathSeparator).last.replaceAll('.dart', '');
    final themeName = filename.replaceAll('_theme', '');
    
    print('\\n🎨 Processing theme: $themeName');
    
    final content = file.readAsStringSync();
    final themeData = _extractThemeData(content, themeName);
    
    if (themeData.isNotEmpty) {
      extractedThemes[themeName] = themeData;
      final darkColors = themeData['dark']?['colors']?.length ?? 0;
      final lightColors = themeData['light']?['colors']?.length ?? 0;
      print('  ✅ Extracted $darkColors dark colors, $lightColors light colors');
    } else {
      print('  ⚠️  No theme data found');
    }
  }

  // Generate CSS and PNG data for each theme
  int totalGenerated = 0;
  for (final themeEntry in extractedThemes.entries) {
    final themeName = themeEntry.key;
    final themeData = themeEntry.value;

    // Generate dark variant
    if (themeData.containsKey('dark')) {
      final darkData = themeData['dark']!;
      final darkGradient = _generateCSSGradient(darkData);
      _writeGradientFile(backgroundsDir, '${themeName}_dark', darkGradient, darkData);
      print('  ✅ Generated ${themeName}_dark.css');
      totalGenerated++;
    }

    // Generate light variant
    if (themeData.containsKey('light')) {
      final lightData = themeData['light']!;
      final lightGradient = _generateCSSGradient(lightData);
      _writeGradientFile(backgroundsDir, '${themeName}_light', lightGradient, lightData);
      print('  ✅ Generated ${themeName}_light.css');
      totalGenerated++;
    }
  }

  // Generate comprehensive preview
  _generateEnhancedPreview(backgroundsDir, extractedThemes);
  
  // Generate JSON data for Python script
  _generateThemeJSON(backgroundsDir, extractedThemes);

  print('\\n🎉 Background generation complete!');
  print('📊 Generated $totalGenerated CSS gradient files');
  print('💾 Generated enhanced_theme_data.json for PNG generation');
  print('🌐 Generated enhanced_preview.html');
  print('\\n🔧 Next steps:');
  print('1. Run: python scripts/generate_png_backgrounds.py');
  print('2. Add assets to pubspec.yaml');
  print('3. Use OptimizedThemeBackgroundWidget in your app');
}

Map<String, Map<String, dynamic>> _extractThemeData(String content, String themeName) {
  final result = <String, Map<String, dynamic>>{};
  
  // Find the color creation method using a simpler approach
  final lines = content.split('\n');
  int methodStart = -1;
  int braceCount = 0;
  String methodBody = '';
  
  // Find the start of the color creation method
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (line.contains('static ThemeColors _create') && line.contains('Colors') && line.contains('bool isDark')) {
      methodStart = i;
      break;
    }
  }
  
  if (methodStart != -1) {
    // Extract the complete method body by counting braces
    for (int i = methodStart; i < lines.length; i++) {
      final line = lines[i];
      methodBody += line + '\n';
      
      // Count opening and closing braces
      braceCount += '{'.allMatches(line).length;
      braceCount -= '}'.allMatches(line).length;
      
      // When braces are balanced and we've started, we're done
      if (braceCount == 0 && i > methodStart) {
        break;
      }
    }
    
    // Now extract dark and light variants from the method body
    result.addAll(_extractVariantsFromMethodBody(methodBody));
  }
  
  // Fallback: try to extract from const declarations
  if (result.isEmpty) {
    result.addAll(_extractFromConstDeclarations(content));
  }
  
  return result;
}

Map<String, Map<String, dynamic>> _extractVariantsFromMethodBody(String methodBody) {
  final result = <String, Map<String, dynamic>>{};
  
  // Split by if (isDark) to find dark and light sections
  final parts = methodBody.split('if (isDark)');
  if (parts.length >= 2) {
    final conditionalPart = parts[1];
    
    // Find the dark section (after the opening brace of if)
    final darkStart = conditionalPart.indexOf('{');
    if (darkStart != -1) {
      int braceCount = 0;
      int darkEnd = darkStart;
      
      // Find the end of the dark section by counting braces
      for (int i = darkStart; i < conditionalPart.length; i++) {
        if (conditionalPart[i] == '{') braceCount++;
        if (conditionalPart[i] == '}') braceCount--;
        
        if (braceCount == 0) {
          darkEnd = i;
          break;
        }
      }
      
      final darkSection = conditionalPart.substring(darkStart + 1, darkEnd);
      final darkColors = _extractColorsFromBlock(darkSection);
      if (darkColors.isNotEmpty) {
        result['dark'] = {
          'colors': darkColors,
          'background': _findBackgroundColor(darkSection),
        };
      }
      
      // Look for the else section
      final remainingPart = conditionalPart.substring(darkEnd);
      final elseIndex = remainingPart.indexOf('} else {');
      if (elseIndex != -1) {
        final elseStart = elseIndex + 8; // Length of '} else {'
        int braceCount = 1; // We're already inside the else block
        int elseEnd = elseStart;
        
        // Find the end of the else section
        for (int i = elseStart; i < remainingPart.length; i++) {
          if (remainingPart[i] == '{') braceCount++;
          if (remainingPart[i] == '}') braceCount--;
          
          if (braceCount == 0) {
            elseEnd = i;
            break;
          }
        }
        
        final lightSection = remainingPart.substring(elseStart, elseEnd);
        final lightColors = _extractColorsFromBlock(lightSection);
        if (lightColors.isNotEmpty) {
          result['light'] = {
            'colors': lightColors,
            'background': _findBackgroundColor(lightSection),
          };
        }
      }
    }
  }
  
  return result;
}

List<String> _extractColorsFromBlock(String block) {
  final colors = <String>[];
  final colorRegex = RegExp(r'Color\(0x([A-Fa-f0-9]{8})\)');
  final matches = colorRegex.allMatches(block);
  
  for (final match in matches) {
    final colorHex = match.group(1)!;
    final color = '#${colorHex.substring(2)}'; // Remove alpha channel
    if (!colors.contains(color)) {
      colors.add(color);
    }
  }
  
  return colors.take(6).toList(); // Limit to 6 main colors
}

String _findBackgroundColor(String block) {
  // Look for background color specifically
  final bgRegex = RegExp(r'background:\s*Color\(0x([A-Fa-f0-9]{8})\)');
  final match = bgRegex.firstMatch(block);
  if (match != null) {
    return '#${match.group(1)!.substring(2)}';
  }
  
  // Fallback to first color found
  final colorRegex = RegExp(r'Color\(0x([A-Fa-f0-9]{8})\)');
  final firstMatch = colorRegex.firstMatch(block);
  if (firstMatch != null) {
    return '#${firstMatch.group(1)!.substring(2)}';
  }
  
  return '#000000'; // Default fallback
}

Map<String, Map<String, dynamic>> _extractFromConstDeclarations(String content) {
  final result = <String, Map<String, dynamic>>{};
  
  // Look for const color declarations
  final constRegex = RegExp(r'const\s+(\w+)\s*=\s*Color\(0x([A-Fa-f0-9]{8})\)');
  final matches = constRegex.allMatches(content);
  
  final colors = <String>[];
  for (final match in matches) {
    final colorHex = match.group(2)!;
    colors.add('#${colorHex.substring(2)}');
  }
  
  if (colors.isNotEmpty) {
    // Assume first half are dark, second half are light
    final midPoint = colors.length ~/ 2;
    
    if (midPoint > 0) {
      result['dark'] = {
        'colors': colors.take(midPoint).toList(),
        'background': colors.first,
      };
      
      result['light'] = {
        'colors': colors.skip(midPoint).toList(),
        'background': colors.length > midPoint ? colors[midPoint] : colors.first,
      };
    } else {
      result['dark'] = {
        'colors': colors,
        'background': colors.first,
      };
    }
  }
  
  return result;
}

String _generateCSSGradient(Map<String, dynamic> themeData) {
  final colors = themeData['colors'] as List<String>;
  final background = themeData['background'] as String;
  
  if (colors.length >= 3) {
    return '''radial-gradient(circle at center, 
  $background 0%, 
  ${colors[0]}40 30%, 
  ${colors[1]}30 60%, 
  ${colors[2]}20 80%, 
  $background 100%)''';
  } else if (colors.length >= 2) {
    return '''radial-gradient(circle at center, 
  $background 0%, 
  ${colors[0]}40 40%, 
  ${colors[1]}30 70%, 
  $background 100%)''';
  } else {
    return '''radial-gradient(circle at center, 
  $background 0%, 
  ${colors[0]}30 50%, 
  $background 100%)''';
  }
}

void _writeGradientFile(Directory dir, String filename, String gradient, Map<String, dynamic> themeData) {
  final file = File('${dir.path}/$filename.css');
  final background = themeData['background'] as String;
  final colors = themeData['colors'] as List<String>;
  
  final css = '''
/* $filename Theme Background */
.${filename.replaceAll('_', '-')}-background {
  background: $background;
  background: $gradient;
  width: 390px;
  height: 844px;
}

/* Alternative linear gradient */
.${filename.replaceAll('_', '-')}-background-linear {
  background: linear-gradient(135deg, 
    ${colors.isNotEmpty ? '${colors[0]}25' : '${background}25'} 0%, 
    ${colors.length > 1 ? '${colors[1]}20' : '${background}20'} 50%, 
    ${colors.length > 2 ? '${colors[2]}15' : '${background}15'} 100%);
  width: 390px;
  height: 844px;
}

/* Color palette */
/*
${colors.asMap().entries.map((e) => '  Color ${e.key + 1}: ${e.value}').join('\\n')}
*/
''';
  
  file.writeAsStringSync(css);
}

void _generateThemeJSON(Directory dir, Map<String, Map<String, Map<String, dynamic>>> themes) {
  final jsonData = StringBuffer();
  jsonData.writeln('{');
  jsonData.writeln('  "themes": {');
  
  final themeEntries = themes.entries.toList();
  for (int i = 0; i < themeEntries.length; i++) {
    final theme = themeEntries[i];
    final themeName = theme.key;
    final variants = theme.value;
    
    jsonData.writeln('    "$themeName": {');
    
    final variantEntries = variants.entries.toList();
    for (int j = 0; j < variantEntries.length; j++) {
      final variant = variantEntries[j];
      final variantName = variant.key;
      final variantData = variant.value;
      final colors = variantData['colors'] as List<String>;
      
      jsonData.writeln('      "$variantName": {');
      jsonData.writeln('        "background": "${variantData['background']}",');
      jsonData.writeln('        "colors": ${_formatColorArray(colors)}');
      jsonData.write('      }');
      
      if (j < variantEntries.length - 1) {
        jsonData.writeln(',');
      } else {
        jsonData.writeln();
      }
    }
    
    jsonData.write('    }');
    
    if (i < themeEntries.length - 1) {
      jsonData.writeln(',');
    } else {
      jsonData.writeln();
    }
  }
  
  jsonData.writeln('  }');
  jsonData.writeln('}');
  
  final jsonFile = File('${dir.path}/enhanced_theme_data.json');
  jsonFile.writeAsStringSync(jsonData.toString());
}

String _formatColorArray(List<String> colors) {
  if (colors.isEmpty) return '[]';
  return '[${colors.map((c) => '"$c"').join(', ')}]';
}

void _generateEnhancedPreview(Directory dir, Map<String, Map<String, Map<String, dynamic>>> themes) {
  final html = StringBuffer();
  html.writeln('''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Enhanced Theme Background Preview</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f8f9fa;
        }
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        h1 {
            text-align: center;
            color: #333;
            margin-bottom: 40px;
        }
        .theme-section {
            margin-bottom: 40px;
            background: white;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.08);
        }
        .theme-title {
            font-size: 24px;
            font-weight: 700;
            color: #333;
            margin-bottom: 20px;
            text-transform: capitalize;
        }
        .variants-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
        }
        .variant-section {
            border: 1px solid #e9ecef;
            border-radius: 8px;
            padding: 16px;
        }
        .variant-title {
            font-size: 16px;
            font-weight: 600;
            color: #666;
            margin-bottom: 12px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .gradient-preview {
            width: 100%;
            height: 120px;
            border-radius: 8px;
            margin: 12px 0;
            border: 1px solid #ddd;
        }
        .color-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(60px, 1fr));
            gap: 8px;
            margin-top: 12px;
        }
        .color-item {
            text-align: center;
        }
        .color-swatch {
            width: 100%;
            height: 40px;
            border-radius: 6px;
            border: 1px solid #ddd;
            margin-bottom: 4px;
        }
        .color-code {
            font-family: 'Monaco', 'Menlo', monospace;
            font-size: 9px;
            color: #666;
            font-weight: 500;
        }
        .stats {
            text-align: center;
            color: #666;
            margin-top: 40px;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 8px;
        }
        .no-variant {
            color: #999;
            font-style: italic;
            text-align: center;
            padding: 40px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎨 Enhanced Theme Background Preview</h1>
''');

  for (final themeEntry in themes.entries) {
    final themeName = themeEntry.key;
    final variants = themeEntry.value;

    html.writeln('''
        <div class="theme-section">
            <div class="theme-title">${_formatThemeName(themeName)}</div>
            <div class="variants-grid">
''');

    // Dark variant
    html.writeln('<div class="variant-section">');
    if (variants.containsKey('dark')) {
      final darkData = variants['dark']!;
      final darkColors = darkData['colors'] as List<String>;
      final darkBg = darkData['background'] as String;
      final gradient = _generateCSSGradient(darkData);
      
      html.writeln('''
                <div class="variant-title">Dark Theme (${darkColors.length} colors)</div>
                <div class="gradient-preview" style="background: $gradient;"></div>
                <div class="color-grid">
''');
      
      for (final color in darkColors) {
        html.writeln('''
                    <div class="color-item">
                        <div class="color-swatch" style="background: $color;"></div>
                        <div class="color-code">$color</div>
                    </div>
''');
      }
      
      html.writeln('                </div>');
    } else {
      html.writeln('<div class="no-variant">No dark variant found</div>');
    }
    html.writeln('            </div>');

    // Light variant
    html.writeln('<div class="variant-section">');
    if (variants.containsKey('light')) {
      final lightData = variants['light']!;
      final lightColors = lightData['colors'] as List<String>;
      final lightBg = lightData['background'] as String;
      final gradient = _generateCSSGradient(lightData);
      
      html.writeln('''
                <div class="variant-title">Light Theme (${lightColors.length} colors)</div>
                <div class="gradient-preview" style="background: $gradient;"></div>
                <div class="color-grid">
''');
      
      for (final color in lightColors) {
        html.writeln('''
                    <div class="color-item">
                        <div class="color-swatch" style="background: $color;"></div>
                        <div class="color-code">$color</div>
                    </div>
''');
      }
      
      html.writeln('                </div>');
    } else {
      html.writeln('<div class="no-variant">No light variant found</div>');
    }
    html.writeln('            </div>');

    html.writeln('''
            </div>
        </div>
''');
  }

  final totalVariants = themes.values
      .map((variants) => variants.length)
      .reduce((a, b) => a + b);

  html.writeln('''
        <div class="stats">
            <p><strong>Enhanced Extraction Complete!</strong></p>
            <p>Processed ${themes.length} themes with $totalVariants total variants</p>
            <p>Properly extracted both dark and light theme colors from theme creation methods</p>
            <p>Ready for PNG generation with python scripts/generate_png_backgrounds.py</p>
        </div>
    </div>
</body>
</html>
''');

  final file = File('${dir.path}/enhanced_preview.html');
  file.writeAsStringSync(html.toString());
}

String _formatThemeName(String name) {
  return name
      .split('_')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}