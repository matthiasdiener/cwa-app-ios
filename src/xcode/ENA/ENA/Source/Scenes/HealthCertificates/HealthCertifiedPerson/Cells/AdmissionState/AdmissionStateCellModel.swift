////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit.UIFont

final class AdmissionStateCellModel {

	// MARK: - Init

	init(healthCertifiedPerson: HealthCertifiedPerson) {
		self.healthCertifiedPerson = healthCertifiedPerson
	}

	// MARK: - Internal

	let title = AppStrings.HealthCertificate.Person.AdmissionState.title

	var subtitle: String? {
		return healthCertifiedPerson.admissionState.subtitle
	}

	var description: String? {
		return healthCertifiedPerson.admissionState.description
	}

	var faqLink: NSAttributedString? {
		let text = String(
			format: AppStrings.HealthCertificate.Person.AdmissionState.faq,
			AppStrings.HealthCertificate.Person.AdmissionState.faqPlaceHolder
		)

		let textAttributes: [NSAttributedString.Key: Any] = [
			.font: UIFont.preferredFont(forTextStyle: ENAFont.body.textStyle)
				.scaledFont(
					size: ENAFont.body.fontSize,
					weight: ENAFont.body.fontWeight
				),
			.foregroundColor: UIColor.enaColor(for: .textPrimary1)
		]
		let attributedString = NSMutableAttributedString(
			string: text,
			attributes: textAttributes
		)

		attributedString.mark(
			AppStrings.HealthCertificate.Person.AdmissionState.faqPlaceHolder,
			with: AppStrings.Links.healthCertificateAdmissionPolicyFAQ
		)

		return attributedString
	}
	
	var shortTitle: String? {
		return healthCertifiedPerson.admissionState.shortTitle
	}

	var gradientType: GradientView.GradientType {
		return healthCertifiedPerson.gradientType
	}

	// MARK: - Private

	private let healthCertifiedPerson: HealthCertifiedPerson

}
