//
// 🦠 Corona-Warn-App
//

import Foundation
import PhotosUI
import PDFKit
import OpenCombine

enum FileScannerError {
	case noQRCodeFound
	case fileNotReadable
	case invalidQRCode
	case photoAccess
	case passwordInput
	case unlockPDF

	var title: String {
		switch self {
		case .noQRCodeFound:
			return AppStrings.FileScanner.NoQRCodeFound.title
		case .fileNotReadable:
			return AppStrings.FileScanner.FileNotReadable.title
		case .invalidQRCode:
			return AppStrings.FileScanner.InvalidQRCodeError.title
		case .photoAccess:
			return AppStrings.FileScanner.AccessError.title
		case .passwordInput:
			return AppStrings.FileScanner.PasswordEntry.title
		case .unlockPDF:
			return AppStrings.FileScanner.PasswordError.title
		}
	}

	var message: String {
		switch self {
		case .noQRCodeFound:
			return AppStrings.FileScanner.NoQRCodeFound.message
		case .fileNotReadable:
			return AppStrings.FileScanner.FileNotReadable.message
		case .invalidQRCode:
			return AppStrings.FileScanner.InvalidQRCodeError.message
		case .photoAccess:
			return AppStrings.FileScanner.AccessError.message
		case .passwordInput:
			return AppStrings.FileScanner.PasswordEntry.message
		case .unlockPDF:
			return AppStrings.FileScanner.PasswordError.message
		}
	}
}

class FileScannerCoordinatorViewModel: NSObject, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {

	// MARK: - Init

	init(
		qrCodeParser: QRCodeParsable,
		finishedPickingImage: @escaping () -> Void,
		processingStarted: @escaping () -> Void,
		processingFinished: @escaping (QRCodeResult) -> Void,
		processingFailed: @escaping (FileScannerError) -> Void,
		missingPasswordForPDF: @escaping (@escaping (String) -> Void) -> Void
	) {
		self.processingStarted = processingStarted
		self.finishedPickingImage = finishedPickingImage
		self.processingFinished = processingFinished
		self.qrCodeParser = qrCodeParser
		self.missingPasswordForPDF = missingPasswordForPDF
		self.processingFailed = processingFailed
	}

	// MARK: - Protocol PHPickerViewControllerDelegate

	@available(iOS 14, *)
	func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
		finishedPickingImage()

