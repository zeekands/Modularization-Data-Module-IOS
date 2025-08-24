//
//  TMDBAPIError.swift
//  SharedData
//
//  Created by zeekands on 05/07/25.
//


//
//  TMDBAPIError.swift
//  SharedDomain
//
//  Created by zeekands on 05/07/25.
//
import Foundation

public enum TMDBAPIError: Error, LocalizedError {
  case invalidURL
  case networkError(Error)
  case invalidResponse
  case decodingError(Error)
  case apiError(statusCode: Int, message: String?)
  case unknown
  
  public var errorDescription: String? {
    switch self {
      case .invalidURL: return NSLocalizedString("Invalid API URL.", comment: "Error message for invalid URL")
      case .networkError(let error): return NSLocalizedString("Network error: \(error.localizedDescription)", comment: "Error message for network issues")
      case .invalidResponse: return NSLocalizedString("Invalid response from server.", comment: "Error message for malformed server response")
      case .decodingError(let error): return NSLocalizedString("Data decoding error: \(error.localizedDescription)", comment: "Error message for data decoding failure")
      case .apiError(let statusCode, let message): return NSLocalizedString("API Error \(statusCode): \(message ?? "Unknown error")", comment: "Error message for TMDB API response error")
      case .unknown: return NSLocalizedString("Unknown error.", comment: "Default error message for unexpected errors")
    }
  }
}

struct APIErrorMessage: Decodable {
  let statusCode: Int?
  let statusMessage: String?
  let success: Bool?
}
