//
//  AddAreaViewController.swift
//  KasaIruApp
//
//  Created by 海老沢優典 on 2023/10/16.
//

import UIKit

class AddAreaViewController: UIViewController {
    
    @IBOutlet weak var prefecturesTextField: UITextField!
    @IBOutlet weak var municipalitiesTextField: UITextField!
    
    var prefecturesPickerView = UIPickerView()
    var municipalitiesPickerView = UIPickerView()
    
    let prefecturesList = ["東京都", "神奈川県"] //TODO 全都道府県 データは外だしがいいかも
    let municipalitiesList = ["千代田区", "港区"] //TODO 全市区町村
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初期値設定
        prefecturesTextField.text = prefecturesList[0]
        municipalitiesTextField.text = municipalitiesList[0]
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
}

extension AddAreaViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == prefecturesPickerView {
            return prefecturesTextField.text = prefecturesList[row]
        } else {
            return municipalitiesTextField.text = municipalitiesList[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == prefecturesPickerView {
            return prefecturesList[row]
        } else {
            return municipalitiesList[row]
        }
    }
}

extension AddAreaViewController: UIPickerViewDataSource {
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

extension AddAreaViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}
