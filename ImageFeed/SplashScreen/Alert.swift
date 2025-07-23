

import UIKit

    
func showErrorAlert(on viewController: UIViewController,title : String,message : String) {
    let alert = UIAlertController(
        title: title,
        message: message,
        preferredStyle: .alert)
        
    let alertAction = UIAlertAction(
        title: "OK",
        style: .default,
        handler: nil)
        
    alert.addAction(alertAction)
    viewController.present(alert, animated: true)
        
}




