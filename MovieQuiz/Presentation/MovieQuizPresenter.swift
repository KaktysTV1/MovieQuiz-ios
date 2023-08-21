//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Андрей Чупрыненко on 20.08.2023.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    //текущий вопрос, который видит пользователь
    var currentQuestion: QuizQuestion?
    private let statisticService: StatisticService = StatisticServiceImplementation()
    weak var viewController: MovieQuizViewController?
    var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    
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
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = true
            
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)}
    }
    
    //событие кнопки да
    func yesButtonClicked() {
        
        //распаковка опционала для хранения текущего вопроса
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = true
            
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func noButtonClicked() {
       
        //распаковка опционала для хранения текущего вопроса
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = false
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func showNextQuestionOrResults() {
        if isLastQuestion() {
            let totalQuestions = currentQuestionIndex + 1
    
                statisticService.store(correct: correctAnswers, total: self.questionsAmount)
                
                let gamesCount = statisticService.gamesCount
                let bestGame = statisticService.bestGame
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.YY HH:mm"
                
                let text = """
                                Ваш результат: \(correctAnswers)\\\(self.questionsAmount)
                                Количество сыгранных квизов: \(gamesCount)
                                Ваш рекорд: \(bestGame.correct)/\(bestGame.total) (\(dateFormatter.string(from: bestGame.date)))
                                Средняя точность: (\(String(format: "%.2f", statisticService.totalAccuracy))%)
                            """
                
            let alertModel = AlertModel(title: "Этот раунд окончен!", message: text, buttonText: "Сыграть ещё раз", completion: startNewQuiz)
                        
                viewController?.show(quiz: alertModel)
            
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            
        }
    }
    
    func startNewQuiz(_ : UIAlertAction){
        self.correctAnswers = 0
        self.currentQuestionIndex = 0
        self.questionFactory?.requestNextQuestion()
    }
}
