//
// 🦠 Corona-Warn-App
//

import Foundation

struct TestResultResource: Resource {

	// MARK: - Init

	init(
		isFake: Bool = false,
		sendModel: RegistrationTokenSendModel
	) {
		self.locator = .testResult(isFake: isFake)
		self.type = .default
		self.sendResource = JSONSendResource<RegistrationTokenSendModel>(sendModel)
		self.receiveResource = JSONReceiveResource<TestResultModel>()
		self.regTokenModel = sendModel
	}

	// MARK: - Protocol Resource

	typealias Send = JSONSendResource<RegistrationTokenSendModel>
	typealias Receive = JSONReceiveResource<TestResultModel>
	typealias CustomError = TestResultError

	var locator: Locator
	var type: ServiceType
	var sendResource: JSONSendResource<RegistrationTokenSendModel>
	var receiveResource: JSONReceiveResource<TestResultModel>

//	func customStatusCodeError(statusCode: Int) -> TestResultError? {
//		switch (keyModel.keyType, statusCode) {
//		case (.teleTan, 400):
//			return .teleTanAlreadyUsed
//		case (_, 400):
//			return .qrAlreadyUsed
//		default:
//			return nil
//		}
//	}

	// MARK: - Private

	private let regTokenModel: RegistrationTokenSendModel

}

enum TestResultError: Error {
	case teleTanAlreadyUsed
	case qrAlreadyUsed

	var errorDescription: String? {
		switch self {
		case .qrAlreadyUsed:
			return AppStrings.ExposureSubmissionError.qrAlreadyUsed
		case .teleTanAlreadyUsed:
			return AppStrings.ExposureSubmissionError.teleTanAlreadyUsed
		}
	}
}
