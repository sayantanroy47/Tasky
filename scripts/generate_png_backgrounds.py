#!/usr/bin/env python3
"""
Generate PNG background images from extracted theme colors
Requires: pip install pillow
Run with: python scripts/generate_png_backgrounds.py
"""

import json
import os
from PIL import Image, ImageDraw
import math

def hex_to_rgb(hex_color):
    """Convert hex color to RGB tuple"""
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def create_radial_gradient(width, height, colors, center=(0.5, 0.5)):
    """Create a radial gradient image"""
    image = Image.new('RGB', (width, height))
    draw = ImageDraw.Draw(image)
    
    # Convert center to pixel coordinates
    center_x = int(center[0] * width)
    center_y = int(center[1] * height)
    
    # Calculate maximum radius
    max_radius = math.sqrt(width**2 + height**2) / 2
    
    # Create gradient
    for y in range(height):
        for x in range(width):
            # Calculate distance from center
            distance = math.sqrt((x - center_x)**2 + (y - center_y)**2)
            
            # Normalize distance (0 to 1)
            normalized_distance = min(distance / max_radius, 1.0)
            
            # Interpolate between colors
            if len(colors) >= 3:
                if normalized_distance < 0.4:
                    # Interpolate between first and second color
                    t = normalized_distance / 0.4
                    color = interpolate_color(colors[0], colors[1], t)
                elif normalized_distance < 0.7:
                    # Interpolate between second and third color
                    t = (normalized_distance - 0.4) / 0.3
                    color = interpolate_color(colors[1], colors[2], t)
                else:
                    # Interpolate between third and first color (back to background)
                    t = (normalized_distance - 0.7) / 0.3
                    color = interpolate_color(colors[2], colors[0], t)
            else:
                # Simple two-color gradient
                color = interpolate_color(colors[0], colors[-1], normalized_distance)
            
            image.putpixel((x, y), color)
    
    return image

def interpolate_color(color1, color2, t):
    """Interpolate between two RGB colors"""
    r1, g1, b1 = color1
    r2, g2, b2 = color2
    
    r = int(r1 + (r2 - r1) * t)
    g = int(g1 + (g2 - g1) * t)
    b = int(b1 + (b2 - b1) * t)
    
    return (r, g, b)

def create_linear_gradient(width, height, colors, angle=135):
    """Create a linear gradient image"""
    image = Image.new('RGB', (width, height))
    draw = ImageDraw.Draw(image)
    
    # Convert angle to radians
    angle_rad = math.radians(angle)
    
    # Calculate gradient direction
    cos_angle = math.cos(angle_rad)
    sin_angle = math.sin(angle_rad)
    
    # Calculate the length of the gradient line
    gradient_length = abs(width * cos_angle) + abs(height * sin_angle)
    
    for y in range(height):
        for x in range(width):
            # Calculate position along gradient line
            position = (x * cos_angle + y * sin_angle) / gradient_length
            position = max(0, min(1, position))  # Clamp to [0, 1]
            
            # Interpolate color
            if len(colors) >= 3:
                if position < 0.5:
                    t = position * 2
                    color = interpolate_color(colors[0], colors[1], t)
                else:
                    t = (position - 0.5) * 2
                    color = interpolate_color(colors[1], colors[2], t)
            else:
                color = interpolate_color(colors[0], colors[-1], position)
            
            image.putpixel((x, y), color)
    
    return image

