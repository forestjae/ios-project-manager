//
//  ProjectManager - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {

    private let viewModel: MainViewModel
    private let bag = DisposeBag()
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 2.0
        return stackView
    }()
    private let tableViews = Array(repeating: UITableView(), count: 3)

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()

        self.viewModel.fetch()
    }

    private func configure() {
        self.view.backgroundColor = .white
        self.title = "ProjectManager"

        self.configureSubView()
        self.configureConstraint()
    }

    private func configureSubView() {
//        self.configureHierarchy()
        self.view.addSubview(stackView)
        self.tableViews.forEach { tableView in
            self.stackView.addArrangedSubview(tableView)
        }
        self.configureTableView()
        self.binding()
    }

//    private func configureHierarchy() {
//
//    }

    private func configureConstraint() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.stackView.leadingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.leadingAnchor
            ),
            self.stackView.trailingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.trailingAnchor
            ),
            self.stackView.topAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.topAnchor
            ),
            self.stackView.bottomAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.bottomAnchor
            )
        ])
    }

    private func configureTableView() {
        self.tableViews.forEach { tableView in
            tableView.register(cellWithClass: ScheduleListCell.self)
        }
    }

    private func binding() {
        self.tableViewBinding()
    }

    private func tableViewBinding() {
        
        self.tableViews.enumerated().forEach { index, tableView in
            self.viewModel.schedules

            .drive(
                tableView.rx.items(
                    cellIdentifier: "ScheduleListCell",
                    cellType: ScheduleListCell.self
                )
            ) { _, item, cell in
                cell.titleLabel.text = item.title
                cell.bodyLabel.text = item.body
                cell.dateLabel.text = item.formattedDateString
            }
            .disposed(by: bag)

            tableView.rx
                .itemDeleted
                .subscribe(onNext: { indexPath in
                    self.deleteRow(at: indexPath)
                })
                .disposed(by: bag)
        }
    }

    private func deleteRow(at indexPath: IndexPath) {
        self.viewModel.delete(at: indexPath)
    }
}