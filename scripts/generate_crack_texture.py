from PIL import Image, ImageDraw
import random
import os

# Create a transparent image
width, height = 1024, 768
img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Function to draw a crack line
def draw_crack(x, y, length, angle, width, branches=3, depth=0, max_depth=3):
    if depth > max_depth:
        return
    
    # Calculate end point
    end_x = x + length * random.uniform(0.8, 1.2) * random.choice([-1, 1])
    end_y = y + length * random.uniform(0.8, 1.2)
    
    # Draw the main crack line
    draw.line([(x, y), (end_x, end_y)], fill=(255, 255, 255, 200), width=width)
    
    # Create branches
    if depth < max_depth:
        for _ in range(random.randint(1, branches)):
            branch_length = length * random.uniform(0.5, 0.8)
            branch_angle = angle + random.uniform(-45, 45)
            branch_x = x + (end_x - x) * random.uniform(0.3, 0.7)
            branch_y = y + (end_y - y) * random.uniform(0.3, 0.7)
            draw_crack(branch_x, branch_y, branch_length, branch_angle, 
                      max(1, width-1), branches-1, depth+1, max_depth)

# Draw multiple cracks starting from different points
for _ in range(3):
    start_x = random.randint(width//3, 2*width//3)
    start_y = random.randint(height//3, 2*height//3)
    draw_crack(start_x, start_y, 100, 0, 3, branches=3, depth=0, max_depth=3)

# Save the image
os.makedirs('textures/effects', exist_ok=True)
img.save('textures/effects/screen_crack.png')

print("Screen crack texture generated successfully!")
