//
//  NewPost.swift
//  Mammut
//
//  Created by Robert Dodson on 12/21/22.
//

import SwiftUI

struct NewPost: View
{
    @State var selectedTimeline : Binding<TimeLine>
    
    @Environment(\.dismiss) private var dismiss
    @State private var shouldPresentSheet = false
    @State private var newPost : String = ""
    
    var body: some View {
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
            VStack
            {
                TextEditor(text: $newPost)
                    .padding()
                
                Text("\(500 - $newPost.wrappedValue.count)")
                    .padding()
            }
            .toolbar
            {
                ToolbarItem
                {
                    Picker(selection: .constant(1),label: Text("Account"),content:
                    {
                        Text("@rdodson").tag(1)
                        Text("@frogradio").tag(2)
                    })
                }
                
                ToolbarItem
                {
                    Picker("Timeline",selection: $selectedTimeline.wrappedValue)
                            {
                                ForEach(TimeLine.allCases)
                                { timeline in
                                    Text(timeline.rawValue.capitalized)
                                }
                            }
                }
                
                ToolbarItem
                {
                    Spacer()
                }
                
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
                        dismiss()
                    }
                }
                    
            }
            .frame(width: 400, height: 300)
        }
    }
}

