import Foundation
import Combine
import Alamofire


public class TMDBAPIClient: @unchecked Sendable {
  
  private let accessToken: String
  private let baseURL: String
  private let session: Session
  
  public init(accessToken: String, baseURL: String) {
    self.accessToken = accessToken
    self.baseURL = baseURL
    print(accessToken)
    
    let configuration = URLSessionConfiguration.default
    configuration.urlCache = URLCache(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024)
    configuration.requestCachePolicy = .returnCacheDataElseLoad
    
    configuration.timeoutIntervalForRequest = 30.0
    configuration.timeoutIntervalForResource = 60.0
    
    self.session = Session(configuration: configuration, interceptor: TMDBRequestInterceptor(accessToken: accessToken))
  }
  
  public func getBaseURL() -> String {
    return baseURL
  }
  
  private struct TMDBRequestInterceptor: RequestInterceptor {
    let accessToken: String
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
      var urlRequest = urlRequest
      urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
      urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
      urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
      
      // --- LOG PERMINTAAN ---
      print("================================== START REQUEST ==================================")
      print("🚀 URL: \(urlRequest.url?.absoluteString ?? "")")
      print("🚀 Method: \(urlRequest.httpMethod ?? "")")
      print("🚀 Headers: Bearer \(accessToken)")
      urlRequest.allHTTPHeaderFields?.forEach { (key, value) in print("   \(key): \(value)") }
      if let httpBody = urlRequest.httpBody, let bodyString = String(data: httpBody, encoding: .utf8) {
        print("🚀 Body: \(bodyString)")
      }
      print("================================== END REQUEST ====================================")
      completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
      print("🔄 Retry triggered for error: \(error.localizedDescription) (attempt \(request.retryCount))")
      if request.retryCount < 2 {
        completion(.retryWithDelay(1.0))
      } else {
        completion(.doNotRetry)
      }
    }
  }
  
  private func makeURL(path: String, queryItems: [URLQueryItem]? = nil) throws -> URL {
    guard let baseURLComponent = URLComponents(string: baseURL) else {
      throw TMDBAPIError.invalidURL
    }
    
    var components = baseURLComponent
    components.path = components.path.appending(path)
    
    var defaultQueryItems = [
      URLQueryItem(name: "language", value: "en-US")
    ]
    
    if let queryItems = queryItems {
      defaultQueryItems.append(contentsOf: queryItems)
    }
    components.queryItems = defaultQueryItems
    
    guard let url = components.url else {
      throw TMDBAPIError.invalidURL
    }
    return url
  }
  
  private func request<T: Decodable & Sendable>(path: String, queryItems: [URLQueryItem]? = nil) -> AnyPublisher<T, TMDBAPIError> {
    do {
      let url = try makeURL(path: path, queryItems: queryItems)
      
      return session.request(url, parameters: nil, encoding: URLEncoding.default, headers: nil)
        .publishData()
        .tryMap { dataResponse -> T in
          print("================================== START RESPONSE ==================================")
          print("⬅️ URL: \(dataResponse.request?.url?.absoluteString ?? "N/A")")
          
          if let httpResponse = dataResponse.response {
            print("⬅️ Status Code: \(httpResponse.statusCode)")
            print("⬅️ Headers:")
            httpResponse.headers.forEach { header in print("   \(header.name): \(header.value)") }
          }
          
          if let data = dataResponse.data {
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
               let prettyPrintedData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
               let prettyPrintedString = String(data: prettyPrintedData, encoding: .utf8) {
              print("📄 Body (Formatted JSON):")
              print(prettyPrintedString)
            } else if let rawString = String(data: data, encoding: .utf8) {
              print("📄 Body (Raw String):")
              print(rawString)
            } else {
              print("📄 Body (Unreadable Data, \(data.count) bytes)")
            }
          }
          
          if let error = dataResponse.error {
            print("❌ AFError: \(error.localizedDescription)")
            if let underlyingError = error.underlyingError {
              print("   Underlying Error: \(underlyingError.localizedDescription)")
            }
          }
          print("================================== END RESPONSE ====================================")

          if let afError = dataResponse.error {
            throw afError
          }
          
          guard let _ = dataResponse.response,
                let statusCode = dataResponse.response?.statusCode else {
            throw TMDBAPIError.networkError(URLError(.badServerResponse))
          }
          
          let responseData = dataResponse.data
          
          if (200..<300).contains(statusCode) {
            guard let data = responseData else {
              throw TMDBAPIError.decodingError(URLError(.zeroByteResource))
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            return try decoder.decode(T.self, from: data)
          } else {
            var errorMessage: String? = nil
            if let data = responseData {
              let decoder = JSONDecoder()
              decoder.keyDecodingStrategy = .convertFromSnakeCase
              if let apiMessage = try? decoder.decode(APIErrorMessage.self, from: data) {
                errorMessage = apiMessage.statusMessage
              }
            }
            throw TMDBAPIError.apiError(statusCode: statusCode, message: errorMessage)
          }
        }
        .mapError { error in
          if let afError = error.asAFError {
            switch afError {
              case .sessionTaskFailed(let urlError as URLError):
                return .networkError(urlError)
              case .responseSerializationFailed(let reason):
                switch reason {
                  case .inputDataNilOrZeroLength, .jsonSerializationFailed(_):
                    return .decodingError(afError.underlyingError ?? afError)
                  default:
                    return .decodingError(afError.underlyingError ?? afError)
                }
              default:
                return .networkError(afError.underlyingError ?? afError)
            }
          } else if let decodingError = error as? DecodingError {
            return .decodingError(decodingError)
          } else if let tmdbError = error as? TMDBAPIError {
            return tmdbError
          } else if let urlError = error as? URLError {
            return .networkError(urlError)
          }
          return .unknown
        }
        .eraseToAnyPublisher()
    } catch {
      return Fail(error: error as? TMDBAPIError ?? .networkError(error))
        .eraseToAnyPublisher()
    }
  }
  
  public func getMovies(category: String, page: Int) -> AnyPublisher<TMDBResponse<MovieDTO>, TMDBAPIError> {
    let queryItems = [URLQueryItem(name: "page", value: String(page))]
    return request(path: "/movie/\(category)", queryItems: queryItems)
  }
  
  public func getTVShows(category: String, page: Int) -> AnyPublisher<TMDBResponse<TVShowDTO>, TMDBAPIError> {
    let queryItems = [URLQueryItem(name: "page", value: String(page))]
    return request(path: "/tv/\(category)", queryItems: queryItems)
  }
  
  public func getTrendingMovies(timeWindow: String = "day", page: Int) -> AnyPublisher<TMDBResponse<MovieDTO>, TMDBAPIError> {
    let queryItems = [URLQueryItem(name: "page", value: String(page))]
    return request(path: "/trending/movie/\(timeWindow)", queryItems: queryItems)
  }
  
  public func getTrendingTVShows(timeWindow: String = "day", page: Int) -> AnyPublisher<TMDBResponse<TVShowDTO>, TMDBAPIError> {
    let queryItems = [URLQueryItem(name: "page", value: String(page))]
    return request(path: "/trending/tv/\(timeWindow)", queryItems: queryItems)
  }
  
  public func getMovieDetails(id: Int) -> AnyPublisher<MovieDTO, TMDBAPIError> {
    return request(path: "/movie/\(id)")
  }
  
  public func getTVShowDetails(id: Int) -> AnyPublisher<TVShowDTO, TMDBAPIError> {
    return request(path: "/tv/\(id)")
  }
  
  public func searchMovies(query: String, page: Int) -> AnyPublisher<TMDBResponse<MovieDTO>, TMDBAPIError> {
    let queryItems = [
      URLQueryItem(name: "query", value: query),
      URLQueryItem(name: "page", value: String(page))
    ]
    return request(path: "/search/movie", queryItems: queryItems)
  }
  
  public func searchTVShows(query: String, page: Int) -> AnyPublisher<TMDBResponse<TVShowDTO>, TMDBAPIError> {
    let queryItems = [
      URLQueryItem(name: "query", value: query),
      URLQueryItem(name: "page", value: String(page))
    ]
    return request(path: "/search/tv", queryItems: queryItems)
  }
  
  public func getMovieGenres() -> AnyPublisher<GenresResponse, TMDBAPIError> {
    return request(path: "/genre/movie/list")
  }
  
  public func getTVShowGenres() -> AnyPublisher<GenresResponse, TMDBAPIError> {
    return request(path: "/genre/tv/list")
  }
}
