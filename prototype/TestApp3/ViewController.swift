import UIKit
import AVFoundation
import CoreML
import Vision

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    var normalCaptureSession: AVCaptureSession!
    var wideAngleCaptureSession: AVCaptureSession!
    var normalCameraLayer: AVCaptureVideoPreviewLayer!

    var normalCamera: AVCaptureDevice!
    var wideAngleCamera: AVCaptureDevice!
    var normalPhotoOutput: AVCapturePhotoOutput!
    var wideAnglePhotoOutput: AVCapturePhotoOutput!
    
    // Globale variable to store the best score
    var bestClassification: String?
    
    // Activity indicator
    var captureButton: UIButton!
    var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSessions()
        setupPreviewLayer()
        setupPhotoOutputs()
        setupCaptureButton()

        // Start the normal camera session for preview
        DispatchQueue.global(qos: .userInitiated).async {
            self.normalCaptureSession.startRunning()
        }
    }

    func setupCaptureSessions() {
        normalCaptureSession = AVCaptureSession()
        wideAngleCaptureSession = AVCaptureSession()
        normalCaptureSession.sessionPreset = .photo
        wideAngleCaptureSession.sessionPreset = .photo

        normalCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        wideAngleCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back)

        guard let normalCamera = normalCamera, let wideAngleCamera = wideAngleCamera else {
            fatalError("Unable to access cameras")
        }

        do {
            let normalInput = try AVCaptureDeviceInput(device: normalCamera)
            let wideAngleInput = try AVCaptureDeviceInput(device: wideAngleCamera)

            if normalCaptureSession.canAddInput(normalInput) {
                normalCaptureSession.addInput(normalInput)
            } else {
                print("Cannot add normal camera input to session")
            }

            if wideAngleCaptureSession.canAddInput(wideAngleInput) {
                wideAngleCaptureSession.addInput(wideAngleInput)
            } else {
                print("Cannot add wide-angle camera input to session")
            }
        } catch {
            fatalError("Error configuring camera inputs: \(error)")
        }
    }

    func setupPhotoOutputs() {
        normalPhotoOutput = AVCapturePhotoOutput()
        wideAnglePhotoOutput = AVCapturePhotoOutput()

        if normalCaptureSession.canAddOutput(normalPhotoOutput) {
            normalCaptureSession.addOutput(normalPhotoOutput)
        } else {
            fatalError("Cannot add normal photo output to session")
        }

        if wideAngleCaptureSession.canAddOutput(wideAnglePhotoOutput) {
            wideAngleCaptureSession.addOutput(wideAnglePhotoOutput)
        } else {
            fatalError("Cannot add wide-angle photo output to session")
        }
    }

    func setupPreviewLayer() {
        normalCameraLayer = AVCaptureVideoPreviewLayer(session: normalCaptureSession)
        normalCameraLayer.videoGravity = .resizeAspect

        let fullWidth = view.bounds.width
        let fullHeight = view.bounds.height

        normalCameraLayer.frame = CGRect(x: 0, y: 0, width: fullWidth, height: fullHeight)
        view.layer.addSublayer(normalCameraLayer)
    }

    func setupCaptureButton() {
        let fullWidth = view.bounds.width
        let fullHeight = view.bounds.height
        
        captureButton = UIButton(frame: CGRect(x: (fullWidth - 120) / 2, y: fullHeight - 100, width: 120, height: 50))
        captureButton.setTitle("Capture", for: .normal)
        captureButton.backgroundColor = .systemGreen
        captureButton.addTarget(self, action: #selector(capturePhotos), for: .touchUpInside)
        view.addSubview(captureButton)
        
        // Activity indicator
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = CGPoint(x: captureButton.bounds.midX, y: captureButton.bounds.midY)
        activityIndicator.hidesWhenStopped = true
        
        captureButton.addSubview(activityIndicator)
    }

    @objc func capturePhotos() {
        // Start activity indicator
        activityIndicator.startAnimating()
        captureButton.setTitle("", for: .normal)

        let settings = AVCapturePhotoSettings()

        // Capture photo from normal camera
        normalPhotoOutput.capturePhoto(with: settings, delegate: self)

        // Delay to ensure the normal photo is taken before switching to the wide-angle camera
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1.0) {
            self.captureWideAnglePhoto()
        }
    }

    func captureWideAnglePhoto() {
        let settings = AVCapturePhotoSettings()

        // Stop the normal camera session and start the wide-angle camera session
        DispatchQueue.global(qos: .userInitiated).async {
            self.normalCaptureSession.stopRunning()
            self.wideAngleCaptureSession.startRunning()
        }

        // Capture photo from wide-angle camera
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.wideAnglePhotoOutput.capturePhoto(with: settings, delegate: self)

            // Stop the wide-angle camera session and restart the normal camera session
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1.0) {
                self.wideAngleCaptureSession.stopRunning()
                self.normalCaptureSession.startRunning()
            }
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }

        // Convert the image and check if the conversion was successful
        if let image = UIImage(data: imageData) {
            if output == normalPhotoOutput {
                print("Photo captured with normal camera")
                analyzeImage(image: image)
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            } else if output == wideAnglePhotoOutput {
                print("Photo captured with wide-angle camera")
                detectEdgesAndLines(image: image)
            }
        } else {
            print("Failed to convert image data to UIImage")
        }
    }

    func analyzeImage(image: UIImage?) {
        guard let model = try? VNCoreMLModel(for: OrderClassification().model) else {
            fatalError("Could not load model")
        }

        let request = VNCoreMLRequest(model: model) { (request, error) in
            if let results = request.results as? [VNClassificationObservation],
               let bestResult = results.first {
                let className = bestResult.identifier
                let confidence = bestResult.confidence * 100
                self.bestClassification = String(format: "Class: %@, Confidence: %.2f%%", className, confidence)
            }
        }

        guard let ciImage = CIImage(image: image!) else {
            fatalError("Could not convert UIImage to CIImage")
        }

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform classification: \(error.localizedDescription)")
            }
        }
    }

    func detectEdgesAndLines(image: UIImage?) {
        guard let image = image else { return }

        // Use the OpenCVWrapper method to detect lines and edges
        let openCVWrapper = OpenCVWrapper()
        if let result = openCVWrapper.detectEdgesAndLines(image) as? [String: Any],
           let processedImage = result["image"] as? UIImage,
           let linesDetected = result["linesDetected"] as? Bool {

            if linesDetected {
                print("Lines detected")
                saveImageToPhotos(image: processedImage)
                showLinesDetectedAlert()
            } else {
                print("No lines detected")
                showClassificationAlert()
            }
            
            // Stop activity indicator when both photos are taken
            activityIndicator.stopAnimating()
            captureButton.setTitle("Capture", for: .normal)
        }
    }

    func saveImageToPhotos(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
    }

    func showLinesDetectedAlert() {
        let alert = UIAlertController(title: "Lines Detected", message: "Lines were detected in the image, indicating a potential attempt to capture a display or printed material. Please take a new photo in a natural environment.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func showClassificationAlert() {
        let alert = UIAlertController(title: "Result", message: bestClassification ?? "No classification result available.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
