//
//  ErrorSystem.swift
//  Mammut
//
//  Created by Robert Dodson on 1/3/23.
//

import SwiftUI



enum MammutError : LocalizedError
{
    case titleEmpty

    var errorDescription: String?
    {
        switch self
        {
        case .titleEmpty:
            return "Missing title"
        }
    }

    var recoverySuggestion: String?
    {
        switch self
        {
        case .titleEmpty:
            return "Article publishing failed due to missing title"
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
    func errorAlert(error: Binding<MammutError?>, buttonTitle: String = "OK") -> some View
    {
        let localizedAlertError = LocalizedAlertError(error: error.wrappedValue)
        
        return alert(isPresented: .constant(localizedAlertError != nil), error: localizedAlertError)
        { _ in
            Button(buttonTitle)
            {
                error.wrappedValue = nil
            }
        }
    message:
        { error in
            Text(error.recoverySuggestion ?? "")
        }
    }
}