		DispatchQueue.global(qos: .background).async { [weak self] in
			// There can only be one selected image, because the selectionLimit is set to 1.
			guard let result = results.first else {
				self?.processingFailed(.noQRCodeFound)
				return
			}

			let itemProvider = result.itemProvider
			guard itemProvider.canLoadObject(ofClass: UIImage.self) else {
				self?.processingFailed(.noQRCodeFound)
				return
			}
			itemProvider.loadObject(ofClass: UIImage.self) { [weak self]  provider, _ in
				guard let self = self,
					  let image = provider as? UIImage
				else {
					Log.debug("No image found in user selection.", log: .fileScanner)
					self?.processingFailed(.noQRCodeFound)
					return
				}

				self.scanImageFile(image)
			}
		}
	}

	// MARK: - UIImagePickerControllerDelegate

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		finishedPickingImage()

		DispatchQueue.global(qos: .background).async { [weak self] in
			guard let self = self,
				let image = info[.originalImage] as? UIImage
			else {
				Log.debug("No image found in user selection.", log: .fileScanner)
				self?.processingFailed(.noQRCodeFound)
				return
			}

			self.scanImageFile(image)
		}
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		finishedPickingImage()
	}

	// MARK: Protocol UIDocumentPickerDelegate

	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		Log.debug("User picked files for QR-Code scan.", log: .fileScanner)
		// we can handle multiple documents here - nice
		guard let url = urls.first else {
			processingFailed(.noQRCodeFound)
			Log.debug("We need to select a least one file")
			return
		}

		if let image = UIImage(contentsOfFile: url.path) {
			scanImageFile(image)
		} else if url.pathExtension.lowercased() == "pdf",
				  let pdfDocument = PDFDocument(url: url) {
			Log.debug("PDF picked, will scan for QR codes", log: .fileScanner)

			// If the document is encryped and locked, try to unlock it.
			// The case where the document is locked, but not encrypted does not exist.
			if pdfDocument.isEncrypted && pdfDocument.isLocked {
				Log.debug("PDF is encrypted and locked. Try to unlock, show password input screen to the user ...", log: .fileScanner)

				missingPasswordForPDF { [weak self] password in
					guard let self = self else { return }

					if pdfDocument.unlock(withPassword: password) {
						Log.debug("PDF successfully unlocked.", log: .fileScanner)

						self.scanPDFDocument(pdfDocument)
					} else {
						Log.debug("PDF unlocking failed.", log: .fileScanner)
						self.processingFailed(.passwordInput)
					}
				}
			} else {
				scanPDFDocument(pdfDocument)
			}
		} else {
			Log.debug("User picked unknown filetype for QR-Code scan.", log: .fileScanner)
			processingFailed(.fileNotReadable)
		}
	}

	// MARK: - Internal

	var authorizationStatus: PHAuthorizationStatus {
		if #available(iOS 14, *) {
			let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
			// a special case on iOS 14 (and above) that won't impact anything at the moment
			if case .limited = status {
				return .authorized
			} else {
				return status
			}
		} else {
			return PHPhotoLibrary.authorizationStatus()
		}
	}

	func requestPhotoAccess(_ completion: @escaping (PHAuthorizationStatus) -> Void) {
		if #available(iOS 14, *) {
			PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: completion)
		} else {
			PHPhotoLibrary.requestAuthorization(completion)
		}
	}

	// MARK: - Private

	private let finishedPickingImage: () -> Void
	private let processingStarted: () -> Void
	private let processingFinished: (QRCodeResult) -> Void
	private let qrCodeParser: QRCodeParsable
	private let missingPasswordForPDF: (@escaping (String) -> Void) -> Void
	private let processingFailed: (FileScannerError) -> Void

	private func scanPDFDocument(_ pdfDocument: PDFDocument) {
		processingStarted()

		DispatchQueue.global(qos: .background).async { [weak self] in
			guard let self = self else {
				self?.processingFailed(.noQRCodeFound)
				Log.error("Failed to stronge self pointer")
				return
			}

			let codes = self.qrCodes(from: pdfDocument)
			self.findValidQRCode(from: codes) { [weak self] result in
				if let result = result {
					self?.processingFinished(result)
				} else {
					self?.processingFailed(.noQRCodeFound)
				}
			}
		}
	}

	private func scanImageFile(_ image: UIImage) {
		processingStarted()

		DispatchQueue.global(qos: .background).async { [weak self] in
			guard let self = self,
				  let codes = self.findQRCodes(in: image)
			else {
				self?.processingFailed(.noQRCodeFound)
				Log.error("Failed to stronge self pointer")
				return
			}
			guard !codes.isEmpty else {
				self.processingFailed(.noQRCodeFound)
				return
			}

			self.findValidQRCode(from: codes) { [weak self] result in
				if let result = result {
					self?.processingFinished(result)
				} else {
					self?.processingFailed(.noQRCodeFound)
				}
			}
		}
	}

	private func qrCodes(from pdfDocument: PDFDocument) -> [String] {
		Log.debug("PDF picked, will scan for QR codes on all pages", log: .fileScanner)
		var found: [String] = []
		imagePage(from: pdfDocument).forEach { image in
			if let codes = findQRCodes(in: image) {
				found.append(contentsOf: codes)
			}
		}
		if found.isEmpty {
			processingFailed(.noQRCodeFound)
		}
		return found
	}

	private func imagePage(from document: PDFDocument) -> [UIImage] {
		var images = [UIImage]()
		for pageIndex in 0..<document.pageCount {
			guard let page = document.page(at: pageIndex) else {
				Log.debug("can't find page in PDF file", log: .fileScanner)
				continue
			}

			let scale = UIScreen.main.scale
			let size = page.bounds(for: .mediaBox).size
			let scaledSize = size.applying(CGAffineTransform(scaleX: scale, y: scale))
			let thumb = page.thumbnail(of: scaledSize, for: .mediaBox)
			images.append(thumb)
		}
		return images
	}

	private func findQRCodes(in image: UIImage) -> [String]? {
		guard let features = detectQRCode(image) else {
			Log.debug("no features found in image", log: .fileScanner)
			return nil
		}
		let codes = features.compactMap { $0 as? CIQRCodeFeature }
		.compactMap { $0.messageString }

		return codes
	}

	private func detectQRCode(_ image: UIImage) -> [CIFeature]? {
		guard let ciImage = CIImage(image: image) else {
			return nil
		}
		let context = CIContext()
		// we can try to use CIDetectorAccuracyLow to speedup things a bit here
		let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
		let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
		let features = qrDetector?.features(in: ciImage, options: options)
		return features
	}

	private func findValidQRCode(from codes: [String], completion: @escaping (QRCodeResult?) -> Void) {
		Log.debug("Try to find a valid QR-Code from codes.", log: .fileScanner)

		let group = DispatchGroup()
		var validCodes = [QRCodeResult]()

		for code in codes {
			group.enter()

			qrCodeParser.parse(qrCode: code) { parseResult in
				switch parseResult {
				case .failure:
					break
				case .success(let result):
					validCodes.append(result)
				}
				group.leave()
			}
		}

		group.notify(queue: .main) { [weak self] in
			// Return first valid result.
			if let firstValidResult = validCodes.first {
				Log.debug("Found valid QR-Code from codes.", log: .fileScanner)
				completion(firstValidResult)
			} else {
				Log.debug("Didn't find a valid QR-Code from codes.", log: .fileScanner)
				self?.processingFailed(.invalidQRCode)
				completion(nil)
			}
		}
	}
}