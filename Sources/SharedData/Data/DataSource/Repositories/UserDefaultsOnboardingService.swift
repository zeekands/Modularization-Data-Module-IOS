//
//  UserDefaultsOnboardingService.swift
//  SharedData
//
//  Created by zeekands on 24/08/25.
//


import Foundation
import SharedDomain

public class UserDefaultsOnboardingService: OnboardingPersistenceService {
  public static let onboardingKey = "hasSeenOnboarding"
  public let userDefaults: UserDefaults
  
  public init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults
  }
  
  public func hasSeenOnboarding() -> Bool {
    return userDefaults.bool(forKey: Self.onboardingKey)
  }
  
  public func markOnboardingAsSeen() {
    userDefaults.set(true, forKey: Self.onboardingKey)
  }
}
