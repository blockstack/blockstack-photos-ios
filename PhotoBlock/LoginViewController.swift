//
//  LoginViewController
//  PhotoBlock
//
//  Created by Shreyas Thiagaraj on 9/20/19.
//  Copyright © 2019 Shreyas Thiagaraj. All rights reserved.
//

import UIKit
import Blockstack

class LoginViewController: UIViewController {

    @IBAction func loginTapped(_ sender: Any) {
        Blockstack.shared.signIn(
            redirectURI: URL(string: "https://pedantic-mahavira-f15d04.netlify.com/redirect.html")!,
            appDomain: URL(string: "https://pedantic-mahavira-f15d04.netlify.com")!,
            scopes: [.storeWrite, .publishData]) { authResult in
                switch authResult {
                case .success(_):
                    DispatchQueue.main.async {
                        // Show next page
                        let photoVC = self.storyboard?.instantiateViewController(withIdentifier: "Photo") as! PhotoViewController
                        self.present(photoVC, animated: true, completion: nil)
                    }
                 case .failed(_):
                    let alert = UIAlertController(title: "Oops!", message: "Login failed, please try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                default:
                    return
                }
        }

    }
}

