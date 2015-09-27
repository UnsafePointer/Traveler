//
//  Traveler.swift
//  Traveler
//
//  Created by Renzo Crisostomo on 26/09/15.
//  Copyright © 2015 Ruenzuo.io. All rights reserved.
//

import Foundation

public struct TravelerConstants {

    enum ErrorDomain: String {
        case Authorization = "TravelerErrorDomainAuthorization"
        case UserService = "TravelerErrorDomainUserService"
    }
    struct ErrorCode {
        static let WrongURL = 9999
        static let RequestFailed = 9998
        static let CookiesNotFound = 9997
        static let SerializationFailed = 9996
    }

}

extension NSHTTPCookieStorage {

    func valueForCookieName(cookieName: String) -> String?  {
        guard let cookies = self.cookies else {
            return nil
        }
        for cookie in cookies {
            if cookie.name == cookieName {
                return cookie.value
            }
        }
        return nil
    }

}

public class Traveler {

    static let baseURL = NSURL(string: "https://www.bungie.net/platform")

    public static var APIKey: String?

    // MARK: - Private

    class func wrongURLErrorWithDomain(domain: TravelerConstants.ErrorDomain) -> NSError {
        let error = NSError(domain: domain.rawValue,
            code: TravelerConstants.ErrorCode.WrongURL,
            userInfo: ["NSLocalizedDescriptionKey" : "URL couldn't be initialised"])
        return error
    }

    class func cookiesNotFoundErrorWithDomain(domain: TravelerConstants.ErrorDomain) -> NSError {
        let error = NSError(domain: domain.rawValue,
            code: TravelerConstants.ErrorCode.CookiesNotFound,
            userInfo: ["NSLocalizedDescriptionKey" : "Couldn't find cookies in shared store"])
        return error
    }

    class func requestFailedErrorWithDomain(domain: TravelerConstants.ErrorDomain) -> NSError {
        let error = NSError(domain: domain.rawValue,
            code: TravelerConstants.ErrorCode.RequestFailed,
            userInfo: ["NSLocalizedDescriptionKey" : "Authorization request failed"])
        return error
    }

    class func serializationFailedErrorWithDomain(domain: TravelerConstants.ErrorDomain) -> NSError {
        let error = NSError(domain: domain.rawValue,
            code: TravelerConstants.ErrorCode.RequestFailed,
            userInfo: ["NSLocalizedDescriptionKey" : "Serialization failed"])
        return error
    }

    class func requestWithPath(path: String) throws -> NSURLRequest {
        guard let URL = baseURL?.URLByAppendingPathComponent(path) else {
            throw wrongURLErrorWithDomain(TravelerConstants.ErrorDomain.UserService)
        }
        guard let bungled = NSHTTPCookieStorage.sharedHTTPCookieStorage().valueForCookieName("bungled") else {
            throw cookiesNotFoundErrorWithDomain(TravelerConstants.ErrorDomain.UserService)
        }
        let request = NSMutableURLRequest(URL: URL)
        request.setValue(APIKey, forHTTPHeaderField: "X-API-Key")
        request.setValue(bungled, forHTTPHeaderField: "X-CSRF")
        return request
    }

    // MARK: - Public

    public class func currentUserWithCompletion(completion: (NSDictionary?, NSError?) -> ()) {
        do {
            let request = try requestWithPath("User/GetBungieNetUser/")
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { (maybeData, maybeResponse, maybeError) in
                if let data = maybeData {
                    do {
                        let currentUser = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary
                        completion(currentUser, nil)
                    } catch {
                        completion(nil, error as NSError)
                    }
                } else {
                    completion(nil, maybeError)
                }
            }
            task.resume()
        } catch {
            completion(nil, error as NSError)
        }
    }

}