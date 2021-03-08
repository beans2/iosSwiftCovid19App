//
//  ViewController.swift
//  Covid19App
//
//  Created by Mac Mini on 2021/03/05.
//

import UIKit
import WaterDrops

class ViewController: UIViewController {
    
    @IBOutlet weak var decideCountLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(showCovidInfo), name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(waterDrop), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear!")
    }
    
    //워터드롭 애니메이션.. (보여주는 기능이 하나라서, 심심하지 않게)
    @objc func waterDrop() {
        self.view.backgroundColor = UIColor.black
        
        let waterDropsView = WaterDropsView(frame: self.view.frame, direction: .down, dropNum: 10, color: UIColor.white.withAlphaComponent(0.8), minDropSize: 5, maxDropSize: 10, minLength: 50, maxLength: self.view.frame.size.height, minDuration: 5, maxDuration: 10)
        waterDropsView.addAnimation()
        self.view.addSubview(waterDropsView)
    }
    
    @objc func showCovidInfo(){
        self.activityIndicator.activityStart()
        let todayDate = self.getDate(beforeDate: 0)
        if let decideInfo = UserDefaults.standard.dictionary(forKey: "decideInfo"){
            //오늘로 지정된 저장된 값이 존재
            if let plusCnt = decideInfo[todayDate] as? Int , plusCnt > -1 {
                let nowDate = decideInfo.keys.first
                //있다면 저장된 추가 확진자수 노출
                print("[오늘의 추가 확진자 수 데이터 존재]: \(plusCnt)")
                self.dateLabel.text = nowDate
                self.decideCountLabel.text = "\(plusCnt)"
                self.activityIndicator.isHidden = true
                return
            }else{
                //없다면 API통신 -> 노출
                print("[오늘의 추가 확진자 수 데이터 존재하지 않음]: ")
                self.requestDecideAPI(date: 0) {[weak self] (plusCnt) in
                    if plusCnt != -1 {
                        self?.dateLabel.text = "\(todayDate)"
                        self?.decideCountLabel.text = "\(plusCnt)"
                    }else{
                        print("[오늘의 추가 확진자 수 받아오기 실패] : \(plusCnt)")
                        guard let todayDate = self?.getDate(beforeDate: 1) else{
                            return
                        }
                        self?.requestDecideAPI(date: 1,completionHandler: { (plusCnt) in
                            print("[어제자로 재호출...] : \(plusCnt)")
                            if plusCnt != -1 {
                                self?.dateLabel.text = "\(todayDate)"
                                self?.decideCountLabel.text = "\(plusCnt)"
                                self?.showAlert(message: "오늘자 데이터가 없습니다.\n가장 최근 데이터를 보여줍니다.")
                            }else{
                                self?.dateLabel.text = "..."
                                self?.decideCountLabel.text = "..."
                                self?.showAlert(message: "날짜 입력이 잘못되었습니다\n기기날짜를 현재로 설정해주세요.")
                            }
                        })
                    }
                }
                return
            }
        }
        self.requestDecideAPI(date:0) {[weak self] (plusCnt) in
            
            if plusCnt != -1{
                print("[오늘의 추가 확진자 수 받아오기 성공] : \(plusCnt)")
                self?.dateLabel.text = "\(todayDate)"
                self?.decideCountLabel.text = "\(plusCnt)"
            }else {
                print("[오늘의 추가 확진자 수 받아오기 실패] : \(plusCnt)")
                guard let todayDate = self?.getDate(beforeDate: 1) else{
                    return
                }
                self?.requestDecideAPI(date: 1, completionHandler: { (plusCnt) in
                    print("[정보 받아오기 어제자로 재호출...] : \(plusCnt)")
                    self?.dateLabel.text = "\(todayDate)"
                    self?.decideCountLabel.text = "\(plusCnt)"
                })
                self?.showAlert(message: "오늘자 데이터가 없습니다.\n어제 데이터를 보여줍니다.")
            }
            
        }
    }
    
    func requestDecideAPI(date:Int, completionHandler :@escaping (Int) -> Void) {
        let apiUrl = URLInfos.decideAPI.url
        let serviceKey = DataInfo.serviceKey.info
        guard let decodedServiceKey = serviceKey.removingPercentEncoding else {
            return
        }
        let injectStartDate = self.getDate(beforeDate: date+1) //어제 날짜
        let injectEndDate = self.getDate(beforeDate: date)//오늘 날짜
        let parameters = ["ServiceKey":decodedServiceKey , "startCreateDt": injectStartDate, "endCreateDt" : injectEndDate] as [String : Any]
        print("[parameters]: \(parameters)")
        Request.init(apiURL: apiUrl, parameters: parameters).DecideAPI { [weak self] (response) in
            let today = self?.getDate(beforeDate: date)
            //값 UserDefault 저장 [날짜:늘어난확진자수]
            if response > -1 {
                self?.activityIndicator.activityStop()
            }
            UserDefaults.standard.setValue([today:response], forKey: "decideInfo")
            completionHandler(response)
        }
    }
    
    func getDate(beforeDate:Int)-> String {
        let YYYYMMDDDateFormatter = DateFormatter()
        YYYYMMDDDateFormatter.dateFormat = "yyyyMMdd"
        let date = Date() + Double(-86400 * beforeDate)
        let formattedDate = YYYYMMDDDateFormatter.string(from: date)
        return formattedDate
    }
    
    func showAlert(message: String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title:Bundle.main.infoDictionary?["CFBundleName"] as? String ?? " ",
                                          message: message,
                                          preferredStyle: .alert) // .actionSheet사용가능
            let ok = UIAlertAction(title: "확인", style: .default)
            alert.addAction(ok)
            self.present(alert, animated: true)
        }
    }
}

