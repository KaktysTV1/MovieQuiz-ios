import UIKit

final class MovieQuizViewController: UIViewController {
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
    private var presenter: MovieQuizPresenter!
  
    //обращение к протоколу фабрики вопросов
    private var questionFactory: QuestionFactoryProtocol?
    
    //текущий вопрос, который видит пользователь
    private var currentQuestion: QuizQuestion?
    
    private var statisticService: StatisticService?
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadingIndicator()
        
        //обращение к фабрике вопросов
        presenter = MovieQuizPresenter(viewController: self)
        
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
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    // приватный метод, который меняет цвет рамки
    func showAnswerResult(isCorrect: Bool) {
            
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
            imageView.layer.cornerRadius = 20
            
            //отключает активность кнопок после нажатия на ответ
            self.yesButton.isEnabled = false
            self.noButton.isEnabled = false
            
        self.presenter.showAnswerResult(isCorrect: true)
        
        self.yesButton.isEnabled = true
        self.noButton.isEnabled = true
        }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса
    func show(quiz step: QuizStepViewModel) {
        imageView.contentMode = .scaleAspectFill
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
        
    }
    
    func show(quiz result: QuizResultsViewModel) {
        self.presenter.show(quiz: result)
        }
    
    
    
    //изменяет статус бар на белый
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        self.presenter.showNetworkError(message: String())
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    func showNextQuestionOrResults() {
           self.presenter.showNextQuestionOrResults()
       }
}
