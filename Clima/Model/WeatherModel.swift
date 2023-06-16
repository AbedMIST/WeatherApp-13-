//
//  WeatherModel.swift
//  Clima
//
//  Created by BS1095 on 16/5/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation


struct WeatherModel {  //For creating model as wanted, own format
    
    let cityName: String
    let temparature: Double
    let conditionId: Int
    
    var conditionName:String {   //computed property var
        switch conditionId {
                case 200...232:
                    return "cloud.bolt"
                case 300...321:
                    return "cloud.drizzle"
                case 500...531:
                    return "cloud.rain"
                case 600...622:
                    return "cloud.snow"
                case 701...781:
                    return "cloud.fog"
                case 800:
                    return "sun.max"
                case 801...804:
                    return "cloud.bolt"
                default:
                    return "cloud"
        }
    }
    
    var temparatureString: String {
        return String(format: "%.1f", temparature)
    }
    
}