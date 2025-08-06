//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Волошин Александр on 8/6/25.
//

import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewProtocol? { get set }
    var photos: [Photo] { get }
    func viewDidLoad()
    func didScrollToBottom()
    func didTapLike(at indexPath: IndexPath)
    func getPhoto(at index: Int) -> Photo?
    func getPhotosCount() -> Int
    func updatePhotos()
}


final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    private var currentPhotosCount: Int = 0
    
    var photos: [Photo] {
        return imagesListService.photos
    }
    
    func viewDidLoad() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updatePhotos()
        }
        
        if !imagesListService.photos.isEmpty {
            DispatchQueue.main.async { [weak self] in
                self?.updatePhotos()
            }
        }
        
        imagesListService.fetchPhotosNextPage()
    }
    
    func updatePhotos() {
        let oldCount = currentPhotosCount
        currentPhotosCount = photos.count
        view?.updateTableViewAnimated(oldCount: oldCount, newPhotos: photos)
    }
    
    func didScrollToBottom() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func didTapLike(at indexPath: IndexPath) {
        guard indexPath.row < photos.count else { return }
        let photo = photos[indexPath.row]
        
        view?.showLoadingHUD()
        imagesListService.changeLike(photo.id, isLike: !photo.isLiked) { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLoadingHUD()
                
                switch result {
                case .success:
                    self?.view?.updateLikeStatus(at: indexPath, isLiked: !photo.isLiked)
                case .failure:
                    self?.view?.showLikeError()
                }
            }
        }
    }
    
    func getPhoto(at index: Int) -> Photo? {
        guard index < photos.count else { return nil }
        return photos[index]
    }
    
    func getPhotosCount() -> Int {
        return photos.count
    }
    
    deinit {
        if let observer = imagesListServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
