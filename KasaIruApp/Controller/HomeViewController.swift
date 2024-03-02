//
//  HomeViewController.swift
//  KasaIruApp
//
//  Created by 海老沢優典 on 2023/10/16.
//

import UIKit
import RealmSwift

class HomeViewController: UIViewController {
    
    @IBOutlet weak var areaTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var areaAddButton: UIButton!
    @IBAction func areaAddButton(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let addAreaViewController = storyBoard.instantiateViewController(identifier: "AddAreaViewController") as! AddAreaViewController
        navigationController?.pushViewController(addAreaViewController, animated: true)
    }
    
    @IBOutlet weak var weatherText: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    // 地域PickerView
    var areaPickerView = UIPickerView()
    
    // 地域データリスト
    var areaDataList: [AreaModel] = []
    
    // 天気id
    var weatherId = 0
    
    // 天気の大まかなid
    var weatherType = WeatherTypeModel.sunny
        
    // 天気idのenumリスト
    var weatherIdList = WeatherIdModel.allCases
    
    // 緯度
    var lat = ""
    // 経度
    var lon = ""
    
    var selectDate = ""
        
    let timeList = ["00:00", "03:00", "06:00", "09:00", "12:00", "15:00", "18:00", "21:00"]
    
    var selectTime = ""
              
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeZone = .current
        dateFormatter.locale = Locale(identifier: "ja-JP")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
    var datePicker: UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.locale = Locale(identifier: "ja-JP")
        datePicker.datePickerMode = .date
        datePicker.timeZone = .current
        datePicker.preferredDatePickerStyle = .inline
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.minimumDate = Date()
        datePicker.maximumDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())
        return datePicker
    }
    var timePicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初期値設定
        initTimeTextField() // 現在時刻の次の時刻を設定する
        dateTextField.text = dateFormatter.string(from: Date())
        selectDate = dateFormatter.string(from: Date())
        
        // delegate, datasource
        dateTextField.delegate = self
        timeTextField.delegate = self
        areaPickerView.delegate = self
        areaPickerView.dataSource = self
        timePicker.delegate = self
        timePicker.dataSource = self
        
        // 戻るボタン非表示
        navigationItem.hidesBackButton = true
        // 次画面の「戻る」非表示
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        // 設定ボタン
        configureNavigationBar()
        // textFieldの設定
        configureAreaTextField()
        configureDateTextField()
        configureTimeTextField()
        // addAreaButtonの設定
        configureFloatingButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 地域データをRealmから取得
        let realm = try! Realm()
        let result = realm.objects(AreaModel.self)
        areaDataList = Array(result)
        
        // textFieldに設定
        areaTextField.text = areaDataList[0].prefecture + " " + areaDataList[0].municipality
        
        // 天気API
        getWeatherData(lat: areaDataList[0].lat, lon: areaDataList[0].lon)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        weatherImageView.image = UIImage(named: "sunny")
        
        switch weatherType {
        case .sunny: weatherText.text = "傘不要"
            weatherImageView.image = UIImage(named: "sunny")
        case .cloud: weatherText.text = "傘あっても良い"
            weatherImageView.image = UIImage(named: "cloud")
        case .rain: weatherText.text = "傘必要"
            weatherImageView.image = UIImage(named: "rain")
        case .none:
            weatherText.text = ""
        }
    }
    
    func initTimeTextField() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeZone = .current
        dateFormatter.locale = Locale(identifier: "ja-JP")
        dateFormatter.dateFormat = "HH:mm"
        for timeStr in timeList {
            let time = dateFormatter.date(from: timeStr)!
            var nowDate = Date.now
            let nowStr = dateFormatter.string(from: nowDate)
            nowDate = dateFormatter.date(from: nowStr)!
            if nowDate <= time {
                timeTextField.text = timeStr
                selectTime = timeStr
                break
            }
        }
    }
    
    func getWeatherData(lat: String, lon: String) {
        if let url = URL(string: CommonConst.apiUrl + "lat=\(lat)&lon=\(lon)&appid=\(CommonConst.apiKey)") {
            
            // リクエスト生成
            let request = URLRequest(url: url)
            
            // URLSessionを作成
            let session = URLSession.shared
            
            // リクエストを送信
            let task = session.dataTask(with: request) { [self] (data, response, error) in
                if let error = error {
                    print("リクエストエラー: \(error)")
                    return
                }
                
                if let data = data {
                    // JSONデータを解析
                    let json = try! JSONDecoder().decode(WeatherModel.self, from: data)
                    
                    //*** debug *** //
                    print(json.list[0].dt_txt)
                    print(json.list[0])
                    print(json.list[0].weather[0])
                    print(json.list[0].weather[0].id)
                    print(json.list[0].weather[0].main)
                    print(json.list[0].weather[0].description)
                    //*** debug *** //
                    
                    for list in json.list {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .long
                        dateFormatter.timeZone = .current
                        dateFormatter.locale = Locale(identifier: "ja-JP")
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:00"
                        let selectDateTime = dateFormatter.date(from: selectDate + CommonConst.halfSpace + selectTime)
                        
                        let dtTxtDate = dateFormatter.date(from: list.dt_txt)!
                        
                        if selectDateTime! <= dtTxtDate {
                            weatherId = list.weather[0].id
                            
                            switch weatherId {
                            case 800: weatherType = WeatherTypeModel.sunny
                            case 801: weatherType = WeatherTypeModel.cloud
                            case 802: weatherType = WeatherTypeModel.cloud
                            case 803: weatherType = WeatherTypeModel.cloud
                            case 804: weatherType = WeatherTypeModel.cloud
                            default:
                                weatherType = WeatherTypeModel.rain
                            }
                            break
                            
                        } else {
                            // 過去日を選択した場合
                            weatherId = -1
                            weatherType = WeatherTypeModel.none
                        }
                    }
                }
            }
            
            task.resume()
        } else {
            print("URLの生成エラー")
        }
    }
    
    func configureNavigationBar() {
        let settingButton = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(clickSettingButton))
        navigationItem.rightBarButtonItem = settingButton
    }
    
    func configureAreaTextField() {
        areaTextField.inputView = areaPickerView
        let toolBar = UIToolbar()
        toolBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePicker))
        toolBar.setItems([spaceItem, doneButtonItem], animated: true)
        areaTextField.inputAccessoryView = toolBar
    }
    
    func configureDateTextField() {
        dateTextField.inputView = datePicker
        // toolBar
        let toolBar = UIToolbar()
        toolBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneDatePicker))
        toolBar.setItems([spacelItem, doneButtonItem], animated: true)
        dateTextField.inputAccessoryView = toolBar
    }
    
    func configureTimeTextField() {
        timeTextField.inputView = timePicker
        // toolBar
        let toolBar = UIToolbar()
        toolBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePicker))
        toolBar.setItems([spacelItem, doneButtonItem], animated: true)
        timeTextField.inputAccessoryView = toolBar
    }
    
    func configureFloatingButton() {
        areaAddButton.layer.cornerRadius = 30
    }
    
    @objc func clickSettingButton() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let settingViewController = storyBoard.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
        navigationController?.pushViewController(settingViewController, animated: true)
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        dateTextField.text = dateFormatter.string(from: sender.date)
        selectDate = dateFormatter.string(from: sender.date)
    }
    
    @objc func doneDatePicker() {
        dateTextField.endEditing(true)
    }
    
    @objc func donePicker() {
        areaTextField.endEditing(true)
        timeTextField.endEditing(true)
//        getWeatherData()
    }
}

extension HomeViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == timePicker {
            selectTime = timeList[row]
            timeTextField.text = timeList[row]
        } else {
            // 地域PickerViewの変更時
            lat = areaDataList[row].lat
            lon = areaDataList[row].lon
            areaTextField.text = areaDataList[row].prefecture + CommonConst.halfSpace + areaDataList[row].municipality
            // 日付と時間を初期値にする
            initTimeTextField()
            dateTextField.text = dateFormatter.string(from: Date())
            selectDate = dateFormatter.string(from: Date())
            // 天気API呼び出し
            getWeatherData(lat: lat, lon: lon)
            
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == timePicker {
            return timeList[row]
        } else {
            return areaDataList[row].prefecture + CommonConst.halfSpace + areaDataList[row].municipality
        }
        
    }
}

extension HomeViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == timePicker {
            return timeList.count
        } else {
            return areaDataList.count
        }
        
    }
}

extension HomeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}
