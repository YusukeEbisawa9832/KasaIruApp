//
//  MunicipalitiesModel.swift
//  KasaIruApp
//
//  Created by 海老沢優典 on 2023/11/13.
//

import Foundation

enum MunicipalitiesModel: Int, CaseIterable {
    
    // 北海道
    case sapporo
    case hakodate
    // 青森
    case hirosaki
    case aomori
    
    var municipalitiesName: String {
        switch self {
        // 北海道
        case .sapporo: return "札幌市"
        case .hakodate: return "函館市"
        // 青森
        case .hirosaki: return "弘前市"
        case .aomori: return "青森市"
        }
    }
    
    // 緯度
    var lat: String {
        switch self {
        // 北海道
        case .sapporo: return "43.04"
        case .hakodate: return "41.46"
        // 青森
        case .hirosaki: return "40.35"
        case .aomori: return "41.33"
        }
    }
    
    // 経度
    var lon: String {
        switch self {
        // 北海道
        case .sapporo: return "141.21"
        case .hakodate: return "140.44"
        // 青森
        case .hirosaki: return "140.29"
        case .aomori: return "139.30"
        }
    }
}
