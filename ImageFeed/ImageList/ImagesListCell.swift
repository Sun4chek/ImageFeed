import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell : ImagesListCell)
    
}



final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    weak var delegate: ImagesListCellDelegate?
    
    private let gradientView: UIView = {
        let view = UIView()
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.0).cgColor,
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.2).cgColor
        ]
        // Устанавливаем точку остановки градиента (53.93% → 0.5393)
        gradient.locations = [0.0, 0.5393]
        // Направление градиента: сверху вниз (180deg)
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(gradient, at: 0)
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGradient()
    }
    
    
    
//    
    func configure(with url: URL,date:String){
        cellImage.kf.indicatorType = .activity
        let placeholder = UIImage(named: "placeholder")
        cellImage.kf.setImage(
                    with: url,
                    placeholder: placeholder,
                    options : [.transition(.fade(0.3))]
                ) {[weak self] result in
                    switch result {
                        case .success:
                            print("успех на соло картинке")
                        case .failure:
                            print("Error downloading image")
                    }
                }
        dateLabel.text = date
        let likeImage = UIImage(named: "NoActive")
        likeButton.setImage(likeImage, for: .normal)
        
    }
//
//    
//    
//    
//    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
//        let photo = photos[indexPath.row]
//        let url = URL(string: photo.thumbImageURL)
//        
//        cell.cellImage.kf.indicatorType = .activity
//        let placeholder = UIImage(named: "placeholder")
//        
//        cell.cellImage.kf.setImage(
//            with: url,
//            placeholder: placeholder,
//            options : [.transition(.fade(0.3))]
//        ) {[weak self] result in
//            switch result {
//                case .success:
//                    self?.tableView.beginUpdates()
//                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
//                    self?.tableView.endUpdates()
//                case .failure:
//                    print("Error downloading image")
//            }
//        }
//        let dateText = photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""
//        cell.dateLabel.text = dateText
//        
//        let likeImage = UIImage(named: "NoActive")
//        cell.likeButton.setImage(likeImage, for: .normal)
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Устанавливаем градиент только на нижние 30 пикселей
        gradientView.frame = CGRect(
            x: 0,
            y: cellImage.bounds.height - 30,
            width: cellImage.bounds.width,
            height: 30
        )
        // Обновляем размер градиентного слоя
        if let gradientLayer = gradientView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = gradientView.bounds
        }
    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(_ isLiked : Bool){
        let likeImage = isLiked ? UIImage(named: "Active") : UIImage(named: "NoActive")
        likeButton.setImage(likeImage, for: .normal)
    }
    private func setupGradient() {
        cellImage.addSubview(gradientView)
        // Убедимся, что дата отображается поверх градиента
        cellImage.bringSubviewToFront(dateLabel)
    }
}
