//
//  UserInfo.swift
//  Signin-UIKitandCombine
//
//  Created by Gary on 4/6/20.
//  Copyright © 2020 Gary Hanson. All rights reserved.
//

import Foundation
import Combine


final class UserInfo : ObservableObject {
    @Published var name = ""
    @Published var password = ""
    @Published var verifyPassword = ""
    @Published var infoValid = false
    @Published var errorMessage: String?

    private var cancellableSet: Set<AnyCancellable> = []


    private func nameIsValid() -> Bool {
        var isValid = true
        self.errorMessage = ""

        if self.name.count < 6 {
            isValid = false
            if self.name.count > 3 {
                self.errorMessage = "User name must have at least six characters"
            }
        }
        return isValid
    }

    private func passwordIsValid() -> Bool {
        var isValid = true
        self.errorMessage = ""

        if self.password.count < 6 {
            isValid = false
            if self.password.count > 3 {
                self.errorMessage = "Password must have at least six characters"
            }
        }
        return isValid
    }

    private func passwordsAreTheSame() -> Bool {
        if password == verifyPassword {
            return true
        } else {
            if self.verifyPassword.count > 5 {
                self.errorMessage = "Passwords must be the same"
            }
            return false
        }
    }

    private func infoIsValid() -> Bool {
        return nameIsValid() && passwordIsValid() && passwordsAreTheSame()
    }

    private var validatedUserInfo: AnyPublisher<Bool, Never> {
        self.errorMessage = ""
        // do validation whenever any of the three fields change
        return Publishers.CombineLatest3($name, $password, $verifyPassword)
                .receive(on: RunLoop.main)
                .map { _, _, _ in
                    guard self.nameIsValid() else {
                        return false
                    }
                    guard self.passwordIsValid() else {
                        return false
                    }
                    guard self.passwordsAreTheSame() else {
                        return false
                    }

                    return true
                }.eraseToAnyPublisher()
        }

    init() {
        validatedUserInfo
            .map { $0 }
            .receive(on: RunLoop.main)
            .assign(to: \.infoValid, on: self)
            .store(in: &cancellableSet)     // save a reference so we don't get garbage collected until we're done

    }
}
