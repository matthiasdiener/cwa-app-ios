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
	typealias CustomError = URLSession.Response.Failure

	var locator: Locator
	var type: ServiceType
	var sendResource: JSONSendResource<RegistrationTokenSendModel>
	var receiveResource: JSONReceiveResource<TestResultModel>

	func customStatusCodeError(statusCode: Int) -> URLSession.Response.Failure? {
		switch statusCode {
		case 400:
			return .qrDoesNotExist
		default:
			return nil
		}
	}

	// MARK: - Private

	private let regTokenModel: RegistrationTokenSendModel
}
