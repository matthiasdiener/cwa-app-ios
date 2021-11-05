////
// 🦠 Corona-Warn-App
//

import Foundation

final class CoronaTestResultOperation: AsyncOperation {
	
	// MARK: - Init
	
	init(restService: RestServiceProviding, registrationToken: String, completion: @escaping Client.TestResultHandler) {
		self.restService = restService
		self.registrationToken = registrationToken
		self.completion = completion
		super.init()
	}
	
	// MARK: - Overrides
	
	override func main() {
//		client.getTestResult(forDevice: registrationToken, isFake: false) { [weak self] result in
//			self?.completion(result)
//			self?.finish()
//		}
		
//
//		let resource = TeleTanResource(
//			sendModel: KeyModel(
//				key: key,
//				keyType: type,
//				keyDob: dateOfBirthKey
//			)
//		)
//
//		restServiceProvider.load(resource) { result in
//			switch result {
//			case .success(let model):
//				completion(.success(model.registrationToken))
//			case .failure(let error):
//				completion(.failure(.serviceError(error)))
//			}
//		}
		let sendModel = RegistrationTokenSendModel(registrationToken: registrationToken)
		let resource = TestResultResource(isFake: false, sendModel: sendModel)
		
		restService.load(resource) { [weak self] result in
			switch result {
			case .success(let model):
				self?.completion(.success(model))
			case .failure(let error):
				print(error)
				//self?.completion(.failure(.serviceError(error)))
			}
			self?.finish()
		}


	}
	
	// MARK: - Private
	
	private let restService: RestServiceProviding
	private let registrationToken: String
	private let completion: Client.TestResultHandler
}
