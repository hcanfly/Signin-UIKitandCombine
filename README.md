# Swift UIKit Signin with Combine

Basic Swift sample app for collecting user info for signup, create account or the like and validating its acceptability before enabling the Signup button. It creates a UserInfo class that uses Combine to provide a clean easy way to validate the input. Using Combine and a separate class removes validation code from the view controller. UIKit requires some initialization that SwiftUI doesn't because it was retro-fitted for publishing. But that can go into an extension and still a very clean view controller.


|![Screenshot](Screenshot.png)





## License

Solitaire is licensed under the MIT License. See the LICENSE file for more information, but basically this is sample code and you can do whatever you want with it.