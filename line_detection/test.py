import cv2
import numpy as np
import os

def process_image(image_path):
    # Load the image
    image = cv2.imread(image_path)
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    # Apply Gaussian Blur for noise reduction
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)

    # Use Canny Edge Detector for edge detection with optimized thresholds
    edges = cv2.Canny(blurred, 218, 216)

    # Hough Line Transformation for line detection with optimized parameters
    lines = cv2.HoughLinesP(edges, 1, np.pi / 180, threshold=92, minLineLength=357, maxLineGap=9)

    # Return 1 if lines are detected, otherwise 0
    return 1 if lines is not None else 0

def process_directory(directory_path):
    total_images = 0
    images_with_lines = []
    images_without_lines = []

    for filename in os.listdir(directory_path):
        if filename.lower().endswith(('.png', '.jpg', '.jpeg')):
            total_images += 1
            if process_image(os.path.join(directory_path, filename)):
                images_with_lines.append(filename)
            else:
                images_without_lines.append(filename)

    print(f"Total images processed in '{directory_path}': {total_images}")
    print(f"Images with detected lines: {len(images_with_lines)}")
    print("Files with detected lines:")
    for file in images_with_lines:
        print(file)

    print(f"\nImages without detected lines: {len(images_without_lines)}")
    print("Files without detected lines:")
    for file in images_without_lines:
        print(file)

if __name__ == "__main__":
    # Define the directories to test
    directories_to_test = ['./test_nature', './test_recapture']

    # Process each directory
    for directory in directories_to_test:
        print(f"\nProcessing directory: {directory}")
        process_directory(directory)