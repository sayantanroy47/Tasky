#!/usr/bin/env python3
"""
Simple script to create a basic PNG icon
"""
import struct

def create_simple_png():
    # Create a minimal 1x1 pixel PNG
    # PNG signature
    png_signature = b'\x89PNG\r\n\x1a\n'
    
    # IHDR chunk
    width = 1
    height = 1
    bit_depth = 8
    color_type = 2  # RGB
    compression = 0
    filter_method = 0
    interlace = 0
    
    ihdr_data = struct.pack('>IIBBBBB', width, height, bit_depth, color_type, compression, filter_method, interlace)
    ihdr_crc = 0x37  # Pre-calculated CRC for this specific IHDR
    ihdr_chunk = struct.pack('>I', len(ihdr_data)) + b'IHDR' + ihdr_data + struct.pack('>I', ihdr_crc)
    
    # IDAT chunk (image data)
    # For a 1x1 RGB pixel, we need 3 bytes (RGB) + 1 filter byte
    pixel_data = b'\x00\x80\x80\x80'  # Filter byte + gray pixel
    
    # Compress the data (simplified - just add zlib header and checksum)
    import zlib
    compressed_data = zlib.compress(pixel_data)
    
    idat_chunk = struct.pack('>I', len(compressed_data)) + b'IDAT' + compressed_data
    idat_crc = zlib.crc32(b'IDAT' + compressed_data) & 0xffffffff
    idat_chunk += struct.pack('>I', idat_crc)
    
    # IEND chunk
    iend_chunk = struct.pack('>I', 0) + b'IEND' + struct.pack('>I', 0xAE426082)
    
    return png_signature + ihdr_chunk + idat_chunk + iend_chunk

if __name__ == '__main__':
    png_data = create_simple_png()
    with open('assets/images/app_icon.png', 'wb') as f:
        f.write(png_data)
    print("Created simple PNG icon")