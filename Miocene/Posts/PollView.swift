//
//  PollView.swift
//  Mioscene
//
//  Created by Robert Dodson on 1/11/23.
//

import SwiftUI
import MastodonKit


struct PollView: View
{
    @State var poll : MastodonKit.Poll
    
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var appState: AppState
    
    @State private var votes : [Int] = Array(repeating: -1, count: 10) // what is the current poll limit?
    @State private var voted : Bool = false
   
    
    var body: some View
    {
        VStack(alignment:.leading)
        {
            VStack(alignment: .leading)
            {
                
                    ForEach(poll.options.indices, id:\.self)
                    { index in
                        
                        let total = Double(poll.votesCount)
                        let itemcount = Double(poll.options[index].votesCount ?? 0)
                        let percent = max(0.0,trunc((itemcount / total) * 100.0))
                        
                        
                        HStack
                        {
                            if voted == false && poll.voted == false && poll.expired == false
                            {
                                Button()
                                {
                                    if votes[index] == -1
                                    {
                                        if poll.multiple == false
                                        {
                                            clearvotes()
                                        }
                                        votes[index] = index
                                    }
                                    else
                                    {
                                        votes[index] = -1
                                    }
                                }
                            label:
                                {
                                    if votes[index] != -1
                                    {
                                        Image(systemName: "checkmark")
                                    }
                                    else
                                    {
                                        Image(systemName: "circle")
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            
                            GeometryReader
                            { geo in
                            
                            ZStack(alignment: .leading)
                            {
                                Rectangle().frame(width:geo.size.width ,height: 20)
                                    .foregroundColor(settings.theme.minorColor.opacity(0.25))
                                
                                if voted == true || poll.voted == true || poll.expired == true
                                {
                                    Rectangle().frame(width:geo.size.width * (percent / 100.0) ,height: 20)
                                        .foregroundColor(settings.theme.accentColor)
                                    
                                    HStack
                                    {
                                        Text(" \(poll.options[index].title)")
                                        Spacer()
                                        Text("\(percent.formatted())% ")
                                    }
                                }
                                else
                                {
                                    Text(" \(poll.options[index].title)")
                                }
                            }
                        }
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                    }
                }
            }
            
            Rectangle().frame(width:100,height: 1).foregroundColor(settings.theme.minorColor)

            Text("Total Votes \(poll.votesCount)")
            Spacer()
          
            if voted == false && poll.voted == false && poll.expired == false
            {
                Button("Vote")
                {
                    vote()
                }
                .disabled(votes.count > 0 ? false : true)
            }
            else
            {
                if poll.ownVotes.count > 0 || voted == true
                {
                    HStack
                    {
                        Text("You voted for")
                        if poll.ownVotes.count > 0
                        {
                            ForEach(poll.ownVotes.indices, id:\.self)
                            { index in
                                Text("#\(poll.ownVotes[index] + 1) ")
                            }
                        }
                        else
                        {
                            ForEach(votes.indices, id:\.self)
                            { index in
                                if (votes[index] != -1)
                                {
                                    Text("#\(votes[index] + 1) ")
                                }
                            }
                        }
                    }
                    .foregroundColor(settings.theme.minorColor)
                }
                else if poll.voted == true
                {
                    Text("This is your poll")
                        .foregroundColor(settings.theme.minorColor)
                }
            }
            
            Spacer()
            
            HStack(spacing:2)
            {
                if poll.expired == true
                {
                    Text("Expired")
                        .foregroundColor(settings.theme.accentColor)
                }
                else
                {
                    Text("Expires")
                }
                
                if let date = poll.expiresAt
                {
                    Text("\(date.formatted(date: .abbreviated, time: .shortened))")
                }
            }
            .foregroundColor(settings.theme.minorColor)
            .font(settings.font.footnote).italic()
        }
        .padding()
        .foregroundColor(settings.theme.nameColor)
        .border(width: 1, edges: [.top,.bottom,.leading,.trailing], color: settings.theme.minorColor)
    }
    

    func clearvotes()
    {
        votes = votes.map { _ in return -1 }
        for index in 0..<votes.count
        {
            votes[index] = -1
        }
    }
    
    
    func vote()
    {
        voted = true
        let choices = votes.compactMap {  $0 > -1 ? $0 : nil}
        
        var choiceSet = IndexSet()
        for val in choices
        {
            choiceSet.insert(val)
        }
        
        appState.mastio()?.voteOnPoll(poll: poll, choices: choiceSet)
        { updatedpoll in
            poll = updatedpoll
        }
    }
    
}
