
import Foundation


struct WeatherData : Codable{  //Decodable protocol to decode from json
    let name : String
    let main : Main
    let weather : [Weather]
}


struct Main : Codable {
    let temp : Double
}

struct Weather : Codable {
    let id : Int
    let description : String
}
