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
            AsyncImage(url: data.imageUrl, scale: 1) { image in
                image.resizable(capInsets: .init(.zero),
                               resizingMode: .stretch)
            } placeholder: {
                Image(systemName: "photo")
                    .renderingMode(.template)
                    .resizable(capInsets: .init(.zero),
                                   resizingMode: .stretch)
                    .foregroundStyle(.black.opacity(0.7))
                
            }
            .frame(width: 120, height: 100)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 14) {
                Text(data.title)
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .leading()
                    .frame(maxWidth: .infinity)
                
                Spacer()
                Text(data.date)
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .leading()
            }// text VStack
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            Spacer()
        }//HStack
        .frame(maxWidth: .infinity, maxHeight: 100)
        .padding(.horizontal)
    }
}
