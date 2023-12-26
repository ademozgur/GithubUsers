import Factory
import Foundation

protocol ReachabilityProtocol {
    func startNotifier() throws
}

extension Reachability: ReachabilityProtocol {}

extension Container {
    static let reachability = Factory {
        if let reachability = try? Reachability() as ReachabilityProtocol {
            return reachability
        }

        fatalError("could not build reachability")
    }
}
