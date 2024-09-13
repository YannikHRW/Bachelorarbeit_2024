#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "OpenCVWrapper.h"

// Implementation of the OpenCVWrapper class, which provides methods for image processing
@implementation OpenCVWrapper

// This method performs edge and line detection and returns the result
- (NSDictionary *)detectEdgesAndLines:(UIImage *)image {

    // Convert UIImage (iOS image format) to cv::Mat (OpenCV image format)
    cv::Mat cvImage;
    UIImageToMat(image, cvImage);
    cv::rotate(cvImage, cvImage, cv::ROTATE_90_CLOCKWISE);
    
    // Convert the image to grayscale to facilitate processing
    cv::Mat grayImage;
    cv::cvtColor(cvImage, grayImage, cv::COLOR_BGR2GRAY);

    // Apply Gaussian Blur to reduce noise and improve edge detection
    cv::Mat blurredImage;
    cv::GaussianBlur(grayImage, blurredImage, cv::Size(5, 5), 0);

    // Perform Canny edge detection with specified thresholds
    cv::Mat edges;
    cv::Canny(blurredImage, edges, 218, 216);  // canny_threshold1 = 218, canny_threshold2 = 216

    // Perform the Hough Transform to identify lines in the detected edges with specified parameters
    std::vector<cv::Vec4i> lines;
    cv::HoughLinesP(edges, lines, 1, CV_PI / 180, 92, 357, 9);  // hough_threshold = 92, min_line_length = 357, max_line_gap = 9

    BOOL linesDetected = NO;
    cv::cvtColor(cvImage, cvImage, cv::COLOR_BGRA2BGR);
    
    if (!lines.empty()) {
        for (size_t i = 0; i < lines.size(); i++) {
            cv::Vec4i l = lines[i];
            
            // Draw all detected lines on the image (in red color)
            cv::line(cvImage, cv::Point(l[0], l[1]), cv::Point(l[2], l[3]), cv::Scalar(255, 0, 0), 20, cv::LINE_AA);
            linesDetected = YES;
        }
    }

    // Convert the processed cv::Mat image back to UIImage for further use in iOS
    UIImage *resultImage = MatToUIImage(cvImage);
    
    return @{@"image": resultImage, @"linesDetected": @(linesDetected)};
}

@end
