//
//  ProjectManager - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit
import RxSwift
import RxCocoa

final class MainViewController: UIViewController {

// MARK: - Properties

    private let bag = DisposeBag()
    private let viewModel: MainViewModel

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 2.0
        return stackView
    }()
    private let tableViews: [UITableView]

// MARK: - Initializer

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        self.tableViews = self.viewModel.schedules.map { _ in UITableView() }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

// MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()

        self.viewModel.fetch()
    }
}

// MARK: - Private Methods

private extension MainViewController {

    func configure() {
        self.view.backgroundColor = .white
        self.title = "ProjectManager"

        self.configureSubView()
    }

    func configureSubView() {
        self.configureHierarchy()
        self.configureConstraint()
        self.configureTableView()
        self.binding()
    }

    func configureHierarchy() {
        self.view.addSubview(stackView)
        self.tableViews.forEach { tableView in
            self.stackView.addArrangedSubview(tableView)
        }
    }

    func configureConstraint() {
        let safeAreaLayoutGuide = self.view.safeAreaLayoutGuide
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            self.stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func configureTableView() {
        self.tableViews.forEach { tableView in
            tableView.register(cellWithClass: ScheduleListCell.self)
        }
    }

    func binding() {
        self.tableViewBinding()
    }

    func tableViewBinding() {
        self.tableViews.enumerated().forEach { index, tableView in
            self.setDataSource(with: index, for: tableView)
            self.setDeleteAction(for: tableView)
        }
    }

    func setDataSource(with index: Int, for tableView: UITableView) {
        self.viewModel.schedules[index]
            .drive(
                tableView.rx.items(cellIdentifier: "ScheduleListCell",
                                   cellType: ScheduleListCell.self
                                  )
            ) { _, item, cell in
                cell.configureContent(with: item)
            }
            .disposed(by: bag)
    }

    func setDeleteAction(for tableView: UITableView) {
        tableView.rx
            .modelDeleted(Schedule.self)
            .subscribe(onNext: { schedule in
                self.deleteSchedule(id: schedule.id)
            })
            .disposed(by: bag)
    }

    func deleteSchedule(id: UUID) {
        self.viewModel.delete(id: id)
    }
}
