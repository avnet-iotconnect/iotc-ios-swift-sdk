//
//  HTTPManagerDelegate.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/20/21.
//

import Foundation

protocol HTTPManagerDelegate {
    func makeRequest(config: HTTPRequestConfig,
                     success: @escaping (Data) -> (),
                     failure: @escaping (Error) -> ())
}
