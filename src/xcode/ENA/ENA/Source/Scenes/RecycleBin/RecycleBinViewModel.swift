//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class RecycleBinViewModel {

	// MARK: - Init

	init(
		store: RecycleBinStoring,
		recycleBin: RecycleBin
	) {
		self.store = store
		self.recycleBin = recycleBin

		store.recycleBinItemsSubject
			.sink { [weak self] in
				self?.recycleBinItems = $0
					.sorted {
						$0.recycledAt > $1.recycledAt
					}
			}.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case description
		case entries
	}

	@OpenCombine.Published private(set) var recycleBinItems: [RecycleBinItem] = []

	var numberOfSections: Int {
		Section.allCases.count
	}

	var isEmpty: Bool {
		numberOfRows(in: Section.entries.rawValue) == 0
	}

	func numberOfRows(in section: Int) -> Int {
		switch Section(rawValue: section) {
		case .description:
			return isEmpty ? 0 : 1
		case .entries:
			return recycleBinItems.count
		case .none:
			fatalError("Invalid section")
		}
	}

	func canEditRow(at indexPath: IndexPath) -> Bool {
		return indexPath.section == Section.entries.rawValue
	}

	func restoreItem(at indexPath: IndexPath) {
		guard indexPath.section == Section.entries.rawValue else {
			fatalError("didTapEntryCell can only be called from the entries section")
		}

		recycleBin.restore(recycleBinItems[indexPath.row])
	}

	func removeEntry(at indexPath: IndexPath) {
		recycleBin.remove(recycleBinItems[indexPath.row])
	}

	func removeAll() {
		recycleBin.removeAll()
	}

	// MARK: - Private

	private let store: RecycleBinStoring
	private let recycleBin: RecycleBin

	private var subscriptions: [AnyCancellable] = []

}