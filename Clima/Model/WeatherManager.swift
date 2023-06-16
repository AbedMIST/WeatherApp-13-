

import Foundation
import CoreLocation



protocol WeatherManagerDelegate{
    
    func updateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func failWithError(error: Error)
}

struct WeatherManager {  //data getting from app using api (Networking)
    
    //URL+API key
    let weatherURL =                                 "https://api.openweathermap.org/data/2.5/weather?appid=e61d77f1696709b641f8a6d502468b23&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    
    func fetchWeather(cityName: String){            //city wise get weather data
        let urlString = "\(weatherURL)&q=\(cityName)"
        print(urlString)
        
        performReq(urlString: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        print(urlString)
        
        performReq(urlString: urlString)
    }
    
    
    func performReq(urlString: String){    //networking section for retrieve data
        
        //1. Create a URL obj
        if let url = URL(string: urlString){
            
            //2. Create a URL session -> work as a browser
            let session = URLSession(configuration: .default)
            
            //3. Give the session a task with the url obj (using triling closure)
            let task = session.dataTask(with: url) { data, response, error in
                if(error != nil){
                    self.delegate?.failWithError(error: error!)
                }
                
                if let safeData = data {    //retrieve data(safely unwrap)
                    
                    let dataString = String(data: safeData, encoding: .utf8)
                    print(dataString!)
                    
                    if let weather = self.parseJSON(weatherData: safeData){
                        
                        print(weather.conditionName) //WeatherViewController() obj can't be created here
                        self.delegate?.updateWeather(self,weather: weather) //update UI
                    }
                }
                
            }
            
            //4. Start the task
            task.resume()
            
        }
    }
    
    
    func parseJSON(weatherData: Data) -> WeatherModel? {
        
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            print(decodedData.name)
            print(decodedData.main.temp)
            print(decodedData.weather[0].description)
            
            let id = decodedData.weather[0].id
            let name = decodedData.name
            let temp = decodedData.main.temp
            
            let weather = WeatherModel(cityName: name, temparature: temp, conditionId: id)
            return weather
            
        }
        catch{
            delegate?.failWithError(error: error)
            return nil
        }
    }
    
}
