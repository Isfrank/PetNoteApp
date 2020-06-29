//
//  WeatherData.swift
//  NoteApp
//
//  Created by frank on 2020/6/29.
//  Copyright © 2020 Frank. All rights reserved.
//

import Foundation

struct WeatherData: Decodable {
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Main: Decodable {
    let temp: Double
}

struct Weather: Decodable {
    let description: String
    let id: Int
}
