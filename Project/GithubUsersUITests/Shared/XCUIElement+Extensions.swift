import XCTest

extension TimeInterval {
    static var longTimeout: Self { 30 }
    static var mediumTimeout: Self { 10 }
    static var shortTimeout: Self { 5 }
}

extension XCUIElement {
    enum Assertion: String {
        case isHittable = "hittable == true"
        case exists = "exists == true"
        case isNotHittable = "hittable == false"
        case doesNotExist = "exists == false"
        case hasFocus = "hasFocus == true"
        case isEnabled = "isEnabled == true"
        case isNotEnabled = "isEnabled == false"
    }

    enum TextAssertion: String {
        case contains = "CONTAINS"
        case matches = "MATCHES"
    }

    var isVisible: Bool {
        guard exists && !frame.isEmpty else {
            return false
        }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(frame)
    }

    func waitFor(_ assertions: Assertion...,
                 failureMessage: String? = nil,
                 timeout: TimeInterval,
                 file: StaticString = #file,
                 line: UInt = #line) {
        let assertionStrings = assertions.map { $0.rawValue }
        let predicateString = assertionStrings.joined(separator: " && ")
        let predicate = NSPredicate(format: predicateString)
        waitFor(predicate: predicate, failureMessage: failureMessage, timeout: timeout, file: file, line: line)
    }

    func waitFor(predicate: NSPredicate,
                 failureMessage: String? = nil,
                 timeout: TimeInterval,
                 file: StaticString = #file,
                 line: UInt = #line) {
        if predicate.evaluate(with: self) { return }

        let expectation = XCTNSPredicateExpectation(
            predicate: predicate,
            object: self)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)

        if result != .completed {
            var message = "Condition '\(predicate)' for \(self) was not satisfied during \(timeout) seconds"
            if let failureMessage = failureMessage {
                message = "\(failureMessage). \(message)"
            }
            XCTFail(message, file: file, line: line)
        }
    }

    func waitForExist(timeout: TimeInterval = .shortTimeout, failureMessage: String? = nil, file: StaticString = #file, line: UInt = #line) {
        waitFor(.exists, failureMessage: failureMessage, timeout: timeout, file: file, line: line)
    }

    func waitForVisible(timeout: TimeInterval = .shortTimeout, failureMessage: String? = nil, file: StaticString = #file, line: UInt = #line) {
        let predicate = NSPredicate { _, _ in
            self.isVisible
        }
        waitFor(predicate: predicate, failureMessage: failureMessage, timeout: timeout, file: file, line: line)
    }

    func waitForEnabled(timeout: TimeInterval = .shortTimeout, failureMessage: String? = nil, file: StaticString = #file, line: UInt = #line) {
        waitFor(.isEnabled, failureMessage: failureMessage, timeout: timeout, file: file, line: line)
    }

    func waitForDisabled(timeout: TimeInterval = .shortTimeout, failureMessage: String? = nil, file: StaticString = #file, line: UInt = #line) {
        waitFor(.isNotEnabled, failureMessage: failureMessage, timeout: timeout, file: file, line: line)
    }

    func tapHittable(timeout: TimeInterval = .shortTimeout) {
        waitForHittable(timeout: timeout)
        tap()
    }

    func waitForDisappearance(timeout: TimeInterval = .shortTimeout, failureMessage: String? = nil, file: StaticString = #file, line: UInt = #line) {
        waitFor(.doesNotExist, failureMessage: failureMessage, timeout: timeout, file: file, line: line)
    }

    func waitUntilFocused(timeout: TimeInterval = .shortTimeout, failureMessage: String? = nil, file: StaticString = #file, line: UInt = #line) {
        waitFor(.hasFocus, failureMessage: failureMessage, timeout: timeout, file: file, line: line)
    }

    func waitForHittable(timeout: TimeInterval = .shortTimeout, failureMessage: String? = nil, file: StaticString = #file, line: UInt = #line) {
        waitFor(.isHittable, failureMessage: failureMessage, timeout: timeout, file: file, line: line)
    }

    func waitFor(text: String, assertion: TextAssertion, negate: Bool = false, timeout: TimeInterval = .shortTimeout, failureMessage: String? = nil, file: StaticString = #file, line: UInt = #line) {
        var predicateString = String(format: "label %@ '%@'", assertion.rawValue, text)
        if negate {
            predicateString = String(format: "NOT (%@)", predicateString)
        }
        let predicate = NSPredicate(format: predicateString)
        waitFor(predicate: predicate, failureMessage: failureMessage, timeout: timeout, file: file, line: line)
    }
}
