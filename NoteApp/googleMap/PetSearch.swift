//
//  PetSearch.swift
//  NoteApp
//
//  Created by student46 on 2020/6/18.
//  Copyright © 2020 Frank. All rights reserved.
//

import Foundation

struct PetSearch: Codable {
    var results: [SearchResult]
    var status: String
}
struct SearchResult: Codable {
    var geometry: Geometry
    var icon: String
    var id: String
    var name: String
    var openingHours: [String:Bool]?
    var photos: [Photo]?
    var types: [String]
    var vicinity: String
    var placeId: String
    var reference: String
}

struct Geometry: Codable  {
    var location: Location
}

struct Location: Codable  {
    var lat: Double
    var lng: Double
}

struct Photo: Codable {
    var height: Double
    var width: Double
    var photoReference: String
}
