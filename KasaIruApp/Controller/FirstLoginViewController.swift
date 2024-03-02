//
//  SettingAreaViewController.swift
//  KasaIruApp
//
//  Created by 海老沢優典 on 2023/10/16.
//

import UIKit
import RealmSwift

class FirstLoginViewController: UIViewController {
    
    @IBOutlet weak var prefecturesTextField: UITextField!
    @IBOutlet weak var municipalitiesTextField: UITextField!
    
    @IBAction func decisionButton(_ sender: Any) {
        // Realmに登録
        let realm = try! Realm()
        try! realm.write ({
            areaData.prefecture = prefecturesTextField.text!
            areaData.municipality = municipalitiesTextField.text!
            areaData.lat = lat
            areaData.lon = lon
            realm.add(areaData)
        })
        pushHomeViewController()
    }
    
    // 地域データ
    var areaData = AreaModel()
    // 緯度
    var lat = ""
    // 経度
    var lon = ""
    
    // 都道府県PickerView
    var prefecturesPickerView = UIPickerView()
    // 市区町村PickerView
    var municipalitiesPickerView = UIPickerView()
    
    let prefecturesList = PrefecturesModel.allCases
    var municipalitiesList = [MunicipalitiesModel]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 地域が選択されていた場合はHomeViewControllerに遷移する
        let realm = try! Realm()
        let result = realm.objects(AreaModel.self)
        let areaModelList = Array(result)
        if areaModelList.count > 0 {
            pushHomeViewController()
        }
        
        // 初期値設定
        municipalitiesList = prefecturesList[0].municipalities
        lat = municipalitiesList[0].lat
        lon = municipalitiesList[0].lon
        // 初期値設定(textField)
        prefecturesTextField.text = prefecturesList[0].prefecturesName
        municipalitiesTextField.text = municipalitiesList[0].municipalitiesName
        
        // delegate, datasource
        prefecturesTextField.delegate = self
        municipalitiesTextField.delegate = self
        prefecturesPickerView.dataSource = self
        municipalitiesPickerView.dataSource = self
        prefecturesPickerView.delegate = self
        municipalitiesPickerView.delegate = self
        
        configureTextField()
    }
    
    func configureTextField() {
        prefecturesTextField.inputView = prefecturesPickerView
        municipalitiesTextField.inputView = municipalitiesPickerView
        // toolbar
        let toolBar = UIToolbar()
        toolBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePicker))
        toolBar.setItems([spacelItem, doneButtonItem], animated: true)

        prefecturesTextField.inputAccessoryView = toolBar
        municipalitiesTextField.inputAccessoryView = toolBar
    }
    
    @objc func donePicker() {
        prefecturesTextField.endEditing(true)
        municipalitiesTextField.endEditing(true)
    }
    
    func pushHomeViewController() {
        // HomeViewに遷移
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyBoard.instantiateViewController(identifier: "HomeViewController") as! HomeViewController
        navigationController?.pushViewController(homeViewController, animated: true)
    }
}

extension FirstLoginViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == prefecturesPickerView {
            // 都道府県を選択時、市区町村を変更する
            municipalitiesList = prefecturesList[row].municipalities
            municipalitiesTextField.text = prefecturesList[row].municipalities[0].municipalitiesName
            
            return prefecturesTextField.text = prefecturesList[row].prefecturesName
        } else {
            return municipalitiesTextField.text = municipalitiesList[row].municipalitiesName
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == prefecturesPickerView {
            return prefecturesList[row].prefecturesName
        } else {
            lat = municipalitiesList[row].lat
            lon = municipalitiesList[row].lon
            return municipalitiesList[row].municipalitiesName
        }
    }
}

extension FirstLoginViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == prefecturesPickerView {
            return prefecturesList.count
        } else {
            return municipalitiesList.count
        }
    }
}

extension FirstLoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}
