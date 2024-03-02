//
//  WeatherModel.swift
//  KasaIruApp
//
//  Created by 海老沢優典 on 2024/02/20.
//

import Foundation

struct WeatherModel: Decodable {
    var list: [List]
}

struct List: Decodable {
    var weather: [Weather]
    var dt_txt: String
}

struct Weather: Decodable {
    var id: Int
    var main: String
    var description: String
}
