//
//  ReportViewController.swift
//  RecordTableView
//
//  Created by おじぇ on 2022/10/26.
//

import UIKit
import Charts

struct chartStruct{
    let name:String
    let value:Int
}

class ReportViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var piChView: PieChartView!
    @IBOutlet weak var barChView: BarChartView!
    @IBOutlet weak var datePickerText: UITextField!
    
    @IBOutlet weak var btn: UIButton!
    
    
    
    let userDefaults = UserDefaults.standard  //ユーザデフォルト
    var filterPickerView:UIPickerView = UIPickerView()  //絞り込み用の選択リストビュー
    let datePickValY:[String] = ["2019","2020","2021","2022"]
    let datePickValM:[String] = ["1","2","3","4","5","6","7","8","9","10","11","12"]
    var pickerTempY:String = ""
    var pickerTempM:String = ""
    var barEntries:[BarChartDataEntry] = []  //リーダーの使用数の棒グラフ用配列
    var barChLabels:[String] = []  //棒グラフのラベルを一時的に保持する
    var pieEntries:[PieChartDataEntry] = []  //勝率のグラフ用配列
    var viewArray:[UIView] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadDisplay()
        switchingView(viewIdx:0)  //０番目のビューのみ表示
        
        //フィルターの設定
        datePickerText.placeholder = "Y/M Filter"
        filterPickerView.delegate = self
        filterPickerView.dataSource = self
        
        let toolbar = UIToolbar(frame: CGRect(x:0, y:0, width:0, height:35))
        let doneItem = UIBarButtonItem(barButtonSystemItem:.done, target:self, action:#selector(self.pickDone))
        let removeItem = UIBarButtonItem(title:"Remove", style:.plain, target:self, action:#selector(self.pickRemove))
        toolbar.setItems([removeItem, doneItem], animated:true)
        self.datePickerText.inputView = filterPickerView
        self.datePickerText.inputAccessoryView = toolbar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //タブ切り替え時に呼ばれる
    func didSelectTab(tabBarController: TabBarController) {
        guard userDefaults.bool(forKey:"isReloadedCharts")==false else {return}
        reloadDisplay()  //レポート再読み込み
    }
    
    //表のセグメント切り替え時に呼ばれるアクション
    @IBAction func ChartSegChangeAct(_ sender: UISegmentedControl) {
        let segIndex = sender.selectedSegmentIndex
        switchingView(viewIdx:segIndex)  //該当のビュー以外を非表示にする
    }
    
    //レコードを集計して表示用の配列に設定する関数
    func calcRecord() {
        let records = BattleRecord.getAll()  //レコードをまとめて取得
        var CMDNumList:[chartStruct] = []  //コマンダー毎の使用回数を保持する
        //var winCountList:[chartStruct] = []  //プレイヤー毎の優勝回数を保持する
        var CMDNumMap:[String:Int] = [:]  //key:コマンダー名、value:使用回数
        var winCount:[Int] = [0,0,0,0,0]  //プレイヤーごとの勝利回数計算用
        
        
        for record in records {
            //コマンダーごとの使用数を集計
            let CMDName1 = record.commander2! == "" ?record.commander1! : record.commander1! + "&" + record.commander2!
            let CMDName2 = record.commander4! == "" ?record.commander3! : record.commander3! + record.commander4!
            let CMDName3 = record.commander6! == "" ?record.commander5! : record.commander5! + record.commander6!
            let CMDName4 = record.commander8! == "" ?record.commander7! : record.commander7! + record.commander8!
            CMDNumMap[CMDName1] = CMDNumMap.keys.contains(CMDName1) ? CMDNumMap[CMDName1]! + 1 : 1
            CMDNumMap[CMDName2] = CMDNumMap.keys.contains(CMDName2) ? CMDNumMap[CMDName2]! + 1 : 1
            CMDNumMap[CMDName3] = CMDNumMap.keys.contains(CMDName3) ? CMDNumMap[CMDName3]! + 1 : 1
            CMDNumMap[CMDName4] = CMDNumMap.keys.contains(CMDName4) ? CMDNumMap[CMDName4]! + 1 : 1
            
            //プレイヤーごとの勝利回数を集計
            winCount[Int(record.winnerNum)] = winCount[Int(record.winnerNum)] + 1
        }
        
        //棒グラフ表示用の配列生成
        
        for (key,value) in CMDNumMap{
            CMDNumList.append(chartStruct(name:key, value:value))
        }
        CMDNumList.sort{$0.value > $1.value}  //降順に並べ替え
        var cnt:Double = 0
        for e in CMDNumList{
            barEntries.append(BarChartDataEntry(x:cnt, y:Double(e.value)))
            barChLabels.append(e.name)  //ラベルを配列で保持
            //barChLabels.append(String(Int(cnt+1)))
            cnt += 1
        }
        
        //円グラフ表示用の配列生成
        self.pieEntries = [
            PieChartDataEntry(value:Double(winCount[1]), label:"Player1"),
            PieChartDataEntry(value:Double(winCount[2]), label:"Player2"),
            PieChartDataEntry(value:Double(winCount[3]), label:"Player3"),
            PieChartDataEntry(value:Double(winCount[4]), label:"Player4")
        ]
        self.pieEntries.sort{$0.value > $1.value}  //降順に並び替え
    }
    
    
    
    //円グラフを生成する関数
    func createPieChart(){
        piChView.centerText = "プレイヤーごとの勝率"
        //piChView.chartDescription.text = "右下のテキスト"
        
        let dataSet = PieChartDataSet(entries: self.pieEntries, label: "")
        
        //グラフの色
        dataSet.colors = ChartColorTemplates.vordiplom()
        //グラフのデータの値の色
        dataSet.valueTextColor = UIColor.black
        //グラフのデータのタイトルの色
        dataSet.entryLabelColor = UIColor.black
        
        dataSet.drawValuesEnabled = true  //値をグラフ上に表示するかどうか
        
        piChView.data = PieChartData(dataSet: dataSet)
        
        //データを％表示にする
        let fmt = NumberFormatter()
        fmt.numberStyle = .percent
        fmt.maximumFractionDigits = 2
        fmt.multiplier = 1.0
        piChView.data?.setValueFormatter(DefaultValueFormatter(formatter: fmt))
        piChView.usePercentValuesEnabled = true  //値を%表示するかどうか
    }
    
    //棒グラフを生成する関数
    func createBarChart() {
        let screenW = UIScreen.main.bounds.width
        
        let dataSet = BarChartDataSet(entries: self.barEntries, label: "")
        //       let nf = NumberFormatter()
        //        nf.allowsFloats = false  //小数点禁止
        //        dataSet.valueFormatter = nf
        //dataSet.valueFormatter = ValueFormatter()
        
        barChView.data = BarChartData(dataSet: dataSet)
        
        //X軸のラベルを設定
        barChView.xAxis.valueFormatter = IndexAxisValueFormatter(values: barChLabels)
        barChView.xAxis.granularity = 1  //粒度
        barChView.xAxis.labelCount = barChLabels.count  //ラベルの数を指定
        barChView.xAxis.labelPosition = .bottom  //ラベルの位置を指定
        
        barChView.xAxis.labelRotationAngle = -30.0  //x軸ラベルを回転させる角度
        barChView.xAxis.wordWrapEnabled = true  //折り返し有効
        
        barChView.rightAxis.enabled = false  //右側のY座標軸を表示・非表示
        barChView.scaleYEnabled = false  //y軸方向にズームさせない
        //barChView.scaleXEnabled = false  //x軸方向にズームさせない
        barChView.doubleTapToZoomEnabled = false  //ダブルタップでズームさせない
        barChView.legend.enabled = false  //下の凡例を非表示
        barChView.setVisibleXRange(minXRange:1, maxXRange:screenW/75)  //x軸の幅の最大値と最小値
        
        
        
    }
    
    //グラフを全て再読み込みして画面業表示する
    func reloadDisplay(){
        barEntries = []
        pieEntries = []
        barChLabels = []
        viewArray = []
        
        calcRecord()  //レコードを集計して表示用配列に設定する
        createPieChart()  //円グラフを生成
        createBarChart()  //棒グラフを生成
        
        viewArray.append(barChView)
        viewArray.append(piChView)
        
        barChView.setNeedsDisplay()  //棒グラフの再描画
        piChView.setNeedsDisplay()  //円グラフの再描画
        
        userDefaults.set(true, forKey: "isReloadedCharts")  //レポート読み込み済みでフラグを設定
    }
    
    //表示させるUIViewをセグメント選択時に切り替える関数
    func switchingView(viewIdx:Int) {
        for i in 0..<viewArray.count {
            if(i == viewIdx){
                viewArray[i].isHidden = false
            }else{
                viewArray[i].isHidden = true
            }
        }
    }
    
    //----------------------イベント処理-----------------------
    //ピッカーの表示する列数を設定
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        //ピッカー表示時に、テキストフィールドに初期値を設定する
        if(pickerTempY == "" && pickerTempM == ""){
            pickerTempY = datePickValY[0]
            pickerTempM = datePickValM[0]
            self.datePickerText.text = pickerTempY + "/" + pickerTempM + "〜"
        }
        return 2
    }
    //ピッカーのリスト値の表示する個数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         
        return component == 0 ? datePickValY.count : datePickValM.count
    }
    // ピッカーの表示する値を設定
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0 ? datePickValY[row] : datePickValM[row]
    }
    //ピッカーの選択された値を随時テキストフィールドに設定する
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            self.datePickerText.text = datePickValY[row] + "/" + pickerTempM + "〜"
            pickerTempY = datePickValY[row]
        }else{
            self.datePickerText.text = pickerTempY + "/" + datePickValM[row] + "〜"
            pickerTempM = datePickValM[row]
        }
        
        //self.datePickerText.text = datePickValY[row]
    }
    //ピッカーのdoneボタン押下時の処理
    @objc func pickDone(){
        self.datePickerText.text = pickerTempY + "/" + pickerTempM + "〜"  //念のため値を設定し直す
        self.datePickerText.endEditing(true)  //ピッカーを閉じる
    }
    //ピッカーのremoveボタン押下時の処理
    @objc func pickRemove(){
        self.datePickerText.text = ""
        pickerTempY = ""
        pickerTempM = ""
        self.filterPickerView.selectRow(0, inComponent: 0, animated: false)  //ピッカーの回転位置をリセット
        self.filterPickerView.selectRow(0, inComponent: 1, animated: false)  //ピッカーの回転位置をリセット
        self.datePickerText.endEditing(true)
    }
    
    
}

public class ValueFormatter: NSObject,AxisValueFormatter {
    public func stringForValue(_ value: Double, axis: Charts.AxisBase?) -> String {
        return "aaa"
    }
    
    //var items:[String]
    //init(of items:[String]){
    //    self.items = items
    //    super.init(values: <#T##[String]#>)
    //}
    /*    public func stringForValue(_ value:Double, entry:ChartDataEntry, dataSetIndex:Int, viewPortHandler:ViewPortHandler?) -> String {
     //return "\(Int(value))"
     return "\(Int(entry.y))"
     }*/
}

