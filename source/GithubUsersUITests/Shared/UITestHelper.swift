import Ambassador
import Embassy
import Foundation

final class UITestHelper {
    static func getFileContent(file: String, fileExtension: String) -> Data {
        let mockDataUrl = Bundle(for: UITestHelper.self)
            .url(forResource: file, withExtension: fileExtension)!

        let data = (try? Data(contentsOf: mockDataUrl))!

        return data
    }

    static func getDataResponse(file: String, fileExtension: String) -> DataResponse {
        let data = getFileContent(file: file, fileExtension: fileExtension)

        let dataResponse = DataResponse(handler: { _, sendData in
            sendData(data)
        })

        return dataResponse
    }

    static func errorResponse() -> DataResponse {
        DataResponse(
            statusCode: 500
        ) { (_, sendData) in
            sendData(Data("The server has made a boo boo.".utf8))
        }
    }
}
