import UIKit
import FirebaseAuth
import FirebaseFirestore

class BookListViewController: UIViewController {
    
    @IBOutlet weak var hotTodayButton: UIButton!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var currentList = K.allBooks
    let db = Firestore.firestore()
    var booksManager = BooksManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        
        tableView.register(UINib(nibName: K.cellFileName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        hotTodayButton.titleLabel?.textColor = .darkGray
        favoritesButton.titleLabel?.textColor = .darkGray
        //loadBooks()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(isViewLoaded)
        if isViewLoaded {
            setAllButtonsToNormal()
            setCurrentButtonPressed()
            booksManager.books = []
            booksManager.likedBooks = []
            loadBooks()
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func bottomButtonPressed(_ sender: UIButton) {
        setAllButtonsToNormal()
        if let title = sender.titleLabel?.text {
            currentList = title
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func setAllButtonsToNormal(){
        hotTodayButton.titleLabel?.textColor = .darkGray
        allButton.titleLabel?.textColor = .darkGray
        favoritesButton.titleLabel?.textColor = .darkGray
    }
    
    func setCurrentButtonPressed(){
        if currentList == K.allBooks {
            allButton.titleLabel?.textColor = .tintColor
        } else if currentList == K.hotToday {
            hotTodayButton.titleLabel?.textColor = .tintColor
        } else if currentList == K.favoriteBooks {
            favoritesButton.titleLabel?.textColor = .tintColor
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.bookListSegue {
            let destinationVC = segue.destination as! BookViewController
            
            destinationVC.booksManager = booksManager
            destinationVC.selectedList = currentList
            let selectedBook = booksManager.books[booksManager.selectedBookIndex]
            if booksManager.checkIfBookIsInList(book: selectedBook , bookList: booksManager.likedBooks) {
                destinationVC.liked = true
            } else {
                destinationVC.liked = false
            }
            
        }
    }

}

//MARK: - Extension for TableView datasource
extension BookListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentList == K.allBooks {
            return booksManager.books.count
        } else if currentList == K.favoriteBooks {
            return booksManager.likedBooks.count
        } else {
            return booksManager.books.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if currentList == K.allBooks {
            return getAllCell(index: indexPath.row, indexPath: indexPath)
        } else if currentList == K.favoriteBooks {
            return getFavoritesCell(index: indexPath.row, indexPath: indexPath)
        } else {
            return getAllCell(index: indexPath.row, indexPath: indexPath)
        }
    }
    
    func getAllCell(index: Int, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! BookCell
        cell.bookTitle?.text = booksManager.books[index].title
        cell.bookAuthor?.text = booksManager.books[index].author
        cell.likesCount?.text = booksManager.books[index].likesCount
        
        if booksManager.checkIfBookIsInList(book: booksManager.books[index], bookList: booksManager.likedBooks) {
            cell.heartImage?.image = UIImage(systemName: "heart.fill")
        } else {
            cell.heartImage?.image = UIImage(systemName: "heart")
        }
        
        if let imageUrl = URL(string: booksManager.books[index].image) {
            cell.bookImage.imageFrom(url: imageUrl)
        }
        return cell
    }
    
    func getFavoritesCell(index: Int, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! BookCell
        cell.bookTitle?.text = booksManager.likedBooks[index].title
        cell.bookAuthor?.text = booksManager.likedBooks[index].author
        cell.likesCount?.text = booksManager.likedBooks[index].likesCount
        cell.heartImage?.image = UIImage(systemName: "heart.fill")
        
        if let imageUrl = URL(string: booksManager.likedBooks[index].image) {
            cell.bookImage.imageFrom(url: imageUrl)
        }
        return cell
    }
}

//MARK: - Extension for TableView Delegate
extension BookListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        booksManager.selectedBookIndex = indexPath.row
        performSegue(withIdentifier: K.bookListSegue, sender: self)
    }
}

//MARK: - Extension for Firestore
extension BookListViewController {
    
    func loadBooks(){
        db.collection(K.FStore.collectionName)
            .addSnapshotListener { [self] querySnapshot, error in
            
            if let e = error {
                print("There was an issue retrieving data from Firestore \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let bImage = data[K.FStore.imageField] as? String ,
                           let bTitle = data[K.FStore.titleField] as? String ,
                           let bAuthor = data[K.FStore.authorField] as? String,
                           let bDescription = data[K.FStore.descriptionField] as? String,
                           let bLikesCount = data[K.FStore.likesCountField] as? String,
                           let bGenres = data[K.FStore.genresField] as? String
                            
                        {
                            let newBook = Book(image: bImage, title: bTitle, author: bAuthor, genres: bGenres, description: bDescription, likesCount: bLikesCount)
                            self.booksManager.books.append(newBook)
                        }
                    }
                    loadFavorites()
                }
                
            }
        }
    }
    
    func loadFavorites(){
        if let userEmail = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionUsers)
                .document(userEmail).collection(K.FStore.collectionFavorites)
                .addSnapshotListener { [self] querySnapshot, error in
                
                if let e = error {
                    print("There was an issue retrieving data from Firestore \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            if let bTitle = data[K.FStore.titleField] as? String ,
                               let bAuthor = data[K.FStore.authorField] as? String
                            {
                                let newBook = booksManager.getBookByTitleAndAuthor(title: bTitle, author: bAuthor)
                                if newBook.title != "" {
                                    self.booksManager.likedBooks.append(newBook)
                                }
                                
                            }
                        }
                       
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}

//MARK: - Extension for loading URL to ImageView
extension UIImageView {
    func imageFrom(url:URL){
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url){
                if let image = UIImage(data:data){
                    DispatchQueue.main.async{
                        self?.image = image
                    }
                }
            }
        }
    }
}

