//
//  ScheduleDetailViewModel.swift
//  ProjectManager
//
//  Created by Lee Seung-Jae on 2022/03/09.
//

import Foundation
import RxSwift
import RxCocoa

private enum Name {
    static let scheduleTitleTextOnError = "제목을 표시할 수 없습니다."
    static let scheduleBodyTextOnError = "내용을 표시할 수 없습니다."
    static let leftBarButtonTitle = "수정"
    static let leftBarButtonTitleWhenEditing = "취소"
}

final class ScheduleItemViewModel {

    // MARK: - Nested

    enum Mode {
        case detail, edit, create
    }

    // MARK: - Properties

    private let bag = DisposeBag()
    private let scheduleUseCase: ScheduleItemUseCase
    private let scheduleHistoryUseCase: ScheduleActionRecodeUseCase
    private let coordinator: ScheduleItemCoordinator

    private let mode: BehaviorRelay<Mode>
    private let currentTitleText = BehaviorRelay<String>(value: .empty)
    private let currentDate: BehaviorRelay<Date>
    private let currentBodyText = BehaviorRelay<String>(value: .empty)

    // MARK: - Initializer

    init(
        scheduleUseCase: ScheduleItemUseCase,
        scheduleHistoryUseCase: ScheduleActionRecodeUseCase,
        coordinator: ScheduleItemCoordinator,
        mode: Mode
    ) {
        self.scheduleUseCase = scheduleUseCase
        self.coordinator = coordinator
        self.scheduleHistoryUseCase = scheduleHistoryUseCase
        self.mode = BehaviorRelay<Mode>(value: mode)
        guard let current = self.scheduleUseCase.currentSchedule.value else {
            self.currentDate = BehaviorRelay<Date>(value: Date())
            return
        }
        self.currentDate = BehaviorRelay<Date>(value: current.dueDate)
    }

    // MARK: - Input/Output

    struct Input {
        let leftBarButtonDidTap: Observable<Void>
        let rightBarButtonDidTap: Observable<Void>
        let scheduleTitleTextDidChange: Observable<String>
        let scheduleDateDidChange: Observable<Date>
        let scheduleBodyTextDidChange: Observable<String>
        let viewDidDisappear: Observable<Void>
    }

    struct Output {
        let scheduleProgress: Driver<String>
        let scheduleTitleText: Driver<String>
        let scheduleDate: Driver<Date>
        let scheduleBodyText: Driver<String>
        let leftBarButtonText: Driver<String>
        let editable: Driver<Bool>
        let isValid: Driver<Bool>
    }

    // MARK: - Methods

    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        [
            self.onLeftBarButtonDidTap(input.leftBarButtonDidTap),
            self.onRightBarButtonDidTap(input.rightBarButtonDidTap),
            self.onScheduleTitleTextDidChange(input.scheduleTitleTextDidChange),
            self.onScheduleDateDidChange(input.scheduleDateDidChange),
            self.onScheduleBodyTextDidChange(input.scheduleBodyTextDidChange),
            self.onViewDidDisappear(input.viewDidDisappear)
        ]
            .forEach { $0.disposed(by: disposeBag)}

        return self.bindOutput(disposeBag: disposeBag)
    }
}

// MARK: - Private Methods

private extension ScheduleItemViewModel {

    func dismiss() {
        self.coordinator.dismiss()
    }

    func onLeftBarButtonDidTap(_ input: Observable<Void>) -> Disposable {
        return input
            .subscribe(onNext: { [weak self] _ in
                guard let mode = self?.mode.value else { return }
                switch mode {
                case .detail:
                    self?.onLeftBarButtonDidTapWhenDetail()
                case .edit:
                    self?.dismiss()
                case .create:
                    self?.onLeftBarButtonDidTapWhenCreate()
                }
            })
    }

    func onLeftBarButtonDidTapWhenDetail() {
        self.currentTitleText.accept(self.scheduleUseCase.currentSchedule.value?.title ?? .empty)
        self.mode.accept(.edit)
    }

    func onLeftBarButtonDidTapWhenCreate() {
        guard let schedule = self.scheduleUseCase.currentSchedule.value else {
            return
        }
        self.scheduleUseCase.currentSchedule.accept(schedule)
        self.mode.accept(.detail)
    }

