
import Foundation

struct BooksManager {
    var books: [Book] = []
    var likedBooks: [Book] = []
    var hotToday: [Book] = []
    
    var currentList: String = K.allBooks
    var selectedBookIndex: Int = 0
    
    func checkIfBookIsInList(_ book: Book, _ bookList: [Book]) -> Bool {
        for b in bookList {
            if book.title == b.title && book.author == b.author {
                return true
            }
        }
        return false
    }
    
    func checkIfCurrentBookLiked() -> Bool {
        var selectedBook = Book(image: "", title: "", author: "", genres: "", description: "", likesCount: 0)
        if currentList == K.allBooks {
            selectedBook = books[selectedBookIndex]
        } else if currentList == K.hotToday {
            selectedBook = hotToday[selectedBookIndex]
        }
        
        if checkIfBookIsInList(selectedBook , likedBooks) {
            return true
        } else {
            return false
        }
    }
    
    mutating func updateLists() {
        if currentList == K.hotToday {
            hotToday = []
            likedBooks = []
        } else if currentList == K.favoriteBooks{
            likedBooks = []
        } else {
            books = []
            likedBooks = []
        }
    }
    
    func getListCount() -> Int {
        if currentList == K.allBooks {
            return books.count
        } else if currentList == K.favoriteBooks {
            return likedBooks.count
        } else if currentList == K.hotToday {
            return hotToday.count
        } else {
            return books.count
        }
    }
    
    func getCurrentBook() -> Book {
        if currentList == K.allBooks {
            return books[selectedBookIndex]
        } else if currentList == K.favoriteBooks {
            return likedBooks[selectedBookIndex]
        } else if currentList == K.hotToday {
            return hotToday[selectedBookIndex]
        } else {
            return books[selectedBookIndex]
        }
    }
    
    func getBookByTitleAndAuthor(title: String, author: String) -> Book{
        for book in books {
            if book.title == title && book.author == author {
                return book
            }
        }
        return Book(image: "", title: "", author: "", genres: "", description: "", likesCount: 0)
    }
    
    mutating func removeBookFromFavorites(_ book: Book){
        for i in (0 ..< likedBooks.count ) {
            if likedBooks[i].title == book.title && likedBooks[i].author == book.author{
                likedBooks.remove(at: i)
                break
            }
        }
    }
    
    mutating func removeBookFromAllBooks(_ book: Book){
        for i in (0 ..< books.count ) {
            if books[i].title == book.title && books[i].author == book.author{
                books.remove(at: i)
                break
            }
        }
    }
}
