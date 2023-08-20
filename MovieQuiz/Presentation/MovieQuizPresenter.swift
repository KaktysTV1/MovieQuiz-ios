//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Андрей Чупрыненко on 20.08.2023.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
}
