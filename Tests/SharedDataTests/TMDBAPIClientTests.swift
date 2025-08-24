//
//  TMDBAPIClientTests.swift
//  SharedData
//
//  Created by zeekands on 11/07/25.
//


import XCTest
import Combine
import Alamofire
@testable import SharedData // Untuk mengakses TMDBAPIClient, DTOs, TMDBAPIError
@testable import SharedDomain // Jika MovieEntity atau sejenisnya diperlukan (untuk context)

final class TMDBAPIClientTests: XCTestCase {

    var apiClient: TMDBAPIClient!
    var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Konfigurasi TMDBAPIClient untuk menggunakan mock session
        let mockSession = Session.mockSession()
        
        // Inisialisasi TMDBAPIClient.
        // Kita harus menyuntikkan mockSession ke dalamnya.
        // Ini memerlukan sedikit penyesuaian pada TMDBAPIClient Anda:
        // tambahkan initializer kedua atau properti internal untuk testing.
        // Misalnya:
        // public class TMDBAPIClient {
        //     internal init(accessToken: String, baseURL: String, session: Session) { ... }
        //     public init(accessToken: String, baseURL: String) { ... self.init(accessToken, baseURL, Session.default) }
        // }
        // Atau jadikan `session` di TMDBAPIClient sebagai `var` (kurang disarankan untuk produksi).
        
