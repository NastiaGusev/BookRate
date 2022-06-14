import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
 
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signInClicked(_ sender: Any) {
        if let email = emailTF.text, let password = passwordTF.text {
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
    
    func navigateToBookList(_ error: Error?){
        if let e = error {
            print(e)
        } else {
            //Navigate to loginController
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
    
}

