
import Foundation

struct BooksManager {
    var books: [Book] = []
    var likedBooks: [Book] = []
    var selectedBookIndex: Int = 0
    
    func checkIfBookIsInList(book: Book, bookList: [Book]) -> Bool {
        for b in bookList {
            if book.title == b.title && book.author == b.author {
                return true
            }
        }
        return false
    }
    
    func getBookByTitleAndAuthor(title: String, author: String) -> Book{
        for book in books {
            if book.title == title && book.author == author {
                return book
            }
        }
        return Book(image: "", title: "", author: "", genres: "", description: "", likesCount: "")
    }
    
    mutating func removeBookFromFavorites(_ book: Book){
        for i in (0 ..< likedBooks.count ) {
            if likedBooks[i].title == book.title && likedBooks[i].author == book.author{
                likedBooks.remove(at: i)
                break
            }
        }
    }
}
