//
//  APIService.swift
//  DollarCostCalculator
//
//  Created by Brendon Bitencourt Braga on 2021-04-23.
//

import Foundation
import Combine

final class APIService {
    
    let keys = ["07W5W7KH1QXKYPMC", "A2I8P3LK8J7XH98P", "LRHBITQVGLDQ7M4B"]
    var HTTP_PROTOCOL = "https"
    var URL_DOMAIN = "www.alphavantage.co"
    var URL_QUERY: String {
        return "\(HTTP_PROTOCOL)://\(URL_DOMAIN)/query"
    }
    var API_KEY: String {
        return keys.randomElement() ?? ""
    }
    
    enum APIServiceError: Error {
        case encodeing
        case badRequest
    }
    
    private func parseQuery(for text: String) -> Result<String, Error> {
        if let query = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            return .success(query)
        } else {
            return .failure(APIServiceError.encodeing)
        }
    }
    
    private func parseURL(for urlString: String) -> Result<URL, Error> {
        if let url = URL(string: urlString) {
            return .success(url)
        } else {
            return .failure(APIServiceError.badRequest)
        }
    }
    
    public func fetchSymbolsPublisher(query: String) -> AnyPublisher<SearchResults, Error> {
        
        let resultQuery = parseQuery(for: query)
        var keywords = ""
        switch resultQuery {
            case .success(let query):
                keywords = query
            case .failure(let error):
                return Fail(error: error).eraseToAnyPublisher()
        }
        
        let urlString = "\(URL_QUERY)?function=SYMBOL_SEARCH&keywords=\(keywords)&apikey=\(API_KEY)"
        let resultUrl = parseURL(for: urlString)
        switch resultUrl {
            case .success(let url):
                return URLSession.shared.dataTaskPublisher(for: url)
                    .map({ $0.data })
                    .decode(type: SearchResults.self, decoder: JSONDecoder())
                    .receive(on: RunLoop.main)
                    .eraseToAnyPublisher()
            case .failure(let error):
                return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    public func fetchTimeSeriesMonthlyAjustedPublisher(query: String) -> AnyPublisher<TimeSeriesMonthlyAjusted, Error> {
        
        let resultQuery = parseQuery(for: query)
        var symbol = ""
        switch resultQuery {
            case .success(let query):
                symbol = query
            case .failure(let error):
                return Fail(error: error).eraseToAnyPublisher()
        }
        
        let urlString = "\(URL_QUERY)?function=TIME_SERIES_MONTHLY_ADJUSTED&symbol=\(symbol)&apikey=\(API_KEY)"
        let resultUrl = parseURL(for: urlString)
        switch resultUrl {
            case .success(let url):
                return URLSession.shared.dataTaskPublisher(for: url)
                    .map({ $0.data })
                    .decode(type: TimeSeriesMonthlyAjusted.self, decoder: JSONDecoder())
                    .receive(on: RunLoop.main)
                    .eraseToAnyPublisher()
            case .failure(let error):
                return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    
}
