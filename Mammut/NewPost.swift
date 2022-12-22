//
//  NewPost.swift
//  Mammut
//
//  Created by Robert Dodson on 12/21/22.
//

import SwiftUI
import MastodonKit


struct NewPost: View
{
    @ObservedObject var mast : Mastodon
    @State var selectedTimeline : Binding<TimeLine>
    
    @Environment(\.dismiss) private var dismiss
    @State private var shouldPresentSheet = false
    @State private var newPost : String = ""
    
    var body: some View
    {
        Button()
        {
            shouldPresentSheet.toggle()
        }
        label:
        {
            Image(systemName: "square.and.pencil")
        }
        .sheet(isPresented: $shouldPresentSheet)
        {
            print("Sheet dismissed!")
        }
        content:
        {
            Text("New Post")
            VStack
            {
                TextEditor(text: $newPost)
                    .foregroundColor(Color.gray)
                    .font(.custom("HelveticaNeue", size: 18))
                    .scrollIndicators(.automatic)
                
                Text("\(500 - $newPost.wrappedValue.count)")
            }
            .toolbar
            {
                ToolbarItem
                {
                    Button("Cancel")
                    {
                        dismiss()
                    }
                }
                ToolbarItem
                {
                    Button("Post")
                    {
                        let request = Statuses.create(status:$newPost.wrappedValue)
                        mast.client.run(request)
                        { result in
                            print("result \(result)")
                        }
                        
                        dismiss()
                    }
                }
                    
            }
            .frame(width: 400, height: 300)
        }
    }
}

