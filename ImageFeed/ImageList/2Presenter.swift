//
//  2Presenter.swift
//  ImageFeed
//
//  Created by Волошин Александр on 8/6/25.
//

import Foundation
import UIKit

protocol ImagesList2PresenterProtocol{
    var photos: [Photo] {get}
    var view : ImagesListViewProtocol? {get set}
    func viewDidLoad()
    func rowingAtIndexPath(_ indexPath: IndexPath)
    func cellHeight(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    func changeLike(at indexPath: IndexPath)
    
}

final class ImagesList2Presenter: ImagesList2PresenterProtocol{
    
    var view : ImagesListViewProtocol?
    var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared
    
    func viewDidLoad() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        
        imagesListService.fetchPhotosNextPage()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func refreshTableViewAnimated(){
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
    }
    
    func rowingAtIndexPath(_ indexPath: IndexPath){
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func cellHeight(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func changeLike(at indexPath: IndexPath) {
        var photo = self.photos[indexPath.row]
        self.view?.blockProgressHUDOn()
        
        imagesListService.changeLike(photo.id, isLike : !photo.isLiked ) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.photos = self.imagesListService.photos
                    self.view?.updatePhoto(at: indexPath, like: !photo.isLiked)
                    
                case .failure:
                    print("ошибка возврат ячейки")
                }
            }
        }
        self.view?.blockProgressHUDOff()
    } 
    
}
