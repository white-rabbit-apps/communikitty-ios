//
//  NetworkLayer.swift
//  CommuniKitty
//
//  Created by shubham Garg on 16/08/20.
//  Copyright © 2020 White Rabbit Apps. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

let rGraphQLServiceBaseUrl = "https://reshare.community/graphql"
class GraphQLServiceManager {
    static let sharedManager = GraphQLServiceManager()
    private init() {}
    var signInUser:SignIn?
    
    func getUSer()-> SignIn?{
        guard let user = signInUser else {
            let userDefaults = UserDefaults.standard
            if let decoded  = userDefaults.data(forKey: "user"), let decodedTeams = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? SignIn{
                return decodedTeams
            }
            return nil
        }
         return user
        
    }
    
    var header:HTTPHeaders = [ HTTPHeader(name: "Content-Type", value: "application/json"),
                               HTTPHeader(name: "User-Agent", value: "Mobile - iOS"),
                               HTTPHeader(name: "Referer", value: "https://www.communikitty.com/")
//                               HTTPHeader(name: "Device-Id", value: UIDevice.current.identifierForVendor!.uuidString),
//                               HTTPHeader(name: "Api-Version", value: "1")
    
    ]
    
    var headerGraphQL = ["Content-Type": "application/json" ,
                         "User-Agent": "Mobile - iOS",
                         "Device-Details": "\(UIDevice.current.model) - \(UIDevice.current.systemVersion.lowercased())",
        "Device-Id":UIDevice.current.identifierForVendor!.uuidString,
        "Api-Version": "8"]
    
    var tokenGraphQL:String? = nil
    
    func createGraphQLRequestWith(currentBaseURL: String = rGraphQLServiceBaseUrl, requestType:Alamofire.HTTPMethod = HTTPMethod.post, path: String = "",query:String = "", variableParam: Parameters? = nil, success: @escaping (Data?) -> (), failure: @escaping (NSError) -> ()) {
        if !(Alamofire.NetworkReachabilityManager()?.isReachable)! {
            failure(NSError(domain: "", code: -1003, userInfo: nil))
        } else {
            if let user = self.getUSer(){
                self.header.add(HTTPHeader(name: "authorization", value: user.credential?.authorization ?? ""))
                self.header.add(HTTPHeader(name: "client", value: user.credential?.client ?? ""))
                self.header.add(HTTPHeader(name: "tokentype", value: user.credential?.tokentype ?? ""))
                self.header.add(HTTPHeader(name: "uid", value: user.credential?.uid ?? ""))
                self.header.add(HTTPHeader(name: "__typename", value: user.credential?.__typename ?? ""))
            }
            let endPoint = currentBaseURL + path
            guard let encodedURL = endPoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),let graphQLParam = self.paramConstructor(query:query, variableParam:variableParam) else {
                failure(NSError(domain: "INVALID URL", code: 5000, userInfo: ["errorMessage": "graphQLParam or path error"]))
                return
            }
            print("HITTING GRAPH QL \(requestType.rawValue) \nUrl:\(encodedURL) \nparameter \(graphQLParam) \nHeader\(self.headerGraphQL)")
            
            AF.request(encodedURL, method:requestType, parameters: graphQLParam, encoding: JSONEncoding.default, headers: self.header).responseString {
                response in
                switch response.result {
                case .success:
                    guard let unwrappedData = response.data else {
                        failure(NSError(domain: "Json error", code: 5001, userInfo: ["errorMessage": "data is null"]))
                        return
                    }
                    do{
                        if let json = try JSONSerialization.jsonObject(with: unwrappedData, options: []) as? Parameters{
                            if let errors = json["errors"] as? [[String:Any]]{
                                
                                if let error = errors.first, let message = error["message"] as? String{
                                    DispatchQueue.main.async {
                                        if let rootVC = (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController{
                                            print(message)
                                        }
                                        
                                    }
                                    
                                    failure(NSError(domain: "Json error", code: 5002, userInfo: ["errorMessage": message]))
                                    
                                }
                                else{
                                    failure(NSError(domain: "Json error", code: 5002, userInfo: ["errorMessage": "Error by GraphQL"]))
                                }
                            } else {
                                success(unwrappedData)
                            }
                        } else {
                            failure(NSError(domain: "Json error", code: 5003, userInfo: ["errorMessage": "Json object is nil"]))
                        }
                    }
                    catch{
                        failure(NSError(domain: "Json error", code: 5004, userInfo: ["errorMessage": "JSONSerialization failure"]))
                    }
                case .failure(let error):
                    failure(NSError(domain: "Json error", code: 5002, userInfo: ["errorMessage":  error.localizedDescription]))
                    break
                }
            }
        }
    }
    
    
    func paramConstructor(query:String = "", variableParam: Parameters? = nil) -> Parameters?{
        var graphQLParam:Parameters = [:]
        graphQLParam["query"] = query
        if let unwrappedTokenGraphQL = self.tokenGraphQL,!query.isEmpty{
            if var graphQLVariableParam = variableParam{
                graphQLVariableParam["token"] = unwrappedTokenGraphQL
                graphQLParam["variables"] = graphQLVariableParam
            } else {
                graphQLParam["variables"] = ["token":unwrappedTokenGraphQL]
            }
            return graphQLParam
        } else {
            if var graphQLVariableParam = variableParam{
                graphQLParam["variables"] = graphQLVariableParam
            }
            return graphQLParam
        }
    }
    
}
