//
//  YelpAPIClient.swift
//  Yelp It Off
//
//  Created by David Lechón Quiñones on 18/08/15.
//
//

import Foundation
import OAuthSwift

struct YelpAPIConsole {
    var consumerKey = "X7zB9VTOptkGhZxCvVGD4w"
    var consumerSecret = "bDDd5jIIxa0WUvESUGeoguWe1Tk"
    var accessToken = "yoWMKTTSgMjQgq6k3fJ3Xo_xLeFUoVus"
    var accessTokenSecret = "hQBmuqv0ehXrPHnbEyZWa-6zHxQ"
}

class YelpAPIClient: NSObject {
    
    let APIBaseUrl = "https://api.yelp.com/v2/"
    let clientOAuth: OAuthSwiftClient?
    let apiConsoleInfo: YelpAPIConsole

    override init() {
        apiConsoleInfo = YelpAPIConsole()
        self.clientOAuth = OAuthSwiftClient(consumerKey: apiConsoleInfo.consumerKey, consumerSecret: apiConsoleInfo.consumerSecret, oauthToken: apiConsoleInfo.accessToken, oauthTokenSecret: apiConsoleInfo.accessTokenSecret, version: OAuthSwiftCredential.Version.oauth2)
        
        super.init()
    }
    
    /* 
    
    searchPlacesWithParameters: Function that can search for places using any specified API parameter
    
    Arguments:
    
        searchParameters: Dictionary<String, String>, optional (See https://www.yelp.co.uk/developers/documentation/v2/search_api )
        successSearch: success callback with data (NSData) and response (NSHTTPURLResponse) as parameters
        failureSearch: error callback with error (NSError) as parameter
    
    Example:
    
    var parameters = ["ll": "37.788022,-122.399797", "category_filter": "burgers", "radius_filter": "3000", "sort": "0"]
    
    searchPlacesWithParameters(parameters, successSearch: { (data, response) -> Void in
        println(NSString(data: data, encoding: NSUTF8StringEncoding))
    }, failureSearch: { (error) -> Void in
        println(error)
    })
    
    
    */
    
    func searchPlacesWithParameters(_ searchParameters: Dictionary<String, String>, successSearch: @escaping (_ data: Data, _ response: HTTPURLResponse) -> Void, failureSearch: @escaping (_ error: Error) -> Void) {
        let searchUrl = APIBaseUrl + "search/"
        
        _ = clientOAuth!.get(searchUrl, parameters: searchParameters, headers: nil, completionHandler: { (result) in
            switch result {
            case .success(let response):
                successSearch(response.data, response.response)
            case .failure(let error):
                failureSearch(error.underlyingError!)
            }
        })
    }
    
    /*
    
    getBusinessInformationOf: Retrieve all the business data using the id of the place
    
    Arguments:
    
        businessId: String
        localeParameters: Dictionary<String, String>, optional (See https://www.yelp.co.uk/developers/documentation/v2/business )
        successSearch: success callback with data (NSData) and response (NSHTTPURLResponse) as parameters
        failureSearch: error callback with error (NSError) as parameter
    
    Example:
    
    getBusinessInformationOf("custom-burger-san-francisco", successSearch: { (data, response) -> Void in
        println(NSString(data: data, encoding: NSUTF8StringEncoding))
    }) { (error) -> Void in
        println(error)
    }
    
    */
    
    func getBusinessInformationOf(_ businessId: String, localeParameters: Dictionary<String, String>? = nil, successSearch: @escaping (_ data: Data, _ response: HTTPURLResponse) -> Void, failureSearch: @escaping (_ error: Error) -> Void) {
        let businessInformationUrl = APIBaseUrl + "business/" + businessId
        var parameters = localeParameters
        if parameters == nil {
            parameters = Dictionary<String, String>()
        }
        
        _ = clientOAuth!.get(businessInformationUrl, parameters: parameters!, headers: nil, completionHandler: { (result) in
            switch result {
            case .success(let response):
                successSearch(response.data, response.response)
            case .failure(let error):
                failureSearch(error.underlyingError!)
            }
        })
    }
    
    /*
    
    searchBusinessWithPhone: Search for a business using a telephone number
    
    Arguments:
    
        phoneNumber: String
        searchParameters: Dictionary<String, String>, optional (See https://www.yelp.co.uk/developers/documentation/v2/phone_search )
        successSearch: success callback with data (NSData) and response (NSHTTPURLResponse) as parameters
        failureSearch: error callback with error (NSError) as parameter
    
    Example:
    
    searchBusinessWithPhone("+15555555555", successSearch: { (data, response) -> Void in
        println(NSString(data: data, encoding: NSUTF8StringEncoding))
    }) { (error) -> Void in
        println(error)
    }
    
    */
    
    func searchBusinessWithPhone(_ phoneNumber: String, searchParameters: Dictionary<String, String>? = nil, successSearch: @escaping (_ data: Data, _ response: HTTPURLResponse) -> Void, failureSearch: @escaping (_ error: Error) -> Void) {
        let phoneSearchUrl = APIBaseUrl + "phone_search/"
        var parameters = searchParameters
        if parameters == nil {
            parameters = Dictionary<String, String>()
        }
        
        parameters!["phone"] = phoneNumber
        
        _ = clientOAuth!.get(phoneSearchUrl, parameters: parameters!, headers: nil, completionHandler: { (result) in
            switch result {
            case .success(let response):
                successSearch(response.data, response.response)
            case .failure(let error):
                failureSearch(error.underlyingError!)
            }
        })
    }
}
