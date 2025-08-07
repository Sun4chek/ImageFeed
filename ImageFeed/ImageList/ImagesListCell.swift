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

