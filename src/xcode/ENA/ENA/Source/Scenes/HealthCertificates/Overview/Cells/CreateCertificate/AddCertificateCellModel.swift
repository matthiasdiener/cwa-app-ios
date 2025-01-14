////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class AddCertificateCellModel: AddButtonAsTableViewCelling {
	
	// MARK: - Internal

	let text: String = AppStrings.HealthCertificate.Overview.addCertificate

	var iconImagePublisher = CurrentValueSubject<UIImage?, Never>(UIImage(named: "Icons_qrScan"))
	var textColorPublisher = CurrentValueSubject<UIColor, Never>(.enaColor(for: .textPrimary1))
	var accessibilityTraitsPublisher = CurrentValueSubject<UIAccessibilityTraits, Never>([.button])

	func setEnabled(_ enabled: Bool) {
		iconImagePublisher.value = enabled ? UIImage(named: "Icons_qrScan") : UIImage(named: "Icons_qrScan_Grey")
		textColorPublisher.value = enabled ? .enaColor(for: .textPrimary1) : .enaColor(for: .textPrimary2)
		accessibilityTraitsPublisher.value = enabled ? [.button] : [.button, .notEnabled]
	}

}
