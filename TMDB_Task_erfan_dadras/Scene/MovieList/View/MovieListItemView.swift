//
//  MovieListItemView.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import SwiftUI

struct MovieListItemView: View {
    let data: MoviesUIModel
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImageView(url: data.imageUrl,
                           contentMode: .fill) {
                Image(systemName: "photo")
                    .renderingMode(.template)
                    .resizable(capInsets: .init(.zero),
                                   resizingMode: .stretch)
                    .foregroundStyle(.black.opacity(0.7))
            }
            .frame(width: 120, height: 100)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(data.title)
                    .lineLimit(2)
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                
                Spacer(minLength: 0)
                Text(data.date)
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                    .leading()
            }// text VStack
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
        }//HStack
        .frame(maxWidth: .infinity, maxHeight: 100)
        .padding(.horizontal)
    }
}
