import UIKit
import FirebaseAuth
import FirebaseFirestore

class BookListViewController: UIViewController {
    
    @IBOutlet weak var hotTodayButton: UIButton!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var currentList = K.hotToday
    let db = Firestore.firestore()
    var booksManager = BooksManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        
        tableView.register(UINib(nibName: K.cellFileName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        setHotTodayClicked()
        loadBooks()
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
            print(currentList)
        }
    }
    
    func setAllButtonsToNormal(){
        hotTodayButton.titleLabel?.textColor = .darkGray
        allButton.titleLabel?.textColor = .darkGray
        favoritesButton.titleLabel?.textColor = .darkGray
    }
    
    func setHotTodayClicked(){
        allButton.titleLabel?.textColor = .darkGray
        favoritesButton.titleLabel?.textColor = .darkGray
    }
    
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
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
                    }
                }
                
            }
        }
    }
    
}

extension BookListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return booksManager.books.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! BookCell
        cell.bookTitle?.text = booksManager.books[indexPath.row].title
        cell.bookAuthor?.text = booksManager.books[indexPath.row].author
        cell.likesCount?.text = booksManager.books[indexPath.row].likesCount
       
        if let imageUrl = URL(string: booksManager.books[indexPath.row].image) {
            cell.bookImage.imageFrom(url: imageUrl)
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.bookListSegue {
            let destinationVC = segue.destination as! BookViewController
            destinationVC.selectedBook = booksManager.books[booksManager.selectedBookIndex]
        }
    }

}

extension BookListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        booksManager.selectedBookIndex = indexPath.row
        performSegue(withIdentifier: K.bookListSegue, sender: self)
    }
}

//MARK: - Extension for loading URL to ImageView
extension UIImageView{
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

