//
//  URLInfo.swift
//  Covid19App
//
//  Created by Mac Mini on 2021/03/05.
//

import Foundation

enum URLInfos {
    case decideAPI
}

extension URLInfos {
    var url : String {
        var selectedUrl = ""
        switch self {
        case .decideAPI:
            selectedUrl = "http://openapi.data.go.kr/openapi/service/rest/Covid19/getCovid19InfStateJson"
            return selectedUrl
        }
    }
}