    func onRightBarButtonDidTap(_ input: Observable<Void>) -> Disposable {
        return input
            .subscribe(onNext: { [weak self] _ in
                guard let mode = self?.mode.value else { return }
                switch mode {
                case .detail:
                    self?.dismiss()
                case .edit:
                    self?.onRightBarButtonDidTapWhenEditMode()
                case .create:
                    self?.onRightBarButtonDidTapWhenCreateMode()
                }
            })
    }

    func onRightBarButtonDidTapWhenEditMode() {
        guard let schedule = self.scheduleUseCase.currentSchedule.value else { return }
        let newSchedule = Schedule(
            id: schedule.id,
            title: self.currentTitleText.value,
            body: self.currentBodyText.value,
            dueDate: self.currentDate.value,
            progress: schedule.progress,
            lastUpdated: Date()
        )

        self.scheduleUseCase.update(newSchedule)
        let action = ScheduleAction(
            type: .modify(newSchedule),
            execute: { self.scheduleUseCase.update(newSchedule) },
            reverse: { self.scheduleUseCase.update(schedule) }
        )
        self.scheduleHistoryUseCase.recode(action: action)
        self.coordinator.dismiss()
    }

    func onRightBarButtonDidTapWhenCreateMode() {
        let newSchedule = Schedule(
            title: self.currentTitleText.value,
            body: self.currentBodyText.value,
            dueDate: self.currentDate.value,
            progress: .todo)

        self.scheduleUseCase.create(newSchedule)
        let action = ScheduleAction(
            type: .add(newSchedule),
            execute: { self.scheduleUseCase.create(newSchedule) },
            reverse: { self.scheduleUseCase.delete(newSchedule.id) }
        )
        self.scheduleHistoryUseCase.recode(action: action)
        self.coordinator.dismiss()
    }

    func onScheduleTitleTextDidChange(_ input: Observable<String>) -> Disposable {
        return input
            .bind(to: self.currentTitleText)
    }

    func onScheduleDateDidChange(_ input: Observable<Date>) -> Disposable {
        return input
            .skip(2)
            .bind(to: self.currentDate)
    }

    func onScheduleBodyTextDidChange(_ input: Observable<String>) -> Disposable {
        return input
            .bind(to: self.currentBodyText)
    }

    func onViewDidDisappear(_ input: Observable<Void>) -> Disposable {
        return input
            .map { nil }
            .bind(to: self.scheduleUseCase.currentSchedule)
    }

    func bindOutput(disposeBag: DisposeBag) -> Output {
        return Output(
            scheduleProgress: self.scheduleProgress(),
            scheduleTitleText: self.scheduleTitleText(),
            scheduleDate: self.scheduleDate(),
            scheduleBodyText: self.scheduleBodyText(),
            leftBarButtonText: self.leftBarButtonText(),
            editable: self.editable(),
            isValid: self.isValid()
        )
    }

    func scheduleTitleText() -> Driver<String> {
        return self.scheduleUseCase.currentSchedule
            .compactMap { $0?.title }
            .asDriver(onErrorJustReturn: Name.scheduleTitleTextOnError)
    }

    func scheduleDate() -> Driver<Date> {
        return self.scheduleUseCase.currentSchedule
            .compactMap { $0?.dueDate }
            .asDriver(onErrorJustReturn: Date())
    }

    func scheduleBodyText() -> Driver<String> {
        return self.scheduleUseCase.currentSchedule
            .compactMap { $0?.body }
            .asDriver(onErrorJustReturn: Name.scheduleBodyTextOnError)
    }

    func scheduleProgress() -> Driver<String> {
        return self.scheduleUseCase.currentSchedule
            .compactMap { $0?.progress.description }
            .asDriver(onErrorJustReturn: Progress.todo.description)
    }

    func editable() -> Driver<Bool> {
        return self.mode
            .map { $0 != .detail }
            .asDriver(onErrorJustReturn: false)
    }

    func leftBarButtonText() -> Driver<String> {
        return self.mode
            .map { $0 == .detail ? Name.leftBarButtonTitle : Name.leftBarButtonTitleWhenEditing }
            .asDriver(onErrorJustReturn: Name.leftBarButtonTitleWhenEditing)
    }

    func isValid() -> Driver<Bool> {
        return Observable.combineLatest(
            self.currentTitleText.map { !$0.isEmpty },
            self.currentBodyText.map { !$0.isEmpty },
            self.mode.map { $0 == .detail },
            resultSelector: { $0 && $1 || $2 }
        )
            .asDriver(onErrorJustReturn: false)
    }
}
