//
//  ImageListService.swift
//  ImageFeed
//
//  Created by Волошин Александр on 7/31/25.
//



import Foundation

enum ImagesListServiceError: Error {
    case invalidRequest
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let fullImageUrl : String
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
    static let shared = ImagesListService()
    private lazy var dateFormatter : ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter}()
    
    
    
    
    
    
    func fetchPhotosNextPage() {
        
        
        
        if task != nil {
            print("запрос для картинок уже отправлен")
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = makePhotoRequest(page :nextPage) else {
            print("пришел пустой запрос для картинок")
            return}
        
        
        
        
         let task = URLSession.shared.objectTask(for: request, completion: { [weak self] (result: Result<[PhotoResult], Error>) in
                        switch result {
                case .success(let response):
                    let newPhotos = response.map{result -> Photo in
                    let size = CGSize(width: result.width, height: result.height)
                    let date = result.createdAt.flatMap{
                        self?.dateFormatter.date(from: $0) }
                        let photo = Photo(id: result.id, size: size, createdAt: date, welcomeDescription: result.description, thumbImageURL: result.urls.thumb, largeImageURL: result.urls.full, fullImageUrl: result.urls.full, isLiked: result.likedByUser
                    )
                        return photo
                        
                    }
                    self?.task = nil
                    DispatchQueue.main.async {
                        self?.lastLoadedPage = nextPage
                        self?.photos.append(contentsOf: newPhotos)
                        NotificationCenter.default.post(name: Self.didChangeNotification , object: nil)
                    }
                case .failure(let error):
                    print(error)
            }
        })
        self.task = task
        task.resume()
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
    
    func reset() {
        self.photos = []
        self.lastLoadedPage = 0
    }
    
}


extension ImagesListService{
    func changeLike(_ photoId : String , isLike : Bool , completion : @escaping (Result<Void,Error>) -> Void){
        guard let request = changeLikeRequest(method: isLike ? "POST" : "DELETE" , id: photoId) else {
            completion(.failure(ImagesListServiceError.invalidRequest))
            print("не получили запрос дл лайков")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request){ [weak self] data, response, error  in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            DispatchQueue.main.async {
                guard let self else { return }
                if let index = self.photos.firstIndex(where: { $0.id == photoId }){
                    let photo = self.photos[index]
                    let newPhoto = Photo(id: photo.id , size: photo.size, createdAt: photo.createdAt, welcomeDescription: photo.welcomeDescription, thumbImageURL: photo.thumbImageURL, largeImageURL: photo.largeImageURL, fullImageUrl: photo.fullImageUrl, isLiked: !photo.isLiked)
                    self.photos[index] = newPhoto
                    print("лайк изменен")
                }
                completion(.success(()))
            }
        }
        task.resume()

    }
    
    func changeLikeRequest(method : String , id : String) -> URLRequest? {
        guard let baseUrl = Constants.defaultBaseURL else {
            print("Не удалось получить базовый URL для лайков")
            return nil }
        let url = URL(
            string: "/photos"
            + "/\(id)"
            + "/like",
            relativeTo: baseUrl
        )!

        guard let token = OAuth2TokenStorage.shared.token else {
            print("нет токена авторизации")
            return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
        
    }
}

