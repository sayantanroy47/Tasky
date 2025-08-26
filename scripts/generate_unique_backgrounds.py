#!/usr/bin/env python3
"""
Generate UNIQUE theme-specific background images that capture each theme's essence
Run with: python scripts/generate_unique_backgrounds.py
"""

import json
import os
from PIL import Image, ImageDraw, ImageFont
import math
import random

def hex_to_rgb(hex_color):
    """Convert hex color to RGB tuple"""
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def create_matrix_background(width, height, is_dark=True):
    """Create Matrix-style code rain background"""
    image = Image.new('RGB', (width, height), (0, 0, 0) if is_dark else (240, 240, 240))
    draw = ImageDraw.Draw(image)
    
    # Matrix characters
    chars = "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン0123456789"
    
    # Create falling code effect
    for col in range(0, width, 20):
        # Random column height
        col_height = random.randint(height // 4, height)
        start_y = random.randint(-height // 2, height // 4)
        
        for y in range(start_y, start_y + col_height, 20):
            if 0 <= y < height:
                char = random.choice(chars)
                # Fade effect - brighter at bottom
                alpha = min(255, max(50, int(255 * (y - start_y) / col_height)))
                
                if is_dark:
                    color = (0, alpha, 0)  # Green
                else:
                    color = (0, max(100, 255 - alpha), 0)  # Dark green on light
                
                # Simple text rendering (approximate)
                draw.rectangle([col, y, col + 15, y + 15], fill=color)
    
    return image

def create_cyberpunk_background(width, height, is_dark=True):
    """Create Cyberpunk 2077 neon city background"""
    if is_dark:
        bg_color = (13, 13, 13)  # Tech black
        neon_colors = [(255, 255, 0), (255, 0, 255), (0, 191, 255)]  # Neon yellow, magenta, blue
    else:
        bg_color = (248, 248, 255)  # Tech white
        neon_colors = [(230, 230, 0), (204, 0, 204), (0, 128, 204)]  # Darker neons
    
    image = Image.new('RGB', (width, height), bg_color)
    draw = ImageDraw.Draw(image)
    
    # Create neon grid lines
    grid_size = 40
    for x in range(0, width, grid_size):
        color = random.choice(neon_colors)
        alpha = random.randint(30, 80)
        # Vertical lines with glow effect
        for offset in range(-2, 3):
            line_alpha = max(0, alpha - abs(offset) * 20)
            line_color = tuple(int(c * line_alpha / 255) for c in color)
            if x + offset >= 0 and x + offset < width:
                draw.line([(x + offset, 0), (x + offset, height)], fill=line_color)
    
    # Add some horizontal accent lines
    for y in range(0, height, grid_size * 3):
        color = random.choice(neon_colors)
        alpha = random.randint(20, 60)
        for offset in range(-1, 2):
            line_alpha = max(0, alpha - abs(offset) * 15)
            line_color = tuple(int(c * line_alpha / 255) for c in color)
            if y + offset >= 0 and y + offset < height:
                draw.line([(0, y + offset), (width, y + offset)], fill=line_color)
    
    return image

def create_dracula_background(width, height, is_dark=True):
    """Create Dracula IDE background with floating code elements"""
    if is_dark:
        bg_color = (40, 42, 54)  # Dracula background
        accent_colors = [(255, 121, 198), (189, 147, 249), (139, 233, 253)]  # Pink, purple, cyan
    else:
        bg_color = (248, 248, 242)  # Light background
        accent_colors = [(255, 121, 198), (189, 147, 249), (139, 233, 253)]  # Same accents
    
    image = Image.new('RGB', (width, height), bg_color)
    draw = ImageDraw.Draw(image)
    
    # Create floating geometric shapes
    for _ in range(15):
        x = random.randint(0, width)
        y = random.randint(0, height)
        size = random.randint(20, 80)
        color = random.choice(accent_colors)
        alpha = random.randint(20, 60)
        
        # Apply alpha
        final_color = tuple(int(bg_color[i] * (1 - alpha/255) + color[i] * (alpha/255)) for i in range(3))
        
        shape_type = random.choice(['circle', 'rect', 'triangle'])
        if shape_type == 'circle':
            draw.ellipse([x - size//2, y - size//2, x + size//2, y + size//2], fill=final_color)
        elif shape_type == 'rect':
            draw.rectangle([x - size//2, y - size//2, x + size//2, y + size//2], fill=final_color)
        else:  # triangle
            points = [(x, y - size//2), (x - size//2, y + size//2), (x + size//2, y + size//2)]
            draw.polygon(points, fill=final_color)
    
    return image

def create_artist_palette_background(width, height, is_dark=True):
    """Create Artist Palette background with paint splatters"""
    if is_dark:
        bg_color = (22, 19, 15)  # Night studio
        paint_colors = [(216, 67, 21), (25, 118, 210), (245, 127, 23)]  # Vermillion, blue, orange
    else:
        bg_color = (255, 253, 247)  # Canvas white
        paint_colors = [(255, 87, 34), (33, 150, 243), (255, 235, 59)]  # Brighter paints
    
    image = Image.new('RGB', (width, height), bg_color)
    draw = ImageDraw.Draw(image)
    
    # Create paint splatters
    for _ in range(25):
        x = random.randint(0, width)
        y = random.randint(0, height)
        color = random.choice(paint_colors)
        
        # Main splatter
        main_size = random.randint(15, 40)
        alpha = random.randint(40, 80)
        final_color = tuple(int(bg_color[i] * (1 - alpha/255) + color[i] * (alpha/255)) for i in range(3))
        draw.ellipse([x - main_size//2, y - main_size//2, x + main_size//2, y + main_size//2], fill=final_color)
        
        # Small droplets around main splatter
        for _ in range(random.randint(3, 8)):
            dx = random.randint(-main_size, main_size)
            dy = random.randint(-main_size, main_size)
            droplet_size = random.randint(3, 8)
            droplet_alpha = random.randint(20, 50)
            droplet_color = tuple(int(bg_color[i] * (1 - droplet_alpha/255) + color[i] * (droplet_alpha/255)) for i in range(3))
            
            drop_x, drop_y = x + dx, y + dy
            if 0 <= drop_x < width and 0 <= drop_y < height:
                draw.ellipse([drop_x - droplet_size//2, drop_y - droplet_size//2, 
                            drop_x + droplet_size//2, drop_y + droplet_size//2], fill=droplet_color)
    
    return image

def create_vegeta_background(width, height, is_dark=True):
    """Create Vegeta Blue theme with energy aura effects"""
    if is_dark:
        bg_color = (10, 10, 10)  # Cosmic void
        aura_colors = [(30, 58, 138), (0, 157, 255), (96, 165, 250)]  # Blue energy
    else:
        bg_color = (248, 250, 252)  # Light cosmic
        aura_colors = [(30, 58, 138), (0, 157, 255), (96, 165, 250)]  # Same energy
    
    image = Image.new('RGB', (width, height), bg_color)
    draw = ImageDraw.Draw(image)
    
    # Create energy aura emanating from center
    center_x, center_y = width // 2, height // 2
    
    for radius in range(50, min(width, height) // 2, 30):
        color = random.choice(aura_colors)
        alpha = max(10, 60 - (radius // 20))  # Fade with distance
        
        # Create energy ring
        for angle in range(0, 360, 10):
            rad = math.radians(angle)
            # Add some randomness to make it look like energy
            r = radius + random.randint(-10, 10)
            x = center_x + int(r * math.cos(rad))
            y = center_y + int(r * math.sin(rad))
            
            if 0 <= x < width and 0 <= y < height:
                final_color = tuple(int(bg_color[i] * (1 - alpha/255) + color[i] * (alpha/255)) for i in range(3))
                size = random.randint(3, 8)
                draw.ellipse([x - size//2, y - size//2, x + size//2, y + size//2], fill=final_color)
    
    return image

def create_autumn_forest_background(width, height, is_dark=True):
    """Create Autumn Forest background with falling leaves"""
    if is_dark:
        bg_color = (26, 22, 17)  # Dark forest
        leaf_colors = [(191, 54, 12), (255, 143, 0), (230, 81, 0)]  # Autumn colors
    else:
        bg_color = (255, 251, 245)  # Light forest
        leaf_colors = [(216, 67, 21), (255, 143, 0), (106, 76, 57)]  # Warmer autumn
    
    image = Image.new('RGB', (width, height), bg_color)
    draw = ImageDraw.Draw(image)
    
    # Create falling leaves
    for _ in range(30):
        x = random.randint(0, width)
        y = random.randint(0, height)
        color = random.choice(leaf_colors)
        
        # Leaf shape (approximate with ellipse)
        leaf_width = random.randint(8, 20)
        leaf_height = random.randint(12, 25)
        alpha = random.randint(30, 70)
        
        final_color = tuple(int(bg_color[i] * (1 - alpha/255) + color[i] * (alpha/255)) for i in range(3))
        
        # Rotate the leaf
        angle = random.randint(0, 360)
        # Simple leaf shape
        draw.ellipse([x - leaf_width//2, y - leaf_height//2, x + leaf_width//2, y + leaf_height//2], fill=final_color)
        
        # Add stem
        stem_color = tuple(int(c * 0.7) for c in final_color)  # Darker stem
        draw.line([(x, y), (x + random.randint(-5, 5), y + leaf_height//2 + 5)], fill=stem_color, width=2)
    
    return image

def create_unicorn_dream_background(width, height, is_dark=True):
    """Create Unicorn Dream background with rainbow sparkles"""
    if is_dark:
        bg_color = (25, 20, 35)  # Midnight magic
        rainbow_colors = [(255, 182, 193), (221, 160, 221), (173, 216, 230), (144, 238, 144)]
    else:
        bg_color = (255, 250, 255)  # Dream white
        rainbow_colors = [(255, 105, 180), (186, 85, 211), (135, 206, 235), (144, 238, 144)]
    
    image = Image.new('RGB', (width, height), bg_color)
    draw = ImageDraw.Draw(image)
    
    # Create sparkles and rainbow swirls
    for _ in range(40):
        x = random.randint(0, width)
        y = random.randint(0, height)
        color = random.choice(rainbow_colors)
        
        # Create sparkle
        size = random.randint(4, 12)
        alpha = random.randint(40, 80)
        final_color = tuple(int(bg_color[i] * (1 - alpha/255) + color[i] * (alpha/255)) for i in range(3))
        
        # Star shape (approximate with diamond)
        points = [
            (x, y - size),      # top
            (x + size//2, y),   # right
            (x, y + size),      # bottom
            (x - size//2, y)    # left
        ]
        draw.polygon(points, fill=final_color)
        
        # Add cross sparkle
        draw.line([(x - size//2, y), (x + size//2, y)], fill=final_color, width=2)
        draw.line([(x, y - size//2), (x, y + size//2)], fill=final_color, width=2)
    
    return image

def create_demon_slayer_background(width, height, is_dark=True):
    """Create Demon Slayer flame background with fire effects"""
    if is_dark:
        bg_color = (20, 10, 5)  # Dark ember
        flame_colors = [(139, 0, 0), (255, 69, 0), (255, 140, 0), (255, 215, 0)]  # Fire gradient
    else:
        bg_color = (255, 248, 240)  # Light flame
        flame_colors = [(139, 0, 0), (255, 69, 0), (255, 140, 0), (255, 215, 0)]
    
    image = Image.new('RGB', (width, height), bg_color)
    draw = ImageDraw.Draw(image)
    
    # Create flame-like patterns rising from bottom
    for x in range(0, width, 15):
        flame_height = random.randint(height // 3, height)
        base_y = height
        
        # Create flame tongue
        for y in range(base_y, base_y - flame_height, -10):
            if y < 0:
                break
                
            # Flame gets narrower as it goes up
            flame_width = max(5, int(20 * (base_y - y) / flame_height))
            color_index = min(3, int(4 * (base_y - y) / flame_height))
            color = flame_colors[color_index]
            
            # Add randomness to flame shape
            offset = random.randint(-flame_width//2, flame_width//2)
            alpha = random.randint(30, 80)
            
            final_color = tuple(int(bg_color[i] * (1 - alpha/255) + color[i] * (alpha/255)) for i in range(3))
            
            # Draw flame segment
            draw.ellipse([x + offset - flame_width//2, y - 5, 
                         x + offset + flame_width//2, y + 5], fill=final_color)
    
    return image

def create_hollow_knight_background(width, height, is_dark=True):
    """Create Hollow Knight shadow background with void effects"""
    if is_dark:
        bg_color = (8, 8, 12)  # Deep void
        void_colors = [(64, 64, 96), (96, 96, 128), (128, 128, 160)]  # Shadow blues
    else:
        bg_color = (240, 240, 245)  # Light void
        void_colors = [(180, 180, 200), (160, 160, 180), (140, 140, 160)]
    
    image = Image.new('RGB', (width, height), bg_color)
    draw = ImageDraw.Draw(image)
    
    # Create void particles and shadow wisps
    for _ in range(25):
        x = random.randint(0, width)
        y = random.randint(0, height)
        color = random.choice(void_colors)
        
        # Create wispy shadow effect
        size = random.randint(20, 60)
        alpha = random.randint(20, 50)
        
        # Draw multiple overlapping circles for wispy effect
        for i in range(3):
            offset_x = random.randint(-size//4, size//4)
            offset_y = random.randint(-size//4, size//4)
            circle_size = size - i * 10
            
            final_color = tuple(int(bg_color[i] * (1 - alpha/255) + color[i] * (alpha/255)) for i in range(3))
            
            draw.ellipse([x + offset_x - circle_size//2, y + offset_y - circle_size//2,
                         x + offset_x + circle_size//2, y + offset_y + circle_size//2], fill=final_color)
    
    return image

def create_starfield_background(width, height, is_dark=True):
    """Create Starfield cosmic background with stars and nebula"""
    if is_dark:
        bg_color = (5, 5, 15)  # Deep space
        star_colors = [(255, 255, 255), (255, 255, 200), (200, 200, 255), (255, 200, 200)]
        nebula_colors = [(100, 50, 150), (150, 50, 100), (50, 100, 150)]
    else:
        bg_color = (240, 245, 255)  # Light cosmic
        star_colors = [(255, 255, 255), (255, 255, 200), (200, 200, 255), (255, 200, 200)]
        nebula_colors = [(200, 150, 250), (250, 150, 200), (150, 200, 250)]
    
    image = Image.new('RGB', (width, height), bg_color)
    draw = ImageDraw.Draw(image)
    
    # Create nebula clouds first
    for _ in range(8):
        x = random.randint(0, width)
        y = random.randint(0, height)
        color = random.choice(nebula_colors)
        size = random.randint(80, 150)
        alpha = random.randint(15, 35)
        
        final_color = tuple(int(bg_color[i] * (1 - alpha/255) + color[i] * (alpha/255)) for i in range(3))
        draw.ellipse([x - size//2, y - size//2, x + size//2, y + size//2], fill=final_color)
    
    # Create stars
    for _ in range(100):
        x = random.randint(0, width)
        y = random.randint(0, height)
        color = random.choice(star_colors)
        size = random.randint(1, 4)
        
        # Bright stars
        if random.random() < 0.1:  # 10% chance for bright star
            size = random.randint(3, 6)
            # Draw cross pattern for bright stars
            draw.line([(x - size, y), (x + size, y)], fill=color, width=1)
            draw.line([(x, y - size), (x, y + size)], fill=color, width=1)
        
        draw.ellipse([x - size//2, y - size//2, x + size//2, y + size//2], fill=color)
    
    return image

def create_executive_background(width, height, is_dark=True):
    """Create Executive Platinum background with geometric patterns"""
    if is_dark:
        bg_color = (66, 66, 66)  # Executive gray
        accent_colors = [(255, 179, 0), (224, 224, 224), (158, 158, 158)]  # Gold, platinum, silver
    else:
        bg_color = (248, 248, 248)  # Light executive
        accent_colors = [(255, 179, 0), (158, 158, 158), (97, 97, 97)]
    
    image = Image.new('RGB', (width, height), bg_color)
    draw = ImageDraw.Draw(image)
    
    # Create professional geometric pattern
    grid_size = 60
    for x in range(0, width, grid_size):
        for y in range(0, height, grid_size):
            if random.random() < 0.3:  # 30% chance for pattern
                color = random.choice(accent_colors)
                alpha = random.randint(10, 30)
                
                final_color = tuple(int(bg_color[i] * (1 - alpha/255) + color[i] * (alpha/255)) for i in range(3))
                
                # Draw professional shapes
                shape_type = random.choice(['rect', 'diamond', 'line'])
                if shape_type == 'rect':
                    size = random.randint(20, 40)
                    draw.rectangle([x, y, x + size, y + size], fill=final_color)
                elif shape_type == 'diamond':
                    size = random.randint(15, 30)
                    points = [(x + size//2, y), (x + size, y + size//2), 
                             (x + size//2, y + size), (x, y + size//2)]
                    draw.polygon(points, fill=final_color)
                else:  # line
                    draw.line([(x, y), (x + grid_size, y + grid_size)], fill=final_color, width=2)
    
    return image

def generate_unique_backgrounds():
    """Generate unique theme-specific backgrounds"""
    print("🎨 Unique Theme Background Generator")
    print("====================================\n")
    
    # Create output directory
    output_dir = 'assets/backgrounds'
    os.makedirs(output_dir, exist_ok=True)
    
    # Image dimensions
    width, height = 390, 844
    
    # Theme generators - each creates unique backgrounds
    theme_generators = {
        'matrix': create_matrix_background,
        'cyberpunk_2077': create_cyberpunk_background,
        'dracula_ide': create_dracula_background,
        'artist_palette': create_artist_palette_background,
        'vegeta_blue': create_vegeta_background,
        'autumn_forest': create_autumn_forest_background,
        'unicorn_dream': create_unicorn_dream_background,
        'demon_slayer_flame': create_demon_slayer_background,
        'hollow_knight_shadow': create_hollow_knight_background,
        'starfield_cosmic': create_starfield_background,
        'executive_platinum': create_executive_background,
    }
    
    total_generated = 0
    
    for theme_name, generator in theme_generators.items():
        print(f"🎨 Creating unique {theme_name} backgrounds...")
        
        try:
            # Generate dark variant
            dark_image = generator(width, height, is_dark=True)
            dark_path = os.path.join(output_dir, f"{theme_name}_dark.png")
            dark_image.save(dark_path)
            print(f"  ✅ Generated {theme_name}_dark.png")
            total_generated += 1
            
            # Generate light variant
            light_image = generator(width, height, is_dark=False)
            light_path = os.path.join(output_dir, f"{theme_name}_light.png")
            light_image.save(light_path)
            print(f"  ✅ Generated {theme_name}_light.png")
            total_generated += 1
            
        except Exception as e:
            print(f"  ❌ Failed to generate {theme_name}: {e}")
    
    print(f"\n🎉 Unique background generation complete!")
    print(f"📊 Generated {total_generated} unique PNG files")
    print(f"💡 Each theme now has its own distinctive background!")
    
    # Generate preview HTML
    generate_unique_preview(output_dir, theme_generators.keys())

def generate_unique_preview(output_dir, theme_names):
    """Generate HTML preview of unique backgrounds"""
    html_content = f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Unique Theme Backgrounds</title>
    <style>
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
        }}
        .container {{
            max-width: 1200px;
            margin: 0 auto;
        }}
        h1 {{
            text-align: center;
            color: #333;
            margin-bottom: 40px;
        }}
        .theme-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
        }}
        .theme-card {{
            background: white;
            border-radius: 12px;
            padding: 16px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }}
        .theme-name {{
            font-weight: 600;
            color: #333;
            margin-bottom: 12px;
            text-transform: capitalize;
            text-align: center;
        }}
        .variants {{
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }}
        .variant {{
            text-align: center;
        }}
        .preview-image {{
            width: 100%;
            height: 150px;
            object-fit: cover;
            border-radius: 8px;
            border: 1px solid #ddd;
            margin-bottom: 8px;
        }}
        .variant-label {{
            font-size: 12px;
            color: #666;
            font-weight: 500;
        }}
        .description {{
            font-size: 11px;
            color: #888;
            margin-top: 4px;
            font-style: italic;
        }}
    </style>
</head>
<body>
    <div class="container">
        <h1>🎨 Unique Theme Backgrounds</h1>
        <p style="text-align: center; color: #666; margin-bottom: 40px;">
            Each theme now has its own distinctive background that captures its unique essence!
        </p>
        <div class="theme-grid">
"""
    
    theme_descriptions = {
        'matrix': 'Falling code rain with Matrix-style characters',
        'cyberpunk_2077': 'Neon grid lines and holographic effects',
        'dracula_ide': 'Floating geometric shapes in signature colors',
        'artist_palette': 'Paint splatters and artistic droplets',
        'vegeta_blue': 'Energy aura emanating from center',
        'autumn_forest': 'Falling leaves in autumn colors',
        'unicorn_dream': 'Rainbow sparkles and magical stars',
        'demon_slayer_flame': 'Rising flames with fire gradient effects',
        'hollow_knight_shadow': 'Wispy void particles and shadow effects',
        'starfield_cosmic': 'Stars and nebula clouds in deep space',
        'executive_platinum': 'Professional geometric patterns in gold and platinum',
    }
    
    for theme_name in theme_names:
        theme_display = theme_name.replace('_', ' ').title()
        description = theme_descriptions.get(theme_name, 'Unique theme-specific design')
        
        html_content += f"""
            <div class="theme-card">
                <div class="theme-name">{theme_display}</div>
                <div class="description">{description}</div>
                <div class="variants">
                    <div class="variant">
                        <img src="{theme_name}_dark.png" alt="{theme_display} Dark" class="preview-image">
                        <div class="variant-label">Dark</div>
                    </div>
                    <div class="variant">
                        <img src="{theme_name}_light.png" alt="{theme_display} Light" class="preview-image">
                        <div class="variant-label">Light</div>
                    </div>
                </div>
            </div>
"""
    
    html_content += f"""
        </div>
        <div style="text-align: center; margin-top: 40px; padding: 20px; background: white; border-radius: 8px;">
            <p><strong>🎉 Unique Backgrounds Generated!</strong></p>
            <p>Each theme now has distinctive backgrounds that reflect their personality</p>
            <p>No more generic gradients - these are theme-specific masterpieces!</p>
        </div>
    </div>
</body>
</html>
"""
    
    with open(os.path.join(output_dir, 'unique_backgrounds_preview.html'), 'w') as f:
        f.write(html_content)

if __name__ == "__main__":
    try:
        # Set random seed for reproducible results
        random.seed(42)
        generate_unique_backgrounds()
    except ImportError:
        print("❌ Error: PIL (Pillow) is required")
        print("Install it with: pip install pillow")
    except Exception as e:
        print(f"❌ Error: {e}")