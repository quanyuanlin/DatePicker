//
//  CCHomeRentPickerView.swift
//  CheFu
//
//  Created by admin on 2018/12/12.
//  Copyright © 2018 Caffrey. All rights reserved.
//

import UIKit

let kOpenHour = "0:00-23:00"
let kScreenW = UIScreen.main.bounds.size.width
let kScreenH = UIScreen.main.bounds.size.height

enum CCRentPickerType{
    case getCarTime //开始时间
    case returnCarTime //结束时间
}

class CCRentDatePicker: UIView {
    /// 公有属性
    /// 开始日期（结束时间选择需传，其它不用）
    var getDate : Date!
    /// 选择种类
    var rentType : CCRentPickerType = .getCarTime
    /// 私有属性
    private var sureBlock: ((Date) -> ())?
    /// 存放所有的时间 数据源
    fileprivate var dataArray = [[String]]()
    /// 选中的pick
    fileprivate var selectRowList = [0,0,0]
    /// 选中的日期
    private var selectDate: Date!
    /// 判断时间是否可选
    fileprivate var isSelectable = false
    /// 营业时间
    fileprivate var busnissHour = ""
    ///  当前时间
    fileprivate var currentDate :Date{
        return Date()
    }
    /// 选中的内容
    fileprivate var selectTextList = ["","",""]{
        didSet{
            let str = selectTextList[0] + selectTextList[1] + ":" + selectTextList[2]
            self.selectDate = getPickerDate(str: str)
            if rentType == .getCarTime {
                if currentDate.compare(self.selectDate!) == .orderedDescending{//当前时间在选中时间之前则执行
                    if currentDate.timeIntervalSince(self.selectDate) > 60{
                        isSelectable = false
                        self.selectDate = currentDate.getLastestTime(self.busnissHour)
                        self.scrollToDate(self.selectDate)
                    }else{
                        isSelectable = true
                    }
                }else{
                    if self.getIsAvarible(date: self.selectDate){
                        isSelectable = true
                    }else{
                        isSelectable = false
                        self.scrollInBussnissHour()
                    }
                }
                
            }else{
                if getDate.compare(self.selectDate!) != .orderedAscending{ // 结束时间不在开始时间之前 升序
                    let timeInterval = TimeInterval(15*60)
                    let newDate = getDate.addingTimeInterval(timeInterval)
                    if self.getIsAvarible(date: newDate){
                        self.scrollToDate(newDate)
                    }else{
                        let oneDayInterval = TimeInterval(24*60*60)
                        let secondDate = getDate.addingTimeInterval(oneDayInterval)
                        self.scrollToDate(secondDate)
                    }
                }else{
                    if self.getIsAvarible(date: self.selectDate){
                        isSelectable = true
                    }else{
                        isSelectable = false
                        self.scrollInBussnissHour()
                    }
                }
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH))
        self.backgroundColor = UIColor.black
        self.alpha = 0.6
        createUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// 界面
    private func createUI(){
        addSubview(backView)
        backView.addSubview(datePicker)
        backView.addSubview(lineView)
        backView.addSubview(titleLB)
        backView.addSubview(cancelBtn)
        backView.addSubview(sureBtn)
        cancelBtn.addTarget(self, action: #selector(clickCancelBtn), for: UIControlEvents.touchUpInside)
        sureBtn.addTarget(self, action: #selector(clickSureBtn), for: UIControlEvents.touchUpInside)
    }
    //设置时间
    func setData(_ busnissHour : String){
        if rentType == .getCarTime{
            self.titleLB.text = "设置开始时间"
        }else{
            self.titleLB.text = "设置结束时间"
        }
        self.busnissHour = busnissHour
        getData()
    }
    // 设置选中时间
    func setSelectDate(date :Date){
        self.selectDate = date
        self.scrollToDate(date)
        self.datePicker.reloadAllComponents()
    }
    /// 获得数据
    fileprivate func getData(){
        var openHour = self.busnissHour
        if openHour.count == 0{
            openHour = kOpenHour
        }
        var hourArray = openHour.components(separatedBy: "-")
        if hourArray.count != 2{
            hourArray = ["0:00","23:00"]
        }
        let startTime =  hourArray[0].components(separatedBy: ":").first ?? "0"
        let endTIme = hourArray[1].components(separatedBy: ":").first ?? "23"
        let startHour = Int (startTime) ?? 0
        let endHour = Int(endTIme) ?? 0
        
        dataArray.removeAll()
        var days = [String]()
        for i in 0...30{
            let future = currentDate.getAfterTime(day: i, dateFormat: "yyyy年MM月dd日eeee")
            days.append(future)
        }
        
        let comps = currentDate.dateComponent()
        if comps.hour ?? 0 > endHour{
            days.remove(at: 0)
        }else if comps.hour ?? 0 == endHour && comps.minute ?? 0 > 0{
            days.remove(at: 0)
        }
        
        dataArray.append(days)
        
        var hours = [String]()
        for i in startHour...endHour {
            hours.append(String(i))
        }
        dataArray.append(hours)
        
        var minutes = [String]()
        for i in 0..<4 {
            minutes.append(String(i*15))
        }
        dataArray.append(minutes)
        self.datePicker.reloadAllComponents()
    }
    ///滚动选中日期
    private func scrollToDate(_ date:Date){
        let comps = date.dateComponent()
        let hour = comps.hour
        let minute = comps.minute
        let dateStr = date.string(dateFormat: "yyyy年MM月dd日eeee")
        var dateRow = 0
        for (n,str) in dataArray[0].enumerated() {
            if dateStr == str{
                dateRow = n
                break
            }
        }
        
        var hourRow = 0
        for (n,hours) in dataArray[1].enumerated() {
            if hour == Int(hours){
                hourRow = n
                break
            }
        }
        var minuteRow = 0
        for (n,minutes) in dataArray[2].enumerated() {
            if minute! == Int(minutes){
                minuteRow = n
                break
            }
        }
        self.datePicker.selectRow(dateRow, inComponent: 0, animated: true)
        self.datePicker.selectRow(hourRow, inComponent: 1, animated: true)
        self.datePicker.selectRow(minuteRow, inComponent: 2, animated: true)
        selectRowList = [dateRow,hourRow,minuteRow]
        selectTextList = [dataArray[0][dateRow],dataArray[1][hourRow],dataArray[2][minuteRow]]
    }
    ///滚动到营业时间范围内
    fileprivate func scrollInBussnissHour(){
        selectRowList[2] = 0
        selectTextList[2] = "0"
        self.datePicker.selectRow(0, inComponent: 2, animated: true)
        isSelectable = true
        let newStr = selectTextList[0] + selectTextList[1] + ":" + selectTextList[2]
        self.selectDate = self.getPickerDate(str: newStr)
    }
    ///判断时间是否在营业时间
    fileprivate func getIsAvarible(date: Date) -> Bool{
        let endHour = Int(dataArray[1].last!) ?? 0
        let comps = date.dateComponent()
        var isIn = false
        if comps.hour ?? 0 > endHour{
            isIn = false
        }else if comps.hour ?? 0 == endHour && comps.minute ?? 0 > 0{
            isIn = false
        }else{
            isIn = true
        }
        return isIn
    }
    ///转化选中日期
    fileprivate func getPickerDate(str: String) -> Date{
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年MM月dd日eeeeH:m"
        formatter.weekdaySymbols = ["周日","周一","周二","周三","周四","周五","周六"]
        let date = formatter.date(from: str)
        return date!
    }
    /// 弹出时间选择界面
    func showView(doneBlock: @escaping (Date) -> ()){
        UIApplication.shared.keyWindow?.addSubview(self)
        self.sureBlock = doneBlock
    }
    @objc func hiddenView(){
        self.removeFromSuperview()
    }
    @objc private func clickCancelBtn(){
        hiddenView()
    }
    @objc private func clickSureBtn(){
        hiddenView()
        sureBlock?(self.selectDate)
    }
    //MARK: - 懒加载
    /// 时间选择
    lazy fileprivate var datePicker: UIPickerView = {
        let picker = UIPickerView(frame: CGRect(x: 0, y: 50, width: kScreenW, height: 220))
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    /// 背景
    fileprivate lazy var backView: UIView = {
        let backView = UIView(frame: CGRect(x: 0, y: kScreenH - 270, width: kScreenW, height: 270))
        backView.backgroundColor = UIColor.white
        
        ///添加点击方法
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenView))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(tap)
        return backView
    }()
    /// 标题
    fileprivate lazy var titleLB: UILabel = {
        let lb = UILabel(frame: CGRect(x: 80, y: 0, width: kScreenW - 160, height: 50))
        lb.font = UIFont.systemFont(ofSize: 18)
        lb.textColor = UIColor.darkText
        lb.textAlignment = .center
        return lb
    }()
    ///分割线
    fileprivate lazy var lineView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 50, width: kScreenW, height: 1))
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    /// 取消按钮
    fileprivate lazy var cancelBtn: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 72, height: 50))
        button.setTitle("取消", for: UIControlState.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(UIColor.black, for: UIControlState.normal)
        return button
    }()
    /// 确定按钮
    fileprivate lazy var sureBtn: UIButton = {
        let button = UIButton(frame: CGRect(x: kScreenW - 72, y: 0, width: 72, height: 50))
        button.setTitle("确定", for: UIControlState.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(UIColor.black, for: UIControlState.normal)
        return button
    }()
}
//MARK: - PickerViewDelegate
extension CCRentDatePicker: UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return dataArray.count
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataArray[component].count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        for view in pickerView.subviews{
            if view.frame.height < 1{
                view.isHidden = true
            }
        }
        let title = dataArray[component][row]
        if component == 0  {
            let index = title.index(title.index(of: "年")!, offsetBy: 1)
            return String(title.suffix(from : index))
        }else if component == 1{
            return title + "点"
        }else if component == 2{
            return title + "分"
        }
        return title
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var lab = view as? UILabel
        if lab == nil{
            lab = UILabel()
            lab?.font = UIFont.systemFont(ofSize: 20)
            lab?.textColor = UIColor.black
            lab?.backgroundColor = UIColor.clear
            lab?.textAlignment = .center
        }
        lab?.text = self.pickerView(datePicker, titleForRow: row, forComponent: component)
        return lab!
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 0 {
            return 165
        }
        return 88
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectRowList[component] = row
        selectTextList[component] = dataArray[component][row]
        pickerView.reloadAllComponents()
    }
}
//MARK: - Date扩充方法
extension Date{
    /// 获得未来的时间
    func getAfterTime(day: Int, dateFormat: String) -> String{
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var comps = DateComponents()
        comps.timeZone = TimeZone(abbreviation: "GMT+0800")
        let formatter = DateFormatter()
        comps.day = day
        formatter.weekdaySymbols = ["周日","周一","周二","周三","周四","周五","周六"]
        formatter.dateFormat = dateFormat
        let date = calendar.date(byAdding: comps, to: self)
        let dateStr:String = formatter.string(from: date!)
        return dateStr
    }
    ///  获取最近的日期 以十五分钟为间隔
    func getLastestTime(_ busnissHour: String) -> Date{
        var openHour = busnissHour
        if openHour.count == 0{
            openHour = kOpenHour
        }
        var hourArray = openHour.components(separatedBy: "-")
        if hourArray.count != 2{
            hourArray = ["0:00","23:00"]
        }
        let startTime =  hourArray[0].components(separatedBy: ":").first ?? "0"
        let endTIme = hourArray[1].components(separatedBy: ":").first ?? "23"
        let startHour = Int (startTime) ?? 0
        let endHour = Int(endTIme) ?? 0
        
        var comps = self.dateComponent()
        if comps.hour ?? 0 > endHour{
            comps.day = (comps.day ?? 0) + 1
            comps.hour = startHour
            comps.minute = 0
        }else if comps.hour ?? 0 < startHour{
            comps.hour = startHour
            comps.minute = 0
        }else if comps.hour ?? 0 == endHour && comps.minute ?? 0 > 0 {
            comps.day = (comps.day ?? 0) + 1
            comps.hour = startHour
            comps.minute = 0
        }else{
            let minute = comps.minute ?? 0
            if minute > 0 && minute <= 15 {
                comps.minute = 15
            }else if minute > 15 && minute <= 30{
                comps.minute = 30
            }else if minute > 30 && minute <= 45{
                comps.minute = 45
            }else if minute > 45 && minute < 60{
                comps.minute = 0
                comps.hour = (comps.hour ?? 0) + 1
            }else if minute == 0{
                comps.minute = 0
            }
        }
        comps.second = 0
        let newDate = Calendar.current.date(from: comps)
        
        return newDate!
    }
    ///计算时间差
    func getBetweenHours(toDate: Date) -> Int{
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var comps = calendar.dateComponents(Set(arrayLiteral: Calendar.Component.hour,Calendar.Component.minute,Calendar.Component.second), from: self, to: toDate)
        comps.timeZone = TimeZone(abbreviation: "GMT+0800")
        if comps.minute ?? 0 > 0 {
            comps.hour = (comps.hour ?? 0) + 1
        }
        return comps.hour ?? 0
    }
    // 获取年月日时分秒
    func dateComponent() -> DateComponents {
        
        let calendar = Calendar.autoupdatingCurrent
        let unitFlags = Set.init(arrayLiteral: .year, .month, .day, .hour, .minute, Calendar.Component.second, .weekday)
        let component = calendar.dateComponents(unitFlags, from: self)
        
        return component
    }
    //字符串转化日期
    func string(dateFormat: String) -> String{
        let dateForm = DateFormatter()
        dateForm.dateFormat = dateFormat
        dateForm.timeZone = TimeZone(identifier: "beijing")
        dateForm.weekdaySymbols = ["周日","周一","周二","周三","周四","周五","周六"]
        return dateForm.string(from: self)
    }
}
extension String{
    func dateFormatTime(dateFormat: String) -> Date{
        
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = dateFormat
        let newDate = dateFormatter.date(from: self)
        return newDate!
    }
}




