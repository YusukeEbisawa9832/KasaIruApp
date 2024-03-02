//
//  SettingViewController.swift
//  KasaIruApp
//
//  Created by 海老沢優典 on 2023/10/19.
//

import UIKit
import RealmSwift

class SettingViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var areaDataList = [AreaModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegate, datasource
        tableView.dataSource = self
        tableView.delegate = self
        
        // 表示するデータ一覧をRealmから取得
        let realm = try! Realm()
        let result = realm.objects(AreaModel.self)
        areaDataList = Array(result)
    }
}

extension SettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return areaDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = areaDataList[indexPath.row].prefecture + CommonConst.halfSpace + areaDataList[indexPath.row].municipality
        
        return cell
    }
    
    
}

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        print("delete")
        let deleteData = areaDataList[indexPath.row]
        let realm = try! Realm()
        try! realm.write {
            realm.delete(deleteData)
        }
        areaDataList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
}
