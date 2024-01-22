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
    
    // 地域データリスト
    var areaDataList: [AreaModel] = []
    
    // 天気id
    var weatherId: Int = 0
    
    // 天気パターン
//    var weatherIdList = WeatherIdModel.allCases
    
    // 緯度
    var lat = "43.04"
    // 経度
    var lon = "141.21"
        
    let timeList = ["0:00", "3:00", "6:00", "9:00", "12:00", "15:00", "18:00", "21:00"]
    
    var areaPicker = UIPickerView()
    
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeZone = .current
        dateFormatter.locale = Locale(identifier: "ja-JP")
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
        timeTextField.text = timeList[0] //TODO 現在時刻の次の時刻を設定する
        dateTextField.text = dateFormatter.string(from: Date())
        
        // delegate, datasource
        dateTextField.delegate = self
        timeTextField.delegate = self
        areaPicker.delegate = self
        areaPicker.dataSource = self
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
        getWeatherData()
    }
    
    func getWeatherData() {
        if let url = URL(string: CommonConst.apiUrl + "lat=\(lat)&lon=\(lon)&appid=\(CommonConst.apiKey)") {
            
            // リクエスト生成
            let request = URLRequest(url: url)
            
            // URLSessionを作成
            let session = URLSession.shared
            
            // リクエストを送信
            let task = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("リクエストエラー: \(error)")
                    return
                }
                
                if let data = data {
                    do {
                        // JSONデータを解析
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            
                            if let main = json["main"] as? [String: Any], let temp = main["temp"] as? Double {
                                // 温度を取得
                                print("温度: \(temp)度")
                            }
                                                        
                            if let weather = json["weather"] as? [[String: Any]], let id = weather.first?["id"] as? Int {
                                
                                // 降水確率
                                self.weatherId = id
                                print("天気id: \(id)")
                            }
                            
                            if let weather = json["weather"] as? [[String: Any]], let description = weather.first?["description"] as? String {
                                
                                // 天気の説明を取得
                                print("天気: \(description)")
                            }
                        }
                    } catch {
                        print("JSONデータの解析エラー: \(error)")
                    }
                }
            }
            
            task.resume()
        } else {
            print("URLの生成エラー")
        }
        
        // 天気パターンの取得
//        weatherIdList[0]
    }
    
    func configureNavigationBar() {
        let settingButton = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(clickSettingButton))
        navigationItem.rightBarButtonItem = settingButton
    }
    
    func configureAreaTextField() {
        areaTextField.inputView = areaPicker
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
    }
    
    @objc func doneDatePicker() {
        dateTextField.endEditing(true)
    }
    
    @objc func donePicker() {
        areaTextField.endEditing(true)
        timeTextField.endEditing(true)
        getWeatherData()
    }
}

extension HomeViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == timePicker {
            timeTextField.text = timeList[row]
        } else {
            lat = areaDataList[row].lat
            lon = areaDataList[row].lon
            areaTextField.text = areaDataList[row].prefecture + CommonConst.halfSpace + areaDataList[row].municipality
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
