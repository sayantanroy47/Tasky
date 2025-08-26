#!/usr/bin/env python3
"""
Generate EPIC theme-specific backgrounds that actually look amazing
Run with: python scripts/generate_epic_backgrounds.py
"""

import os
from PIL import Image, ImageDraw, ImageFont
import math
import random

def create_matrix_background(width, height, is_dark=True):
    """Create PROPER Matrix background with actual characters and numbers"""
    if is_dark:
        bg_color = (0, 0, 0)  # Pure black
        text_colors = [(0, 255, 0), (0, 200, 0), (0, 150, 0), (0, 100, 0)]  # Bright to dim green
    else:
        bg_color = (250, 250, 250)  # Almost white
        text_colors = [(0, 100, 0), (0, 80, 0), (0, 60, 0), (0, 40, 0)]  # Dark greens
    
    image = Image.new('RGB', (width, height), bg_color)
    draw = ImageDraw.Draw(image)
    
    # Matrix characters - mix of numbers, letters, and Japanese
    matrix_chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZアイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン"
    
    # Create multiple columns of falling text
    col_width = 18
    for col in range(0, width, col_width):
        # Each column has different speed and length
        col_length = random.randint(height // 3, height)
        start_y = random.randint(-height // 2, 0)
        
        # Create the falling effect
        for i, y in enumerate(range(start_y, start_y + col_length, 20)):
            if 0 <= y < height:
                char = random.choice(matrix_chars)
                
                # Color intensity based on position (brighter at bottom)
                intensity_factor = min(1.0, (i + 1) / (col_length // 20))
                color_index = min(3, int(intensity_factor * 4))
                color = text_colors[color_index]
                
                # Draw character (approximate with filled rectangle for now)
                char_size = 14
                draw.rectangle([col + 2, y, col + char_size, y + 16], fill=color)
                
                # Add some random pixels around for digital effect
                if random.random() < 0.3:
                    for _ in range(3):
                        px = col + random.randint(-2, char_size + 2)
                        py = y + random.randint(-2, 18)
                        if 0 <= px < width and 0 <= py < height:
                            draw.point((px, py), fill=color)
    
    return image

def create_cyberpunk_background(width, height, is_dark=True):
    """Create INTENSE Cyberpunk 2077 background with proper neon effects"""
    if is_dark:
        bg_color = (5, 5, 10)  # Almost black with blue tint
        neon_colors = [(255, 255, 0), (255, 0, 255), (0, 255, 255)]  # Bright neons
        grid_alpha = 80
    else:
        bg_color = (240, 240, 245)  # Light with slight blue
        neon_colors = [(200, 200, 0), (200, 0, 200), (0, 200, 200)]  # Darker neons
        grid_alpha = 40
    
    image = Image.new('RGB', (width, height), bg_color)
    draw = ImageDraw.Draw(image)
    
    # Create neon grid with glow effect
    grid_size = 30
    
    # Vertical lines
    for x in range(0, width, grid_size):
        if random.random() < 0.4:  # Not every line
            color = random.choice(neon_colors)
            
            # Draw glow effect (multiple lines with decreasing opacity)
            for glow in range(5, 0, -1):
                glow_color = tuple(int(c * (grid_alpha * glow / 5) / 255) for c in color)
                final_color = tuple(bg_color[i] + glow_color[i] for i in range(3))
                final_color = tuple(min(255, c) for c in final_color)
                
                for offset in range(-glow, glow + 1):
                    if 0 <= x + offset < width:
                        draw.line([(x + offset, 0), (x + offset, height)], fill=final_color)
    
    # Horizontal accent lines
    for y in range(0, height, grid_size * 2):
        if random.random() < 0.3:
            color = random.choice(neon_colors)
            
            # Glow effect for horizontal lines
            for glow in range(3, 0, -1):
                glow_color = tuple(int(c * (grid_alpha * glow / 3) / 255) for c in color)
                final_color = tuple(bg_color[i] + glow_color[i] for i in range(3))
                final_color = tuple(min(255, c) for c in final_color)
                
                for offset in range(-glow, glow + 1):
                    if 0 <= y + offset < height:
                        draw.line([(0, y + offset), (width, y + offset)], fill=final_color)
    
    # Add some neon rectangles for extra cyberpunk feel
    for _ in range(8):
        x = random.randint(0, width - 60)
        y = random.randint(0, height - 40)
        w = random.randint(20, 60)
        h = random.randint(10, 40)
        color = random.choice(neon_colors)
        
        # Draw glowing rectangle outline
        glow_color = tuple(int(c * 0.3) for c in color)
        final_color = tuple(bg_color[i] + glow_color[i] for i in range(3))
        final_color = tuple(min(255, c) for c in final_color)
        
        draw.rectangle([x, y, x + w, y + h], outline=final_color, width=2)
    
    return image

def create_dracula_background(width, height, is_dark=True):
    """Create sophisticated Dracula IDE background"""
    if is_dark:
        bg_color = (40, 42, 54)  # True Dracula background
        accent_colors = [(255, 121, 198), (189, 147, 249), (139, 233, 253), (80, 250, 123)]
    else:
        bg_color = (248, 248, 242)  # Dracula light
        accent_colors = [(255, 121, 198), (189, 147, 249), (139, 233, 253), (80, 250, 123)]
    
    image = Image.new('RGB', (width, height), bg_color)
    draw = ImageDraw.Draw(image)
    
    # Create floating code-like elements
    for _ in range(20):
        x = random.randint(0, width)
        y = random.randint(0, height)
        size = random.randint(30, 80)
        color = random.choice(accent_colors)
        
        # Create semi-transparent overlay
        alpha = 0.15 if is_dark else 0.08
        final_color = tuple(int(bg_color[i] * (1 - alpha) + color[i] * alpha) for i in range(3))
        
        # Draw different shapes
        shape = random.choice(['circle', 'rect', 'diamond', 'hexagon'])
        
        if shape == 'circle':
            draw.ellipse([x - size//2, y - size//2, x + size//2, y + size//2], fill=final_color)
        elif shape == 'rect':
            draw.rectangle([x - size//2, y - size//2, x + size//2, y + size//2], fill=final_color)
        elif shape == 'diamond':
            points = [(x, y - size//2), (x + size//2, y), (x, y + size//2), (x - size//2, y)]
            draw.polygon(points, fill=final_color)
        else:  # hexagon
            points = []
            for i in range(6):
                angle = i * math.pi / 3
                px = x + (size//2) * math.cos(angle)
                py = y + (size//2) * math.sin(angle)
                points.append((px, py))
            draw.polygon(points, fill=final_color)
    
    return image

def create_artist_palette_background(width, height, is_dark=True):
    """Create MESSY artist studio with paint everywhere"""
    if is_dark:
        bg_color = (15, 12, 8)  # Very dark studio
        paint_colors = [(220, 50, 20), (20, 120, 220), (250, 180, 20), (180, 20, 180), (20, 200, 50)]
    else:
        bg_color = (255, 253, 250)  # Canvas white
        paint_colors = [(255, 87, 34), (33, 150, 243), (255, 193, 7), (156, 39, 176), (76, 175, 80)]
    
    image = Image.new('RGB', (width, height), bg_color)
    draw = ImageDraw.Draw(image)
    
    # Create paint splatters of various sizes
    for _ in range(35):
        x = random.randint(0, width)
        y = random.randint(0, height)
        color = random.choice(paint_colors)
        
        # Main splatter
        main_size = random.randint(20, 60)
        alpha = random.uniform(0.4, 0.8)
        final_color = tuple(int(bg_color[i] * (1 - alpha) + color[i] * alpha) for i in range(3))
        
        # Irregular splatter shape
        points = []
        for i in range(8):
            angle = i * math.pi / 4
            radius = main_size // 2 + random.randint(-main_size//4, main_size//4)
            px = x + radius * math.cos(angle)
            py = y + radius * math.sin(angle)
            points.append((px, py))
        
        draw.polygon(points, fill=final_color)
        
        # Paint droplets around main splatter
        for _ in range(random.randint(5, 12)):
            dx = random.randint(-main_size, main_size)
            dy = random.randint(-main_size, main_size)
            droplet_size = random.randint(3, 12)
            
            drop_x, drop_y = x + dx, y + dy
            if 0 <= drop_x < width and 0 <= drop_y < height:
                droplet_alpha = random.uniform(0.2, 0.6)
                droplet_color = tuple(int(bg_color[i] * (1 - droplet_alpha) + color[i] * droplet_alpha) for i in range(3))
                draw.ellipse([drop_x - droplet_size//2, drop_y - droplet_size//2, 
                            drop_x + droplet_size//2, drop_y + droplet_size//2], fill=droplet_color)
        
        # Paint streaks
        if random.random() < 0.3:
            streak_length = random.randint(30, 80)
            angle = random.uniform(0, 2 * math.pi)
            end_x = x + streak_length * math.cos(angle)
            end_y = y + streak_length * math.sin(angle)
            
            streak_alpha = random.uniform(0.2, 0.5)
            streak_color = tuple(int(bg_color[i] * (1 - streak_alpha) + color[i] * streak_alpha) for i in range(3))
            draw.line([(x, y), (end_x, end_y)], fill=streak_color, width=random.randint(2, 6))
    
    return image

def create_vegeta_background(width, height, is_dark=True):
    """Create POWERFUL Vegeta energy aura"""
    if is_dark:
        bg_color = (2, 2, 5)  # Almost pure black space
        aura_colors = [(30, 58, 138), (59, 130, 246), (147, 197, 253), (255, 255, 255)]
    else:
        bg_color = (248, 250, 252)  # Light cosmic
        aura_colors = [(30, 58, 138), (59, 130, 246), (147, 197, 253), (200, 200, 200)]
    
    image = Image.new('RGB', (width, height), bg_color)
    draw = ImageDraw.Draw(image)
    
    center_x, center_y = width // 2, height // 2
    
    # Create intense energy rings
    for radius in range(20, min(width, height) // 2, 25):
        color = aura_colors[min(3, radius // 60)]
        
        # Energy intensity decreases with distance
        intensity = max(0.1, 0.8 - (radius / 200))
        
        # Create energy particles around the ring
        num_particles = int(radius * 0.3)
        for i in range(num_particles):
            angle = (i / num_particles) * 2 * math.pi
            
            # Add some randomness to make it look like energy
            r = radius + random.randint(-15, 15)
            particle_angle = angle + random.uniform(-0.2, 0.2)
            
            x = center_x + int(r * math.cos(particle_angle))
            y = center_y + int(r * math.sin(particle_angle))
            
            if 0 <= x < width and 0 <= y < height:
                particle_alpha = intensity * random.uniform(0.3, 1.0)
                final_color = tuple(int(bg_color[i] * (1 - particle_alpha) + color[i] * particle_alpha) for i in range(3))
                
                particle_size = random.randint(2, 8)
                draw.ellipse([x - particle_size//2, y - particle_size//2, 
                            x + particle_size//2, y + particle_size//2], fill=final_color)
    
    # Add energy bolts
    for _ in range(12):
        start_angle = random.uniform(0, 2 * math.pi)
        bolt_length = random.randint(80, 150)
        
        points = [(center_x, center_y)]
        current_x, current_y = center_x, center_y
        
        for segment in range(bolt_length // 10):
            angle = start_angle + random.uniform(-0.3, 0.3)
            segment_length = random.randint(8, 15)
            
            current_x += segment_length * math.cos(angle)
            current_y += segment_length * math.sin(angle)
            points.append((current_x, current_y))
        
        # Draw the bolt
        for i in range(len(points) - 1):
            alpha = max(0.1, 0.6 - i * 0.05)
            color = aura_colors[1]  # Blue
            final_color = tuple(int(bg_color[j] * (1 - alpha) + color[j] * alpha) for j in range(3))
            draw.line([points[i], points[i + 1]], fill=final_color, width=2)
    
    return image

def create_demon_slayer_background(width, height, is_dark=True):
    """Create INTENSE flame background"""
    if is_dark:
        bg_color = (10, 5, 0)  # Very dark ember
        flame_colors = [(139, 0, 0), (255, 69, 0), (255, 140, 0), (255, 215, 0), (255, 255, 100)]
    else:
        bg_color = (255, 248, 240)  # Light flame
        flame_colors = [(139, 0, 0), (255, 69, 0), (255, 140, 0), (255, 215, 0), (255, 255, 200)]
    
    image = Image.new('RGB', (width, height), bg_color)
    draw = ImageDraw.Draw(image)
    
    # Create multiple flame columns
    for x in range(0, width, 25):
        flame_height = random.randint(height // 2, height)
        base_y = height
        
        # Create flame with multiple layers
        for layer in range(3):
            layer_offset = layer * 8
            
            for y in range(base_y, base_y - flame_height, -15):
                if y < 0:
                    break
                
                # Flame gets narrower and changes color as it goes up
                progress = (base_y - y) / flame_height
                flame_width = max(3, int(25 * (1 - progress * 0.7)))
                
                # Color changes from red to yellow as flame goes up
                color_index = min(4, int(progress * 5))
                color = flame_colors[color_index]
                
                # Add randomness and wind effect
                wind_offset = int(progress * 20 * math.sin(y * 0.02))
                random_offset = random.randint(-flame_width//3, flame_width//3)
                
                flame_x = x + wind_offset + random_offset + layer_offset
                
                if 0 <= flame_x < width:
                    alpha = random.uniform(0.3, 0.8) * (1 - layer * 0.2)
                    final_color = tuple(int(bg_color[i] * (1 - alpha) + color[i] * alpha) for i in range(3))
                    
                    # Draw flame segment
                    draw.ellipse([flame_x - flame_width//2, y - 8, 
                                flame_x + flame_width//2, y + 8], fill=final_color)
    
    # Add ember particles
    for _ in range(30):
        x = random.randint(0, width)
        y = random.randint(0, height)
        size = random.randint(1, 4)
        
        color = random.choice(flame_colors[2:])  # Orange to yellow
        alpha = random.uniform(0.4, 0.9)
        final_color = tuple(int(bg_color[i] * (1 - alpha) + color[i] * alpha) for i in range(3))
        
        draw.ellipse([x - size, y - size, x + size, y + size], fill=final_color)
    
    return image

def create_autumn_forest_background(width, height, is_dark=True):
    """Create BEAUTIFUL autumn forest with falling leaves"""
    if is_dark:
        bg_color = (20, 15, 10)  # Very dark forest
        leaf_colors = [(139, 69, 19), (205, 133, 63), (255, 140, 0), (255, 69, 0), (178, 34, 34)]
        branch_color = (101, 67, 33)
    else:
        bg_color = (255, 251, 245)  # Light forest
        leaf_colors = [(139, 69, 19), (205, 133, 63), (255, 140, 0), (255, 69, 0), (178, 34, 34)]
        branch_color = (101, 67, 33)
    
    image = Image.new('RGB', (width, height), bg_color)
    draw = ImageDraw.Draw(image)
    
    # Draw tree branches first
    for _ in range(8):
        start_x = random.randint(-50, width + 50)
        start_y = random.randint(0, height // 2)
        
        # Create branching pattern
        current_x, current_y = start_x, start_y
        branch_length = random.randint(100, 200)
        
        for segment in range(branch_length // 20):
            angle = random.uniform(-0.5, 0.5) + math.pi / 2  # Generally downward
            segment_length = random.randint(15, 25)
            
            end_x = current_x + segment_length * math.cos(angle)
            end_y = current_y + segment_length * math.sin(angle)
            
            if 0 <= current_x < width and 0 <= current_y < height:
                alpha = 0.3 if is_dark else 0.6
                final_color = tuple(int(bg_color[i] * (1 - alpha) + branch_color[i] * alpha) for i in range(3))
                draw.line([(current_x, current_y), (end_x, end_y)], fill=final_color, width=3)
            
            current_x, current_y = end_x, end_y
    
    # Create falling leaves
    for _ in range(40):
        x = random.randint(0, width)
        y = random.randint(0, height)
        color = random.choice(leaf_colors)
        
        # Leaf shape and size
        leaf_width = random.randint(8, 16)
        leaf_height = random.randint(12, 20)
        rotation = random.uniform(0, 2 * math.pi)
        
        alpha = random.uniform(0.6, 0.9)
        final_color = tuple(int(bg_color[i] * (1 - alpha) + color[i] * alpha) for i in range(3))
        
        # Create leaf shape (approximate with rotated ellipse)
        # For simplicity, using ellipse - could be enhanced with actual leaf shape
        draw.ellipse([x - leaf_width//2, y - leaf_height//2, 
                     x + leaf_width//2, y + leaf_height//2], fill=final_color)
        
        # Add leaf vein (stem)
        stem_end_x = x + random.randint(-3, 3)
        stem_end_y = y + leaf_height//2 + random.randint(3, 8)
        stem_color = tuple(int(c * 0.7) for c in final_color)
        draw.line([(x, y), (stem_end_x, stem_end_y)], fill=stem_color, width=1)
    
    return image

def create_unicorn_dream_background(width, height, is_dark=True):
    """Create MAGICAL unicorn background with rainbow effects"""
    if is_dark:
        bg_color = (15, 10, 25)  # Very dark magical night
        rainbow_colors = [(255, 182, 193), (221, 160, 221), (173, 216, 230), (144, 238, 144), 
                         (255, 255, 224), (255, 218, 185), (255, 192, 203)]
    else:
        bg_color = (255, 250, 255)  # Dream white
        rainbow_colors = [(255, 105, 180), (186, 85, 211), (135, 206, 235), (144, 238, 144),
                         (255, 255, 0), (255, 165, 0), (255, 20, 147)]
    
    image = Image.new('RGB', (width, height), bg_color)
    draw = ImageDraw.Draw(image)
    
    # Create rainbow swirls
    center_x, center_y = width // 2, height // 2
    
    for radius in range(50, 200, 30):
        color = rainbow_colors[radius // 30 % len(rainbow_colors)]
        
        # Create swirl pattern
        for angle in range(0, 360, 10):
            rad = math.radians(angle)
            spiral_factor = radius + 20 * math.sin(angle * 0.1)
            
            x = center_x + spiral_factor * math.cos(rad)
            y = center_y + spiral_factor * math.sin(rad)
            
            if 0 <= x < width and 0 <= y < height:
                alpha = random.uniform(0.2, 0.5)
                final_color = tuple(int(bg_color[i] * (1 - alpha) + color[i] * alpha) for i in range(3))
                
                size = random.randint(3, 8)
                draw.ellipse([x - size//2, y - size//2, x + size//2, y + size//2], fill=final_color)
    
    # Create magical sparkles
    for _ in range(60):
        x = random.randint(0, width)
        y = random.randint(0, height)
        color = random.choice(rainbow_colors)
        
        # Create star sparkle
        size = random.randint(4, 12)
        alpha = random.uniform(0.4, 0.8)
        final_color = tuple(int(bg_color[i] * (1 - alpha) + color[i] * alpha) for i in range(3))
        
        # Draw 4-pointed star
        points = [
            (x, y - size),      # top
            (x + size//3, y - size//3),
            (x + size, y),      # right
            (x + size//3, y + size//3),
            (x, y + size),      # bottom
            (x - size//3, y + size//3),
            (x - size, y),      # left
            (x - size//3, y - size//3)
        ]
        draw.polygon(points, fill=final_color)
        
        # Add cross sparkle lines
        draw.line([(x - size//2, y), (x + size//2, y)], fill=final_color, width=2)
        draw.line([(x, y - size//2), (x, y + size//2)], fill=final_color, width=2)
    
    return image

def create_hollow_knight_background(width, height, is_dark=True):
    """Create MYSTERIOUS void background with shadow effects"""
    if is_dark:
        bg_color = (5, 5, 8)  # Almost pure void
        void_colors = [(64, 64, 96), (96, 96, 128), (128, 128, 160), (160, 160, 192)]
    else:
        bg_color = (240, 240, 245)  # Light void
        void_colors = [(200, 200, 220), (180, 180, 200), (160, 160, 180), (140, 140, 160)]
    
    image = Image.new('RGB', (width, height), bg_color)
    draw = ImageDraw.Draw(image)
    
    # Create void wisps and shadow particles
    for _ in range(30):
        x = random.randint(0, width)
        y = random.randint(0, height)
        color = random.choice(void_colors)
        
        # Create wispy shadow effect with multiple overlapping circles
        base_size = random.randint(30, 80)
        alpha = random.uniform(0.15, 0.4)
        
        # Draw multiple layers for wispy effect
        for layer in range(4):
            layer_size = base_size - layer * 8
            if layer_size <= 0:
                break
                
            offset_x = random.randint(-layer * 3, layer * 3)
            offset_y = random.randint(-layer * 3, layer * 3)
            
            layer_alpha = alpha * (1 - layer * 0.2)
            final_color = tuple(int(bg_color[i] * (1 - layer_alpha) + color[i] * layer_alpha) for i in range(3))
            
            draw.ellipse([x + offset_x - layer_size//2, y + offset_y - layer_size//2,
                         x + offset_x + layer_size//2, y + offset_y + layer_size//2], fill=final_color)
    
    # Add floating void particles
    for _ in range(50):
        x = random.randint(0, width)
        y = random.randint(0, height)
        size = random.randint(1, 3)
        
        color = random.choice(void_colors)
        alpha = random.uniform(0.3, 0.7)
        final_color = tuple(int(bg_color[i] * (1 - alpha) + color[i] * alpha) for i in range(3))
        
        draw.ellipse([x - size, y - size, x + size, y + size], fill=final_color)
    
    return image

def generate_epic_backgrounds():
    """Generate EPIC theme backgrounds that actually look amazing"""
    print("🔥 EPIC Theme Background Generator")
    print("==================================\n")
    
    output_dir = 'assets/backgrounds'
    os.makedirs(output_dir, exist_ok=True)
    
    width, height = 390, 844
    
    # Epic theme generators
    epic_generators = {
        'matrix': create_matrix_background,
        'cyberpunk_2077': create_cyberpunk_background,
        'dracula_ide': create_dracula_background,
        'artist_palette': create_artist_palette_background,
        'vegeta_blue': create_vegeta_background,
        'demon_slayer_flame': create_demon_slayer_background,
        'autumn_forest': create_autumn_forest_background,
        'unicorn_dream': create_unicorn_dream_background,
        'hollow_knight_shadow': create_hollow_knight_background,
    }
    
    total_generated = 0
    
    for theme_name, generator in epic_generators.items():
        print(f"🔥 Creating EPIC {theme_name} backgrounds...")
        
        try:
            # Generate DARK variant (much darker)
            dark_image = generator(width, height, is_dark=True)
            dark_path = os.path.join(output_dir, f"{theme_name}_dark_EPIC.png")
            dark_image.save(dark_path)
            print(f"  ✅ Generated {theme_name}_dark_EPIC.png")
            total_generated += 1
            
            # Generate light variant
            light_image = generator(width, height, is_dark=False)
            light_path = os.path.join(output_dir, f"{theme_name}_light_EPIC.png")
            light_image.save(light_path)
            print(f"  ✅ Generated {theme_name}_light_EPIC.png")
            total_generated += 1
            
        except Exception as e:
            print(f"  ❌ Failed to generate {theme_name}: {e}")
    
    print(f"\n🔥 EPIC background generation complete!")
    print(f"📊 Generated {total_generated} EPIC PNG files")
    print(f"💥 These backgrounds are actually EPIC and theme-specific!")

if __name__ == "__main__":
    try:
        random.seed(42)  # For consistent results
        generate_epic_backgrounds()
    except ImportError:
        print("❌ Error: PIL (Pillow) is required")
        print("Install it with: pip install pillow")
    except Exception as e:
        print(f"❌ Error: {e}")