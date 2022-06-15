
import UIKit

class BookCell: UITableViewCell {
    
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var bookTitle: UITextView!
    @IBOutlet weak var bookAuthor: UITextView!
    @IBOutlet weak var heartImage: UIImageView!
    @IBOutlet weak var likesCount: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
