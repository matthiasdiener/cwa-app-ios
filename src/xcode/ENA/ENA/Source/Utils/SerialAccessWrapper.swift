//
// 🦠 Corona-Warn-App
//

import Foundation

@propertyWrapper
struct SerialAccess<Value> {
	private let queue = DispatchQueue(label: "com.sap.serialaccess")
	private var value: Value

	init(wrappedValue: Value) {
		self.value = wrappedValue
	}
	
	var wrappedValue: Value {
		get {
			return queue.sync { value }
		}
		set {
			queue.sync { value = newValue }
		}
	}
}
