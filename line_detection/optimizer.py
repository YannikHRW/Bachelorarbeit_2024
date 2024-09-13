import cv2
import numpy as np
import os
from skopt import load, dump, Optimizer
from skopt.space import Integer
from concurrent.futures import ThreadPoolExecutor, as_completed
import csv

def save_progress(opt):
    # Save the progress after each iteration
    print(f"Saving progress after iteration {len(opt.Xi)}...")
    dump(opt, optimizer_file)

def process_image(image, canny_threshold1, canny_threshold2, min_line_length, max_line_gap, hough_threshold):
    # Apply Canny Edge Detection
    edges = cv2.Canny(image, canny_threshold1, canny_threshold2)
    # Perform Hough Line Transformation for line detection
    lines = cv2.HoughLinesP(edges, 1, np.pi / 180, threshold=hough_threshold,
                            minLineLength=min_line_length, maxLineGap=max_line_gap)

    # Return 1 if lines are detected, otherwise 0
    return 1 if lines is not None else 0

def load_images(directory_path):
    # Load all images from a given directory
    images = {}
    for filename in os.listdir(directory_path):
        if filename.lower().endswith(('.png', '.jpg', '.jpeg')):
            image_path = os.path.join(directory_path, filename)
            images[filename] = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    return images

# Define the search space for the optimizer
search_space = [
    Integer(50, 500, name='canny_threshold1'),
    Integer(50, 500, name='canny_threshold2'),
    Integer(50, 500, name='min_line_length'),
    Integer(1, 50, name='max_line_gap'),
    Integer(50, 500, name='hough_threshold')
]

csv_file = 'optimizer_results.csv'
if not os.path.exists(csv_file):
    # Create CSV file to store optimization results
    with open(csv_file, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(['canny_threshold1', 'canny_threshold2', 'min_line_length', 'max_line_gap', 'hough_threshold', 'false_positives', 'true_positives', 'precision', 'recall', 'f1_score'])

def objective(params, nature_images, recapture_images):
    # Extract parameter values
    canny_threshold1 = params['canny_threshold1']
    canny_threshold2 = params['canny_threshold2']
    min_line_length = params['min_line_length']
    max_line_gap = params['max_line_gap']
    hough_threshold = params['hough_threshold']

    def process_directory(images):
        # Process all images in a directory
        results = {}
        with ThreadPoolExecutor(max_workers=16) as executor:
            futures = {
                executor.submit(process_image, image, canny_threshold1, canny_threshold2, min_line_length, max_line_gap, hough_threshold): filename
                for filename, image in images.items()
            }
            for future in as_completed(futures):
                filename = futures[future]
                try:
                    detected_lines = future.result()
                    results[filename] = detected_lines
                except Exception as e:
                    print(f"Error processing {filename}: {e}")
        return results

    # Process images from both directories
    nature_results = process_directory(nature_images)
    recapture_results = process_directory(recapture_images)

    # Calculate performance metrics
    false_positives = sum(1 for _, detected_lines in nature_results.items() if detected_lines > 0)
    true_positives = sum(1 for _, detected_lines in recapture_results.items() if detected_lines > 0)
    total_nature = len(nature_results)
    total_recapture = len(recapture_results)

    precision = true_positives / (true_positives + false_positives) if (true_positives + false_positives) > 0 else 0
    recall = true_positives / total_recapture if total_recapture > 0 else 0
    f1_score = 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0

    # Print the current combination of parameters and their results
    print(f"Tested combination: canny_threshold1={canny_threshold1}, canny_threshold2={canny_threshold2}, min_line_length={min_line_length}, max_line_gap={max_line_gap}, hough_threshold={hough_threshold}")
    print(f"False positives: {false_positives}, True positives: {true_positives}, Precision: {precision}, Recall: {recall}, F1-Score: {f1_score}")

    # Save the results to the CSV file
    with open(csv_file, mode='a', newline='') as file:
        writer = csv.writer(file)
        writer.writerow([canny_threshold1, canny_threshold2, min_line_length, max_line_gap, hough_threshold, false_positives, true_positives, precision, recall, f1_score])

    return -f1_score

if __name__ == "__main__":
    nature_directory = './nature_gaus_filter'
    recapture_directory = './recapture_gaus_filter'

    # Load images into memory
    print("Loading images...")
    nature_images = load_images(nature_directory)
    recapture_images = load_images(recapture_directory)
    print("Images loaded.")

    n_calls = 1000  # Number of optimization iterations

    optimizer_file = 'optimizer.pkl'

    # Load previous optimizer state if available
    if os.path.exists(optimizer_file):
        print("Loading previous optimization results...")
        optimizer = load(optimizer_file)
    else:
        optimizer = Optimizer(dimensions=search_space, random_state=42)

    try:
        for _ in range(n_calls):
            # Suggest the next set of parameters
            suggested_params = optimizer.ask()

            # Compute the F1-Score for the suggested parameters
            f1_score = objective(dict(zip([dim.name for dim in search_space], suggested_params)), nature_images, recapture_images)

            # Update the optimizer with the results
            optimizer.tell(suggested_params, f1_score)

            # Save progress after each iteration
            save_progress(optimizer)

    except KeyboardInterrupt:
        print("Optimization interrupted")

    # Display the best parameters and results
    if optimizer.Xi:
        best_index = np.argmin(optimizer.yi)
        best_params = optimizer.Xi[best_index]
        best_f1_score = -optimizer.yi[best_index]

        print(f"Best parameters: {best_params}")
        print(f"Best F1-Score: {best_f1_score}")
    else:
        print("No parameters found.")