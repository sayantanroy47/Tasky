// Complete theme color extractor
// Run with: dart run scripts/extract_all_theme_colors.dart

import 'dart:io';

void main() {
  print('🎨 Complete Theme Color Extractor');
  print('==================================\n');

  // Read all theme files and extract colors
  final themeDir = Directory('lib/core/theme/themes');
  final themeFiles = themeDir.listSync()
      .where((file) => file.path.endsWith('.dart'))
      .cast<File>()
      .toList();

  print('Found ${themeFiles.length} theme files:');
  
  final extractedThemes = <String, Map<String, List<String>>>{};
  
  for (final file in themeFiles) {
    final filename = file.path.split(Platform.pathSeparator).last.replaceAll('.dart', '');
    final themeName = filename.replaceAll('_theme', '');
    
    print('📄 Processing: $themeName');
    
    final content = file.readAsStringSync();
    final colors = _extractColorsFromTheme(content);
    
    if (colors.isNotEmpty) {
      extractedThemes[themeName] = colors;
      print('  ✅ Extracted ${colors['dark']?.length ?? 0} dark colors, ${colors['light']?.length ?? 0} light colors');
    } else {
      print('  ⚠️  No colors found');
    }
  }

  // Generate comprehensive color data
  _generateColorData(extractedThemes);
  
  print('\\n🎉 Color extraction complete!');
  print('📊 Processed ${extractedThemes.length} themes');
  print('💾 Generated assets/backgrounds/theme_colors.json');
}

Map<String, List<String>> _extractColorsFromTheme(String content) {
  final darkColors = <String>[];
  final lightColors = <String>[];
  
  // Extract color values using regex - fix the pattern
  final colorRegex = RegExp(r'Color\(0x([A-Fa-f0-9]{8})\)');
  final matches = colorRegex.allMatches(content);
  
  // Look for dark/light theme sections
  final isDarkSection = RegExp(r'if \(isDark\)|isDark \?|createDark\(\)');
  final isLightSection = RegExp(r'else|createLight\(\)');
  
  // Extract all colors first
  final allColors = matches.map((match) => match.group(1)!).toList();
  
  if (allColors.isEmpty) {
    return {'dark': [], 'light': []};
  }
  
  // Try to separate dark and light colors based on context
  final lines = content.split('\n');
  bool inDarkSection = false;
  bool inLightSection = false;
  
  for (final line in lines) {
    if (line.contains('isDark') || line.contains('createDark')) {
      inDarkSection = true;
      inLightSection = false;
    } else if (line.contains('createLight') || line.contains('} else {')) {
      inDarkSection = false;
      inLightSection = true;
    }
    
    final lineMatches = colorRegex.allMatches(line);
    for (final match in lineMatches) {
      final colorHex = match.group(1)!;
      final color = '#${colorHex.substring(2)}'; // Remove alpha channel for CSS
      
      if (inDarkSection && darkColors.length < 10) {
        darkColors.add(color);
      } else if (inLightSection && lightColors.length < 10) {
        lightColors.add(color);
      }
    }
  }
  
  // Fallback: if we couldn't separate them, split evenly
  if (darkColors.isEmpty && lightColors.isEmpty && allColors.isNotEmpty) {
    final midPoint = allColors.length ~/ 2;
    for (int i = 0; i < allColors.length && (darkColors.length < 10 || lightColors.length < 10); i++) {
      final color = '#${allColors[i].substring(2)}';
      if (i < midPoint && darkColors.length < 10) {
        darkColors.add(color);
      } else if (lightColors.length < 10) {
        lightColors.add(color);
      }
    }
  }
  
  return {
    'dark': darkColors,
    'light': lightColors,
  };
}

