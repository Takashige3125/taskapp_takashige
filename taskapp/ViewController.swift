//
//  ViewController.swift
//  taskapp
//
//  Created by 秋山剛成 on 2021/03/15.
//

import UIKit
import Realm
import RealmSwift  // ←追加
import UserNotifications    // 追加


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,  UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // Realmインスタンスを取得する
    let realm = try! Realm()  // ←追加
    
    
    // DB内のタスクが格納されるリスト。
    // 日付の近い順でソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)  // ←追加
    var taskArray_now = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)  // ←追加
    
    //検索結果配列にデータをコピーする。
    var searchResult = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("*")
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        //デリゲート先を自分に設定する。
        searchBar.delegate = self
                
        //何も入力されていなくてもReturnキーを押せるようにする。
        searchBar.enablesReturnKeyAutomatically = false
    
        for task in taskArray {
            searchResult.append(task.title)
        }
    }
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray_now.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る ふるいの使い回し
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Cellに値を設定する.  --- ここから ---
        let task = taskArray_now[indexPath.row]
        print(indexPath.row)
        print(searchBar.text! == "")
        
//        if searchResult[indexPath.row] != "" && indexPath.row == 0{
//            cell.textLabel?.text = searchResult[indexPath.row]
//        }
       if(searchBar.text! == ""){
            cell.textLabel?.text = taskArray_now[indexPath.row].title
        }
        else{
            if indexPath.row < searchResult.count{
                let index_num = indexPath.row
        
                if searchResult == []{
                    cell.textLabel?.text = ""
                }
                else{
                    cell.textLabel?.text = searchResult[index_num]
                }
            }
            else{
                cell.textLabel?.text = ""
            }
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        // --- ここまで追加 ---
        
        return cell
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil) // ←追加する
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // --- ここから ---
        if editingStyle == .delete {
            
            // 削除するタスクを取得する
            let task = self.taskArray_now[indexPath.row]

            
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])

            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
            
            // データベースから削除する
            try! realm.write {
                print(self.taskArray)
                self.realm.delete(self.taskArray_now[indexPath.row])
//                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
        } // --- ここまで変更 ---
    }
    
    //データを返すメソッド
    
    
    //データの個数を返すメソッド
//    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
//            return searchResult.count
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableView
//
//        let row_item = currentItems[indexPath.row]
//        cell.setArticle(item: row_item)
//
//        return cell
//    }

    // segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController

        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray_now[indexPath!.row]
        } else {
            let task = Task()

            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }

            inputViewController.task = task
        }
    }
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.delegate = self
        tableView.reloadData()
    }
    
    //検索ボタン押下時の呼び出しメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる。
        searchBar.endEditing(true)
    }
    
    //検索バーに入力された文字が変わったときの呼び出しメソッド
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //検索結果配列を空にする。
        searchResult.removeAll()
            
        if(searchBar.text == "") {
            //検索文字列が空の場合はすべてを表示する。
            for data in taskArray {
                searchResult.append(data.title)
            }
            taskArray_now = taskArray
        } else {
            taskArray_now = try! Realm().objects(Task.self).filter("category contains %@", searchBar.text!)
//            //検索文字列を含むデータを検索結果配列に追加する。
//            for data in taskArray {
//                if data.category.contains(searchBar.text!) {
//                    searchResult.append(data.title)
//                }
//            }
            for data in taskArray_now {
                searchResult.append(data.title)
            }
        }
            
        //テーブルを再読み込みする。
        tableView.reloadData()
        
    }

}

