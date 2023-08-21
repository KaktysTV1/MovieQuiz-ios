import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    //аутлет кнопки да
    @IBOutlet weak var yesButton: UIButton!
    
    // аутелт кнопки нет
    @IBOutlet weak var noButton: UIButton!
    
    //аутлет изображения
    @IBOutlet weak private var imageView: UIImageView!
    
    //аутлет афиши фильма
    @IBOutlet weak private var textLabel: UILabel!
    
    //аутлет счетчика вопросов
    @IBOutlet weak private var counterLabel: UILabel!
    
    //аутлет загрузки
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    //Добавляем презентер в вью контроллер
    private let presenter = MovieQuizPresenter()
    
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    
    //обращение к протоколу фабрики вопросов
    private var questionFactory: QuestionFactoryProtocol?
    
    //текущий вопрос, который видит пользователь
    private var currentQuestion: QuizQuestion?
    
    private lazy var alertPsenenter = AlertPresenter(viewController: self)
    
    private var statisticService: StatisticService?
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadingIndicator()
        
        //обращение к фабрике вопросов
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        presenter.viewController = self
        
        statisticService = StatisticServiceImplementation()
        
        //скругление углов у афиши фильма
        imageView.layer.cornerRadius = 20
    }
    
    //событие кнопки да
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
        
      
    }
    
    //событие кнопки нет
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func hideLoadingIndicator() {
            activityIndicator.isHidden = true
        }
    
    // приватный метод, который меняет цвет рамки
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
               correctAnswers += 1
           }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
        
        //отключает активность кнопок после нажатия на ответ
        self.yesButton.isEnabled = false
        self.noButton.isEnabled = false
        
        ///реализована корректная работа замыкания
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestionOrResults()
            
            self?.imageView.layer.borderWidth = 0
            
            //включает активность кнопок после показа следующего вопроса
            self?.yesButton.isEnabled = true
            self?.noButton.isEnabled = true
            }
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса
    func show(quiz step: QuizStepViewModel) {
      imageView.contentMode = .scaleAspectFill
      imageView.image = step.image
      textLabel.text = step.question
      counterLabel.text = step.questionNumber
        
        }
    
    private func show(quiz result: QuizResultsViewModel) {
            let completion = {
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
                    }
        
            let alertModel = AlertModel(
                        title: result.title,
                        message: result.text,
                        buttonText: result.buttonText,
                        completion: completion)
            
            alertPsenenter.showResultsAlert(alertModel)
            
        }
    
    
    
    //изменяет статус бар на белый
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPsenenter.showResultsAlert(model)
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            if let statisticService = statisticService {
                
                statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
                
                let gamesCount = statisticService.gamesCount
                let bestGame = statisticService.bestGame
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.YY HH:mm"
                
                let text = """
                                Ваш результат: \(correctAnswers)\\\(presenter.questionsAmount)
                                Количество сыгранных квизов: \(gamesCount)
                                Ваш рекорд: \(bestGame.correct)/\(bestGame.total) (\(dateFormatter.string(from: bestGame.date)))
                                Средняя точность: (\(String(format: "%.2f", statisticService.totalAccuracy))%)
                            """
                
                let viewModel = QuizResultsViewModel(
                                    title: "Этот раунд окончен!",
                                    text: text,
                                    buttonText: "Сыграть ещё раз")
                                show(quiz: viewModel)
            }
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            
        }
    }
}
