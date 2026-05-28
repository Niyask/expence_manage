import SwiftUI

extension ExpenseStore {
    func withSettings(_ transform: (inout AppSettings) -> Void) {
        var updated = settings
        transform(&updated)
        settings = updated
    }

    func settingBinding<T>(_ keyPath: WritableKeyPath<AppSettings, T>) -> Binding<T> where T: Equatable {
        Binding(
            get: { self.settings[keyPath: keyPath] },
            set: { newValue in
                var updated = self.settings
                updated[keyPath: keyPath] = newValue
                self.settings = updated
            }
        )
    }
}
