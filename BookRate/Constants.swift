
struct K {
    static let cellIdentifier = "ReusableCell"
    static let cellFileName = "BookCell"
    static let loginSegue = "SigninToBookList"
    static let bookListSegue = "BookListToBook"
    
    static let hotToday = "Hot today"
    static let allBooks = "All"
    static let favoriteBooks = "Favorites"
    
    struct FStore {
        static let collectionName = "books"
        static let imageField = "image"
        static let titleField = "title"
        static let authorField = "author"
        static let descriptionField = "description"
        static let likesCountField = "likesCount"
        static let genresField = "genres"
    }
}
