//
//  ViewController.swift
//  Signin-UIKitandCombine
//
//  Created by Gary on 2/16/20.
//  Copyright © 2020 Gary Hanson. All rights reserved.
//

import UIKit
import Combine


fileprivate final class UserInfo : ObservableObject {
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




class CreateAccountViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verifyPasswordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var createAccountButton: UIButton!

    private var userInfo = UserInfo()
    private var cancellableSet: Set<AnyCancellable> = []


    override func viewDidLoad() {
        super.viewDidLoad()

        self.createAccountButton.isEnabled = self.userInfo.infoValid

        self.initializeCombine()
        self.initUIKitDelegates()

    }

    @IBAction func createAccountButtonTapped(_ sender: Any) {
        print("Create Account")
    }

}

//MARK: extension for Combine functionality
extension CreateAccountViewController {

    fileprivate func initializeCombine() {

        // SwiftUI was designed so that a text field's text value could be directly assigned to
        // a published value. The retrofit for UIKit os to broadcast changes via the
        // NotificationCenter and we have to manually link up to the published data fields.
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self.userNameTextField)
            .map( { ($0.object as? UITextField)?.text ?? "" } )
            .assign(to: \.name, on: self.userInfo)
            .store(in: &self.cancellableSet)

        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self.passwordTextField)
            .map( { ($0.object as? UITextField)?.text ?? "" } )
            .assign(to: \.password, on: self.userInfo)
            .store(in: &self.cancellableSet)

        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self.verifyPasswordTextField)
            .map( { ($0.object as? UITextField)?.text ?? "" } )
            .assign(to: \.verifyPassword, on: self.userInfo)
            .store(in: &self.cancellableSet)

        self.userInfo.$infoValid.receive(on: DispatchQueue.main).assign(to: \.isEnabled, on: createAccountButton).store(in: &self.cancellableSet)

        self.userInfo.$errorMessage.receive(on: DispatchQueue.main).assign(to: \.text, on: self.errorMessageLabel).store(in: &self.cancellableSet)


    }
}

//MARK: TextFieldDelegate extension
extension CreateAccountViewController: UITextFieldDelegate {

    func initUIKitDelegates() {
        self.userNameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.verifyPasswordTextField.delegate = self

        self.userNameTextField.becomeFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1

        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            if self.createAccountButton.isEnabled {
                textField.resignFirstResponder()
                self.createAccountButtonTapped(self)
            }
        }

        return true
    }

}

