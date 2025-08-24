////
////  MockURLProtocol.swift
////  SharedData
////
////  Created by zeekands on 11/07/25.
////
//
//
//import Foundation
//import Alamofire
//
//class MockURLProtocol: URLProtocol {
//  @MainActor static let requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
//
//    override class func canInit(with request: URLRequest) -> Bool {
//        return true
//    }
//
//    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
//        return request
//    }
//
//    override func startLoading() {
//        guard let handler = MockURLProtocol.requestHandler else {
//            fatalError("Request handler is not set.")
//        }
//
//        do {
//            let (response, data) = try handler(request)
//            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
//            client?.urlProtocol(self, didLoad: data)
//            client?.urlProtocolDidFinishLoading(self)
//        } catch {
//            client?.urlProtocol(self, didFailWithError: error)
//        }
//    }
//
//    override func stopLoading() {}
//}
//
//
//
//extension Session {
//  static func mockSession() -> Session {
//    let configuration = URLSessionConfiguration.ephemeral
//    configuration.protocolClasses = [MockURLProtocol.self]
//    return Session(configuration: configuration)
//  }
//}