void _generateColorData(Map<String, Map<String, List<String>>> themes) {
  final backgroundsDir = Directory('assets/backgrounds');
  if (!backgroundsDir.existsSync()) {
    backgroundsDir.createSync(recursive: true);
  }
  
  // Generate JSON data
  final jsonData = StringBuffer();
  jsonData.writeln('{');
  jsonData.writeln('  "themes": {');
  
  final themeEntries = themes.entries.toList();
  for (int i = 0; i < themeEntries.length; i++) {
    final theme = themeEntries[i];
    final themeName = theme.key;
    final colors = theme.value;
    
    jsonData.writeln('    "$themeName": {');
    jsonData.writeln('      "dark": ${_formatColorArray(colors['dark'] ?? [])},');
    jsonData.writeln('      "light": ${_formatColorArray(colors['light'] ?? [])}');
    jsonData.write('    }');
    
    if (i < themeEntries.length - 1) {
      jsonData.writeln(',');
    } else {
      jsonData.writeln();
    }
  }
  
  jsonData.writeln('  }');
  jsonData.writeln('}');
  
  final jsonFile = File('${backgroundsDir.path}/theme_colors.json');
  jsonFile.writeAsStringSync(jsonData.toString());
  
  // Generate HTML preview with all extracted colors
  _generateFullPreview(backgroundsDir, themes);
}

String _formatColorArray(List<String> colors) {
  if (colors.isEmpty) return '[]';
  return '[${colors.map((c) => '"$c"').join(', ')}]';
}

void _generateFullPreview(Directory dir, Map<String, Map<String, List<String>>> themes) {
  final html = StringBuffer();
  html.writeln('''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Complete Theme Color Extraction</title>
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
        .variant-section {
            margin-bottom: 24px;
        }
        .variant-title {
            font-size: 16px;
            font-weight: 600;
            color: #666;
            margin-bottom: 12px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .color-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
            gap: 12px;
        }
        .color-item {
            text-align: center;
        }
        .color-swatch {
            width: 100%;
            height: 60px;
            border-radius: 8px;
            border: 1px solid #ddd;
            margin-bottom: 8px;
            position: relative;
            overflow: hidden;
        }
        .color-code {
            font-family: 'Monaco', 'Menlo', monospace;
            font-size: 11px;
            color: #666;
            font-weight: 500;
        }
        .gradient-preview {
            width: 100%;
            height: 100px;
            border-radius: 8px;
            margin: 16px 0;
            border: 1px solid #ddd;
        }
        .stats {
            text-align: center;
            color: #666;
            margin-top: 40px;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 8px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎨 Complete Theme Color Extraction</h1>
''');

  for (final themeEntry in themes.entries) {
    final themeName = themeEntry.key;
    final colors = themeEntry.value;
    final darkColors = colors['dark'] ?? [];
    final lightColors = colors['light'] ?? [];

    html.writeln('''
        <div class="theme-section">
            <div class="theme-title">${_formatThemeName(themeName)}</div>
''');

    // Dark variant
    if (darkColors.isNotEmpty) {
      html.writeln('''
            <div class="variant-section">
                <div class="variant-title">Dark Theme (${darkColors.length} colors)</div>
                <div class="gradient-preview" style="background: linear-gradient(135deg, ${darkColors.take(5).join(', ')});"></div>
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
      
      html.writeln('''
                </div>
            </div>
''');
    }

    // Light variant
    if (lightColors.isNotEmpty) {
      html.writeln('''
            <div class="variant-section">
                <div class="variant-title">Light Theme (${lightColors.length} colors)</div>
                <div class="gradient-preview" style="background: linear-gradient(135deg, ${lightColors.take(5).join(', ')});"></div>
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
      
      html.writeln('''
                </div>
            </div>
''');
    }

    html.writeln('        </div>');
  }

  html.writeln('''
        <div class="stats">
            <p><strong>Extraction Complete!</strong></p>
            <p>Processed ${themes.length} themes with ${themes.values.map((t) => (t['dark']?.length ?? 0) + (t['light']?.length ?? 0)).reduce((a, b) => a + b)} total colors</p>
            <p>Colors extracted from Flutter theme files using regex pattern matching</p>
        </div>
    </div>
</body>
</html>
''');

  final file = File('${dir.path}/complete_theme_colors.html');
  file.writeAsStringSync(html.toString());
}

String _formatThemeName(String name) {
  return name
      .split('_')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}