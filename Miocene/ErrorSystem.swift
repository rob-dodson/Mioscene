//
//  ErrorSystem.swift
//  Miocene
//
//  Created by Robert Dodson on 1/3/23.
//

import SwiftUI



enum MioceneError : LocalizedError
{
    case postingError

    var errorDescription: String?
    {
        switch self
        {
        case .postingError:
            return "Posting Error"
        }
    }

    var recoverySuggestion: String?
    {
        switch self
        {
        case .postingError:
            return "Article publishing failed due to missing text"
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
    func errorAlert(error: Binding<MioceneError?>,msg:String, buttonTitle: String = "OK") -> some View
    {
        let localizedAlertError = LocalizedAlertError(error: error.wrappedValue)
        
        return alert(isPresented: .constant(localizedAlertError != nil ), error: localizedAlertError)
        { _ in
           
            Button(buttonTitle)
            {
                error.wrappedValue = nil
            }
        }
    message:
        { error in
            Text(msg)
        }
    }
}
