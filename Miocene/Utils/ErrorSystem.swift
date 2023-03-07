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
    
    @Published var infoType : MioceneInfo?
    @Published var infoMessage : String = "Unknown Info"
    
    static var shared : ErrorSystem?
    
    init()
    {
        ErrorSystem.shared = self
    }
    
    func reportError(type:MioceneError,msg:String)
    {
        DispatchQueue.main.async
        {
            self.errorMessage = msg
            self.errorType = type
        }
    }
    
    func showMessage(type:MioceneInfo,msg:String)
    {
        DispatchQueue.main.async
        {
            self.infoMessage = msg
            self.infoType = .info
        }
    }
}

enum MioceneInfo : LocalizedError
{
    case info
    case warning
    
    var infoDescription : String?
    {
        switch self
        {
            case .info:
                return "Info"
            case .warning:
                return "Warning"
        }
    }
}


enum MioceneError : LocalizedError
{
    case ok
    case info
    case unknownError
    case postingError
    case sqlError
    case accountError
    case loginError
    case registrationError
    case notimplemented
    
    var errorDescription: String?
    {
        switch self
        {
        case .ok:
            return "Ok"
        case .info:
            return "Info"
        case .unknownError:
            return "Unknown Error"
        case .postingError:
            return "Posting Error"
        case .sqlError:
            return "Database Error"
        case .accountError:
            return "Account Error"
        case .loginError:
            return "Login Error"
        case .registrationError:
            return "Registration Error"
        case .notimplemented:
            return "Sorry, Not implemented yet"
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
    
    func messageAlert(title:String,show: Binding<MioceneInfo?>,msg:String, buttonTitle: String = "OK",done:@escaping () -> Void) -> some View
    {
        
        return alert(title,isPresented: .constant(show.wrappedValue != nil))
        {
            
            Button(buttonTitle)
            {
                show.wrappedValue = nil
                done()
            }
        }
    message:
        {
            Text(msg)
        }
    }
}
