//
//  ShowImagePanel.swift
//  Miocene
//
//  Created by Robert Dodson on 1/31/23.
//

import SwiftUI

struct ShowImagePanel: View
{
    var url : URL
    var done : () -> Void
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            PopButton(text: "", icon: "xmark")
            {
                done()
            }
            .padding()
            
            AsyncImage(url: url)
            { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width:800,height:800)
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

