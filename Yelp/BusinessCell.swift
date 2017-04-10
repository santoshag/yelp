import UIKit

class BusinessCell: UITableViewCell {

    // MARK: Outlets
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var pricingLabel: UILabel!
    
    var business: Business!{
        didSet{
            nameLabel.text = business.name
            if let image = business.imageURL{
                photoImageView.setImageWith(image)
            }
            if let image = business.ratingImageURL{
                ratingImageView.setImageWith(image)
            }
            if let reviewCount = business.reviewCount {
                reviewCountLabel.text = "\(reviewCount) Reviews"
            }
            addressLabel.text = business.address
            distanceLabel.text = business.distance
            categoriesLabel.text = business.categories
            //pricingLabel.text = business.
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
