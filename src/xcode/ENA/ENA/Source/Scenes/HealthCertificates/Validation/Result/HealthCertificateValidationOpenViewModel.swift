//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import class CertLogic.ValidationResult

struct HealthCertificateValidationOpenViewModel: HealthCertificateValidationResultViewModel {

	// MARK: - Init

	init(
		arrivalCountry: Country,
		arrivalDate: Date,
		validationResults: [ValidationResult],
		healthCertificate: HealthCertificate,
		vaccinationValueSetsProvider: VaccinationValueSetsProviding
	) {
		self.arrivalCountry = arrivalCountry
		self.arrivalDate = arrivalDate
		self.validationResults = validationResults
		self.healthCertificate = healthCertificate
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider
	}

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		var cells: [DynamicCell] = [
			.headlineWithImage(
				headerText: AppStrings.HealthCertificate.Validation.Result.Open.title,
				image: UIImage(imageLiteralResourceName: "Illu_Validation_Unknown")
			),
			.footnote(
				text: String(
					format: AppStrings.HealthCertificate.Validation.Result.validationParameters,
					arrivalCountry.localizedName,
					DateFormatter.localizedString(from: arrivalDate, dateStyle: .short, timeStyle: .short),
					DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
				),
				color: .enaColor(for: .textPrimary2)
			),
			.title2(text: AppStrings.HealthCertificate.Validation.Result.Open.subtitle),
			.space(height: 10),
			.headline(text: AppStrings.HealthCertificate.Validation.Result.Open.openSectionTitle),
			.body(text: AppStrings.HealthCertificate.Validation.Result.Open.openSectionDescription)
		]

		cells.append(contentsOf: openValidationResults.map { .validationResult($0, healthCertificate: healthCertificate, vaccinationValueSetsProvider: vaccinationValueSetsProvider) })
		cells.append(
			.dynamicType(
				text: """
					<p>\(AppStrings.HealthCertificate.Validation.Result.moreInformation01) <a href="\(AppStrings.Links.healthCertificateValidationFAQ)">\(AppStrings.HealthCertificate.Validation.Result.moreInformation02)</a> \(AppStrings.HealthCertificate.Validation.Result.moreInformation03) <a href="\(AppStrings.Links.healthCertificateValidationEU)">\(AppStrings.Links.healthCertificateValidationEU)</a>.</p>
					""",
				cellStyle: .htmlString
			)
		)

		return DynamicTableViewModel([
			.section(
				cells: cells
			)
		])
	}

	// MARK: - Private

	private let arrivalCountry: Country
	private let arrivalDate: Date
	private let validationResults: [ValidationResult]
	private let healthCertificate: HealthCertificate
	private let vaccinationValueSetsProvider: VaccinationValueSetsProviding

	private var openValidationResults: [ValidationResult] {
		openAcceptanceRuleValidationResults + openInvalidationRuleValidationResults
	}

	private var openAcceptanceRuleValidationResults: [ValidationResult] {
		validationResults
			.filter { $0.rule?.ruleType == .acceptence && $0.result == .open }
			.sorted { $0.rule?.identifier ?? "" < $1.rule?.identifier ?? "" }
	}

	private var openInvalidationRuleValidationResults: [ValidationResult] {
		validationResults
			.filter { $0.rule?.ruleType == .invalidation && $0.result == .open }
			.sorted { $0.rule?.identifier ?? "" < $1.rule?.identifier ?? "" }
	}

}