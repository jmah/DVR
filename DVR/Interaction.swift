import Foundation

struct Interaction {

    // MARK: - Properties

    let request: NSURLRequest
    let response: NSURLResponse
    let responseData: NSData?
    let recordedAt: NSDate


    // MARK: - Initializers

    init(request: NSURLRequest, response: NSURLResponse, responseData: NSData? = nil, recordedAt: NSDate = NSDate()) {
        self.request = request
        self.response = response
        self.responseData = responseData
        self.recordedAt = recordedAt
    }


    // MARK: - Encoding

    static func encodeBody(body: NSData, headers: [String: String]? = nil) -> AnyObject? {
        if let contentType = headers?["Content-Type"] {
            // Text
            if contentType.hasPrefix("text/") {
                // TODO: Use encoding if specified in headers
                return String(NSString(data: body, encoding: NSUTF8StringEncoding)!)
            }

            // JSON
            if contentType == "application/json" {
                return NSJSONSerialization.JSONObjectWithData(body, options: nil, error: nil)
            }
        }

        // Base64
        return body.base64EncodedStringWithOptions(nil)
    }

    static func dencodeBody(body: AnyObject?, headers: [String: String]? = nil) -> NSData? {
        if let body: AnyObject = body {

            if let contentType = headers?["Content-Type"] {
                // Text
                if let string = body as? String where contentType.hasPrefix("text/") {
                    // TODO: Use encoding if specified in headers
                    return string.dataUsingEncoding(NSUTF8StringEncoding)
                }

                // JSON
                if contentType == "application/json" {
                    return NSJSONSerialization.dataWithJSONObject(body, options: nil, error: nil)
                }
            }

            // Base64
            if let base64 = body as? String {
                return NSData(base64EncodedString: base64, options: nil)
            }
        }

        return nil
    }
}


extension Interaction {
    var dictionary: [String: AnyObject] {
        var dictionary: [String: AnyObject] = [
            "request": request.dictionary,
            "recorded_at": recordedAt.timeIntervalSince1970
        ]

        var response = self.response.dictionary
        if let data = responseData, body: AnyObject = Interaction.encodeBody(data, headers: response["headers"] as? [String: String]) {
            response["body"] = body
        }
        dictionary["response"] = response

        return dictionary
    }

    init?(dictionary: [String: AnyObject]) {
        if let request = dictionary["request"] as? [String: AnyObject],
            response = dictionary["response"] as? [String: AnyObject],
            recordedAt = dictionary["recorded_at"] as? Int {

                self.request = NSMutableURLRequest(dictionary: request)
                self.response = URLHTTPResponse(dictionary: response)
                self.recordedAt = NSDate(timeIntervalSince1970: NSTimeInterval(recordedAt))
                self.responseData = Interaction.dencodeBody(response["body"], headers: response["headers"] as? [String: String])
        } else {
            return nil
        }
    }
}
