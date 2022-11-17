//
//  ViewController.swift
//  RecordTableView
//
//  Created by おじぇ on 2022/10/21.
//

import UIKit
import Charts

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIAdaptivePresentationControllerDelegate {
    @IBOutlet weak var RecordTableView: UITableView!
    @IBOutlet weak var recordRegistTipsLabel: UILabel!  //レコードが０件のときのヒントを表示するラベル
    
    let userDefaults = UserDefaults.standard  //ユーザデフォルト
    var recordList:[BattleRecord] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ビューの高さを広告と被らないように調整
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        let viewHeight = screenHeight - 135 - 48 - TabBarController.bannerAdHeight
        RecordTableView.translatesAutoresizingMaskIntoConstraints = false  //AutoresizingMaskを無効化してAutoLayoutにする
        RecordTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 135).isActive = true
        RecordTableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: -5).isActive = true
        RecordTableView.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
        RecordTableView.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
        
        userDefaults.set(false, forKey: "isReloadedCharts")  //レポート読み込み済みかのフラグを設定
        recordList = BattleRecord.getAll()
        
        recordRegistTipsLabel.isHidden = recordList.count == 0 ? false : true  //レコードが０件だったらレコード登録のヒントを表示する
    }

    
    //----------------------------イベント処理の記述----------------------------
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordList.count
    }
    //各セルの値を設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath) as! TableViewCell//RecordCell
        let r = recordList[indexPath.row]
        
        cell.textLabel!.text = r.createdDateStr
        cell.textLabel!.textColor = r.winnerNum == 0 ? UIColor.blue : UIColor.green  //優勝者が選択されていたら文字色をみどり
        cell.rowDeleteButton.tag = indexPath.row  //ボタンのタグに行数を保持させる
        cell.rowDeleteButton.isHidden = false  //「-」ボタンを表示
        
        return cell
    }
    //tableセルがタップされたときの処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetRecord = recordList[indexPath.row]
        let vc = getNextVC(isUpdate:true)
        vc.record = targetRecord
        present(vc, animated:true, completion:nil)  //編集画面を開く
    }
    
    //「＋」ボタン押下時の処理
    @IBAction func addRecordBtnAct(_ sender: Any) {
        let vc = getNextVC(isUpdate:false)
        present(vc, animated:true, completion:nil)
    }
    
    //各行の「ー」ボタン押下時の処理
    @IBAction func rowDeleteBtnAct(_ sender: UIButton) {
        let rowNum = sender.tag  //削除ボタンが押された行番号を取得
        RecordTableView.selectRow(at:IndexPath(row:rowNum,section:0), animated:true, scrollPosition:.none)  //対象行を選択状態にする
        
        //アラートを生成
        let alert:UIAlertController = UIAlertController(title:"Delete record?", message:"targetRow：\(rowNum)", preferredStyle:UIAlertController.Style.alert)
        //OKボタンの処理
        let confirmAction:UIAlertAction = UIAlertAction(title:"OK!", style:UIAlertAction.Style.default, handler:{ (acation:UIAlertAction!) -> Void in
            print("削除実行")
            CoreDataRepository.delete(self.recordList[rowNum])  //リポジトリーからレコードを削除
            CoreDataRepository.save()  //コミット
            self.recordList = BattleRecord.getAll()  //リストを再取得
            self.userDefaults.set(false, forKey: "isReloadedCharts")  //レポート読み込み済みかのフラグを設定
            self.RecordTableView.reloadData()  //画面の再描画
        })
        //キャンセルの処理
        let cancelAction: UIAlertAction = UIAlertAction(title:"Cancel", style:UIAlertAction.Style.cancel,handler:{ (acation:UIAlertAction!) -> Void in
            self.RecordTableView.deselectRow(at:IndexPath(row:rowNum,section:0), animated:true)
        })
        
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated:true, completion: nil)  //アラート表示
        /*CoreDataRepository.delete(recordList[rowNum])  //リポジトリーからレコードを削除
        CoreDataRepository.save()  //コミット
        recordList = BattleRecord.getAll()  //リストを再取得
        RecordTableView.reloadData()  //画面の再描画
        */
    }
    
    
    
    //次画面のviewControllerを取得して返す
    func getNextVC(isUpdate:Bool) -> AddRecordController {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddRecordControllerId") as! AddRecordController
        vc.presentationController?.delegate = self
        vc.isUpdate = isUpdate
        return vc
    }
    
    //子画面が閉じられたのを検知して実行される
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController){
        recordList = BattleRecord.getAll()  //リストを再取得
        recordRegistTipsLabel.isHidden = recordList.count == 0 ? false : true  //レコードが０件だったらレコード登録のヒントを表示する
        RecordTableView.reloadData()  //画面のtableCellを更新
    }
    
    
    //アラートを生成する
    /*func createAlert(msg:String) -> UIAlertController {
        let alert:UIAlertController = UIAlertController(title:"", message:msg, preferredStyle:UIAlertController.Style.alert)
        //OKボタンの処理
        let confirmAction:UIAlertAction = UIAlertAction(title:"OK!", style:UIAlertAction.Style.default, handler:{ (acation:UIAlertAction!) -> Void in
            print("削除実行")
        })
        //キャンセルの処理
        let cancelAction: UIAlertAction = UIAlertAction(title:"Cancel", style:UIAlertAction.Style.cancel)
        //})
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        return alert
    }*/
}

