//
//  AddRecordController.swift
//  RecordTableView
//
//  Created by おじぇ on 2022/10/21.
//

import UIKit

class AddRecordController: UIViewController,UITextFieldDelegate,DataReturn {
    @IBOutlet weak var WinCheck1: UIButton!
    @IBOutlet weak var winCheck2: UIButton!
    @IBOutlet weak var winCheck3: UIButton!
    @IBOutlet weak var winCheck4: UIButton!
    
    @IBOutlet weak var leaderLabel1: UITextField!
    @IBOutlet weak var leaderLabel2: UITextField!
    @IBOutlet weak var leaderLabel3: UITextField!
    @IBOutlet weak var leaderLabel4: UITextField!
    @IBOutlet weak var leaderLabel5: UITextField!
    @IBOutlet weak var leaderLabel6: UITextField!
    @IBOutlet weak var leaderLabel7: UITextField!
    @IBOutlet weak var leaderLabel8: UITextField!
    
    var userDefaults = UserDefaults.standard
    
    var tgtBtn:String!  //どのリーダー検索ボタンを押したかを保持し、子画面から処理が帰ってきたときに、リーダー名を設定するLabelを判別する
    var winnerNum:Int16 = 0
    var isUpdate:Bool = false
    var record:BattleRecord!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leaderLabel1.placeholder = "Commander1"
        leaderLabel2.placeholder = "Commander2"
        leaderLabel3.placeholder = "Commander1"
        leaderLabel4.placeholder = "Commander2"
        leaderLabel5.placeholder = "Commander1"
        leaderLabel6.placeholder = "Commander2"
        leaderLabel7.placeholder = "Commander1"
        leaderLabel8.placeholder = "Commander2"
        tgtBtn = ""
        if(isUpdate){
            recordReflectToScreen(r:record)  //レコードの値を画面に反映
        }else{
            record = BattleRecord.new()
            record.player1Name = "Player1"
            record.player2Name = "Player2"
            record.player3Name = "Player3"
            record.player4Name = "Player4"
        }
    }
    
