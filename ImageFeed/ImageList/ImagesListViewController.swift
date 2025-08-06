import UIKit
import Kingfisher


protocol ImagesListViewProtocol: AnyObject {
    
    var presenter: ImagesList2PresenterProtocol? { get set }
    func blockProgressHUDOn()
    func blockProgressHUDOff()
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func updatePhoto(at indexPath: IndexPath, like: Bool)


}

final class ImagesListViewController: UIViewController , ImagesListViewProtocol{
    
    

    
    func blockProgressHUDOn() {
        UIBlockingProgressHUD.show()
    }

    func blockProgressHUDOff() {
        UIBlockingProgressHUD.dismiss()
    }

    var presenter: ImagesList2PresenterProtocol?
    @IBOutlet private var tableView: UITableView!
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
//    private let imagesListService = ImagesListService.shared
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    
    @objc func updateTableViewAnimated(oldCount: Int, newCount: Int) {

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
        guard
            let photo = presenter?.photos[indexPath.row],
            let url = URL(string: photo.thumbImageURL) else {return}
        
        let dateText = photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""
        
        cell.configure(with : url,date: dateText)
    }

    
    func tableView(_ tableView : UITableView,
                   willDisplay cell:UITableViewCell,
                   forRowAt indexPath : IndexPath
    ){
        presenter?.rowingAtIndexPath(indexPath)
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
            if let photo = presenter?.photos[indexPath.row]{
                let url = URL(string: photo.largeImageURL)
                let imageData = url.flatMap { try? Data(contentsOf: $0) }
                let image = imageData.flatMap { UIImage(data: $0) }
                viewController.image = image
            }
         } else {
                super.prepare(for: segue, sender: sender)
         }
    }
    
    func updatePhoto(at indexPath: IndexPath,like: Bool) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else {
            print("лайк не получился")
            return
        }
        cell.setIsLiked(like)
    }
    
    

}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let presenter = presenter as? ImagesListPresenter else {
            return 10
        }
        return presenter.photos.count
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
        guard let size = presenter?.cellHeight(tableView, heightForRowAt: indexPath) else {return 0}
        return size
    }
}




extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.changeLike(at: indexPath)
    }
    
    
    
    
}
