import Foundation

public class Session: NSURLSession {

    // MARK: - Properties

    public var outputDirectory: String
    public let cassetteName: String
    public let backingSession: NSURLSession
    public var recordingEnabled = true
    private let testBundle: NSBundle


    // MARK: - Initializers

    public init(outputDirectory: String = "~/Desktop/DVR/", cassetteName: String, testBundle: NSBundle = (NSBundle.allBundles() as! [NSBundle]).filter() { $0.bundlePath.hasSuffix(".xctest") }.first!, backingSession: NSURLSession = NSURLSession.sharedSession()) {
        self.outputDirectory = outputDirectory
        self.cassetteName = cassetteName
        self.testBundle = testBundle
        self.backingSession = backingSession
        super.init()
    }


    // MARK: - NSURLSession

    public override func dataTaskWithRequest(request: NSURLRequest) -> NSURLSessionDataTask {
        return SessionDataTask(session: self, request: request)
    }

    public override func dataTaskWithRequest(request: NSURLRequest, completionHandler: ((NSData?, NSURLResponse?, NSError?) -> Void)?) -> NSURLSessionDataTask {
        return SessionDataTask(session: self, request: request, completion: completionHandler)
    }

    public override func downloadTaskWithRequest(request: NSURLRequest) -> NSURLSessionDownloadTask {
        return SessionDownloadTask(session: self, request: request)
    }

    public override func downloadTaskWithRequest(request: NSURLRequest, completionHandler: ((NSURL?, NSURLResponse?, NSError?) -> Void)?) -> NSURLSessionDownloadTask {
        return SessionDownloadTask(session: self, request: request, completion: completionHandler)
    }
    
    public override func invalidateAndCancel() {
        // Don't do anything
    }

    // MARK: - Internal

    var cassette: Cassette? {
        if let path = testBundle.pathForResource(cassetteName, ofType: "json"), data = NSData(contentsOfFile: path) {
            if let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? [String: AnyObject] {
                return Cassette(dictionary: json)
            }
            return nil
        } else { return nil }
    }
}
