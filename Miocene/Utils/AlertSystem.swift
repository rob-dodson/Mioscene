//
//  AlertSystem.swift
//  Miocene
//
//  Created by Robert Dodson on 1/3/23.
//
import SwiftUI


class AlertSystem : ObservableObject
{
    @Published var errorType : MioceneError?
    @Published var errorMessage : String = "Unknown Error"
    
    @Published var infoType : MioceneInfo?
    @Published var infoMessage : String = "Unknown Info"
    
    static var shared : AlertSystem?
    
    init()
    {
        AlertSystem.shared = self
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


extension View
{
    func errorAlert(error: Binding<MioceneError?>,msg:String, buttonTitle: String = "OK",done:@escaping () -> Void) -> some View
    {
        return alert(isPresented: .constant(error.wrappedValue != nil ), error: error.wrappedValue)
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
    
    func messageAlert(title:String = "Info",show: Binding<MioceneInfo?>,msg:String, buttonTitle: String = "OK",done:@escaping () -> Void) -> some View
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
