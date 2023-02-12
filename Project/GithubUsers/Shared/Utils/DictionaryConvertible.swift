import Foundation

protocol DictionaryConvertible { }

extension DictionaryConvertible {
    func toDictionary() -> [String: CustomStringConvertible] {
        Dictionary(
            uniqueKeysWithValues: Mirror(reflecting: self).children
                .compactMap { child in
                    if let label = child.label,
                        let value = child.value as? CustomStringConvertible {
                        return (label, value)
                    } else {
                        return nil
                    }
                }
        )
    }
}
