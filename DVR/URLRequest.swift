import Foundation

extension NSURLRequest {
    var dictionary: [String: AnyObject] {
        var dictionary = [String: AnyObject]()

        if let method = HTTPMethod {
            dictionary["method"] = method
        }

        if let url = URL?.absoluteString {
            dictionary["url"] = url
        }

        if let headers = allHTTPHeaderFields {
            dictionary["headers"] = headers
        }

        if let data = HTTPBody, body: AnyObject = Interaction.encodeBody(data, headers: allHTTPHeaderFields as? [String: String]) {
            dictionary["body"] = body
        }

        return dictionary
    }
}


extension NSMutableURLRequest {
    convenience init(dictionary: [String: AnyObject]) {
        self.init()

        if let method = dictionary["method"] as? String {
            HTTPMethod = method
        }

        if let string = dictionary["url"] as? String, url = NSURL(string: string) {
            URL = url
        }

        if let headers = dictionary["headers"] as? [String: String] {
            allHTTPHeaderFields = headers
        }

        HTTPBody = Interaction.dencodeBody(dictionary["body"], headers: allHTTPHeaderFields as? [String: String])
    }
}
