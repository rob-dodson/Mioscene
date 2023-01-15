//
//  PollBuilder.swift
//  Mioscene
//
//  Created by Robert Dodson on 1/14/23.
//

import SwiftUI
import MastodonKit


enum PollType : String, Identifiable, CaseIterable
{
    case single = "Single Choice"
    case muliple = "Multiple Choice"
    
    var id: Self { return self }
}


enum PollTimes : String, Identifiable, CaseIterable
{
    case fiveMinutes = "5 minutes"
    case thirtyMinutes = "30 minutes"
    case oneHour = "1 hour"
    case sixHours = "6 hours"
    case oneDay = "1 day"
    case threeDays = "3 days"
    case oneWeek = "1 week"

    var id: Self { return self }
}


class PollState : ObservableObject
{
    @Published var pollTime = PollTimes.oneHour
    @Published var pollType = PollType.single
    @Published var pollOptions = [String](repeating: String(), count:4)
}


struct PollBuilder: View
{
    @ObservedObject var pollState : PollState
    
    @EnvironmentObject var settings: Settings
    
    var body: some View
    {
        VStack(alignment: .center)
        {
            Text("Poll")
                .foregroundColor(settings.theme.accentColor)
                .font(settings.fonts.title)
            
            VStack(alignment: .leading,spacing: 10)
            {
                ForEach(pollState.pollOptions.indices, id:\.self)
                { index in
                    HStack
                    {
                        TextField("Poll Option Name", text: $pollState.pollOptions[index])
                        
                        Button
                        {
                            if pollState.pollOptions.count > 2
                            {
                                pollState.pollOptions.remove(at: index)
                            }
                        }
                    label:
                        {
                            Text("-")
                        }
                    }
                }
            }

            HStack
            {
                Button
                {
                    if pollState.pollOptions.count < 10 // WHAT IS MAX?
                    {
                        pollState.pollOptions.append("")
                    }
                }
            label:
                {
                    Text("+")
                }

          
                Picker("", selection: $pollState.pollType)
                {
                    ForEach(PollType.allCases)
                    { polltype in
                        Text(polltype.rawValue.capitalized)
                    }
                }
                .frame(width: 150)
                
                Picker("", selection: $pollState.pollTime)
                {
                    ForEach(PollTimes.allCases)
                    { polltime in
                        Text(polltime.rawValue.capitalized)
                    }
                }
                .frame(width: 150)
            }
        }
        .padding()
    }
    

    
    static func getPollPayLoad(pollState:PollState) -> MastodonKit.PollPayload
    {
        var pollexirationseconds = 0
        
        switch pollState.pollTime
        {
        case .fiveMinutes:
            pollexirationseconds = 5 * 60
        case .thirtyMinutes:
            pollexirationseconds = 30 * 60
        case .oneHour:
            pollexirationseconds = 60 * 60
        case .sixHours:
            pollexirationseconds = 60 * 60 * 6
        case .oneDay:
            pollexirationseconds = 60 * 60 * 24
        case .threeDays:
            pollexirationseconds = 60 * 60 * 24 * 3
        case .oneWeek:
            pollexirationseconds = 60 * 60 * 24 * 7
        }
        
        let pollpayload  = MastodonKit.PollPayload(options: pollState.pollOptions,
                                                   expiration: Double(pollexirationseconds),
                                                   multipleChoice: pollState.pollType == PollType.muliple ? true : false)
        
        return pollpayload
    }
}

