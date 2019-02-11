//
//  GnaviClient.swift
//  Gourmet-app
//
//  Created by minagi on 2019/02/10.
//  Copyright © 2019 minagi. All rights reserved.
//

import Foundation

final class GnaviClient {
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        return session
    }()
    
    func send<Request : GnaviRequest>(
        request: Request,
        completion: @escaping (Result<Request.Response, GnaviClientError>) ->Void) {
        let urlRequest = request.buildURLRequest()
        let task = session.dataTask(with: urlRequest) {
            data, response, error in
            
            switch (data, response, error) {
            case (_, _, let error?):
                completion(Result(error: .connectionError(error)))
            case (let data?, let response?, _):
                do {
                    let response = try request.response(from:data, urlResponse: response)
                    completion(Result(value: response))
                } catch let error as GnaviAPIError {
                    completion(Result(error: .apiError(error)))
                } catch {
                    completion(Result(error: .responseParseError(error)))
                }
            default:
                fatalError("invalid response combination \(data), \(response), \(error).")
            }
        }
        
        task.resume()
    }
}
