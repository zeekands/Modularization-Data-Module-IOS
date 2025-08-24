import XCTest
import RealmSwift
@testable import SharedData
@testable import SharedDomain

final class MovieLocalDataSourceTests: XCTestCase {
  
  var realmDataSource: RealmDataSource!
  var movieLocalDataSource: MovieLocalDataSource!
  var testRealm: Realm!
  
  override func setUpWithError() throws {
    let config = Realm.Configuration(inMemoryIdentifier: self.name, deleteRealmIfMigrationNeeded: true)
    testRealm = try Realm(configuration: config)
    
    Realm.Configuration.defaultConfiguration = config
    realmDataSource = RealmDataSource()
    movieLocalDataSource = MovieLocalDataSource(realmDataSource: realmDataSource)
  }
  
  override func tearDownWithError() throws {
    try testRealm.write {
      testRealm.deleteAll()
    }
    testRealm = nil
    realmDataSource = nil
    movieLocalDataSource = nil
    Realm.Configuration.defaultConfiguration = Realm.Configuration()
  }
  
  func testAddOrUpdateMovie() async throws {
    let movieId = 1
    let initialTitle = "Initial Movie"
    let updatedTitle = "Updated Movie"
    
    let movie = MovieRealmObject(id: movieId, title: initialTitle, overview: "Overview", posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: nil, isFavorite: false)
    
    try await movieLocalDataSource.addOrUpdateMovie(movie)
    
    var fetchedMovie = try await movieLocalDataSource.getMovie(by: movieId)
    XCTAssertNotNil(fetchedMovie)
    XCTAssertEqual(fetchedMovie?.id, movieId)
    XCTAssertEqual(fetchedMovie?.title, initialTitle)
    
    let updatedMovie = MovieRealmObject(id: movieId, title: updatedTitle, overview: "New Overview", posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: nil, isFavorite: true)
    try await movieLocalDataSource.addOrUpdateMovie(updatedMovie)
    
    fetchedMovie = try await movieLocalDataSource.getMovie(by: movieId)
    XCTAssertNotNil(fetchedMovie)
    XCTAssertEqual(fetchedMovie?.title, updatedTitle)
    XCTAssertTrue(fetchedMovie!.isFavorite)
  }
  
  func testGetMovieById() async throws {
    let movieId = 100
    let movie = MovieRealmObject(id: movieId, title: "Specific Movie")
    try await movieLocalDataSource.addOrUpdateMovie(movie)
    
    let fetchedMovie = try await movieLocalDataSource.getMovie(by: movieId)
    
    XCTAssertNotNil(fetchedMovie)
    XCTAssertEqual(fetchedMovie?.id, movieId)
    XCTAssertEqual(fetchedMovie?.title, "Specific Movie")
    
    let nonExistentMovie = try await movieLocalDataSource.getMovie(by: 999)
    XCTAssertNil(nonExistentMovie)
  }
  
  func testGetMovies() async throws {
    let movie1 = MovieRealmObject(id: 1, title: "Movie A")
    let movie2 = MovieRealmObject(id: 2, title: "Movie B")
    try await movieLocalDataSource.addOrUpdateMovie(movie1)
    try await movieLocalDataSource.addOrUpdateMovie(movie2)
    
    let movies = try await movieLocalDataSource.getMovies()
    
    XCTAssertEqual(movies.count, 2)
    XCTAssertTrue(movies.contains(where: { $0.id == 1 && $0.title == "Movie A" }))
    XCTAssertTrue(movies.contains(where: { $0.id == 2 && $0.title == "Movie B" }))
  }
  
  func testGetFavoriteMovies() async throws {
    let movie1 = MovieRealmObject(id: 1, title: "Fav Movie 1", isFavorite: true)
    let movie2 = MovieRealmObject(id: 2, title: "Non-Fav Movie", isFavorite: false)
    let movie3 = MovieRealmObject(id: 3, title: "Fav Movie 2", isFavorite: true)
    try await movieLocalDataSource.addOrUpdateMovie(movie1)
    try await movieLocalDataSource.addOrUpdateMovie(movie2)
    try await movieLocalDataSource.addOrUpdateMovie(movie3)
    
    let favoriteMovies = try await movieLocalDataSource.getFavoriteMovies()
    
    XCTAssertEqual(favoriteMovies.count, 2)
    XCTAssertTrue(favoriteMovies.contains(where: { $0.id == 1 }))
    XCTAssertTrue(favoriteMovies.contains(where: { $0.id == 3 }))
    XCTAssertFalse(favoriteMovies.contains(where: { $0.id == 2 }))
  }
  
  func testDeleteMovie() async throws {
    let movieId = 500
    let movie = MovieRealmObject(id: movieId, title: "Movie to Delete")
    try await movieLocalDataSource.addOrUpdateMovie(movie)
    
    var fetchedMovie = try await movieLocalDataSource.getMovie(by: movieId)
    XCTAssertNotNil(fetchedMovie)
    
    try await movieLocalDataSource.deleteMovie(id: movieId)
    
    fetchedMovie = try await movieLocalDataSource.getMovie(by: movieId)
    XCTAssertNil(fetchedMovie)
  }
  
  func testAddOrUpdateGenres() async throws {
    let genreId = 10
    let initialName = "Action"
    let updatedName = "Action Thriller"
    
    let genre = GenreRealmObject(id: genreId, name: initialName)
    
    try await movieLocalDataSource.addOrUpdateGenres([genre])
    
    var fetchedGenre = try await movieLocalDataSource.getGenre(by: genreId)
    XCTAssertNotNil(fetchedGenre)
    XCTAssertEqual(fetchedGenre?.id, genreId)
    XCTAssertEqual(fetchedGenre?.name, initialName)
    
    let updatedGenre = GenreRealmObject(id: genreId, name: updatedName)
    try await movieLocalDataSource.addOrUpdateGenres([updatedGenre])
    
    fetchedGenre = try await movieLocalDataSource.getGenre(by: genreId)
    XCTAssertNotNil(fetchedGenre)
    XCTAssertEqual(fetchedGenre?.name, updatedName)
  }
  
  func testGetLocalGenres() async throws {
    let genre1 = GenreRealmObject(id: 1, name: "Comedy")
    let genre2 = GenreRealmObject(id: 2, name: "Drama")
    try await movieLocalDataSource.addOrUpdateGenres([genre1, genre2])
    
    let genres = try await movieLocalDataSource.getLocalGenres()
    
    XCTAssertEqual(genres.count, 2)
    XCTAssertTrue(genres.contains(where: { $0.id == 1 && $0.name == "Comedy" }))
    XCTAssertTrue(genres.contains(where: { $0.id == 2 && $0.name == "Drama" }))
  }
  
  func testGetGenreById() async throws {
    let genreId = 200
    let genre = GenreRealmObject(id: genreId, name: "Horror")
    try await movieLocalDataSource.addOrUpdateGenres([genre])
    
    let fetchedGenre = try await movieLocalDataSource.getGenre(by: genreId)
    
    XCTAssertNotNil(fetchedGenre)
    XCTAssertEqual(fetchedGenre?.id, genreId)
    XCTAssertEqual(fetchedGenre?.name, "Horror")
    
    let nonExistentGenre = try await movieLocalDataSource.getGenre(by: 999)
    XCTAssertNil(nonExistentGenre)
  }
}
