//
//  ErrorSystem.swift
//  Miocene
//
//  Created by Robert Dodson on 1/3/23.
//

import SwiftUI


class ErrorSystem : ObservableObject
{
    @Published var errorType : MioceneError?
    @Published var errorMessage : String = "Unknown Error"

    func reportError(type:MioceneError,msg:String)
    {
        DispatchQueue.main.async
        {
            self.errorMessage = msg
            self.errorType = type
        }
    }
}

enum MioceneError : LocalizedError
{
    case ok
    case unknownError
    case postingError
    case sqlError
    case accountError
    case loginError
    case registrationError
    
    var errorDescription: String?
    {
        switch self
        {
        case .ok:
            return "Ok"
        case .unknownError:
            return "Unknown Error"
        case .postingError:
            return "Posting Error"
        case .sqlError:
            return "Sql Error"
        case .accountError:
            return "Account Error"
        case .loginError:
            return "Logi Error"
        case .registrationError:
            return "Registration Error"
        }
    }

    var recoverySuggestion: String?
    {
        switch self
        {
        case .ok:
            return "Ok"
        case .unknownError:
            return "Something's not working"
        case .postingError:
            return "Article publishing failed due to missing text"
        case .sqlError:
            return "Sql Error"
        case .accountError:
            return "Account Error"
        case .loginError:
            return "Logi Error"
        case .registrationError:
            return "Registration Error"
        }
    }

}

struct LocalizedAlertError: LocalizedError
{
    let underlyingError: LocalizedError
    var errorDescription: String?
    {
        underlyingError.errorDescription
    }
    var recoverySuggestion: String?
    {
        underlyingError.recoverySuggestion
    }

    init?(error: Error?)
    {
        guard let localizedError = error as? LocalizedError else { return nil }
        underlyingError = localizedError
    }
}

extension View
{
    func errorAlert(error: Binding<MioceneError?>,msg:String, buttonTitle: String = "OK",done:@escaping () -> Void) -> some View
    {
        let localizedAlertError = LocalizedAlertError(error: error.wrappedValue)
        
        return alert(isPresented: .constant(localizedAlertError != nil ), error: localizedAlertError)
        { _ in
           
            Button(buttonTitle)
            {
                error.wrappedValue = nil
                done()
            }
        }
    message:
        { error in
            Text(msg)
        }
    }
}