        // Untuk tujuan testing ini, kita akan mengasumsikan Anda memiliki
        // initializer yang memungkinkan penyuntikan session.
        apiClient = TMDBAPIClient(
            accessToken: "dummy_access_token_for_test", // Nilai dummy karena tidak akan dipakai
            baseURL: "https://api.themoviedb.org/3", // Base URL harus match dengan request handler
            session: mockSession // Suntikkan mock session
        )
        // Note: Jika TMDBAPIClient Anda masih pakai `static let shared`, Anda perlu mengubahnya
        // agar bisa disuntikkan seperti ini, atau mock `Bundle.main.infoDictionary`.
        // Pendekatan DI yang kita bahas sebelumnya adalah yang terbaik.
    }

    override func tearDownWithError() throws {
        MockURLProtocol.requestHandler = nil // Bersihkan handler setelah setiap test
        cancellables.removeAll()
        apiClient = nil
    }

    func testGetPopularMoviesSuccess() throws {
        // Given: Contoh data JSON respons sukses untuk film populer
        let expectedResponseData = """
        {
            "page": 1,
            "results": [
                {
                    "adult": false,
                    "backdrop_path": "/path/to/backdrop1.jpg",
                    "genre_ids": [28, 12],
                    "id": 1,
                    "original_language": "en",
                    "original_title": "Test Movie 1",
                    "overview": "Overview 1",
                    "popularity": 100.0,
                    "poster_path": "/path/to/poster1.jpg",
                    "release_date": "2023-01-01",
                    "title": "Test Movie 1",
                    "video": false,
                    "vote_average": 7.5,
                    "vote_count": 1000
                }
            ],
            "total_pages": 1,
            "total_results": 1
        }
        """.data(using: .utf8)!

        // Konfigurasi MockURLProtocol untuk memberikan respons sukses
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, expectedResponseData)
        }

        let expectation = XCTestExpectation(description: "Fetching popular movies should succeed")

        // When: Panggil fungsi API client
        apiClient.getMovies(category: "popular", page: 1)
            .sink { completion in
                // Then: Verifikasi penyelesaian
                if case .failure(let error) = completion {
                    XCTFail("Test failed with error: \(error.localizedDescription)")
                }
                expectation.fulfill()
            } receiveValue: { response in
                // Then: Verifikasi nilai yang diterima
                XCTAssertEqual(response.page, 1)
                XCTAssertEqual(response.results.count, 1)
                XCTAssertEqual(response.results.first?.id, 1)
                XCTAssertEqual(response.results.first?.title, "Test Movie 1")
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0) // Tunggu hingga async operation selesai
    }

    func testGetMovieDetailsFailureAPIError404() throws {
        // Given: Contoh data JSON respons error 404 dari API
        let expectedErrorData = """
        {
            "success": false,
            "status_code": 34,
            "status_message": "The resource you requested could not be found."
        }
        """.data(using: .utf8)!

        // Konfigurasi MockURLProtocol untuk memberikan respons error 404
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return (response, expectedErrorData)
        }

        let expectation = XCTestExpectation(description: "Fetching movie details should fail with 404 API error")

        // When: Panggil fungsi API client untuk detail film yang tidak ada
        apiClient.getMovieDetails(id: 99999) // ID yang dijamin tidak ada
            .sink { completion in
                // Then: Verifikasi error yang diterima
                if case .failure(let error) = completion {
                    if case .apiError(let statusCode, let message) = error {
                        XCTAssertEqual(statusCode, 404)
                        XCTAssertEqual(message, "The resource you requested could not be found.")
                    } else {
                        XCTFail("Expected TMDBAPIError.apiError, but got: \(error)")
                    }
                } else {
                    XCTFail("Expected failure, but got success for 404 response.")
                }
                expectation.fulfill()
            } receiveValue: { _ in
                // Tidak ada nilai yang diharapkan
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }
    
    func testGetPopularMoviesNetworkError() throws {
        // Given: Konfigurasi MockURLProtocol untuk mensimulasikan error jaringan
        MockURLProtocol.requestHandler = { request in
            throw URLError(.notConnectedToInternet) // Simulasikan tidak ada koneksi internet
        }

        let expectation = XCTestExpectation(description: "Fetching popular movies should fail with network error")

        // When: Panggil fungsi API client
        apiClient.getMovies(category: "popular", page: 1)
            .sink { completion in
                // Then: Verifikasi error yang diterima
                if case .failure(let error) = completion {
                    if case .networkError(let underlyingError) = error, let urlError = underlyingError as? URLError {
                        XCTAssertEqual(urlError.code, .notConnectedToInternet)
                    } else {
                        XCTFail("Expected network error, but got: \(error)")
                    }
                } else {
                    XCTFail("Expected failure, but got success for network error.")
                }
                expectation.fulfill()
            } receiveValue: { _ in
                // Tidak ada nilai yang diharapkan
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testGetMovieGenresSuccess() throws {
        // Given
        let expectedResponseData = """
        {
            "genres": [
                {"id": 1, "name": "Action"},
                {"id": 2, "name": "Comedy"}
            ]
        }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, expectedResponseData)
        }

        let expectation = XCTestExpectation(description: "Fetching movie genres succeeds")

        // When
        apiClient.getMovieGenres()
            .sink { completion in
                if case .failure(let error) = completion {
                    XCTFail("Test failed with error: \(error.localizedDescription)")
                }
                expectation.fulfill()
            } receiveValue: { response in
                XCTAssertEqual(response.genres.count, 2)
                XCTAssertEqual(response.genres.first?.name, "Action")
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    // Anda dapat menambahkan test serupa untuk TV Shows dan Search

}

// Pastikan Anda juga memiliki definisi DTO untuk MovieDTO, TMDBResponse, TVShowDTO, GenresResponse
// Ini harus ada di SharedData/Data/Remote/DTOs atau SharedData/Data/Remote/Models
// Contoh singkat:
/*
struct TMDBResponse<T: Decodable>: Decodable {
    let page: Int
    let results: [T]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct MovieDTO: Decodable, Sendable {
    let adult: Bool?
    let backdropPath: String?
    let genreIds: [Int]?
    let id: Int
    let originalLanguage: String?
    let originalTitle: String?
    let overview: String?
    let popularity: Double?
    let posterPath: String?
    let releaseDate: String?
    let title: String
    let video: Bool?
    let voteAverage: Double?
    let voteCount: Int?

    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genreIds = "genre_ids"
        case id
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview, popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title, video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

struct GenreDTO: Decodable, Sendable {
    let id: Int
    let name: String
}

struct GenresResponse: Decodable {
    let genres: [GenreDTO]
}
*/