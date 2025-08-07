//
//  ImageListTests.swift
//  ImageFeed
//
//  Created by Волошин Александр on 8/7/25.
//
import Foundation
import XCTest
import UIKit
@testable import ImageFeed

class ImagePresenterSpy: ImagesListPresenterProtocol {
    func didScrollToBottom() {
        
    }
    
    func didTapLike(at indexPath: IndexPath) {
        
    }
    
    func getPhoto(at index: Int) -> Photo? {
        guard index < photos.count else { return nil }
        return photos[index]
    }
    
    func getPhotosCount() -> Int {
        return photos.count
    }
    
    func updatePhotos() {
        
    }
    
    var photos: [Photo] = []
    
    var view: (any ImageFeed.ImagesListViewProtocol)?
    var viewDidLoadCalled = false
    var willDisplayCellCalled = false
    var calculateCellHeightCalled = false
    var changeLikeCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
}

final class ImagesListViewControllerTests: XCTestCase {
    func testViewDidLoadCallsPresenter() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        
        let imagePresenterSpy = ImagePresenterSpy()
        viewController.presenter = imagePresenterSpy
        
        
        viewController.loadViewIfNeeded()
        
        XCTAssertTrue(imagePresenterSpy.viewDidLoadCalled)
    }
    
    func testTableViewDelegatesSetup() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        
        let imagePresenterSpy = ImagePresenterSpy()
        viewController.presenter = imagePresenterSpy
        
        
        viewController.loadViewIfNeeded()
        
        XCTAssertNotNil(viewController.tableView.dataSource)
        XCTAssertNotNil(viewController.tableView.delegate)
    }
    
    func testCellConfiguration() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        
        let imagePresenterSpy = ImagePresenterSpy()
        viewController.presenter = imagePresenterSpy
        
        
        
        let testPhoto = Photo(
            id: "test",
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            welcomeDescription: "Test",
            thumbImageURL: "https://example.com/thumb.jpg",
            largeImageURL: "https://example.com/large.jpg",
            fullImageUrl: "https://example.com/full.jpg",
            isLiked: false
        )
        imagePresenterSpy.photos = [testPhoto]
        
        
        viewController.loadViewIfNeeded()
        viewController.tableView.reloadData()
        let tableView = viewController.tableView!
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.dataSource?.tableView(
            tableView,
            cellForRowAt: indexPath
        ) as! ImagesListCell
        
        
        XCTAssertEqual(cell.likeButton.currentImage, UIImage(named: "NoActive"))
    }
}
