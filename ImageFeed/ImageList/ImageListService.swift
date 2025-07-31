//
//  ImageListService.swift
//  ImageFeed
//
//  Created by Волошин Александр on 7/31/25.
//



import Foundation


struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}


struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let likedByUser: Bool
    let urls: Urls

    enum CodingKeys: String, CodingKey {
        case id, width, height, description, urls
        case createdAt = "created_at"
        case likedByUser = "liked_by_user"
    }
}



struct Urls:Decodable {
    let raw : String
    let full : String
    let regular : String
    let small : String
    let thumb : String
}

class ImagesListService {
    private var lastLoadedPage : Int?
    private var task: URLSessionTask?
    private(set) var photos : [Photo] = []
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    let shared = ImagesListService()
    private lazy var dateFormatter : ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    
    
    
    
    
    func fetchPhotosNextPage() {
        
        
        
        if let _ = task {
            print("запрос для картинок уже отправлен")
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = makePhotoRequest(page :nextPage) else {
            print("пришел пстой запрос для картинок")
            return}
        
        
        
        
        task = URLSession.shared.objectTask(for: request, completion: { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            switch result {
                case .success(let response):
                    let newPhotos = response.map{result -> Photo in
                    let size = CGSize(width: result.width, height: result.height)
                    let date = result.createdAt.flatMap{
                        self.dateFormatter.date(from: $0) }
                    let photo = Photo(id: result.id, size: size, createdAt: date, welcomeDescription: result.description, thumbImageURL: result.urls.thumb, largeImageURL: result.urls.full, isLiked: result.likedByUser
                    )
                        return photo
                    }
                    DispatchQueue.main.async {
                        self.lastLoadedPage = nextPage
                        self.photos.append(contentsOf: newPhotos)
                        NotificationCenter.default.post(name: Self.didChangeNotification , object: nil)
                    }
                case .failure(let error):
                    print(error)
            }
        })
        task?.resume()
    }

    func makePhotoRequest(page : Int) -> URLRequest?{
        guard let baseUrl = Constants.defaultBaseURL else { return nil }
        let url = URL(
            string: "/photos"
            + "?page=\(page)",
            relativeTo: baseUrl
        )!
        guard let token = OAuth2TokenStorage.shared.token else {
            print("нет токена авторизации")
            return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