def generate_theme_backgrounds():
    """Generate PNG backgrounds for all themes"""
    print("🎨 PNG Background Generator")
    print("===========================\n")
    
    # Load theme colors - try enhanced data first, fallback to basic
    enhanced_file = 'assets/backgrounds/enhanced_theme_data.json'
    basic_file = 'assets/backgrounds/theme_colors.json'
    
    if os.path.exists(enhanced_file):
        colors_file = enhanced_file
        print("📊 Using enhanced theme data")
    elif os.path.exists(basic_file):
        colors_file = basic_file
        print("📊 Using basic theme data")
    else:
        print(f"❌ Error: No theme data found!")
        print("Please run 'dart run scripts/generate_backgrounds.dart' first")
        return
    
    with open(colors_file, 'r') as f:
        data = json.load(f)
    
    themes = data['themes']
    
    # Create output directory
    output_dir = 'assets/backgrounds'
    os.makedirs(output_dir, exist_ok=True)
    
    # Image dimensions (mobile screen size)
    width, height = 390, 844
    
    total_generated = 0
    
    for theme_name, theme_colors in themes.items():
        print(f"🎨 Processing theme: {theme_name}")
        
        # Generate dark variant
        dark_data = theme_colors.get('dark', {})
        if dark_data:
            # Handle both enhanced format (with 'colors' key) and basic format (direct list)
            if isinstance(dark_data, dict) and 'colors' in dark_data:
                dark_colors = dark_data['colors']
            elif isinstance(dark_data, list):
                dark_colors = dark_data
            else:
                dark_colors = []
                
            if dark_colors:
                try:
                    # Convert hex colors to RGB
                    rgb_colors = [hex_to_rgb(color) for color in dark_colors[:3]]
                    
                    # Create radial gradient
                    radial_image = create_radial_gradient(width, height, rgb_colors)
                    radial_path = os.path.join(output_dir, f"{theme_name}_dark_radial.png")
                    radial_image.save(radial_path)
                    
                    # Create linear gradient
                    linear_image = create_linear_gradient(width, height, rgb_colors)
                    linear_path = os.path.join(output_dir, f"{theme_name}_dark_linear.png")
                    linear_image.save(linear_path)
                    
                    print(f"  ✅ Generated {theme_name}_dark_radial.png and {theme_name}_dark_linear.png")
                    total_generated += 2
                    
                except Exception as e:
                    print(f"  ❌ Failed to generate {theme_name}_dark: {e}")
        
        # Generate light variant
        light_data = theme_colors.get('light', {})
        if light_data:
            # Handle both enhanced format (with 'colors' key) and basic format (direct list)
            if isinstance(light_data, dict) and 'colors' in light_data:
                light_colors = light_data['colors']
            elif isinstance(light_data, list):
                light_colors = light_data
            else:
                light_colors = []
                
            if light_colors:
                try:
                    # Convert hex colors to RGB
                    rgb_colors = [hex_to_rgb(color) for color in light_colors[:3]]
                    
                    # Create radial gradient
                    radial_image = create_radial_gradient(width, height, rgb_colors)
                    radial_path = os.path.join(output_dir, f"{theme_name}_light_radial.png")
                    radial_image.save(radial_path)
                    
                    # Create linear gradient
                    linear_image = create_linear_gradient(width, height, rgb_colors)
                    linear_path = os.path.join(output_dir, f"{theme_name}_light_linear.png")
                    linear_image.save(linear_path)
                    
                    print(f"  ✅ Generated {theme_name}_light_radial.png and {theme_name}_light_linear.png")
                    total_generated += 2
                    
                except Exception as e:
                    print(f"  ❌ Failed to generate {theme_name}_light: {e}")
    
    print(f"\n🎉 PNG generation complete!")
    print(f"📊 Generated {total_generated} PNG files in {output_dir}/")
    print(f"💡 You can now use these PNGs as background images in your Flutter app")
    
    # Generate a simple HTML preview
    generate_png_preview(output_dir, themes)
    print(f"🌐 Generated PNG preview at {output_dir}/png_preview.html")

def generate_png_preview(output_dir, themes):
    """Generate HTML preview of PNG backgrounds"""
    html_content = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PNG Background Preview</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        h1 {
            text-align: center;
            color: #333;
            margin-bottom: 40px;
        }
        .theme-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }
        .theme-card {
            background: white;
            border-radius: 12px;
            padding: 16px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .theme-name {
            font-weight: 600;
            color: #333;
            margin-bottom: 12px;
            text-transform: capitalize;
        }
        .preview-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 8px;
        }
        .preview-item {
            text-align: center;
        }
        .preview-image {
            width: 100%;
            height: 120px;
            object-fit: cover;
            border-radius: 8px;
            border: 1px solid #ddd;
            margin-bottom: 4px;
        }
        .preview-label {
            font-size: 11px;
            color: #666;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .stats {
            text-align: center;
            color: #666;
            margin-top: 40px;
            padding: 20px;
            background: white;
            border-radius: 8px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎨 PNG Background Preview</h1>
        <div class="theme-grid">
"""
    
    for theme_name in themes.keys():
        theme_display_name = theme_name.replace('_', ' ').title()
        html_content += f"""
            <div class="theme-card">
                <div class="theme-name">{theme_display_name}</div>
                <div class="preview-grid">
"""
        
        # Check which files exist and add them
        variants = [
            (f"{theme_name}_dark_radial.png", "Dark Radial"),
            (f"{theme_name}_dark_linear.png", "Dark Linear"),
            (f"{theme_name}_light_radial.png", "Light Radial"),
            (f"{theme_name}_light_linear.png", "Light Linear"),
        ]
        
        for filename, label in variants:
            filepath = os.path.join(output_dir, filename)
            if os.path.exists(filepath):
                html_content += f"""
                    <div class="preview-item">
                        <img src="{filename}" alt="{label}" class="preview-image">
                        <div class="preview-label">{label}</div>
                    </div>
"""
        
        html_content += """
                </div>
            </div>
"""
    
    html_content += f"""
        </div>
        <div class="stats">
            <p><strong>PNG Generation Complete!</strong></p>
            <p>Generated background images for {len(themes)} themes</p>
            <p>Each theme includes radial and linear gradient variants</p>
        </div>
    </div>
</body>
</html>
"""
    
    with open(os.path.join(output_dir, 'png_preview.html'), 'w') as f:
        f.write(html_content)

if __name__ == "__main__":
    try:
        generate_theme_backgrounds()
    except ImportError:
        print("❌ Error: PIL (Pillow) is required to generate PNG images")
        print("Install it with: pip install pillow")
    except Exception as e:
        print(f"❌ Error: {e}")