import UIKit
import FirebaseAuth

class BookViewController: UIViewController {
    
    @IBOutlet weak var bookNameTextView: UITextView!
    @IBOutlet weak var authorTextView: UITextView!
    @IBOutlet weak var likesCountTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var genresTextView: UITextView!
    
    var selectedBook = Book(image: "", title: "", author: "", genres: "", description: "", likesCount: "")

    override func viewDidLoad() {
        super.viewDidLoad()
        updateBookView()
    }
    
    func updateBookView(){
        bookNameTextView.text = selectedBook.title
        authorTextView.text = selectedBook.author
        likesCountTextView.text = selectedBook.likesCount
        descriptionTextView.text = selectedBook.description
        genresTextView.text = selectedBook.genres
        if let imageUrl = URL(string: selectedBook.image) {
            bookImage.imageFrom(url: imageUrl)
        }
    }

    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
}
