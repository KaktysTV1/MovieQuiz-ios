//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Андрей Чупрыненко on 20.08.2023.
//

import Foundation
import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func showAnswerResult(isCorrect: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}

final class MovieQuizPresenter: QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    //текущий вопрос, который видит пользователь
    var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService = StatisticServiceImplementation()
    weak var viewController: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    
    
    lazy var alertPresenter: AlertPresenter? = AlertPresenter(viewController: viewController as! UIViewController)
       
       let questionsAmount: Int = 10
       private var currentQuestionIndex: Int = 0
       var correctAnswers: Int = 0
       
       init(viewController: MovieQuizViewControllerProtocol) {
           self.viewController = viewController
           
           statisticService = StatisticServiceImplementation()
           
           questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
                   questionFactory?.loadData()
           viewController.showLoadingIndicator()
       }
    
    
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
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func didAnswer(isYes: Bool) {
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
    
    func show(quiz result: QuizResultsViewModel) {
        let completion = { (_: UIAlertAction) -> Void in
               self.currentQuestionIndex = 0
               self.correctAnswers = 0
               self.questionFactory?.requestNextQuestion()
           }
           let alertModel = AlertModel(
               title: result.title,
               message: result.text,
               buttonText: result.buttonText,
               completion: completion)
           
           alertPresenter?.showResultsAlert(alertModel)
       }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            ///реализована корректная работа замыкания
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.correctAnswers = self.correctAnswers
                self.questionFactory = self.questionFactory
                showNextQuestionOrResults()
            }
        }
    }
        func showNetworkError(message: String) {
            
            let model = AlertModel(title: "Ошибка",
                                   message: message,
                                   buttonText: "Попробовать еще раз") { [weak self] _ in
                guard let self = self else { return }
                
                self.resetQuestionIndex()
                self.correctAnswers = 0
                
                self.questionFactory?.requestNextQuestion()
            }
            
            alertPresenter?.showResultsAlert(model)
        }
        
      func showNextQuestionOrResults() {
          if isLastQuestion() {
                        
              let questionsAmount = currentQuestionIndex + 1
              statisticService.store(correct: correctAnswers, total: questionsAmount)
                        
                        let gamesCount = statisticService.gamesCount
                        let bestGame = statisticService.bestGame
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd.MM.YY HH:mm"
                        
                        let text = """
                                        Ваш результат: \(correctAnswers) из \(questionsAmount)
                                        Количество сыгранных квизов: \(gamesCount)
                                        Ваш рекорд: \(bestGame.correct)/\(bestGame.total) (\(dateFormatter.string(from: bestGame.date)))
                                        Средняя точность: (\(String(format: "%.2f", statisticService.totalAccuracy))%)
                                    """
                        
                        let alertModel = AlertModel(title: "Этот раунд окончен!", message: text, buttonText: "Сыграть ещё раз", completion: startNewQuiz)
                        
                        alertPresenter?.showResultsAlert(alertModel)
                        
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
