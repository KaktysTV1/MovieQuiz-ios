//
//  MoviesQuizPresenter.swift
//  MovieQuizTests
//
//  Created by Андрей Чупрыненко on 23.08.2023.
//

import XCTest

@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: MovieQuiz.QuizStepViewModel) { }
    
    func show(quiz result: MovieQuiz.QuizResultsViewModel) { }
    
    func showAnswerResult(isCorrect: Bool) { }
    
    func showLoadingIndicator() { }
    
    func hideLoadingIndicator() { }
    
    func showNetworkError(message: String) { }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: MovieQuizViewControllerMock())
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
