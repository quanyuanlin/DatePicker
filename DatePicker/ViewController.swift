//
//  ViewController.swift
//  DatePicker
//
//  Created by admin on 2018/12/17.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    fileprivate var getDate = Date().getLastestTime(kOpenHour)
    fileprivate var returnDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let timeInterval = TimeInterval(2*24*60*60)
        returnDate = getDate.addingTimeInterval(timeInterval)
        
        self.view.addSubview(getBtn)
        self.view.addSubview(returnBtn)
    }
    
    @objc private func clickGetBtn(){
        self.getPickView.setData(kOpenHour)
        self.getPickView.setSelectDate(date: getDate)
        self.getPickView.showView(doneBlock: {
            [weak self] selectDate in
            self?.getDate = selectDate
            self?.getBtn.setTitle("开始时间 \(self?.getDate.string(dateFormat: "MM月dd日 eeeeH:m") ?? "")", for: UIControlState.normal)
        })
    }
    @objc private func clickReturnBtn(){
        self.returnPickView.setData(kOpenHour)
        self.returnPickView.getDate = getDate        
        self.returnPickView.setSelectDate(date: returnDate)
        self.returnPickView.showView(doneBlock: {
            [weak self] selectDate in
            self?.returnDate = selectDate
            self?.returnBtn.setTitle("结束时间 \(self?.returnDate.string(dateFormat: "MM月dd日 eeeeH:m") ?? "")", for: UIControlState.normal)
        })
    }
    
    /// 开始按钮
    fileprivate lazy var getBtn: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 100, width: kScreenW, height: 50))
        button.setTitle("开始时间 \(getDate.string(dateFormat: "MM月dd日 eeeeH:m"))", for: UIControlState.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(UIColor.gray, for: UIControlState.normal)
        button.addTarget(self, action: #selector(clickGetBtn), for: UIControlEvents.touchUpInside)
        return button
    }()
    /// 结束按钮
    fileprivate lazy var returnBtn: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 200, width: kScreenW, height: 50))
        button.setTitle("结束时间 \(returnDate.string(dateFormat: "MM月dd日 eeeeH:m"))", for: UIControlState.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(UIColor.gray, for: UIControlState.normal)
        button.addTarget(self, action: #selector(clickReturnBtn), for: UIControlEvents.touchUpInside)
        return button
    }()
    /// 选择开始时间
    fileprivate lazy var getPickView: CCRentDatePicker = {
        let picker = CCRentDatePicker()
        picker.rentType = .getCarTime
        return picker
    }()
    /// 选择结束时间
    fileprivate lazy var returnPickView: CCRentDatePicker = {
        let picker = CCRentDatePicker()
        picker.rentType = .returnCarTime
        return picker
    }()
    
}

