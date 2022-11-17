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
    @IBOutlet weak var winBarChView: BarChartView!
    @IBOutlet weak var datePickerText: UITextField!
    
    
    let userDefaults = UserDefaults.standard  //ユーザデフォルト
    var filterPickerView:UIPickerView = UIPickerView()  //絞り込み用の選択リストビュー
    var datePickValY:[String] = []
    let datePickValM:[String] = ["1","2","3","4","5","6","7","8","9","10","11","12"]
    var pickerY = ""  //ピッカーで選択した値を保持
    var pickerM = ""
    var pickerTempY:String = ""  //キャンセル押された時は前回フィルター時の値に戻したいため、done押される前はtempに保持させる
    var pickerTempM:String = ""
    var barEntries:[BarChartDataEntry] = []  //リーダーの使用数の棒グラフ用配列
    var barChLabels:[String] = []  //棒グラフのラベルを一時的に保持する
    var usedNumSum:Int = 0  //リーダーの使用回数の合計値を保持する
    var winBarEntries:[BarChartDataEntry] = []  //リーダーの勝率の棒グラフ用配列
    var winBarChLabels:[String] = []  //ラベルを保持
    var winNumSum:Int = 0  //勝者が決まったバトルの合計数を保持する
    var pieEntries:[PieChartDataEntry] = []  //勝率のグラフ用配列
    var viewArray:[UIView] = []
    var isAnimatedArray:[Bool] = []
    var segCurrentIndex:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ビューの高さを下の広告と被らないよう調整
        fitViewBottomToAd(chView: barChView, topHeight: 175)
        fitViewBottomToAd(chView: winBarChView, topHeight: 175)
        fitViewBottomToAd(chView: piChView, topHeight: 175)
        
        //フィルターの設定
        datePickValY = createDatePickArrY()  //年のリスト値を生成
        datePickerText.placeholder = "Y/M Filter"
        filterPickerView.delegate = self
        filterPickerView.dataSource = self
        let toolbar = UIToolbar(frame: CGRect(x:0, y:0, width:0, height:35))
        let doneItem = UIBarButtonItem(barButtonSystemItem:.done, target:self, action:#selector(self.pickDone))
        let removeItem = UIBarButtonItem(title:"Remove", style:.plain, target:self, action:#selector(self.pickRemove))
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.pickCancel))
        toolbar.setItems([cancelItem , spaceItem, removeItem, doneItem], animated:true)
        self.datePickerText.inputView = filterPickerView
        self.datePickerText.inputAccessoryView = toolbar
        
        //前回起動時のフィルタを取得
        var whereStr = ""
        var filteredStr:String? = userDefaults.string(forKey:"filteredWhereStr")
        if(filteredStr == nil){
            userDefaults.set("", forKey: "filteredWhereStr")  //nilということはユーザデフォルトにもないということなので初期値設定
            filteredStr = ""
        }
        if(filteredStr != ""){
            let ymParam:[String] = filteredStr!.components(separatedBy:"/")
            datePickerText.text = filteredStr! + "〜"
            pickerY = ymParam[0]
            pickerM = ymParam[1]
            pickerTempY = pickerY
            pickerTempM = pickerM
            whereStr = createWhereStr(y:pickerY, m:pickerM)
        }
        self.filterPickerView.selectRow(datePickValY.firstIndex(of: pickerY) ?? datePickValY.count-1, inComponent:0, animated:false)  //年のピッカーの回転位置を反映
        self.filterPickerView.selectRow(datePickValM.firstIndex(of: pickerM) ?? 0, inComponent:1, animated:false)  //月のピッカーの回転位置を反映
        
        reloadDisplay(filtererdStr: whereStr)  //グラフ生成
        switchingView(viewIdx:0)  //０番目のビューのみ表示
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //タブ切り替え時に呼ばれる
    func didSelectTab(tabBarController: TabBarController) {
        guard userDefaults.bool(forKey:"isReloadedCharts")==false else {return}
        reloadDisplay(filtererdStr: createWhereStr(y:pickerY, m:pickerM))  //レポート再読み込み Y,Mが空だったら空が返ってくる
        isAnimatedArray[segCurrentIndex] = true
    }
    
    //表のセグメント切り替え時に呼ばれるアクション
    @IBAction func ChartSegChangeAct(_ sender: UISegmentedControl) {
        segCurrentIndex = sender.selectedSegmentIndex
        switchingView(viewIdx:segCurrentIndex)  //該当のビュー以外を非表示にする
    }
    
    //レコードを集計して表示用の配列に設定する関数
    func calcRecord(whereStr:String) {
        let records = BattleRecord.getAll(whereStr:whereStr)  //レコードをまとめて取得
        var CMDNumList:[chartStruct] = []  //コマンダー毎の使用回数を保持する
        var CMDNumMap:[String:Int] = [:]  //key:コマンダー名、value:使用回数
        var CMDWinNumList:[chartStruct] = []  //コマンダー毎の勝利回数を保持する
        var CMDWinNumMap:[String:Int] = [:]  //key:コマンダー名、value:勝利回数
        var winCount:[Int] = [0,0,0,0,0]  //プレイヤーごとの勝利回数計算用
        usedNumSum = 0
        winNumSum = 0
        
        
        for record in records {
            //コマンダーごとの使用数を集計
            let CMDName1 = newLine(str: record.commander2! == "" ?record.commander1! : record.commander1! + " &" + record.commander2!)
            let CMDName2 = newLine(str: record.commander4! == "" ?record.commander3! : record.commander3! + " &" + record.commander4!)
            let CMDName3 = newLine(str: record.commander6! == "" ?record.commander5! : record.commander5! + " &" + record.commander6!)
            let CMDName4 = newLine(str: record.commander8! == "" ?record.commander7! : record.commander7! + " &" + record.commander8!)
            CMDNumMap[CMDName1] = CMDNumMap.keys.contains(CMDName1) ? CMDNumMap[CMDName1]! + 1 : 1
            CMDNumMap[CMDName2] = CMDNumMap.keys.contains(CMDName2) ? CMDNumMap[CMDName2]! + 1 : 1
            CMDNumMap[CMDName3] = CMDNumMap.keys.contains(CMDName3) ? CMDNumMap[CMDName3]! + 1 : 1
            CMDNumMap[CMDName4] = CMDNumMap.keys.contains(CMDName4) ? CMDNumMap[CMDName4]! + 1 : 1
            
            //コマンダー毎の勝利回数を集計
            switch Int(record.winnerNum) {
            case 1:
                CMDWinNumMap[CMDName1] = CMDWinNumMap.keys.contains(CMDName1) ? CMDWinNumMap[CMDName1]! + 1 : 1
            case 2:
                CMDWinNumMap[CMDName2] = CMDWinNumMap.keys.contains(CMDName2) ? CMDWinNumMap[CMDName2]! + 1 : 1
            case 3:
                CMDWinNumMap[CMDName3] = CMDWinNumMap.keys.contains(CMDName3) ? CMDWinNumMap[CMDName3]! + 1 : 1
            case 4:
                CMDWinNumMap[CMDName4] = CMDWinNumMap.keys.contains(CMDName4) ? CMDWinNumMap[CMDName4]! + 1 : 1
            default:
                print("何もしない")
            }
            if(Int(record.winnerNum) != 0){ winNumSum += 1 }
            
            //プレイヤーごとの勝利回数を集計
            winCount[Int(record.winnerNum)] += 1
        }
        
        //棒グラフ表示用の配列生成
        for (key,value) in CMDNumMap{
            CMDNumList.append(chartStruct(name:key, value:value))
        }
        CMDNumList.sort{$0.value > $1.value}  //降順に並べ替え barEntriesとbarChLabelsのindex番号を一致させるために先に並び替える
        var cnt:Double = 0
        for  e in CMDNumList{
            barEntries.append(BarChartDataEntry(x:cnt, y:Double(e.value)))
            barChLabels.append(e.name)  //ラベルを配列で保持
            usedNumSum += e.value
            cnt += 1
        }
        
        //棒グラフ（リーダーごとの勝率）表示用の配列生成
        for (key,value) in CMDWinNumMap{
            CMDWinNumList.append(chartStruct(name:key, value:value))
        }
        CMDWinNumList.sort{$0.value > $1.value}  //降順に並べ替え
        cnt = 0
        for e in CMDWinNumList{
            winBarEntries.append(BarChartDataEntry(x:cnt, y:Double(e.value) / Double(winNumSum)))
            winBarChLabels.append(e.name)  //ラベルを配列で保持
            cnt += 1
        }
        
        //円グラフ表示用の配列生成
        pieEntries = [
            PieChartDataEntry(value:Double(winCount[1]), label:"Player1"),
            PieChartDataEntry(value:Double(winCount[2]), label:"Player2"),
            PieChartDataEntry(value:Double(winCount[3]), label:"Player3"),
            PieChartDataEntry(value:Double(winCount[4]), label:"Player4")
        ]
        pieEntries.sort{$0.value > $1.value}  //降順に並び替え
    }
    
    
    //円グラフを生成する関数
    func createPieChart(){
        guard pieEntries[0].value != 0 || pieEntries[1].value != 0 || pieEntries[2].value != 0 || pieEntries[3].value != 0 else {
            piChView.data = nil
            return
        }
        //piChView.centerText = "プレイヤーごとの勝率"
        //piChView.chartDescription.text = "右下のテキスト"
        let dataSet = PieChartDataSet(entries:self.pieEntries, label:"")
        //グラフの色
        dataSet.colors = [UIColor(red:61/255, green:133/255, blue:198/255, alpha:1)
                          ,UIColor(red:164/255, green:194/255, blue:244/255, alpha:1)
                          ,UIColor(red:183/255, green:183/255, blue:183/255, alpha:1)
                          ,UIColor(red:217/255, green:217/255, blue:217/255, alpha:1)]
        piChView.data = PieChartData(dataSet: dataSet)
        
        piChView.drawHoleEnabled = false  //中心のをくり抜くかどうか
        piChView.rotationEnabled = false  //回転させない
        piChView.highlightPerTapEnabled = false  //タップ時のハイライトをさせない
        piChView.animate(yAxisDuration: 0.8)  //アニメーションをつける
        
        //データを％表示にする
        let fmt = NumberFormatter()
        fmt.numberStyle = .percent
        fmt.maximumFractionDigits = 2
        fmt.multiplier = 1.0
        piChView.data?.setValueFormatter(DefaultValueFormatter(formatter: fmt))
        piChView.usePercentValuesEnabled = true  //値を%表示するかどうか
        piChView.legend.enabled = false  //凡例を非表示
    }
    
    //棒グラフを生成する関数
    func createBarChart(chType:String, chView:BarChartView, entries:[BarChartDataEntry], chLabels:[String], numSum:Int) {
        let screenW = UIScreen.main.bounds.width
        
        guard 1 <= entries.count else {
            chView.data = nil
            return
        }
        //表を設定
        let dataSet = BarChartDataSet(entries:entries, label: "")
        let data = BarChartData(dataSet: dataSet)
        
        chView.xAxis.labelCount = chLabels.count  //ラベルの数を指定
        chView.xAxis.valueFormatter = IndexAxisValueFormatter(values: chLabels)  //X軸のラベルを設定
        
        //全体の設定
        chView.animate(xAxisDuration:0.5, yAxisDuration:0.5)  //アニメーションをつける
        chView.scaleYEnabled = false  //y軸方向にズームさせない
        //chView.scaleXEnabled = false  //x軸方向にズームさせない
        chView.doubleTapToZoomEnabled = false  //ダブルタップでズームさせない
        chView.legend.enabled = false  //下の凡例を非表示
        chView.highlightPerTapEnabled = false  //タップ時のハイライトをしない
        chView.highlightPerDragEnabled = false  //ドラッグ時のハイライトをしない
        
        //X軸の設定
        chView.xAxis.granularity = 1  //x軸の粒度
        chView.xAxis.labelPosition = .bottom  //ラベルの位置を指定
        chView.xAxis.labelRotationAngle = 50.0  //x軸ラベルを回転させる角度
        chView.xAxis.centerAxisLabelsEnabled = true  //x軸ラベルの位置を、棒の中央から始まるようにする
        chView.xAxis.drawGridLinesEnabled = false  //x軸のグリッドを非表示
        if(Int(screenW/60) <= chLabels.count){
            let lastElemLabelLen = getNewLineLength(str:chLabels[chLabels.count - 1])
            chView.extraRightOffset = CGFloat(lastElemLabelLen) * 1.8 + 10  //ラベルがはみ出るため右側のpaddingを微調整
        }
        
        //y軸の設定
        chView.rightAxis.enabled = false  //右側のY座標軸を表示・非表示
        chView.leftAxis.axisMinimum = 0  // Y座標の値が0始まりになるように設定
        chView.leftAxis.labelTextColor = .gray  // 左のy座標軸の色を設定
        
        //dataセット
        //x軸の設定をした後でdataセットしないと、ラベルを含めた高さに自動調整してくれない
        //formatterを設定する前でセットしないと、formattrが反映されない
        chView.data = data
        if(chType == "usedNum"){  //使用回数の表の場合
            dataSet.colors = [UIColor(red:109/255, green:158/255, blue:235/255, alpha:1)]  //バーの色設定　ブルー
            chView.leftAxis.granularity = 1  //y軸の粒度
            //アベレージの線を設定
            if(1 <= chLabels.count){
                let limitLine = ChartLimitLine(limit: Double(numSum) / Double(chLabels.count))
                limitLine.lineColor = .systemOrange
                limitLine.lineDashLengths = [3]
                chView.leftAxis.removeAllLimitLines()  //平均線を一度削除　更新時に元の線が消えないため
                chView.leftAxis.addLimitLine(limitLine)
            }
            //y軸の値を整数表示にする
            let fmt = NumberFormatter()
            chView.data?.setValueFormatter(DefaultValueFormatter(formatter: fmt))
        }else if(chType == "winRate"){  //勝率の表の場合
            dataSet.colors = [UIColor(red:243/255, green:178/255, blue:106/255, alpha:1)]  //バーの色設定　オレンジ
            chView.leftAxis.granularity = 0.1  //y軸の粒度
            chView.leftAxis.axisMaximum = 1 //y左軸最大値
            chView.leftAxis.valueFormatter = BarChartFormatter()  //左のy座標軸を％表示
            //y軸の値を%表示
            let fmt = NumberFormatter()
            fmt.numberStyle = .percent
            fmt.maximumFractionDigits = 2  //小数点以下の桁数
            fmt.multiplier = 100.0  //乗数
            chView.data?.setValueFormatter(DefaultValueFormatter(formatter: fmt))
        }
        chView.setVisibleXRange(minXRange:screenW/60, maxXRange:screenW/60)  //x軸の表示する幅の最大値と最小値　dataセットした後じゃないと反映されない
        
    }
    
    
    //グラフを全て再読み込みして画面際表示する
    func reloadDisplay(filtererdStr:String){
        barEntries = []
        winBarEntries = []
        pieEntries = []
        barChLabels = []
        winBarChLabels = []
        viewArray = []
        isAnimatedArray = []
        
        calcRecord(whereStr: filtererdStr)  //レコードを集計して表示用配列に設定する
        createPieChart()  //円グラフを生成
        createBarChart(chType:"usedNum",chView:barChView, entries:barEntries, chLabels:barChLabels, numSum:usedNumSum)  //棒グラフを生成
        createBarChart(chType:"winRate", chView:winBarChView, entries:winBarEntries, chLabels:winBarChLabels, numSum:winNumSum)  //棒グラフを生成
        
        viewArray.append(barChView)
        isAnimatedArray.append(false)
        viewArray.append(winBarChView)
        isAnimatedArray.append(false)
        viewArray.append(piChView)
        isAnimatedArray.append(false)
        
        barChView.setNeedsDisplay()  //棒グラフの再描画
        winBarChView.setNeedsLayout()
        piChView.setNeedsDisplay()  //円グラフの再描画
        
        userDefaults.set(true, forKey: "isReloadedCharts")  //レポート読み込み済みでフラグを設定
    }
    
    //表示させるUIViewをセグメント選択時に切り替える関数
    func switchingView(viewIdx:Int) {
        for i in 0..<viewArray.count {
            if(i == viewIdx){
                if(isAnimatedArray[i] == false){
                    piChView.animate(yAxisDuration: 0.8)  //円グラフのアニメーション
                    barChView.animate(xAxisDuration:0.5, yAxisDuration:0.5)  //棒グラフのアニメーション
                    winBarChView.animate(xAxisDuration:0.5, yAxisDuration:0.5)  //棒グラフのアニメーション
                    isAnimatedArray[i] = true
                }
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
        print("ピッカーの設定通ったよ")
        if(pickerY == "" || pickerM == ""){
            pickerTempY = datePickValY[0]
            pickerTempM = datePickValM[0]
        }else{
            pickerTempY = pickerY
            pickerTempM = pickerM
        }
        if(self.datePickerText.isEditing){  //画面初回起動時にも初期値が設定されてしまうため、ピッカー表示時の読み込みの時のみ設定する
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
            pickerTempY = datePickValY[row]
        }else{
            pickerTempM = datePickValM[row]
        }
        self.datePickerText.text = pickerTempY + "/" + pickerTempM + "〜"
    }
    //ピッカーのdoneボタン押下時の処理
    @objc func pickDone(){
        pickerY = pickerTempY
        pickerM = pickerTempM
        let yearMonth = pickerY + "/" + pickerM
        self.datePickerText.text = yearMonth + "〜"  //念のため画面の入力ボックスに設定し直す(コピペで変な値を入力された時用)
        self.datePickerText.endEditing(true)  //ピッカーを閉じる
        
        let whereStr = createWhereStr(y:pickerY, m:pickerM)  //WHERE句文字を生成
        
        reloadDisplay(filtererdStr: whereStr)  //条件を指定してグラフを再読み込み
        userDefaults.set(yearMonth, forKey: "filteredWhereStr")  //ユーザデフォルトに設定 "yyyy/m"の形で保持させる
    }
    //ピッカーのremoveボタン押下時の処理
    @objc func pickRemove(){
        self.datePickerText.text = ""
        pickerY = ""
        pickerM = ""
        pickerTempY = ""
        pickerTempM = ""
        self.filterPickerView.selectRow(datePickValY.count-1, inComponent: 0, animated: false)  //ピッカーの回転位置をリセット
        self.filterPickerView.selectRow(0, inComponent: 1, animated: false)  //ピッカーの回転位置をリセット
        self.datePickerText.endEditing(true)  //ピッカーを閉じる
        
        reloadDisplay(filtererdStr: "")  //グラフの再読み込み
        userDefaults.set("", forKey: "filteredWhereStr")  //ユーザデフォルトに設定
    }
    
//TODO  ピッカーのcancelボタン押下時の処理
    @objc func pickCancel(){
        let txt = pickerY == "" ? "" : pickerY + "/" + pickerM + "〜"  //フィルタの値をtempじゃない方に戻す
        self.datePickerText.text = txt
        pickerTempY = ""
        pickerTempM = ""
        
        self.filterPickerView.selectRow(datePickValY.firstIndex(of: pickerY) ?? datePickValY.count-1, inComponent:0, animated:false)  //年のピッカーの回転位置をリセット
        self.filterPickerView.selectRow(datePickValM.firstIndex(of: pickerM) ?? 0, inComponent:1, animated:false)  //月のピッカーの回転位置をリセット
        
        self.datePickerText.endEditing(true)  //ピッカーを閉じる
    }
    
    //フィルターの選択リスト（年）を生成　[1990〜端末のタイムゾーンの年]
    func createDatePickArrY() -> [String]{
        var resultArr:[String] = []
        let startYear = 1990
        var endYear = 2300
        let df = DateFormatter()
        df.locale = Locale.current
        df.timeZone = TimeZone.current
        df.dateFormat = "yyyy"
        endYear = Int(df.string(from: Date()))!
        for i in startYear..<endYear+1{
            resultArr.append(String(i))
        }
        return resultArr
    }
    
    //1行がlineLenの文字数を超えた場合に、次にくる空白で改行する関数
    /*func newLine(str:String, lineLen:Int) -> String {
        var cnt = 0
        var resultStr = ""
        Array(str).forEach{
            cnt += 1
            if(cnt >= lineLen && ($0 == " " || $0 == "&")){
                resultStr.append($0 == " " ? "\n" : "\n&")
                cnt = 0
            }else{
                resultStr.append($0)
            }
        }
        return resultStr
    }*/
    //1行がlineSafeLenの値に一番近くなるように前後の空白で改行を入れる関数
    func newLine(str:String) -> String {
        let lineSafeLen = 20  //1行の長さ
        var beforeAddingLen = 0
        var sumLen = -1
        var resultStr = ""
        let wordArr = str.components(separatedBy: " ")
        
        for (i,word) in wordArr.enumerated() {
            let thisLen = Array(word).count
            sumLen += (thisLen + 1)
            if(sumLen >= lineSafeLen){
                if(lineSafeLen - beforeAddingLen <= sumLen - lineSafeLen){
                    resultStr.append("\n" + word)
                    beforeAddingLen = thisLen
                    sumLen = thisLen
                }else{
                    resultStr.append(beforeAddingLen == 0 ? word : " " + word)  //行の先頭だったら空白入れない
                    resultStr.append(i == wordArr.count-1 ? "" : "\n")  //最後の要素だったら改行入れない
                    beforeAddingLen = 0
                    sumLen = -1
                }
            }else{
                resultStr.append(beforeAddingLen == 0 ? word : " " + word)
                beforeAddingLen = sumLen
            }
            
        }
        return resultStr
    }
    
    //改行コードで区切ったときに、一番長い行の文字数を返す関数
    func getNewLineLength(str:String) -> Int {
        var maxLen = 0
        var cnt = -1  //0から開始させたいためforEach内の+1を考慮して初期値を-1とする
        Array(str).forEach{
            cnt += 1
            if($0 == "\n"){
                maxLen = max(maxLen, cnt)  //大きい方を保持
                cnt = -1
            }
        }
        maxLen = max(maxLen,cnt)  //最後の行は改行文字がないためforEach後にもう一度判定
        return maxLen
    }
    
    //年と月からWHERE句文字列を生成して返す
    func createWhereStr(y:String, m:String) -> String{
        if(y == "" || m == ""){return ""}
        
        let strDate = getStrDateForCurrentTimeZone(y: y, m: m)
        return "createdDateStr >= '" + strDate + "'"
    }
    
    //端末のタイムゾーンを考慮した日時をテキストで返す関数
    func getStrDateForCurrentTimeZone(y:String,m:String) -> String {
        if(y.isEmpty || m.isEmpty){return ""}
        //dateを生成
        let calendar = Calendar(identifier: .gregorian)
        let myDate = calendar.date(from: DateComponents(year: Int(y), month: Int(m), day: 1))
        
        let df = DateFormatter()
        df.locale = Locale.current
        df.timeZone = TimeZone.current
        df.dateStyle = .short
        df.timeStyle = .short
        return df.string(from: myDate!)
    }
    
    //ビューの高さを広告と被らないように調整
    func fitViewBottomToAd(chView:UIView, topHeight:CGFloat){
        let tabBarHeight = 48.0
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        let viewHeight = screenHeight - topHeight - tabBarHeight - TabBarController.bannerAdHeight
        chView.translatesAutoresizingMaskIntoConstraints = false  //AutoresizingMaskを無効化してAutoLayoutにする
        chView.topAnchor.constraint(equalTo: view.topAnchor, constant: topHeight).isActive = true
        chView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        chView.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
        chView.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
    }
    
}

//棒グラフのY座標軸を％表示するためのクラス
public class BarChartFormatter: NSObject, AxisValueFormatter{
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return String(Int(value * 100)) + "%"
    }
}

