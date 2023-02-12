import Factory
import Foundation

struct RemoteUrlConfigurations {
    var baseUrl: String

    init(baseUrl: String) {
        self.baseUrl = baseUrl
    }

    func userListUrl(since: Int64?) -> URL {
        guard var urlComponents = URLComponents(string: baseUrl + Routes.users) else {
            // If can not construct a proper url, crash the app.
            fatalError(Errors.userListUrlNotValid.localizedDescription)
        }

        urlComponents.queryItems = [URLQueryItem(name: "per_page", value: "100")]

        if let since {
            let sinceQueryItem = URLQueryItem(name: "since", value: "\(since)")
            urlComponents.queryItems?.append(sinceQueryItem)
        }

        guard let url = urlComponents.url else {
            // If can not construct a proper url, crash the app.
            fatalError(Errors.userListUrlNotValid.localizedDescription)
        }

        return url
    }

    func singleUserUrl(id: String) -> URL {
        if let url = URL(string: baseUrl + Routes.users + "/" + id) {
            return url
        }
        // If can not construct a proper url, crash the app.
        fatalError(Errors.userUrlNotValid.localizedDescription)
    }
}

extension RemoteUrlConfigurations {
    enum Errors: Error {
        case userListUrlNotValid
        case userUrlNotValid
    }
}

extension RemoteUrlConfigurations {
    struct Routes {
        static let users = "/users"
    }
}

extension Container {
    static let urlConfigurations = Factory {
        // if the app is running inside a UI test
        if let baseUrl = ProcessInfo.processInfo.environment["ENVOY_BASEURL"] {
            return RemoteUrlConfigurations(baseUrl: baseUrl)
        }
        return RemoteUrlConfigurations(baseUrl: "https://api.github.com")
    }
}
