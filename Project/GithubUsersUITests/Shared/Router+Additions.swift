import Ambassador

// Router has a regex bug, this is the workaround.
// https://github.com/envoy/Ambassador/issues/49
extension Router {
    func set(path: String, response: WebApp) {
        self["^" + path + "$"] = response
    }
}
