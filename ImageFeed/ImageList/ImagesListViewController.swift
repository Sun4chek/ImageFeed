import UIKit
import Kingfisher

protocol ImagesListViewProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get }
    var photos: [Photo] { get set }
    
    func updateTableViewAnimated(oldCount: Int, newPhotos: [Photo])
    func showLoadingHUD()
    func hideLoadingHUD()
    func showLikeError()
    func updateLikeStatus(at indexPath: IndexPath, isLiked: Bool)
}

final class ImagesListViewController: UIViewController, ImagesListViewProtocol {
    
    @IBOutlet private var tableView: UITableView!
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    var photos: [Photo] = []
    var presenter: ImagesListPresenterProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        if presenter == nil {
            let imagesListPresenter = ImagesListPresenter()
            configure(imagesListPresenter)
        }
        
        presenter?.viewDidLoad()
    }
    
    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    func updateTableViewAnimated(oldCount: Int, newPhotos: [Photo]) {
        photos = newPhotos
        
        if oldCount == 0 && newPhotos.count > 0 {
            tableView.reloadData()
        } else if oldCount != newPhotos.count {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newPhotos.count).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    func showLoadingHUD() {
        UIBlockingProgressHUD.show()
    }
    
    func hideLoadingHUD() {
        UIBlockingProgressHUD.dismiss()
    }
    
    func showLikeError() {
        showErrorAlert(on: self, title: "Что-то пошло не так(", message: "Не удалось войти в систему")
    }
    
    func updateLikeStatus(at indexPath: IndexPath, isLiked: Bool) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else { return }
        photos = presenter?.photos ?? []
        cell.setIsLiked(isLiked)
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let photo = presenter?.getPhoto(at: indexPath.row) else { return }
        let url = URL(string: photo.thumbImageURL)
        
        cell.cellImage.kf.indicatorType = .activity
        let placeholder = UIImage(named: "placeholder")
        
        cell.cellImage.kf.setImage(
            with: url,
            placeholder: placeholder,
            options : [.transition(.fade(0.3))]
        ) {[weak self] result in
            switch result {
                case .success:
                    self?.tableView.beginUpdates()
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                    self?.tableView.endUpdates()
                case .failure:
                    break
            }
        }
        let dateText = photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""
        cell.dateLabel.text = dateText
        
        let likeImage = photo.isLiked ? UIImage(named: "Active") : UIImage(named: "NoActive")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
    
    func tableView(_ tableView : UITableView,
                   willDisplay cell:UITableViewCell,
                   forRowAt indexPath : IndexPath
    ){
        if indexPath.row + 1 == (presenter?.getPhotosCount() ?? 0) {
            presenter?.didScrollToBottom()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else{
                assertionFailure("Invalid segue destination")
                return
            }
            guard let photo = presenter?.getPhoto(at: indexPath.row) else { return }
            let url = URL(string: photo.largeImageURL)
            let imageData = url.flatMap { try? Data(contentsOf: $0) }
            let image = imageData.flatMap { UIImage(data: $0) }
            viewController.image = image
                    
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.getPhotosCount() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        imageListCell.delegate = self
        return imageListCell
    }
}



extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter?.getPhoto(at: indexPath.row) else { return 0 }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}




extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLike(at: indexPath)
    }
}

