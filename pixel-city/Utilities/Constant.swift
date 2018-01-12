//
//  Constant.swift
//  pixel-city
//
//  Created by Raju Dhumne on 11/01/18.
//  Copyright © 2018 Raju Dhumne. All rights reserved.
//

import Foundation

let apiKey = "a12dc5dce18dfb491c1fd9d1ae69feea"

func flickrUrl(forApiKey: String,withAnnotation annotation:DroppablePin,addNumberOfPhotos number:Int) -> String {
 return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
}

