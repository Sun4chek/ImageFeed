//
//  Data.swift
//  ImageFeed
//
//  Created by Волошин Александр on 6/30/25.
//

import Foundation

enum NetworkError: Error {  // 1
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in  // 2
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data)) // 3
                } else {
                    print("status code \(statusCode) is not in 200..<300")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode))) // 4
                }
            } else if let error = error {
                print("catch error \(error) in request")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error))) // 5
            } else {
                print("catch error in URLSession")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError)) // 6
            }
        })
        
        return task
    }
}


extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {

        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result{
            case .success(let data):
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Полученные данные: \(jsonString)\n\n\n\n\n\n\n\n???????n")
                }
                do {
                    print("начинаеи декодить")
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(T.self, from: data)
                    completion(.success(response))
                }
                catch {
                    print("trouble UrlSseion objTask can't decode: \(error), data: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("UrlSseion objTask failed to make a request: \(error)")
                completion(.failure(error))
            }
        }
        return task
    }
}