//--------------------------イベントの処理を記述---------------------------
    
    //Saveボタンの処理 レコードのINSERT or UPDATE
    @IBAction func saveAct(_ sender: Any) {
        screenReflectToRecord(r: record)  //画面の値をレコードに反映
        if(!isUpdate){
            record.createdDate = Date()  //作成日を設定
            record.createdDateStr = getStrDateForCurrentTimeZone(myDate: record.createdDate)
            CoreDataRepository.insert(record)
        }
        CoreDataRepository.save()  //コミット
        userDefaults.set(false, forKey: "isReloadedCharts")  //レポート読み込み済みかのフラグを設定
        if let pc = presentationController{
            pc.delegate?.presentationControllerDidDismiss?(pc) //閉じる前に親画面のdelegateメソッドを実行
        }
        dismiss(animated: true, completion: nil)  //モーダル画面を閉じる
    }
    
    //winner選択ボタン押下時の処理
    @IBAction func winCheckAct1(_ sender: Any) {
        if(winnerNum == 1){
            //既に同じ優勝者が選択されていたら、選択を解除
            winnerNum = 0
            WinCheck1.setTitle("◯", for: .normal)
        }else{
            //player1を選択済みにし、他playerの選択を解除
            winnerNum = 1
            WinCheck1.setTitle("◉", for: .normal)
            winCheck2.setTitle("◯", for: .normal)
            winCheck3.setTitle("◯", for: .normal)
            winCheck4.setTitle("◯", for: .normal)
        }
    }
    @IBAction func winCheckAct2(_ sender: Any) {
        if(winnerNum == 2){
            //既に同じ優勝者が選択されていたら、選択を解除
            winnerNum = 0
            winCheck2.setTitle("◯", for: .normal)
        }else{
            //player2を選択済みにし、他playerの選択を解除
            winnerNum = 2
            WinCheck1.setTitle("◯", for: .normal)
            winCheck2.setTitle("◉", for: .normal)
            winCheck3.setTitle("◯", for: .normal)
            winCheck4.setTitle("◯", for: .normal)
        }
    }
    @IBAction func winCheckAct3(_ sender: Any) {
        if(winnerNum == 3){
            //既に同じ優勝者が選択されていたら、選択を解除
            winnerNum = 0
            winCheck3.setTitle("◯", for: .normal)
        }else{
            //player3を選択済みにし、他playerの選択を解除
            winnerNum = 3
            WinCheck1.setTitle("◯", for: .normal)
            winCheck2.setTitle("◯", for: .normal)
            winCheck3.setTitle("◉", for: .normal)
            winCheck4.setTitle("◯", for: .normal)
        }
    }
    @IBAction func winCheckAct4(_ sender: Any) {
        if(winnerNum == 4){
            //既に同じ優勝者が選択されていたら、選択を解除
            winnerNum = 0
            winCheck4.setTitle("◯", for: .normal)
        }else{
            //player4を選択済みにし、他playerの選択を解除
            winnerNum = 4
            WinCheck1.setTitle("◯", for: .normal)
            winCheck2.setTitle("◯", for: .normal)
            winCheck3.setTitle("◯", for: .normal)
            winCheck4.setTitle("◉", for: .normal)
        }
    }
    
    //リーダーtextFieldをタップした瞬間呼ばれる関数
    @IBAction func textFieldDidBegin1(_ sender: Any) {
        self.view.endEditing(true)  //キーボードを閉じる
        tgtBtn = "btn1"
        performSegue(withIdentifier: "searchSegue1", sender: self)
    }
    @IBAction func textFieldDidBegin2(_ sender: Any) {
        self.view.endEditing(true)  //キーボードを閉じる
        tgtBtn = "btn2"
        performSegue(withIdentifier: "searchSegue1", sender: self)
    }
    @IBAction func textFieldDidBegin3(_ sender: Any) {
        self.view.endEditing(true)  //キーボードを閉じる
        tgtBtn = "btn3"
        performSegue(withIdentifier: "searchSegue1", sender: self)
    }
    @IBAction func textFieldDidBegin4(_ sender: Any) {
        self.view.endEditing(true)  //キーボードを閉じる
        tgtBtn = "btn4"
        performSegue(withIdentifier: "searchSegue1", sender: self)
    }
    @IBAction func textFieldDidBegin5(_ sender: Any) {
        self.view.endEditing(true)  //キーボードを閉じる
        tgtBtn = "btn5"
        performSegue(withIdentifier: "searchSegue1", sender: self)
    }
    @IBAction func textFieldDidBegin6(_ sender: Any) {
        self.view.endEditing(true)  //キーボードを閉じる
        tgtBtn = "btn6"
        performSegue(withIdentifier: "searchSegue1", sender: self)
    }
    @IBAction func textFieldDidBegin7(_ sender: Any) {
        self.view.endEditing(true)  //キーボードを閉じる
        tgtBtn = "btn7"
        performSegue(withIdentifier: "searchSegue1", sender: self)
    }
    @IBAction func textFieldDidBegin8(_ sender: Any) {
        self.view.endEditing(true)  //キーボードを閉じる
        tgtBtn = "btn8"
        performSegue(withIdentifier: "searchSegue1", sender: self)
    }
    
    //画面遷移の前処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchSegue1"{
            let nextVC = segue.destination as! SearchLeaderController
            nextVC.delegate = self
        }
    }
    
    //リーダー選択画面が閉じられたときに実行される
    func store(data: String) {
        switch tgtBtn{
        case "btn1":
            leaderLabel1!.text = data
        case "btn2":
            leaderLabel2!.text = data
        case "btn3":
            leaderLabel3!.text = data
        case "btn4":
            leaderLabel4!.text = data
        case "btn5":
            leaderLabel5!.text = data
        case "btn6":
            leaderLabel6!.text = data
        case "btn7":
            leaderLabel7!.text = data
        case "btn8":
            leaderLabel8!.text = data
        default:
            print("何もしない")
        }
        tgtBtn = ""
    }
    
    func getStrDateForCurrentTimeZone(myDate: Date?) -> String {
        if(myDate == nil){ return ""}
        let df = DateFormatter()
        df.locale = Locale.current
        df.timeZone = TimeZone.current
        df.dateStyle = .short
        df.timeStyle = .short
        return df.string(from: myDate!)
    }
    
    //レコードの更新の場合に、レコードの値を画面に反映させる関数
    func recordReflectToScreen(r:BattleRecord){
        //winnerの設定
        winnerNum = r.winnerNum
        switch winnerNum{
        case 1:
            WinCheck1.setTitle("◉", for: .normal)
        case 2:
            winCheck2.setTitle("◉", for: .normal)
        case 3:
            winCheck3.setTitle("◉", for: .normal)
        case 4:
            winCheck4.setTitle("◉", for: .normal)
        default:
            print("何もしない")
        }
        //コマンダーの設定
        leaderLabel1!.text = r.commander1
        leaderLabel2!.text = r.commander2
        leaderLabel3!.text = r.commander3
        leaderLabel4!.text = r.commander4
        leaderLabel5!.text = r.commander5
        leaderLabel6!.text = r.commander6
        leaderLabel7!.text = r.commander7
        leaderLabel8!.text = r.commander8
        //プレイヤー名の設定も必要？
    }
    
    //画面の値をレコードに反映させる関数
    func screenReflectToRecord(r:BattleRecord){
        r.winnerNum = winnerNum
        r.commander1 = leaderLabel1!.text
        r.commander2 = leaderLabel2!.text
        r.commander3 = leaderLabel3!.text
        r.commander4 = leaderLabel4!.text
        r.commander5 = leaderLabel5!.text
        r.commander6 = leaderLabel6!.text
        r.commander7 = leaderLabel7!.text
        r.commander8 = leaderLabel8!.text
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
