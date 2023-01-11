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
    @State var poll :  MastodonKit.Poll
    
    @EnvironmentObject var settings: Settings
    
    var body: some View
    {
        
        VStack(alignment:.leading)
        {
            VStack(alignment: .leading)
            {
                ForEach(poll.options.indices, id:\.self)
                { index in
                    
                    let total : Double = Double(poll.votesCount)
                    let itemcount : Double = Double(poll.options[index].votesCount)
                    var percent = trunc((itemcount / total) * 100.0)
                    
                    ZStack(alignment: .leading)
                    {
                        Rectangle().frame(width:300 ,height: 20)
                            .foregroundColor(settings.theme.minorColor.opacity(0.25))
                        
                        Rectangle().frame(width:CGFloat(percent),height: 20)
                            .foregroundColor(settings.theme.accentColor)
                        
                        HStack
                        {
                            Text(" \(poll.options[index].title)")
                            Spacer()
                            Text("\(percent.formatted())% ")
                        }
                    }
                }
            }
            .frame(width: 300)
            
            Rectangle().frame(width:100,height: 1).foregroundColor(settings.theme.minorColor)

            Text("Votes \(poll.votesCount)")
          
            Spacer()
            
            HStack(spacing:2)
            {
                if poll.expired == true
                {
                    Text("Expired")
                }
                else
                {
                    Text("Expires")
                }
                
                Text("\(poll.expiresAt.formatted(date: .abbreviated, time: .shortened))")
            }
            .foregroundColor(settings.theme.minorColor)
            .font(settings.fonts.small).italic()
        }
        .padding()
        .foregroundColor(settings.theme.nameColor)
        .border(width: 1, edges: [.top,.bottom,.leading,.trailing], color: settings.theme.minorColor)
    }
}
