//
//  SearchPlaceViewController.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 8. 31..
//  Copyright © 2018년 박정규. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Speech
import AVFoundation
import RealmSwift
import CoreLocation

//***************************************************************************************
// ViewController 라이프사이클
// 레이아웃 설정(height, marginTop)
// Place 테이블, Search Place History 테이블
// 상단바
// 음성검색
// 장소 검색 api
// Search Type에 따른 레이아웃 생성
//***************************************************************************************
class SearchPlaceViewController: UIViewController, UITextFieldDelegate,   SFSpeechRecognizerDelegate,  TapPlaceTableViewDelegate, TapSearchPlaceHistoryTableViewDelegate{
    
    
    
    //***************************************************************************************
    //
    // ViewController 라이프사이클
    //
    //***************************************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initLayout()
        
        
        initAlamofireManager()
        
        initSearchKeywordInput()
                
        
        initTableDelegateAndDataSource()
        
        initPlaceTable()
        
        initSearchPlaceHistoryTable()
        
        initSpeechRecognizer()
        
        initViewControllerLifecycleObserver()
        
        createLayout()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
    }
    
    // Gets triggered when you leave the ViewController.
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        loseAudioFocus()
        stopRecording()
    }
    
    @objc func appResumed() {
        print("App resumed")
    }
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
        loseAudioFocus()
        stopRecording()
    }
    
    private func initViewControllerLifecycleObserver() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appResumed), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    
    //***************************************************************************************
    //
    // 레이아웃 설정
    //
    //***************************************************************************************
    
    @IBOutlet weak var yourLocationSectionHeight: NSLayoutConstraint!
    @IBOutlet weak var chooseOnMapSectionHeight: NSLayoutConstraint!
    @IBOutlet weak var deleteButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var sortButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var voiceSearchButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var sectionSeperatorHeight: NSLayoutConstraint!
    @IBOutlet weak var deleteButtonTrailing: NSLayoutConstraint!
    
    func initLayout() {
        let screenWidth = UIScreen.main.bounds.width
        let topSearchBarBackgroundImg = ImageMaker.getRoundRectangleWithoutFill(width: screenWidth - 18, height: 55, lineWidth: 1, colorHexString: "#dadce0", cornerRadius: 6.0)
        topSearchBar.backgroundColor = UIColor(patternImage: topSearchBarBackgroundImg)
    }
    
    //***************************************************************************************
    //
    // Place 테이블, Search Place History 테이블
    //
    //***************************************************************************************
    @IBOutlet weak var placeTable: UITableView!
    @IBOutlet weak var searchPlaceHistoryTable: UITableView!
    var placeModels = [PlaceModel]()
    weak var selectPlaceDelegate: SelectPlaceDelegate?
    var searchPlaceHistoryDatas: Results<PlaceVO>?
    
    var searchPlaceTableViewDataSource: SearchPlaceTableViewDataSource?
    var searchPlaceTableViewDelegate: SearchPlaceTableViewDelegate?
    
    
    func onPlaceTableViewTapped(row: Int) {
        if let delegate = self.selectPlaceDelegate {
            delegate.onPlaceSelected(placeModel: placeModels[row], searchType: Mn4pSharedDataStore.searchType ?? SearchPlaceViewController.PLACE)
        }
        self.dismiss(animated: true)
    }
    
    func onSearchPlaceHistoryTableViewTapped(row: Int) {
        //TODO 제대로 작동하는지 확인하세요
        if let delegate = self.selectPlaceDelegate {
            let reversedIndex = (searchPlaceHistoryDatas?.count ?? 0) - 1 - row
            
            let placeModel = PlaceModel()
            placeModel.setName(name: searchPlaceHistoryDatas?[reversedIndex].name ?? "")
            placeModel.setLatitude(latitude: searchPlaceHistoryDatas?[reversedIndex].latitude ?? 0)
            placeModel.setLongitude(longitude: searchPlaceHistoryDatas?[reversedIndex].longitude ?? 0)
            placeModel.setAddress(address: searchPlaceHistoryDatas?[reversedIndex].address ?? "")
            placeModel.setBizname(bizName: searchPlaceHistoryDatas?[reversedIndex].bizName ?? "")
            placeModel.setDistance(distance: searchPlaceHistoryDatas?[reversedIndex].distance ?? 0)
            placeModel.setTelNo(telNo: searchPlaceHistoryDatas?[reversedIndex].telNo ?? "")
            
     
            
            delegate.onPlaceSelected(placeModel: placeModel, searchType: Mn4pSharedDataStore.searchType ?? SearchPlaceViewController.PLACE)
        }
        self.dismiss(animated: true)
    }
    private func initTableDelegateAndDataSource() {
      
        self.searchPlaceTableViewDelegate = SearchPlaceTableViewDelegate(placeTable: placeTable, searchPlaceHistoryTable: searchPlaceHistoryTable, tapPlaceTableViewDelegate: self, tapSearchPlaceHistoryTableViewDelegate: self)
        self.searchPlaceTableViewDataSource = SearchPlaceTableViewDataSource(placeTable: placeTable, searchPlaceHistoryTable: searchPlaceHistoryTable, placeData: [], searchPlaceHistoryData: nil)
        
    }
    
    
    
    private func initPlaceTable() {
        
        
        self.placeTable.register(PlaceTableCell.self, forCellReuseIdentifier: "placeTableCell")
        self.placeTable.delegate = self.searchPlaceTableViewDelegate
        self.placeTable.dataSource = self.searchPlaceTableViewDataSource
        self.placeTable.rowHeight = 60
        
        //hidden으로 지정하지 않았는데 TableView가 안보여서 isHidden을 false로 지정하니 보임
        //Swift 버그인가?
        self.placeTable.isHidden = true
        
    }
    
    private func initSearchPlaceHistoryTable() {
        //TableView의 dataSource는 2개 지정할 수 없는 듯
        //두 번째 지정하는 것이 첫 번째 지정한 것을 무효화하는 듯 
        
        self.searchPlaceHistoryTable.register(SearchPlaceHistoryTableCell.self, forCellReuseIdentifier: "searchPlaceHistoryTableCell")
        self.searchPlaceHistoryTable.delegate = self.searchPlaceTableViewDelegate
        self.searchPlaceHistoryTable.dataSource = self.searchPlaceTableViewDataSource
        self.searchPlaceHistoryTable.rowHeight = 60
        
        self.searchPlaceHistoryTable.isHidden = false
        
    }
    
    private func showSearchPlaceHistoryTable() {
        
        
        searchPlaceHistoryDatas = RealmManager.sharedInstance.getSearchPlaceHistory()
        
        if (searchPlaceHistoryDatas?.count == 0) {
            return
        }
         
        self.searchPlaceTableViewDataSource?.searchPlaceHistoryData = searchPlaceHistoryDatas
        self.searchPlaceHistoryTable.reloadData()
     }
    
    
    
    //***************************************************************************************
    //
    // 상단바
    //
    //***************************************************************************************
    @IBOutlet weak var searchKeywordInput: UITextField!
    @IBOutlet weak var topSearchBar: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var voiceSearchButton: UIButton!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //키보드 내림
        //textField.resignFirstResponder()
        //여기에 키보드의 엔터키를 눌렀을 때 처리할 작업 명시
        
        //검색어가 nil일 경우 처리
        if let searchKeyword = searchKeywordInput.text {
            searchPlace(searchKeyword: searchKeyword)
        }
        return true
    }
    
    @IBAction func onBackTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onDeleteButtonTapped(_ sender: Any) {
        searchKeywordInput.text = ""
        placeModels.removeAll()
        placeTable.reloadData()
        
        hideDeleteButton()
        hideSortButton()
        showVoiceSearchButton()
        
    }
    
    
    @IBAction func onSortButtonTapped(_ sender: Any) {
        hideSortButton()
        putDeleteButtonToRightOfSuperView()
        sortTableByDistance()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        print("typed text: " + (textField.text!))
        //resignFirstResponder: 키보드 내려가게 하는 기능
        //textField.resignFirstResponder()
        if let searchKeyword = searchKeywordInput.text {
            print("typed text2: " + (textField.text!))
            
            if (!searchKeyword.isEmpty) {
                showDeleteButton()
                hideVoiceSearchButton()
                searchPlace(searchKeyword: searchKeyword)
            } else {
                hideDeleteButton()
                showVoiceSearchButton()
            }
            
        }
    }
    
    private func sortTableByDistance() {
        print("sortTable")
        //거리순 정렬
        self.placeModels.sort { $0.getDistance() ?? 0 < $1.getDistance() ?? 0 }
        self.placeTable.reloadData()
        
    }
    
    private func hideSortButton() {
        sortButtonWidth.constant = 0
        sortButton.isHidden = true
    }
    
    private func initSearchKeywordInput() {
        searchKeywordInput.delegate = self
        //키보드 표시
        //시뮬레이터에서는 작동하지 않음
        searchKeywordInput.becomeFirstResponder()
        searchKeywordInput.addTarget(self, action: #selector(SearchPlaceViewController.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    private func showDeleteButton() {
        deleteButtonWidth.constant = 40
        deleteButton.isHidden = false
    }
    
    private func hideVoiceSearchButton() {
        voiceSearchButtonWidth.constant = 0
        voiceSearchButton.isHidden = true
    }
    
    private func hideDeleteButton() {
        deleteButtonWidth.constant = 0
        deleteButton.isHidden = true
    }
    
    private func showVoiceSearchButton() {
        voiceSearchButtonWidth.constant = 40
        voiceSearchButton.isHidden = false
    }
    
    //***************************************************************************************
    //
    // 음성검색
    //
    //***************************************************************************************
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        //TODO 필요시 구현하세요
        if available {
            
        } else {
            
        }
    }
    
    @IBAction func onVoiceSearchButtonTapped(_ sender: Any) {
        
        // Make the authorization request
        SFSpeechRecognizer.requestAuthorization { authStatus in
            
            // The authorization status results in changes to the
            // app’s interface, so process the results on the app’s
            // main queue.
            OperationQueue.main.addOperation {
                //swift는 case문에 break를 안써도 됨
                switch authStatus {
                case .authorized:
                    print("gainAudioFocus")
                    //main thread에서만 호출 가능
                    self.searchKeywordInput.resignFirstResponder()
                    
                    
                    let audioSession = AVAudioSession.sharedInstance()
                    if (audioSession.isOtherAudioPlaying) {
                        self.gainAudioFocusForBeep()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(1114)) {
                            self.gainAudioFocusForVoiceRecognizer()
                            self.startRecording()
                        }
                    })
                    
                case .denied:
                    print("denied")
                case .restricted:
                    print("restricted")
                case .notDetermined:
                    print("notDetermined")
                }
            }
        }
        
    }
    
    private func playStartRecordBeep() {
        
        // create a sound ID, in this case its the tweet sound.
        let systemSoundID: SystemSoundID = 1114 //1113: begin_record, 1114: end_record
        
        // to play sound
        AudioServicesPlaySystemSound (systemSoundID)
    }
    
    private func playEndRecordBeep() {
        // create a sound ID, in this case its the tweet sound.
        let systemSoundID: SystemSoundID = 1114 //1113: begin_record, 1114: end_record
        
        // to play sound
        AudioServicesPlaySystemSound (systemSoundID)
    }
    
    private func gainAudioFocusForBeep() {
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            //음악 재생용
            //setCategory와 setMode를 정확히 사용해야함
            //setCategory와 setMode를 다른 것으로 지정하면 갱신되는 듯
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setMode(AVAudioSessionModeDefault)
            try audioSession.setActive(true)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
    }
    
    private func gainAudioFocusForVoiceRecognizer() {
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            //녹음용
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
    }
    
    private func loseAudioFocus() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            //with: .notifyOthersOnDeactivation 파라미터는 setActive를 false로 지정할 때 사용해야 제대로 작동
            //setActvie(false)를 지정한 다음 또 setActive(false, with: .notifyOthersOnDeactivation)을 지정하면 음악이 다시 재생되지 않음
            try audioSession.setActive(false)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
    }
    
    
    private func loseAudioFocusWithNotify() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            //with: .notifyOthersOnDeactivation 파라미터는 setActive를 false로 지정할 때 사용해야 제대로 작동
            try audioSession.setActive(false, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
    }
    
    
    private func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
    }
    
    
    private func startRecording() {
        //main thread에서만 호출 가능
        // searchKeywordInput.resignFirstResponder()
        
        if recognitionTask != nil {
            stopRecording()
        }
        
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            if result != nil {
                if let result = result {
                    let keyword = result.bestTranscription.formattedString
                    print("keyword: " + keyword)
                    self.gainAudioFocusForBeep()
                    self.playEndRecordBeep()
                    self.showDeleteButton()
                    self.hideVoiceSearchButton()
                    self.searchPlace(searchKeyword: keyword)
                    self.searchKeywordInput.text = keyword
                    self.stopRecording()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        self.loseAudioFocusWithNotify()
                    })
                }
                else if let error = error {
                    print(error)
                }
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
    }
    
    private func initSpeechRecognizer() {
        speechRecognizer?.delegate = self
    }
    
    //********************************************************************************************************
    //
    // 장소검색(Alamofire)
    //
    //********************************************************************************************************
    //Alamofire
    var alamofireManager : AlamofireManager!
    
    @objc func receiveAlamofireSearchPlaceNotification(_ notification: NSNotification) {
        if notification.name.rawValue == PPNConstants.NOTIFICATION_ALAMOFIRE_SEARCH_PLACE {
            
            SpinnerView.remove()
            
            
            if notification.userInfo != nil {
                guard let userInfo = notification.userInfo as? [String:Any] else { return }
                
                let result : String = userInfo["result"] as! String
                
                switch result {
                case "success" :
                    
                    showSortButton()
                    putDeleteButtonToRightOfSortButton()
                    showPlaceTable(userInfo: userInfo)
                     
                    break;
                case "overApi" :
                    
                    showOverApiAlert()
                    
                    break;
                    
                case "fail" :
                    //TODO: 필요시 구현하세요
                    
                    break;
                default:
                    
                    break;
                }
                
            }
        }
    }
    private func showPlaceTable(userInfo: [String:Any]) {
        placeModels = userInfo["placeModels"] as! [PlaceModel]
        
        if (placeModels.count > 0) {
            //placeTable을 표시영역을 지정하지 않으면 이상하게 content가 표시안됨
            //영역을 지정하면 아래 searchPlaceHistoryTable은 클릭할 수 없음
            //따라서 장소검색 결과값이 있으면 isHidden을 false로 없으면 true로 사용해서 처리 
            placeTable.isHidden = false
        setDistance(placeModels: placeModels)
        
        searchPlaceTableViewDataSource?.placeData = placeModels
        placeTable.reloadData()
        } else {
            placeTable.isHidden = true
        }
        
    }
    
    private func initAlamofireManager() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SearchPlaceViewController.receiveAlamofireSearchPlaceNotification(_:)),
                                               name: NSNotification.Name(rawValue: PPNConstants.NOTIFICATION_ALAMOFIRE_SEARCH_PLACE),
                                               object: nil)
        
        alamofireManager = AlamofireManager()
    }
    
    private func setDistance( placeModels: [PlaceModel]) {
        if let location = LocationManager.sharedInstance.getCurrentLocation() {
            
            var distance: Int = 0
            
            for placeModel in placeModels {
                
                distance = DistanceCaculator.getDistanceInt(currentLocation: location, lattitude: placeModel.getLatitude() ?? 0, longitude: placeModel.getLongitude() ?? 0)
                placeModel.setDistance(distance: distance)
            }
        }
    }
    
    private func putDeleteButtonToRightOfSuperView() {
        if (!deleteButton.isHidden) {
            for constraint in (deleteButton.superview?.constraints)! {
                
                if let first = constraint.firstItem as? UIView, first == deleteButton, constraint.firstAttribute == .trailing {  deleteButton.superview?.removeConstraint(constraint)
                }
            }
            
            
            let deleteButtonTrailingConstraint =
                deleteButton.trailingAnchor.constraint(equalTo:
                                                        deleteButton.superview!.trailingAnchor, constant: -14)
            
            let newConstraintArray =
                [deleteButtonTrailingConstraint]
            deleteButton.superview?.addConstraints(newConstraintArray)
            
        }
    }
    
    
    private func putDeleteButtonToRightOfSortButton() {
        if (!deleteButton.isHidden) {
            for constraint in (deleteButton.superview?.constraints)! {
                if let first = constraint.firstItem as? UIView, first == deleteButton, constraint.firstAttribute == .trailing {  deleteButton.superview?.removeConstraint(constraint)
                }
            }
            
            let deleteButtonTrailingConstraint =
                deleteButton.trailingAnchor.constraint(equalTo:
                                                        sortButton.leadingAnchor, constant: -14)
            
            let newConstraintArray =
                [deleteButtonTrailingConstraint]
            deleteButton.superview?.addConstraints(newConstraintArray)
            
        }
    }
    
    private func showSortButton() {
        sortButtonWidth.constant = 40
        sortButton.isHidden = false
    }
    
    
    
    
    private func searchPlace(searchKeyword:String) {
        
        if (InternetConnectionChecker.sharedInstance.isOffline()) {            InternetConnectionChecker.sharedInstance.showOfflineAlertPopup(parentViewControler: self)
            
            return
        }
        
        SpinnerView.show(onView: self.view)
        
        alamofireManager.searchPlace(searchKeyword : searchKeyword)
        
    }
    
    
    private func showOverApiAlert() {
        //TODO 필요시 구현하세요
        
    }
    
    
    //********************************************************************************************************
    //
    // Search Type에 따른 레이아웃 생성
    //
    //********************************************************************************************************
    
    
    var placeName:String?
    //Swift에서 static은 final이기 때문에 final이라고 선언하면 안되는 듯
    public static let PLACE: Int = 0;
    public static let START_POINT: Int = 1;
    public static let DESTINATION: Int = 2;
    public static let HOME: Int = 3;
    public static let WORK: Int = 4;
    public static let HOME_FROM_SETTING: Int = 5;
    public static let WORK_FROM_SETTING: Int = 6;
    public static let PIN_LOCATION: Int = 7;
    
    @IBOutlet weak var yourLocationButton: UIView!
    @IBOutlet weak var chooseOnMapButton: UIView!
    @IBOutlet weak var sectionSeperator: UIView!
    
    
    private func setKeywordInputText() {
        searchKeywordInput.text = placeName
        //TODO 정상동작하는지 확인하세요
        //커서를 텍스트 맨뒤에 위치
        let newPosition = searchKeywordInput.endOfDocument
        searchKeywordInput.selectedTextRange = searchKeywordInput.textRange(from: newPosition, to: newPosition)
    }
    
    
    private func getPlaceModelWithCurrentLocation() -> PlaceModel?{
        if let userLocation = LocationManager.sharedInstance.getCurrentLocation() {
            AddressManager.getFullAddressForCurrentLocation(location: userLocation, completion: {(addressString, error ) in
                
                if let error = error {
                    print(error)
                    return nil
                }
                
                if let addressString = addressString {
                    let placeModel = PlaceModel()
                    placeModel.setLatitude(latitude: userLocation.coordinate.latitude )
                    placeModel.setLongitude(longitude:  userLocation.coordinate.longitude )
                    placeModel.setAddress(address: addressString)
                    placeModel.setName(name: "Your location")
                    return placeModel
                }
                return nil
            })
            
        }
        return nil
    }
    
    private func initYourLocationAndChooseOnMapButton() {
        
        let yourLocationButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.yourLocationButtonTapped(_:)))
        yourLocationButtonTapGesture.numberOfTapsRequired = 1
        yourLocationButtonTapGesture.numberOfTouchesRequired = 1
        yourLocationButton.addGestureRecognizer(yourLocationButtonTapGesture)
        yourLocationButton.isUserInteractionEnabled = true
        
        
        let chooseOnMapButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.chooseOnMapButtonTapped(_:)))
        chooseOnMapButtonTapGesture.numberOfTapsRequired = 1
        chooseOnMapButtonTapGesture.numberOfTouchesRequired = 1
        chooseOnMapButton.addGestureRecognizer(chooseOnMapButtonTapGesture)
        chooseOnMapButton.isUserInteractionEnabled = true
        
    }
    
    
    
    @objc func yourLocationButtonTapped(_ sender: UITapGestureRecognizer) {
        if let delegate = self.selectPlaceDelegate {
            let placeModel = getPlaceModelWithCurrentLocation()
            delegate.onPlaceSelected(placeModel: placeModel!, searchType: Mn4pSharedDataStore.searchType ?? SearchPlaceViewController.PLACE)
        }
        self.dismiss(animated: true)
    }
    
    @objc func chooseOnMapButtonTapped(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "SearchPlace", bundle: nil)
        let chooseOnMapViewController = storyboard.instantiateViewController(withIdentifier: "choose_on_map")
        
        self.present(chooseOnMapViewController, animated: true, completion: nil)
    }
    
    private func createLayout() {
        print("createLayout")
        
        switch (Mn4pSharedDataStore.searchType) {
        //static 변수를 그냥 사용하면 오류 발생
        //SearchPlaceViewController.PLACE 이렇게 ViewController를 명시해야 함
        case SearchPlaceViewController.PLACE:
            createSearchPlaceLayout()
        case SearchPlaceViewController.START_POINT:
            createSearchStartPointLayout()
        case SearchPlaceViewController.DESTINATION:
            createSearchDestinationLayout()
        case SearchPlaceViewController.HOME:
            createSearchHomeLayout()
        case SearchPlaceViewController.WORK:
            createSearchWorkLayout()
        case SearchPlaceViewController.HOME_FROM_SETTING:
            createSearchHomeLayout()
        case SearchPlaceViewController.WORK_FROM_SETTING:
            createSearchWorkLayout()
        default:
            createSearchPlaceLayout()
        }
        
    }
    
    private func createSearchWorkLayout() {
        initYourLocationAndChooseOnMapButton()
        setKeywordInputHint(placeholder: "Set work")
    }
    
    private func createSearchHomeLayout() {
        initYourLocationAndChooseOnMapButton()
        setKeywordInputHint(placeholder: "Set home")
    }
    
    private func createSearchDestinationLayout() {
        initYourLocationAndChooseOnMapButton()
        setKeywordInputText()
        setKeywordInputHint(placeholder: "Choose destination")
        showSearchPlaceHistoryTable()
    }
    
    private func createSearchStartPointLayout() {
        initYourLocationAndChooseOnMapButton()
        setKeywordInputText()
        setKeywordInputHint(placeholder: "Choose starting point")
        showSearchPlaceHistoryTable()
    }
    
    private func createSearchPlaceLayout() {
        setKeywordInputHint(placeholder: "Search for a place or address");
        showSearchPlaceHistoryTable()
        removeYourLocationAndChooseOnMapButton()
    }
    
    private func removeYourLocationAndChooseOnMapButton() {
        for view in yourLocationButton.subviews{
            view.removeFromSuperview()
        }
        
        for view in chooseOnMapButton.subviews{
            view.removeFromSuperview()
        }
        
        for view in sectionSeperator.subviews{
            view.removeFromSuperview()
        }
        
        yourLocationSectionHeight.constant = 0;
        chooseOnMapSectionHeight.constant = 0;
        sectionSeperatorHeight.constant = 0;
        
    }
    
    private func setKeywordInputHint(placeholder: String) {
        searchKeywordInput.placeholder = placeholder
    }
}




