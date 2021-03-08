//
//  XMLParcer.swift
//  Covid19App
//
//  Created by Mac Mini on 2021/03/05.
//

import Foundation
import SwiftyXMLParser

class XMLParser{
    let xmlData : Data
    init(xmlData: Data) {
        self.xmlData = xmlData
    }
    
    //xml parse
    func xmlDataParser() -> Int {
        var plusDecideCnt = -1
        let value = NSMutableDictionary()
        let string = String(decoding: xmlData, as: UTF8.self)
        let xml = try! XML.parse(string)
        for i in 0...1{
            if let decideCnt = xml["response", "body", "items", "item", i ,"decideCnt"].int, let stateDate = xml["response", "body", "items", "item", i, "stateDt"].text  {
                value.setValue(decideCnt, forKey: stateDate)
            }
        }
        if value.count == 2{
            plusDecideCnt = self.calculateDecideCnt(value: value)
        }
        return plusDecideCnt
    }
    
    //늘어난 확진자 값 구하기
    func calculateDecideCnt(value: NSMutableDictionary) -> Int{
        var plusDecideCnt = -1
        if let value1 = value.allValues[0] as? Int, let value2 = value.allValues[1] as? Int{
            if value1 > value2 {
                plusDecideCnt = value1 - value2
            }else{
                plusDecideCnt = value2 - value1
            }
        }
        return plusDecideCnt
    }
}
