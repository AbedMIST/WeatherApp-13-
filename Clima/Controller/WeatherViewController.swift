

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .black
        return activityIndicator
    }()

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    var weatherManager = WeatherManager()  //as structure used, obj will be ref typed
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        searchTextField.delegate = self  //ViewController signup to be notified by textField
        weatherManager.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()  //need to permit for current location
        
        
        activityIndicator.center = view.center
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
    }

    @IBAction func curLocationPressed(_ sender: UIButton) {
        
        if let latValue = UserDefaults.standard.object(forKey: "latKey") as? CLLocationDegrees,
           let lonValue = UserDefaults.standard.object(forKey: "lonKey") as? CLLocationDegrees{
            
            print("Latitude: \(latValue), Longitude: \(lonValue)") //already have cur location
            weatherManager.fetchWeather(latitude: latValue, longitude: lonValue)
        }
        else {
            
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            
            locationManager.requestLocation()
        }

    }
}


extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func searchPressed(_ sender: UIButton) {
        
        searchTextField.endEditing(true)
    }
    
    
    //delegate func to notify controller
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {  //for go button in keyboard

        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool { //null textfield won't end
        if(textField.text != ""){
            return true
        }
        else{                                        //null
            textField.placeholder = "Type something.."
            return false
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

        //use textField.text
        print(searchTextField.text!)
        
        if let city = searchTextField.text {  //optinal unwrapping
            weatherManager.fetchWeather(cityName: city)            //fetchWeather called
        }
        
        searchTextField.text = ""
    }
}

extension WeatherViewController: WeatherManagerDelegate{
    
    //WeatherManager delegate func
    func updateWeather(_ weatherManager: WeatherManager,weather: WeatherModel){
        //The func is called from WeatherManager using delegate ptrn
        
        print(weather.temparature)
        DispatchQueue.main.async {      //call main thread to update UI in background(VVI)
            self.temperatureLabel.text = weather.temparatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
    
    func failWithError(error: Error){
        print(error)
    }
}


extension WeatherViewController: CLLocationManagerDelegate { //will find your current location
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if let storedValue = UserDefaults.standard.object(forKey: "myValueKey") as? String {
            print(storedValue) // Output: Hello, UserDefaults!
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5){   //makes delay
            
            self.activityIndicator.stopAnimating()       //after getting current location
            self.activityIndicator.removeFromSuperview()
            
            if let location = locations.last {
                manager.stopUpdatingLocation()
                let lat = location.coordinate.latitude
                let lon = location.coordinate.longitude
                print(lat)
                print(lon)
                UserDefaults.standard.set(lat, forKey: "latKey")
                UserDefaults.standard.set(lon, forKey: "lonKey")
                
                self.weatherManager.fetchWeather(latitude: lat, longitude: lon)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedWhenInUse,.authorizedAlways:
            locationManager.requestLocation()            //fetch user's current location
        case .denied:
            self.activityIndicator.stopAnimating()       //after getting current location
            self.activityIndicator.removeFromSuperview()
            showAlert()
        case .notDetermined:
            print("Isn't determined.")
            locationManager.requestWhenInUseAuthorization()
        default:
            print("Unknown error.\(status)")
        }
    }
    
    
    func showAlert(){
        let alertController = UIAlertController(title: "Alert", message: "Your current location access is denied.", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            print("OK")
        }
        alertController.addAction(okAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            print("Cancel")
        }
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)

    }
}

