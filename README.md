## iOS 커리어 스타터 캠프

# 📂 프로젝트 매니저

### 개요

- 팀원 : 나무, 숲재
- 기간 : 22/02/28 ~ 22/03/11
- 리뷰어 : 내일날씨맑음
- 사용기술 : `RxSwift`
- 사용 라이브러리: `Firebase`, `Realm`
로컬과 리모트 데이터의 동기화를 지원하는 iPad ToDo 앱

### 키워드

- `RxSwift` , `RxCocoa`
- `MVVM`, `단방향 데이터 바인딩`
- `Firebase` , `Firestore`
- `SPM`
- `UserNotification`
- `UndoManager`
- `Command Pattern`
- `NWPathMonitor` 
- `UIToolbar`

### 아키텍쳐
`MVVM + CleanArchitecture`

![](https://i.imgur.com/jQum7Ox.png)

- `Clean Archetecture`를 적용하여 `Presentation, Domain, Data` 로 Layer를 구분하여 설계
- `Presentation Layer`에서는 View와 Presentation 로직을 분리하여 `MVVM` 패턴을 적용
- ViewModel은 View의 UI 이벤트를 받아 해당하는 `UseCase`를 사용
- MVVM 패턴에 맞게 단방향 데이터 바인딩을 수월하게 해 주는 `RxCocoa, RxSwift`를 사용
- `Repository Pattern`을 적용하여 `Domain Layer`로부터 `Data Layer`를 분리 
- 추후 여러가지 `DataSource`에 대응할 수 있도록 `DataSource`를 추상화 (현재 MemoryDataSource만 구현, 추후 FireBaseDataSource 구현 예정)
- 화면 전환 및 의존성 주입을 담당하는 `Coordinator` 설계

### 구현 상세

- Firebase Firestore를 사용하여 Remote Server 구축
    - 해당 프레임워크와 직접 소통하는 `FirestoreService` 타입 구현 및 추상화
- Realm을 사용하여 Local DB 구축
    - 해당 프레임워크와 직접 소통하는 `RealmService` 타입 구현 및 추상화
- 네트워크 상태에 따라 Remote-Local 동기화 기능 구현
- 앱의 네트워크 연결상태 변화를 감지하는 기능 구현
    - 네트워크가 연결되지 않은 상태에서는 Toolbar에 점멸하는 적색 아이콘 표시
- 변경내역(History) 관리를 위한 Entity인 ScheduleAction 타입 구현
- 변경내역 관리를 위한 별도의 Repository와 Usecase 구현
- Toolbar의 Undo, Redo버튼으로 변경내용을 되돌리거나 다시 실행 가능하도록 구현
    - Undo로 되돌린 사항은 History에 보이지 않도록 구현
- 할일 요소의 수정,삭제,변경에 대한 내용을 PopoverView로 확인할 수 있도록 구현
    - 아무 변경사항이 없을 시 별도의 Label을 표시하도록 구현

### 실행예시

https://user-images.githubusercontent.com/76479760/159509182-06903ed2-bd0f-4ced-9b32-db80f7d051ec.mov

## STEP 1 - ****적용기술 선정****

### 뷰 바인딩
→ RxCocoa + MVVM

### 로컬과 리모트의 데이터 동기화 및 로컬 데이터 저장 
→ Firebase(Firestore)

리모트 데이터를 업로드하기 위해 Firestore를 사용하기로 했으며, Firestore의 오프라인 저장 기능으로 로컬 저장까지 통합하여 구현하기로 했습니다.  
[오프라인으로 데이터에 액세스 | Firebase Documentation](https://firebase.google.com/docs/firestore/manage-data/enable-offline?hl=ko#configure_cache_size)

- 하위 버전 호환성에는 문제가 없는가?
    Firebase 7.4 버전에서는 ios 10부터 지원한다고 합니다. 프로젝트의 minimum target을 ios 13으로 잡았기 때문에, 문제 없다고 판단됩니다.
- 안정적으로 운용 가능한가?
    로컬 및 리모트 데이터 운용을 동일 프레임워크에서 담당하므로, 호환성 측면이나 예측하지 못한 에러 등에서 좀 더 자유로울 수 있다고 생각했습니다.
- 미래 지속가능성이 있는가?
    Google의 서비스이고, 이미 수많은 앱 개발자들이 사용하고 있는 라이브러리이므로 지속가능성 측면에서는 우려가 없다고 판단됩니다.
- 리스크를 최소화 할 수 있는가? 알고있는 리스크는 무엇인가?
    Firebase의 서버가 해외에 있기에 속도 측면에서 리스크가 있으며 일정 용량을 초과하면 유료 과금이 되지만,
자료에 영상, 이미지 등 고용량의 데이터가 들어가지 않는다는 특성 상 Firebase의 용량 제한 및 속도 이슈에서도 어느정도 자유로울 수 있다고 기대합니다.   
Firebase가 지원하는 국가에도 제한이 있습니다. 과거보다 서비스 지역이 늘어나고 있는 상황이지만, 여전히 미지원 국가가 있으므로 리스크가 될 것 같습니다. 
[프로젝트의 위치 선택 | Firebase Documentation](https://firebase.google.com/docs/projects/locations)
    
- 어떤 의존성 관리도구를 사용하여 관리할 수 있는가?
    Firebase는 CocoaPods, 카르타고, SPM을 모두 지원합니다. 저희는 SPM을 선택했습니다.
    
- 이 앱의 요구기능에 적절한 선택인가?
    로컬과 리모트의 데이터의 경합을 어떻게 처리할지에 주안점을 두었습니다. FireStore는 로컬과 리모트의 데이터 변경사항을 추적하고 처리하는데 용이한 기능을 제공합니다.

# STEP 2 & 3

## 고민한 점

### 1. ViewModel의 Input/Output 
View에서 수신하는 Input과 View에서 바인딩을 하게되는 Output을 ViewModel의 Nested Type으로 구현하였습니다. Input과 Output의 프로퍼티들은 모두 Observable로 설계했습니다. `ViewdidLoad` 시점에 View(VC)는 ViewModel에 Input을 전달하고, Output을 받아 바인딩을 진행합니다.

### 2. TableView와 ViewModel
3개의 리스트 형태의 화면을 구현하기 위해 하나의 스택뷰 내부에 3개의 테이블 뷰를 넣어서 구현하였습니다. 각 테이블 뷰의 DataSource로 활용하기 위해 ViewModel에서 3개의 `Driver<Schedule>` 타입을 가지고 있습니다. ViewModel이 UseCase를 사용하여 DataSource로부터 데이터를 가져오고 해당 데이터를 가공하여 3개의 Observable로 만들어내는 역할을 하고 있습니다. 

## 궁금한 점

### 1. Model은 어떤 객체가 소유하고 있어야 하는지
(MVVM + Clean 구조에서) 한 번 fetch해 온 데이터(모델)을 뷰에 표현하기 위해 가공하거나 사용하기 위해서 누군가는 데이터를 소유할 필요가 있었습니다. 이 데이터를 뷰모델이 소유하는 것이 맞는지, 혹은 `UseCase`가 소유하는 것이 맞는지 궁금합니다.
현재 저희는 `ScheduleUseCase`에서 `BehaviorRelay`로 `schedules`와  `currentSchedule`을 소유하여 이것을 각 뷰모델이 사용하고 있습니다. 

### 2. UseCase의 주입과 역할
usecase는 어디서 주입해야하는지, 서로 다른 뷰모델이 하나의 usecase를 공유해도 되는지, usecase를 공유한다면 어떤 방법으로 해야하는지, usecase가 observable프로퍼티를 가져도 되는지 궁금합니다.

### 3. 특정 이벤트 상황에서 뷰모델에 ViewComponent를 전달해도 될까요? (Popover의 sourceView)
뷰의 TableView에서 LongPress 제스쳐 이벤트가 발생했을때, 팝오버 뷰를 해당 셀의 위치에서 띄우기 위해서 현재 해당 이벤트에서 UITableViewCell을 받도록 구현되어 있습니다. 그래서 해당 ViewModel에서 `UIKit`이 import 되어 있는데, MVVM 원칙에 위배되는게 아닌지 생각이 되었습니다. (현재 뷰 전환을 담당하는 Coordinator를 ViewModel에서 소유하고 있습니다.)

### 4. View가 ViewModel에게 모델 Entity 타입을 사용하여 데이터를 전달해도 되는지
`MainVC`와 `MainVM` 간에, TableView의 특정 Cell에 해당하는 모델을 직접 주고받고 있습니다. 이 모델(`Schedule`)은 셀을 그리는데에는 불필요한 id, progress 와 같은 프로퍼티를 가지고 있습니다. 이런 상황에서 현재처럼 모델 Entity 타입을 사용하여 소통해도 괜찮은건지 궁금합니다.
정리하면, `Presentaion Layer`에서 뷰에 표시할 정보(e.g. tableViewCell)를 일반화한 모델 타입과 Domain 및 Data Layer에서 비즈니스 로직에 사용할 모델 타입을 별개로 만들어야 하는 것일지가 궁금합니다. 
(View를 그리는데 필요한 요소만 남기게 된다면 각 모델을 식별하는 UUID가 필요가 없어질텐데 , 이 경우에는 ViewModel에서 모델을 식별하는 방법이 없어지지 않을까요?)

### 5. RxSwift 사용 시 Optional Unwrapping을 쉽게 하는 방법?
```swift
.flatMap { Observable.from(optional: targetProgressSet.first) }
```
프로젝트에서 flatMap 오퍼레이터를 사용하여 위와 같이 옵셔널 언래핑을 진행하고 있는데요, 새로운 Observable이 create되기 때문에, 좋지 못한 방법이라는 생각되었습니다. 

### 6. `ScheduleItemViewModel`에서 Mode에 따른 로직이 복잡해지는 문제
현재 모달로 띄워지는 `ScheduleItemView`가 상세보기/수정/생성 모드 별로 다르게 동작해야 하는 상황입니다. 이를 위해 enum Mode를 정의하여 이에 따라 사용자 이벤트를 다르게 처리하도록 하고 있는데요. 그로 인해 다음과 같이 switch문을 사용해야 하며 Operator 사용이 제한되는 등의 불편함이 생겼습니다.
```swift
func onLeftBarButtonDidTap(_ input: Observable<Void>) -> Disposable {
        return input
            .subscribe(onNext: { _ in
                switch self.mode.value {
                case .detail:
                    self.onLeftBarButtonDidTapWhenDetail()
                case .edit:
                    self.dismiss()
                case .create:
                    self.onLeftBarButtonDidTapWhenCreate()
                }
            })
    }

```
이를 개선하기 위해서 `filter` operator를 사용하는 등의 시도를 해 봤지만, 해결 방법을 찾지 못했습니다. 

### 7. Repository와 DataSource의 역할
현재는 MemoryDataSource밖에 없는 상태라서 Repository와 DataSource의 구현이 단순한데요, 각 객체가 어떠한 역할을 하는데에 혼동이 있습니다. 저희는 아래와 같이 이해했습니다.

- DataSource는 데이터의 원천이 될 수 있는 여러 형태를 포괄하는 개념으로 DataLayer의 가장 하위 계층이다.
- Repository는 DataLayer와 DomainLayer의 중간에서 UseCase의 요청을 받아 DataSource에서 데이터를 가져오거나 업데이트 하는 역할을 담당한다. 이 객체에서 각 DataSource에서 사용하는 Entity를 Domain에서 필요한 Model Data Entity로 변환한다. 여러 DataSource를 동기화하거나 조합하는 작업도 이루어 질 수 있다.

### 8. 현재 Observable(Driver)과 Subject(Relay)의 사용이 적절한지
Observable과 Subject(Relay)의 사용이 적절하지 않다고 저번에 디스코드에서 말씀해주셨는데요. 이후 VM -> VC로 전달되는 `Output`을 모두 Driver나 Observer로 변경했습니다. 저희가 수정한 것이 적절한지 궁금합니다!

## 해결하지 못한 점
### 1. 메모리 누수
Xcode에서 메모리 디버깅을 진행해 본 결과, 특정 상황에서 메모리 누수가 발생하는 것을 확인했습니다. 캡쳐리스트 사용 시 약한 참조를 걸어 개선해 볼 수 있다는걸 알게 되었는데요, `subscribe` 를 하는 과정에서 self에 대한 참조가 생긴다면 모두 해당 처리를 해줘야 하는 걸까요? 다른 기준이 있는지 궁금합니다. 

### 2. Protocol을 활용한 추상화
많은 MVVM 샘플 코드를 검색해 본 결과, ViewModelProtocol과 UseCaseProtocol를 사용하여 ViewModel과 UseCase를 추상화한것을 확인 했습니다. 저희는 시간 관계상 하지 못하였는데요, 이러한 추상화의 목적이 단순히 의존성 역전을 위한 것인지가 궁금합니다!

# Step 4

## 고민한 점

### 1. History관리를 위한 신규 Repository와 Usecase의 생성
ViewModel은 기존과 같이 Main과 Modal VC를 위한 2개를 유지하되, `ScheduleHistoryRepository`와 `ScheduleHistoryUsecase`를 추가로 구현했습니다. 하나의 Repository는 하나의 Model Entity만을 담당해야 된다고 생각해서 별도의 `Repository`를 구현했습니다. 또, 하나의 Usecase가 여러 Repository를 사용해도 된다고 생각했지만, 변경내역 관리라는 성격이 다른 목적을 갖고 있기에 담당하는 Usecase를 추가로 구현했습니다.

### 2. 네트워크 연결상태 감지 방법
네트워크 연결상태 감지를 위해 `Network` 프레임워크의 `NWPathMonitor` 클래스를 사용했습니다.
해당 클래스를 사용해 `NetWorkChecker` 커스텀 클래스를 싱글턴패턴으로 구현하여, 변경되는 네트워크 상태를 `Observable<Bool>` 타입으로 emit하도록 설계했습니다. 네트워크 감지가 필요한 객체에서 싱글턴으로 접근해 `Subscribe` 할수 있도록 의도하였습니다. `NetWorkChecker`는 어느 계층에도 속하기 애매하다고 생각해 Utility폴더에 넣었습니다.

### 3. 동기화를 담당하는 계층 및 Local - Remote 간 동기화 정책
가장 고민이 많았던 게 동기화를 어느 부분에서 해줘야 할지를 고민했습니다. Domain Layer에서는 해당 동기화가 구체적으로 어떤방식으로 진행되는지 알 필요가 없다고 생각하고, 네트워크 상태를 감시하여 적절한 시점에 재 요청만 하는것으로 결정하였습니다. 따라서`Data` 계층의 `ScheduleRepository`가 `NetworkService` 및 `LocalDatabaseService`를 프로퍼티로 갖고 있으며, 동기화 작업도 수행합니다.

동기화 정책은 아래와 같습니다.
1. **네트워크 연결이 유지되는 상황**
네트워크가 유지된 상태에서는 Remote의 데이터를 기반으로 Domain의 요청에 대응하되, Remote와 Local의 생성,변경,삭제가 동시에 이루어지도록 하여 갑작스러운 네트워크 종료상태에 대응할 수 있도록 하였습니다. 
2. **네트워크가 끊어진 후 재 연결되는 상황**
Local의 변경사항과 Remote서버를 비교하여 Local을 기준으로 한 최신 변경사항을 추려내어 Remote에 반영되도록 만들었습니다. 
```swift
// DefaultScheduleRepository.swift
    func syncronize() -> Completable {
        return Single.zip(
            self.localDataSource.fetch(),
            self.remoteDataSource.fetch()
        ).map { local, remote -> Completable in // 각 데이터 소스에서 fetch해온 내용을 Completable로 변환
        // 집합연산을 사용한 변경내용 추리기 
            let localIDSet = Set(local.map { $0.id })
            let remoteIDSet = Set(remote.map { $0.id })
            let differenceFromLocalIDToRemoteID = localIDSet.subtracting(remoteIDSet)
            let differenceFromLocalToRemote = local
                .filter { differenceFromLocalIDToRemoteID.contains($0.id) }
       // remote에 새로 생성해줘야 하는 요소를 위한 create메서드 사용 및 Completable로 변환
            let remoteCreatesCompletable = Completable.zip(differenceFromLocalToRemote.map {
                self.remoteDataSource.create($0)
            })
            let differenceFromRemoteToLocal = remoteIDSet.subtracting(localIDSet)
    // remote에서 삭제해줘야 하는 요소를 위한 create메서드 사용 및 Completable로 변환
            let remoteDeletesCompletable = Completable.zip(differenceFromRemoteToLocal.map {
                self.remoteDataSource.delete($0)
            })

            let idIntersection = localIDSet.intersection(remoteIDSet)
            let localIntersection = local.filter { idIntersection.contains($0.id) }
            let remoteIntersection = remote.filter { idIntersection.contains($0.id)}

    // remote에서 수정해줘야 하는 요소를 위한 create메서드 사용 및 Completable로 변환
            let remoteUpdatesCompletable = Completable.zip(
                remoteIntersection.flatMap { remoteSchedule in
                    localIntersection.filter { localSchedule in
                        localSchedule.id == remoteSchedule.id &&
                        localSchedule.lastUpdated > remoteSchedule.lastUpdated
                    }.map { self.remoteDataSource.update($0) }
                }
            )
   // 위의 모든 작업들을 한번더 zip으로 묶어서 반환
            return Completable.zip(
                remoteCreatesCompletable,
                remoteDeletesCompletable,
                remoteUpdatesCompletable
            )
        }.flatMapCompletable { $0 }
    }

```
다만 현재의 구현으로는, 다른 기기에서 Remote의 변경사항을 야기하여 그 수정사항이 반영될 필요가 있을 경우에는 문제가 됩니다. 따라서 추후 개선사항으로 Local과 Remote에서 각각 별도로 변경에 대한 로그를 기록해 두어 이 로그를 기반으로 동기화를 진행한다면 이러한 문제를 해소할 수 있을 것으로 생각하고있습니다

### 4. 데이터 변경에 따른 View의 변경을 어떻게 반영할 것인지
View에서 이벤트가 발생하여 DataSource의 모델이 수정된다면 어떤방법으로 View에 반영할지 고민했습니다. Firebase와 Realm의 CRUD는 모두 비동기적으로 작동하기 때문에, 매번 그러한 변경사항이 생길 때마다 데이터 소스에서 데이터 전부를 Fetch 해 오기에는 부담이 크다고 생각되었습니다. 그래서 View쪽에서 Event가 발생하면 ViewModel이 그 이벤트에 해당하는 UseCase 인터페이스를 사용하고, Domain 계층에서는 Data계층에 그 작업을 요청하여 해당 작업의 성공여부를 `Single`로 되돌려받아 View를 업데이트 해주는 것으로 결정하였습니다. 

다만 현재 `Usecase`에서 `BehaviorRelay<[Schedule]>`를 가지고 있는데, Usecase에 `BehaviorRelay`가 있는것이 어색하게 느껴집니다. 스텝4에서는 `Repository`가 `BehaviorRelay`를 소유하는 것으로 변경하고, `Usecase`쪽으로는 `Observable`로 넘겨줘서 ViewModel이 바인딩을 할 수 있도록 하는 방향으로 변경해보려 합니다.

### 5. `Undomanager`와 `Command Pattern`의 사용
히스토리 관리를 위해 Undomanager와 Command Pattern을 활용하였습니다. 클로저를 저장할 수 있는 `ScheduleAction` 타입을 구현하고 `ScheduleHistoryRepository`에서 해당 타입의 배열의 BehaviorRelay를 소유하고 있습니다.

## 궁금한 점

### 1. Property 변화를 감지하는 방법
`UndoManager`클래스는 현재 Undo와 Redo가 가능한지 확인할 수 있는 `canUndo` 및 `canRedo` Bool 타입 프로퍼티를 가지고 있습니다. 이를 활용해서 해당 프로퍼티가 변경될때마다 자동으로 그 변경사항을 emit하도록 설계하고 싶었는데요, 방법을 찾지 못해 현재는 아래와 같이 구현한 상태입니다.
```swift
private let undoManager = UndoManager()
private var historyCanUndo = BehaviorRelay<Bool>(value: false)

// 현재는 undo 이벤트가 발생할 때마다 변경된 canUndo 값을 BehaviorRelay에 accept하도록 구현
func undo() {
    guard self.canUndo else { return }
    self.undoManager.undo()
    ...
    self.historyCanUndo.accept(canUndo)
    ...
}

```
다른 좋은 방법이 있을까요? Rx Extension을 활용하면 가능할까요?

### 2. 참조타입의 emit
현재 ScheduleAction 클래스로 변경에 대한 히스토리를 저장하고 있습니다. 어떤 작업을 실행하고 Undo를 했을때, 그 작업은 히스토리 뷰에서 보이지 않게 되어야 한다고 생각했습니다. 그래서 Undo가 실행될때 사용될 클로저에서 ScheduleAction의 isUndone 프로퍼티를 true로 변경해주고, 히스토리 뷰에서는 isUndone이 false인 요소들만 보여주도록 구현하였습니다. ScheduleAction이 참조타입이라서BehaviorRelay내부의 action은 변경이 잘되지만, 추가로 history BehaviorRelay 현재 값을 accept해주어야 해당 변경사항까지 반영되어 emmit되는 것을 확인할 수 있었습니다. 그래서 아래와 같은 다소 이상한 모양이 되었는데요, 이런 경우에 사용할 수 있는 오퍼레이터나 메서드가 있을까요?
    
```swift
private var history = BehaviorRelay<[ScheduleAction]>(value: [])
func undo() {
    ...
    //현재 history의 value값을 그대로 accept
    self.history.accept(self.history.value)
    ...
}
private func registerUndoFor(action: ScheduleAction) {
    self.undoManager.registerUndo(withTarget: self) { target in
        action.isUndone = true
        ...
    }
}
```
    
### 3. 하나의 Output에서 변형하여 여러 요소에 바인딩을 할수 있나요?
아래와 같이 하나의 Observable을 사용해서 두번의 바인딩을 진행하고 있는데, 어떻게 합칠 수 있을까요?
```swift
// scheduleHistory 는 Observable<[ScheduleAction]> 타입입니다.
output.scheduleHistory
    .asDriver(onErrorJustReturn: [])
    .do(onNext: { _ in self.presentHistoryPopover() })
    .drive(self.historyPopoverView.tableView.rx.items(
        cellIdentifier: String(describing: HistoryListCell.self),
        cellType: HistoryListCell.self
    )) { _, item, cell in
        cell.configureContent(with: item)
    }
    .disposed(by: self.bag)

output.scheduleHistory
    .map { $0.count != 0 }
    .asDriver(onErrorJustReturn: false)
    .drive(self.historyPopoverView.statusLabel.rx.isHidden)
    .disposed(by: self.bag)
```

### 4. 뷰컨트롤러가 소유한 뷰의 하위뷰에 바인딩을 하는 법
위 질문과 이어지는 질문입니다. `drive`메서드에서 아래와 같이 소유하고있는 뷰의 하위뷰에 접근해서 직접 바인딩을 해주고 있는데 이러한 방식이 옳은것일까요? 
```
.drive(self.historyPopoverView.statusLabel.rx.isHidden)
```

### 5. DTO의 사용
MVVM과 클린아키텍쳐에 대해 공부하다보니, `DTO(data transfer object)` 에 대해서 알게되었습니다. Data계층에서 각각의 라이브러리나 프레임워크에 따라 별도의 Data Entity를 필요로 하기에 해당 Entity를 Domain에서 사용하는 Entity로 변환시키거나 반대의 상황에 사용할 수 있는 객체라고 이해했습니다. 현재는 `Schedule`의 private extension을 활용하여 Data Entity로 변환할 수 있는 메서드와 Domain Entity로 변환할 수 있는 실패가능한 이니셜라이져를 활용했습니다. DTO를 만드는데 어떤 이점이 있는 걸까요? 
