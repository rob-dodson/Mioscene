//
//  ShowImagePanel.swift
//  Miocene
//
//  Created by Robert Dodson on 1/31/23.
//

import SwiftUI

struct ShowImagePanel: View
{
    static var url : URL?
    var done : () -> Void
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            PopButton(text: "", icon: "xmark",isSelected: false)
            {
                done()
            }
            .padding()
            
            AsyncImage(url: ShowImagePanel.url)
            { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth:900,minHeight:900)
            }
        placeholder:
            {
                Image(systemName: "photo")
            }
            .onTapGesture
            {
                done()
            }
        }
    }
}

