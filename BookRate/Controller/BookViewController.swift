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
    var selectedBook = Book(image: "", title: "", author: "", genres: "", description: "", likesCount: 0)
    var booksManager = BooksManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateBookView()
    }
    
    func updateBookView(){
        selectedBook = booksManager.getCurrentBook()
        
        bookNameTextView.text = selectedBook.title
        authorTextView.text = selectedBook.author
        likesCountTextView.text = String(selectedBook.likesCount)
        descriptionTextView.text = selectedBook.description.replacingOccurrences(of: "/n", with: "\n")
        genresTextView.text = selectedBook.genres
        updateHeartView()
        
        if let imageUrl = URL(string: selectedBook.image) {
            bookImage.imageFrom(url: imageUrl)
        }
    }
    
    @IBAction func heartClicked(_ sender: UIButton) {
        updateLike()
        updateLikesCount()
        updateFavorites()
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
    
    func updateFavorites(){
        if !booksManager.checkIfBookIsInList(selectedBook, booksManager.likedBooks){
            booksManager.likedBooks.append(selectedBook)
            uploadFavorite(selectedBook)
        } else {
            booksManager.removeBookFromFavorites(selectedBook)
            deleteFavorite(selectedBook)
        }
    }
    
    func updateLikesCount(){
        var likes = selectedBook.likesCount
        if liked {
            likes += 1
        } else {
            likes -= 1
        }
        selectedBook.likesCount = likes
        likesCountTextView.text = String(selectedBook.likesCount)
        updateBook(selectedBook)
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
    
    func updateBook(_ book: Book){
        db.collection(K.FStore.collectionName).whereField(K.FStore.titleField, isEqualTo: book.title).whereField(K.FStore.authorField, isEqualTo: book.author).getDocuments()
        { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    document.reference.updateData([K.FStore.likesCountField: book.likesCount])
                    { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                }
            }
        }
    }
}
