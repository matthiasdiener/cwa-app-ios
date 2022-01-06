//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class FileScannerErrorTests: XCTestCase {

	// check count of errors we know so far - if extended we need to add a test as well
	func testFileScannerError_Count_THEN_isSix() {
		let count = FileScannerError.allCases.count

		// THEN
		XCTAssertEqual(count, 7)
	}

	func testGIVEN_FileScannerError_noQRCodeFound_THEN_TextsAreCorrect() {
		// GIVEN
		let error: FileScannerError = .noQRCodeFound

		// THEN
		XCTAssertEqual(error.title, AppStrings.FileScanner.NoQRCodeFound.title)
		XCTAssertEqual(error.message, AppStrings.FileScanner.NoQRCodeFound.message)
	}

	func testGIVEN_FileScannerError_fileNotReadable_THEN_TextsAreCorrect() {
		// GIVEN
		let error: FileScannerError = .fileNotReadable

		// THEN
		XCTAssertEqual(error.title, AppStrings.FileScanner.FileNotReadable.title)
		XCTAssertEqual(error.message, AppStrings.FileScanner.FileNotReadable.message)
	}

	func testGIVEN_FileScannerError_invalidQRCode_THEN_TextsAreCorrect() {
		// GIVEN
		let error: FileScannerError = .invalidQRCode

		// THEN
		XCTAssertEqual(error.title, AppStrings.FileScanner.InvalidQRCodeError.title)
		XCTAssertEqual(error.message, AppStrings.FileScanner.InvalidQRCodeError.message)
	}

	func testGIVEN_FileScannerError_photoAccess_THEN_TextsAreCorrect() {
		// GIVEN
		let error: FileScannerError = .photoAccess

		// THEN
		XCTAssertEqual(error.title, AppStrings.FileScanner.AccessError.title)
		XCTAssertEqual(error.message, AppStrings.FileScanner.AccessError.message)
	}

	func testGIVEN_FileScannerError_passwordInput_THEN_TextsAreCorrect() {
		// GIVEN
		let error: FileScannerError = .passwordInput

		// THEN
		XCTAssertEqual(error.title, AppStrings.FileScanner.PasswordEntry.title)
		XCTAssertEqual(error.message, AppStrings.FileScanner.PasswordEntry.message)
	}

	func testGIVEN_FileScannerError_unlockPDF_THEN_TextsAreCorrect() {
		// GIVEN
		let error: FileScannerError = .unlockPDF

		// THEN
		XCTAssertEqual(error.title, AppStrings.FileScanner.PasswordError.title)
		XCTAssertEqual(error.message, AppStrings.FileScanner.PasswordError.message)
	}

}
