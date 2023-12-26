import Ambassador
import Embassy
import Foundation
import XCTest

class BaseTest: XCTestCase {
    // TODO: for parallel test execution, we need to start the server on different ports for each test
    // using a single port for all tests results in a "port is already in use" error
    let port = 8080
    var router: Router!
    var eventLoop: EventLoop!
    var server: HTTPServer!
    var eventLoopThreadCondition: NSCondition!
    var eventLoopThread: Thread!
    var app: XCUIApplication!

    func launchApp() {
        app.launchArguments = ["isRunningUITests"]
        app.launch()
    }

    override func setUp() {
        super.setUp()
        setupWebApp()
        setupApp()
    }

    // setup the Embassy web server for testing
    private func setupWebApp() {
        eventLoop = try! SelectorEventLoop(selector: try! KqueueSelector())
        router = Router()
        server = DefaultHTTPServer(eventLoop: eventLoop, port: port, app: router.app)

        // Start HTTP server to listen on the port
        try! server.start()

        eventLoopThreadCondition = NSCondition()
        eventLoopThread = Thread(target: self, selector: #selector(runEventLoop), object: nil)
        eventLoopThread.start()
    }

    // set up XCUIApplication
    private func setupApp() {
        app = XCUIApplication()
        app.launchEnvironment["ENVOY_BASEURL"] = "http://localhost:\(port)"
    }

    override func tearDown() {
        super.tearDown()
        app.terminate()
        server.stopAndWait()
        eventLoopThreadCondition.lock()
        eventLoop.stop()
        while eventLoop.running {
            if !eventLoopThreadCondition.wait(until: NSDate().addingTimeInterval(10) as Date) {
                fatalError("Join eventLoopThread timeout")
            }
        }
    }

    @objc private func runEventLoop() {
        eventLoop.runForever()
        eventLoopThreadCondition.lock()
        eventLoopThreadCondition.signal()
        eventLoopThreadCondition.unlock()
    }

    /*
     if ProcessInfo.processInfo.arguments.contains("isRunningUITests") {
         // Prepare application for UI tests.
     }
     */
}
