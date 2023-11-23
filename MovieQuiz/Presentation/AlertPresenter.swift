//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Андрей Чупрыненко on 10.07.2023.
//

import Foundation
import UIKit

//класс который формирует алерт
class AlertPresenter {
    weak var viewController: UIViewController?
        
        init(viewController: UIViewController) {
            self.viewController = viewController
        }
        
    func showResultsAlert(_ alertModel: AlertModel) {
            let alert = UIAlertController(title: alertModel.title, message: alertModel.message, preferredStyle: .alert)
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { alertAction in alertModel.completion(alertAction)}
            
            guard let viewController = viewController else { return }
            alert.view.accessibilityIdentifier = "Alert Result"
            alert.addAction(action)
            viewController.present(alert, animated: true, completion: nil)
        }
}
