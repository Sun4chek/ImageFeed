//
//  ProfileViewControllerTests.swift
//  ImageFeed
//
//  Created by Волошин Александр on 8/6/25.
//

@testable import ImageFeed
import XCTest


final class ProfileViewTests: XCTestCase {

    func testPresenterCallDidLoad() {
        let presenterSpy = ProfileViewPresenterSpy()
        let view = ProfileViewController()
        
        view.configure(presenterSpy)
        view.viewDidLoad()
        
        XCTAssertTrue(presenterSpy.didLoadCalled)
    }
    
    func testPresenterCallDidTapExitBtn() {
        let presenterSpy = ProfileViewPresenterSpy()
        let view = ProfileViewController()
        
        view.configure(presenterSpy)
        view.didTapButton()
        
        XCTAssertTrue(presenterSpy.didTapExitBtnCalled)
    }
    
    func testUpdateLabel(){
        let view = ProfileViewController()
        
        view.updateUI(name: "тест", loginName:"тест", bio: "тест", avatar: UIImage(named: "тест"))
        
        XCTAssertEqual(view.nameLabel.text, "тест")
        XCTAssertEqual(view.shortNameLabel.text, "@тест")
        XCTAssertEqual(view.profileText.text, "тест")
        XCTAssertEqual(view.avatarImageView.image, UIImage(named: "тест"))
        
    }
}

final class ProfileViewPresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var didLoadCalled = false
    var didTapExitBtnCalled = false
    
    func viewDidLoad() {
        didLoadCalled = true
    }
    
    func didTapExitBtn() {
        didTapExitBtnCalled = true
    }
    
    
}
