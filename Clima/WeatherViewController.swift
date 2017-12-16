
import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
  
  //Constants
  let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
  let APP_ID = "6e8019b6f246ab07b04fe07a93a01d5c"
  
  
  //TODO: Declare instance variables here
  let locationManager = CLLocationManager()
  let weatherDataModelObject = WeatherDataModel()
  
  //Pre-linked IBOutlets
  @IBOutlet weak var weatherIcon: UIImageView!
  @IBOutlet weak var cityLabel: UILabel!
  @IBOutlet weak var temperatureLabel: UILabel!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    //TODO:Set up the location manager here.
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.requestWhenInUseAuthorization()
    
    locationManager.startUpdatingLocation()
    
    
  }
  
  
  
  //MARK: - Networking
  /***************************************************************/
  func getWeatherData(url: String, parameters:[String: String]) {
    Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
      response in
      if response.result.isSuccess {
        print("Success! Got the weather data")
        
        let weatherJSON:JSON = JSON(response.result.value!)
        self.updateWeatherData(json: weatherJSON)
        
      } else {
        print("Error\(response.result.error)")
        self.cityLabel.text = "Connection Issues"
      }
    }
  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "changeCityName" {
      let destin = segue.destination as! ChangeCityViewController
      destin.delegate = self
    }
  }
  
  
  //MARK: - JSON Parsing
  /***************************************************************/
  
  
  //Write the updateWeatherData method here:
  func updateWeatherData(json:JSON) {
    if let tempResult = json["main"]["temp"].double {
      weatherDataModelObject.temperature = Int(tempResult - 273.15)
      weatherDataModelObject.city = json["name"].stringValue
      weatherDataModelObject.condition = json["weather"][0]["id"].intValue
      weatherDataModelObject.weatherIconName = weatherDataModelObject.updateWeatherIcon(condition:
        weatherDataModelObject.condition)
      updateWeatherUI()
    } else {
      cityLabel.text = "Weather Unavailable"
    }
    
    
  }
  
  
  
  
  //MARK: - UI Updates
  /***************************************************************/
  
  func updateWeatherUI() {
    cityLabel.text = weatherDataModelObject.city
    temperatureLabel.text = "\(weatherDataModelObject.temperature)°"
    weatherIcon.image = UIImage(named: weatherDataModelObject.weatherIconName)
  }
  
  
  
  
  //MARK: - Location Manager Delegate Methods
  /***************************************************************/
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location = locations[locations.count - 1]
    if location.horizontalAccuracy > 0 {
      locationManager.stopUpdatingLocation()
      locationManager.delegate = nil
      print("Long = \(location.coordinate.latitude)")
      let latitude = String(location.coordinate.latitude)
      let longitude = String(location.coordinate.longitude)
      let params:[String: String] = ["lat": latitude, "lon": longitude, "appid": APP_ID]
      
      getWeatherData(url: WEATHER_URL, parameters: params)
      
    }
  }
  
  
  //Write the didFailWithError method here:
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Print Error")
    cityLabel.text = "Location Unavailable"
  }
  
  
  
  
  //MARK: - Change City Delegate methods
  /***************************************************************/
  
  func userEnterANewCity(city: String) {
    let params:[String: String] = ["q": city, "appid":APP_ID]
    getWeatherData(url: WEATHER_URL, parameters: params)
  }
  
  
}


