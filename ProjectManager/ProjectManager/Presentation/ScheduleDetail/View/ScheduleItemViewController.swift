//
//  ScheduleDetailView.swift
//  ProjectManager
//
//  Created by Jae-hoon Sim on 2022/03/09.
//

import UIKit
import RxSwift
import RxCocoa

class ScheduleItemViewController: UIViewController {

    var viewModel: ScheduleItemViewModel?
    private let bag = DisposeBag()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 5
        return stackView
    }()

    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Title"
        textField.shadow()
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always

        return textField
    }()

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300))
        datePicker.datePickerMode = .date
        if #available(iOS 13.5, *) {
            datePicker.preferredDatePickerStyle = .wheels
            }
        return datePicker
    }()

    private let bodyTextView: UITextView = {
        let textView = UITextView()
        textView.layer.masksToBounds = false
        textView.shadow()

        return textView
    }()

    private let rightBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem()
        barButtonItem.title = "완료"
        return barButtonItem
    }()

    private let leftBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem()
        barButtonItem.title = "취소"
        return barButtonItem
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

private extension ScheduleItemViewController {
    func configure() {
        self.view.backgroundColor = .white
        configureHierarchy()
        configureConstraint()
        configureNavigationBar()
        binding()
    }

    func configureHierarchy() {
        self.view.addSubview(stackView)
        self.stackView.addArrangedSubview(titleTextField)
        self.stackView.addArrangedSubview(datePicker)
        self.stackView.addArrangedSubview(bodyTextView)
    }

    func configureConstraint() {
        let safeAreaLayoutGuide = self.view.safeAreaLayoutGuide
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.bodyTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
            self.stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
            self.stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 4),
            self.stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            self.titleTextField.heightAnchor.constraint(
                equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.08
            ),
            self.bodyTextView.heightAnchor.constraint(
                equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.55
            )
        ])
    }

    func configureNavigationBar() {
        self.title = "TODO"
        self.navigationItem.rightBarButtonItem = rightBarButton
        self.navigationItem.leftBarButtonItem = leftBarButton
    }

    func binding() {
        let input = ScheduleItemViewModel.Input(
            leftBarButtonDidTap: self.leftBarButton.rx.tap.asObservable(),
            rightBarButtonDidTap: self.rightBarButton.rx.tap.asObservable(),
            scheduleTitleTextDidChange: self.titleTextField.rx.text.orEmpty.asObservable(),
            scheduleDateDidChange: self.datePicker.rx.date.asObservable(),
            scheduleBodyTextDidChange: self.bodyTextView.rx.text.orEmpty.asObservable()
        )

        guard let output = self.viewModel?.transform(input: input, disposeBag: self.bag) else {
            return
        }

        output.scheduleProgress.asDriver()
            .drive(self.rx.title)
            .disposed(by: bag)
        output.scheduleTitleText.asDriver()
            .drive(self.titleTextField.rx.text)
            .disposed(by: bag)
        output.scheduleDate.asDriver()
            .drive(self.datePicker.rx.date)
            .disposed(by: bag)
        output.scheduleBodyText.asDriver()
            .drive(self.bodyTextView.rx.text)
            .disposed(by: bag)
        output.leftBarButtonText.asDriver()
            .drive(self.leftBarButton.rx.title)
            .disposed(by: bag)
        output.rightBarButtonText.asDriver()
            .drive(self.rightBarButton.rx.title)
            .disposed(by: bag)
        output.editable.asDriver()
            .drive(self.titleTextField.rx.isEnabled,
                   self.datePicker.rx.isEnabled,
                   self.bodyTextView.rx.isEditable)
            .disposed(by: bag)
    }
}

extension UIView {
    func shadow() {
        self.backgroundColor = .white
        self.layer.borderColor = UIColor.systemGray4.cgColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 1

        self.layer.shadowColor = UIColor.systemGray.cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 2
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
    }
}