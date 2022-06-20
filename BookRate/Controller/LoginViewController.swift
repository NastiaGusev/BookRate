import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTF.delegate = self
        self.passwordTF.delegate = self
        clearEmailPassword()
    }
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           self.view.endEditing(true)
           return false
       }
    
    @IBAction func signInClicked(_ sender: Any) {
        if let email = emailTF.text, let password = passwordTF.text {
            clearEmailPassword()
            if signinButton.titleLabel?.text == "Register" {
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    self.navigateToBookList(error)
                }
            } else {
                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                    self.navigateToBookList(error)
                }
            }
        }
    }
    
    func clearEmailPassword(){
        emailTF.text = ""
        passwordTF.text = ""
    }
    
    func navigateToBookList(_ error: Error?){
        if let e = error {
            print(e)
        } else {
            self.performSegue(withIdentifier: K.loginSegue, sender: self)
        }
    }

    @IBAction func signUpClicked(_ sender: UIButton) {
        if signinButton.titleLabel?.text == "Register" {
            signinButton.setTitle("Sign in", for: .normal)
            sender.setTitle("Register", for: .normal)
        } else {
            signinButton.titleLabel?.text = "Register"
            signinButton.setTitle("Register", for: .normal)
            sender.setTitle("Sign in", for: .normal)
        }
    }
    
    func uploadBooks(){
        print(db)
        db.collection(K.FStore.collectionName)
            .addDocument(data:[K.FStore.imageField: "https://user-images.githubusercontent.com/49269198/173869254-a020e14f-6640-4724-9e9b-ba564b5ebb5f.png",
                               K.FStore.titleField: "Ugly Love: A Novel",
                               K.FStore.authorField: "Colleen Hoover",
                               K.FStore.descriptionField: "",
                               K.FStore.likesCountField: 0
           ]) { (error) in
                if let e = error {
                    print("There was an error \(e)")
                } else {
                    print("Successfully saved data")
                }
            }
    }
}

