## iOS 커리어 스타터 캠프

# 📂 프로젝트 매니저

### 개요

- 팀원 : 나무, 숲재
- 기간 : 22/02/28 ~ 22/03/11
- 리뷰어 : 내일날씨맑음
- 사용기술 : RxSwift

로컬과 리모트 데이터의 동기화를 지원하는 iPad ToDo 앱

### 키워드

- `RxSwift` , `RxCocoa`
- `MVVM`, `단방향 데이터 바인딩`
- `Firebase` , `Firestore`
- `SPM`
- `UserNotification`
- `UndoManager`

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

### 컨벤션
1. StyleShare Swift Style 준수
2. NameSpace로 상수 관리
3. 메서드 길이 10줄, 타입 길이 200줄 내로 구현 
4. self 키워드 명시

### 실행예시

https://user-images.githubusercontent.com/76479760/158027054-4775660a-8474-4570-8cae-998fdb7e92eb.mov

# STEP1-2

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
뷰의 TableView에서 LongPress 제스쳐 이벤트가 발생했을때, 팝오버 뷰를 해당 셀의 위치에서 띄우기 위해서 현재 해당 이벤트에서 UITableViewCell을 받도록 구현되어 있습니다. 그래서 해당 ViewModel에서 `UIKit`이 import 되어 있는데, MVVM 원칙에 위배되는게 아닌지 생각이 되었습니다. (현재 뷰 전환을 담당하는 Coordinator를 ViewModel에서 소유하고 있습니다.) 웨더라면 어떻게 설계하셨을지가 궁금합니다! 

### 4. View가 ViewModel에게 모델 Entity 타입을 사용하여 데이터를 전달해도 되는지
`MainVC`와 `MainVM` 간에, TableView의 특정 Cell에 해당하는 모델을 직접 주고받고 있습니다. 이 모델(`Schedule`)은 셀을 그리는데에는 불필요한 id, progress 와 같은 프로퍼티를 가지고 있습니다. 이런 상황에서 현재처럼 모델 Entity 타입을 사용하여 소통해도 괜찮은건지 궁금합니다.
정리하면, `Presentaion Layer`에서 뷰에 표시할 정보(e.g. tableViewCell)를 일반화한 모델 타입과 Domain 및 Data Layer에서 비즈니스 로직에 사용할 모델 타입을 별개로 만들어야 하는 것일지가 궁금합니다. 
(View를 그리는데 필요한 요소만 남기게 된다면 각 모델을 식별하는 UUID가 필요가 없어질텐데 , 이 경우에는 ViewModel에서 모델을 식별하는 방법이 없어지지 않을까요?)

### 5. RxSwift 사용 시 Optional Unwrapping을 쉽게 하는 방법?
```swift
.flatMap { Observable.from(optional: targetProgressSet.first) }
```
프로젝트에서 flatMap 오퍼레이터를 사용하여 위와 같이 옵셔널 언래핑을 진행하고 있는데요, 새로운 Observable이 create되기 때문에, 좋지 못한 방법이라는 생각되었습니다. 검색해봐도 찾지 못해 문의드립니다.

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
이를 개선하기 위해서 `filter` operator를 사용하는 등의 시도를 해 봤지만, 해결 방법을 찾지 못했습니다. 웨더라면 이 부분을 어떻게 처리하실지 조언을 부탁드립니다!

### 7. Repository와 DataSource의 역할
현재는 MemoryDataSource밖에 없는 상태라서 Repository와 DataSource의 구현이 단순한데요, 각 객체가 어떠한 역할을 하는데에 혼동이 있습니다. 저희는 아래와 같이 이해했습니다.

- DataSource는 데이터의 원천이 될 수 있는 여러 형태를 포괄하는 개념으로 DataLayer의 가장 하위 계층이다.
- Repository는 DataLayer와 DomainLayer의 중간에서 UseCase의 요청을 받아 DataSource에서 데이터를 가져오거나 업데이트 하는 역할을 담당한다. 이 객체에서 각 DataSource에서 사용하는 Entity를 Domain에서 필요한 Model Data Entity로 변환한다. 여러 DataSource를 동기화하거나 조합하는 작업도 이루어 질 수 있다.

위와 같은 이해에 틀린 점이 있을까요? ㅜ.ㅜ

### 8. 현재 Observable(Driver)과 Subject(Relay)의 사용이 적절한지
Observable과 Subject(Relay)의 사용이 적절하지 않다고 저번에 디스코드에서 말씀해주셨는데요. 이후 VM -> VC로 전달되는 `Output`을 모두 Driver나 Observer로 변경했습니다. 저희가 수정한 것이 적절한지 궁금합니다!

## 해결하지 못한 점
### 1. 메모리 누수
Xcode에서 메모리 디버깅을 진행해 본 결과, 특정 상황에서 메모리 누수가 발생하는 것을 확인했습니다. 캡쳐리스트 사용 시 약한 참조를 걸어 개선해 볼 수 있다는걸 알게 되었는데요, `subscribe` 를 하는 과정에서 self에 대한 참조가 생긴다면 모두 해당 처리를 해줘야 하는 걸까요? 다른 기준이 있는지 궁금합니다. 

### 2. Protocol을 활용한 추상화
많은 MVVM 샘플 코드를 검색해 본 결과, ViewModelProtocol과 UseCaseProtocol를 사용하여 ViewModel과 UseCase를 추상화한것을 확인 했습니다. 저희는 시간 관계상 하지 못하였는데요, 이러한 추상화의 목적이 단순히 의존성 역전을 위한 것인지가 궁금합니다!

# STEP3

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
