//
//  SettingViewController.swift
//  KasaIruApp
//
//  Created by 海老沢優典 on 2023/10/19.
//

import UIKit

class SettingViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var areaDataList = ["a", "b"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegate, datasource
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension SettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return areaDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = areaDataList[indexPath.row]
        
        return cell
    }
    
    
}

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "削除") { action, view, completionHandler in
            
            print("delete")
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
