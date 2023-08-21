//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Андрей Чупрыненко on 10.07.2023.
//

import Foundation
import UIKit

//публичная модель алерат
public struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (UIAlertAction) -> Void
}
