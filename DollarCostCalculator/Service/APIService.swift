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
    
    public func fetchSymbolsPublisher(keywords: String) -> AnyPublisher<SearchResults, Error> {
        let urlString = "\(URL_QUERY)?function=SYMBOL_SEARCH&keywords=\(keywords)&apikey=\(API_KEY)"
        let url = URL(string: urlString)!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map({ $0.data })
            .decode(type: SearchResults.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    
}
