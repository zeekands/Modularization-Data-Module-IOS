//
//  CombineUtils.swift
//  SharedData
//
//  Created by zeekands on 07/07/25.
//


import Foundation
import Combine


@MainActor
public func firstValue<Output: Sendable, Failure: Error>(
  from publisher: AnyPublisher<Output, Failure>
) async throws -> Output {
  return try await withCheckedThrowingContinuation { continuation in
    var cancellable: AnyCancellable?
    cancellable = publisher
      .first()
      .sink(
        receiveCompletion: { completion in
          if case .failure(let error) = completion {
            continuation.resume(throwing: error)
          }
          cancellable?.cancel()
        }, receiveValue: { value in
          continuation.resume(returning: value)
          cancellable?.cancel()
        }
      )
  }
}

@MainActor
extension AnyPublisher {
  func async() async throws -> Output {
    try await withCheckedThrowingContinuation { continuation in
      var cancellable: AnyCancellable?
      
      cancellable = self.sink(
        receiveCompletion: { completion in
          switch completion {
            case .finished:
              break
            case .failure(let error):
              Task { @MainActor in
                continuation.resume(throwing: error)
              }
          }
          cancellable?.cancel()
        },
        receiveValue: { value in
          Task { @MainActor in
            continuation.resume(returning: value)
          }
          cancellable?.cancel()
        }
      )
    }
  }
}
