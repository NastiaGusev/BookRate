import UIKit
import FirebaseAuth
import FirebaseFirestore

class BookViewController: UIViewController {
    
    @IBOutlet weak var bookNameTextView: UITextView!
    @IBOutlet weak var authorTextView: UITextView!
    @IBOutlet weak var likesCountTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var genresTextView: UITextView!
    @IBOutlet weak var heartButton: UIButton!
    
    let db = Firestore.firestore()
    var liked: Bool = false
    var booksManager = BooksManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateBookView()
    }
    
    func updateBookView(){
        let selectedBook = booksManager.books[booksManager.selectedBookIndex]
        bookNameTextView.text = selectedBook.title
        authorTextView.text = selectedBook.author
        likesCountTextView.text = selectedBook.likesCount
        descriptionTextView.text = selectedBook.description
        genresTextView.text = selectedBook.genres
        updateHeartView()
        
        if let imageUrl = URL(string: selectedBook.image) {
            bookImage.imageFrom(url: imageUrl)
        }
    }
    
    @IBAction func heartClicked(_ sender: UIButton) {
        print(liked)
        updateLike()
        updateFavorites(booksManager.books[booksManager.selectedBookIndex])
    }
    
    func updateLike(){
        if liked {
            liked = false
        } else {
            liked = true
        }
    }
    
    func updateHeartView(){
        if liked {
            heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
    
    func updateFavorites(_ book: Book){
        if !booksManager.checkIfBookIsInList(book: book, bookList: booksManager.likedBooks){
            booksManager.likedBooks.append(book)
            uploadFavorite(book)
        } else {
            booksManager.removeBookFromFavorites(book)
            deleteFavorite(book)
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

//MARK: - Extension for Firestore
extension BookViewController {
    func uploadFavorite(_ book: Book){
        if let userEmail = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionUsers)
                .document(userEmail).collection(K.FStore.collectionFavorites)
                .addDocument(data:[K.FStore.titleField: book.title, K.FStore.authorField: book.author])
            { (error) in
                    if let e = error {
                        print("There was an error \(e)")
                    } else {
                        print("Successfully saved data")
                    }
                    DispatchQueue.main.async {
                        self.heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                    }
                }
        }
    }
    
    func deleteFavorite(_ book: Book){
        if let userEmail = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionUsers)
                .document(userEmail).collection(K.FStore.collectionFavorites)
                .whereField(K.FStore.titleField, isEqualTo: book.title)
                .whereField(K.FStore.authorField, isEqualTo: book.author)
                .getDocuments{ (querySnapshot, error) in
                    if let e = error {
                        print(e)
                    } else {
                        for document in querySnapshot!.documents {
                            document.reference.delete()
                        }
                    }
                    DispatchQueue.main.async {
                        self.heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
                    }
                }
        }

    }
}
