//
//  ApodApi.swift
//  swift-apod
//
//  Created by rehez on 12.07.20.
//

import Foundation

struct Apod: Codable{
    let date : Date
    let explanation : String
    let url : String
    let hdurl : String? // missing if media_type is not image
    let media_type : String
    let service_version : String
    let title : String
    let copyright : String?
}

enum Result<Value> {
    case success(Value)
    case failure(Error)
}

enum ApodApiError: Error {
    case urlError(reason: String)
    case requestError(reason: String)
    case objectSerialization(reason: String)
}

extension DateFormatter {
    static let yearMonthDay: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
}

class ApodApi {
    
    func getCurrent(completion: @escaping ((Result<Apod>) -> Void)) {
        get(date: nil, completion: completion)
    }
    
    func get(date: String?, completion: @escaping ((Result<Apod>) -> Void)) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https";
        urlComponents.host = "api.nasa.gov";
        urlComponents.path = "/planetary/apod";
        
        let apiKeyQuery = URLQueryItem(name: "api_key", value: "DEMO_KEY")
        urlComponents.queryItems = [apiKeyQuery]
        
        if (date != nil) {
            let dateQuery = URLQueryItem(name: "date", value: date!)
            urlComponents.queryItems!.append(dateQuery)
        }
        
        guard let url = urlComponents.url else {
            let error = ApodApiError.urlError(reason: "Failed to build url")
            completion(.failure(error))
            return
        }
        
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let json = data else {
                let error = ApodApiError.requestError(reason: "Empty response")
                completion(.failure(error))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                let apod = try decoder.decode(Apod.self, from: json)
                DispatchQueue.main.async {
                    completion(.success(apod))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
}
