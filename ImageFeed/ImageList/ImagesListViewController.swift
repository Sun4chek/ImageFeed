import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController{

    
    @IBOutlet private var tableView: UITableView!
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared
    
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
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )

        imagesListService.fetchPhotosNextPage()
    }
    
    
    @objc func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    

    
    
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
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
                    print("Error downloading image")
            }
        }
        let dateText = photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""
        cell.dateLabel.text = dateText
        
        let likeImage = UIImage(named: "NoActive")
        cell.likeButton.setImage(likeImage, for: .normal)
    }

    
    func tableView(_ tableView : UITableView,
                   willDisplay cell:UITableViewCell,
                   forRowAt indexPath : IndexPath
    ){
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
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
            let photo = photos[indexPath.row]
            let url = URL(string: photo.largeImageURL)
            let imageData = url.flatMap { try? Data(contentsOf: $0) }
            let image = imageData.flatMap { UIImage(data: $0) }
            viewController.image = image
                    
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
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
        let photo = photos[indexPath.row]
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
        let photo = photos[indexPath.row]

        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photo.id, isLike: !photo.isLiked){ [weak self] result in
            
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success:
                    self.photos = self.imagesListService.photos
                    cell.setIsLiked(!photo.isLiked)
                    UIBlockingProgressHUD.dismiss()
                    
                case .failure(let error):
                    print(" Ошибка лайка: \(error.localizedDescription)")
                    UIBlockingProgressHUD.dismiss()
                    showErrorAlert(on: self, title: "Что-то пошло не так(", message: "Не удалось войти в систему")
                    print("Error: \(error)")
                }
                
                
            }
        }

    }
    
    
    
    
}
