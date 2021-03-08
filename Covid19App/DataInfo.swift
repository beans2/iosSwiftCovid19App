//
//  DataInfo.swift
//  Covid19App
//
//  Created by Mac Mini on 2021/03/05.
//

import Foundation

enum DataInfo {
    case serviceKey
}

extension DataInfo {
    var info:String {
        var selectedData: String
        switch self {
        case .serviceKey:
            selectedData = "인증키" //https://www.data.go.kr/tcs/dss/selectApiDataDetailView.do?publicDataPk=15043376 에서의 인증키 받아서 입력
            return selectedData
        }
    }
}
