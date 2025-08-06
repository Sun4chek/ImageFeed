//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Волошин Александр on 8/6/25.
//

import Foundation
import UIKit





protocol ImagesListPresenterProtocol{
    var view: ImagesListViewProtocol? { get set }
    var photos: [Photo] {get set}
    func viewDidLoad()
    func willDisplayCell(at indexPath: IndexPath)
    func calculCellHeight(indexPath: IndexPath,tableView: UITableView) -> CGFloat
    
}
final class ImagesListPresenter: ImagesListPresenterProtocol{
    var photos: [Photo] = []
    
    private let imageListService : ImagesListService
    var view : ImagesListViewProtocol?
    
    init(imageListService: ImagesListService, view: ImagesListViewProtocol) {
        self.imageListService = imageListService
        self.view = view
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func viewDidLoad() {
        imageListService.fetchPhotosNextPage()
        observer()
    }
    
    private func observer() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
    }
    
    @objc private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imageListService.photos.count
        photos = imageListService.photos
        if oldCount != newCount {
            view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
        }
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imageListService.fetchPhotosNextPage()
        }
    }
    
    func calculCellHeight(indexPath: IndexPath,tableView: UITableView) -> CGFloat{
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    
    
}
