import numpy as np
from PIL import Image, ImageDraw
import random
import math

# Create a new image with transparent background
width, height = 1024, 768
image = Image.new('RGBA', (width, height), (0, 0, 0, 0))
draw = ImageDraw.Draw(image)

# Function to create a crack pattern
def draw_crack(x, y, length, angle, width, branches=3, depth=0, max_depth=3):
    if depth > max_depth:
        return
    
    # Calculate end point
    end_x = x + length * math.cos(angle)
    end_y = y + length * math.sin(angle)
    
    # Draw the main crack line
    draw.line([(x, y), (end_x, end_y)], fill=(255, 255, 255, 200), width=width)
    
    # Create branches
    if depth < max_depth:
        for _ in range(branches):
            # Randomize branch angle, length, and width
            branch_angle = angle + random.uniform(-math.pi/4, math.pi/4)
            branch_length = length * random.uniform(0.5, 0.8)
            branch_width = max(1, width - 1)
            
            # Recursively draw branches
            draw_crack(end_x, end_y, branch_length, branch_angle, branch_width, 
                      branches=max(1, branches-1), depth=depth+1, max_depth=max_depth)

# Create several cracks starting from random points
for _ in range(3):
    # Start from edges for more realistic cracks
    edge = random.choice(['top', 'bottom', 'left', 'right'])
    if edge == 'top':
        start_x = random.randint(0, width)
        start_y = 0
        angle = random.uniform(math.pi/4, 3*math.pi/4)
    elif edge == 'bottom':
        start_x = random.randint(0, width)
        start_y = height
        angle = random.uniform(-3*math.pi/4, -math.pi/4)
    elif edge == 'left':
        start_x = 0
        start_y = random.randint(0, height)
        angle = random.uniform(-math.pi/4, math.pi/4)
    else:  # right
        start_x = width
        start_y = random.randint(0, height)
        angle = random.uniform(3*math.pi/4, 5*math.pi/4)
    
    # Draw the main crack
    draw_crack(start_x, start_y, random.randint(100, 300), angle, 3, branches=3, max_depth=3)

# Save the image
image.save('/home/ubuntu/too-fishy/textures/effects/screen_crack.png')
