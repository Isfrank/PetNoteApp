//
//  DispatchQueue+Once.swift
//  MyMap
//
//  Created by student46 on 2020/4/23.
//  Copyright © 2020 Frank. All rights reserved.
//

import Foundation

//closure只執行一次
extension DispatchQueue {
    //private私有的onceTokens只有DispatchQueue才能用,extension可以用static,系統會幫他配置記憶體,
    //直到app結束後記憶體才會消失,不管有沒有使用,是不會消失的
    //不屬於任何一個instance, global的
    private static var _onceTokens = [String]()
    //closure跟func是一樣的東西, 可以互相代換
    //Public全部函數可以用, ()->是closure型別, 沒有吃任何參數, 也沒有回傳任何東西
    public class func once(token: String, job:()->Void){
        
        //Thread Safe 多個Thread存取同一個東西可能會當
        objc_sync_enter(self) //上鎖 self本身當鎖
//        guard !_onceTokens.contains(token)else{
//            return
//        } 偵測
        defer { //延後
            objc_sync_exit(self)
        }
        if _onceTokens.contains(token){
            return
        }
        _onceTokens.append(token)
        job()
    }
}
