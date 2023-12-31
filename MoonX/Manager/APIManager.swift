//
//  APIManager.swift
//  MoonX
//
//  Created by Ömer Faruk Ercivan on 6.09.2023.
//

import Foundation
import Alamofire
import ChatGPTSwift

class APIManager {
	static let shared = APIManager()

	var weatherDate = ""
	var gptDate = ""
	var lunarTip = ""

	func fetchWeatherData(completion: @escaping([String: Any]?, Error?) -> Void) {
		let key = "API_KEY"
		let adress = UserDefaults.standard.value(forKey: "location")! as! String

		let url = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/\(adress)/\(weatherDate)?unitGroup=metric&key=\(key)&include=days&elements=datetime,sunrise,sunset,moonset,moonrise,temp,conditions"

		AF.request(url, method: .get).responseJSON { response in
			switch response.result {
			case .success(let value):
				if let json = value as? [String: Any] {
					completion(json, nil)
				} else {
					completion(nil, NSError(domain: "APIManager", code: 0))
				}
			case .failure(let error):
				completion(nil, error)
			}
		}
	}

	func getHoroscope(horoscopeName: String, completion: @escaping (Result<String, Error>) -> Void) {
		let gptApi = ChatGPTAPI(apiKey: "API_KEY")

		let text = "If I am a \(horoscopeName), pretend you are a fortune teller, please generate my horoscope for \(gptDate) \(lunarTip)."

		if gptDate == "" {
			gptDate = "today"
		}

		Task {
			do {
				let response = try await gptApi.sendMessage(text: text)
				completion(.success(response))
			} catch {
				completion(.failure(error))
			}
		}
	}
}
