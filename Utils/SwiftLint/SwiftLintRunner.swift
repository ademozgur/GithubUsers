#!/usr/bin/env swift
import Foundation

enum LinterErrors: String {
    case gitDiffFailed = "Failed to run git diff"
    case gitLsFilesFailed = "Failed to run git ls-files"
    case swiftLintFailed = "Failed to run swiftlint"
    case wrongNumberOfArguments = "Wrong number of arguments"

    var errorCode: Int32 {
        switch self {
        case .gitDiffFailed:
            return 1
        case .gitLsFilesFailed:
            return 2
        case .swiftLintFailed:
            return 3
        case .wrongNumberOfArguments:
            return 4
        }
    }
}
class SwiftLintRunner {
    static var rootPath = ""

    static func listChangedSwiftFiles() -> [String] {
        let allFiles = Array(Set(
            listGitCommittedModifiedFiles()
            + listGitUnCommittedModifiedFiles()
            + listGitNewFiles()
        ))
        let swiftFiles = allFiles.filter({$0.hasSuffix(".swift")})
        return swiftFiles
    }

    static func listGitCommittedModifiedFiles() -> [String] {
        let gitFetch = git(["fetch"])
        let gitDiff = git(["diff", "origin/master...", "--name-only", "--diff-filter=d"])
        let gitPipe = Pipe()
        gitDiff.standardOutput = gitPipe

        do {
            try gitFetch.run()
            gitFetch.waitUntilExit()

            try gitDiff.run()
            gitDiff.waitUntilExit()
        } catch {
            print(LinterErrors.gitDiffFailed.rawValue)
            exit(LinterErrors.gitDiffFailed.errorCode)
        }

        let data = gitPipe.fileHandleForReading.readDataToEndOfFile()
        var filesList = [String]()

        if let output = String(data: data, encoding: String.Encoding.utf8) {
            filesList = output.components(separatedBy: "\n")
        }
        return filesList
    }

    static func listGitUnCommittedModifiedFiles() -> [String] {
        let gitDiff = git(["diff", "HEAD", "--name-only", "--diff-filter=d"])
        let gitPipe = Pipe()
        gitDiff.standardOutput = gitPipe

        do {
            try gitDiff.run()
            gitDiff.waitUntilExit()
        } catch {
            print(LinterErrors.gitDiffFailed.rawValue)
            exit(LinterErrors.gitDiffFailed.errorCode)
        }

        let data = gitPipe.fileHandleForReading.readDataToEndOfFile()
        var filesList = [String]()

        if let output = String(data: data, encoding: String.Encoding.utf8) {
            filesList = output.components(separatedBy: "\n")
        }
        return filesList
    }

    static func listGitNewFiles() -> [String] {
        let gitCommandCached = git(["ls-files", "--others", "--exclude-standard"])
        let gitPipe = Pipe()
        gitCommandCached.standardOutput = gitPipe

        do {
            try gitCommandCached.run()
            gitCommandCached.waitUntilExit()
        } catch {
            print(LinterErrors.gitLsFilesFailed.rawValue)
            exit(LinterErrors.gitLsFilesFailed.errorCode)
        }

        let data = gitPipe.fileHandleForReading.readDataToEndOfFile()
        var filesList = [String]()

        if let output = String(data: data, encoding: String.Encoding.utf8) {
            filesList = output.components(separatedBy: "\n")
        }
        return filesList
    }

    static func git(_ arguments: [String]) -> Process {
        let git = Process()
        git.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        git.arguments = arguments
        git.currentDirectoryURL = URL(fileURLWithPath: "\(rootPath)/..")

        return git
    }

    static func swiftLint(_ arguments: [String]) -> Process {
        let linter = Process()
        linter.executableURL = URL(fileURLWithPath: "\(rootPath)/../Utils/Scripts/SwiftLint/swiftlint")
        linter.arguments = arguments
        linter.currentDirectoryURL = URL(fileURLWithPath: "\(rootPath)/..")

        return linter
    }

    static func runLinterWith(files: [String]) {
        let swiftLintFix = swiftLint(["--fix"] + files)
        let swiftLintLinter = swiftLint(["lint"] + files)
        do {
            try swiftLintFix.run()
            swiftLintFix.waitUntilExit()

            swiftLintLinter.terminationHandler = { exit($0.terminationStatus) }
            try swiftLintLinter.run()
            swiftLintLinter.waitUntilExit()

        } catch {
            print(LinterErrors.swiftLintFailed.rawValue)
            exit(LinterErrors.swiftLintFailed.errorCode)
        }
    }

    static func main() {
        guard CommandLine.argc == 2 else {
            print(LinterErrors.wrongNumberOfArguments.rawValue)
            exit(LinterErrors.wrongNumberOfArguments.errorCode)
        }

        rootPath = CommandLine.arguments[1]
        let changedFiles = listChangedSwiftFiles()

        if changedFiles.isEmpty {
            exit(0)
        }

        runLinterWith(files: changedFiles)
    }
}

SwiftLintRunner.main()
