//
//  SheetView.swift
//  CitiesPlayground
//
//  Created by Piero Sierra on 10/09/2024.
//

import Foundation
import SwiftUI

struct SheetView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme // for DarkMode detection
    var sheetImage: Image
    var sheetImageResize: Bool
    var sheetTitle: String
    var sheetContent: String  // Changed to String
    
    var body: some View {
        ScrollView {
            VStack {
                Spacer()
                if (sheetImageResize)
                {
                    sheetImage
                        .resizable() // Allows the image to be resized
                        .scaledToFill() // Ensures the image
                        .frame(minHeight: 450) // Set the maximum height to 800
                        .frame(maxWidth: .infinity)
                        .frame(minWidth: 10)
                        .clipped()
                        .padding()
                } else {
                    sheetImage
                        .clipped()
                }
                
                Text(sheetTitle)
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                Text(LocalizedStringKey(sheetContent))  // Wrap in LocalizedStringKey here
                    .padding()
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Button("Dismiss") {
                    dismiss() // Dismiss the sheet
                }.buttonStyle(GrowingButton())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
  //          .background(Color(UIColor.systemBackground))
            .overlay(dismissButton, alignment: .topTrailing)
        }
    }

    private var dismissButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.gray)
                .imageScale(.large)
        }
        .padding()
    }
}

#Preview {
    SheetView(
        sheetImage: Image(""),
        sheetImageResize: false,
        sheetTitle: "About",
        sheetContent: """
        NerdBookiOS test content.
        For Mila ❤️ Papa, 2024.
        For Mila ❤️ Papa, 2024.
        For Mila ❤️ Papa, 2024.
        And more
        And now a url:
        And more
        URL: [CNN](https://www.cnn.com)
        the end
        """
    )
    .environmentObject(AppState())
}

#Preview {
    SheetView(
        sheetImage: Image("Logo_transparent_100"),
        sheetImageResize: true,
        sheetTitle: "About",
        sheetContent: """
        NerdBookiOS test content.
        For Mila ❤️ Papa, 2024.
        For Mila ❤️ Papa, 2024.
        For Mila ❤️ Papa, 2024.
        And more
        And now a url:
        And more
        URL: [CNN](https://www.cnn.com)
        the end
        """
    )
    .environmentObject(AppState())
}

#Preview {
    SheetView(sheetImage: Image("Logo_transparent_100"), sheetImageResize: true, sheetTitle: "About", sheetContent: "Seattle is a seaport city on the West Coast of the United States. It is the seat of King County, Washington. With a 2023 population of 755,078 it is the most populous city in both the state of Washington and the Pacific Northwest region of North America, and the 18th-most populous city in the United States. The Seattle metropolitan area's population is 4.02 million, making it the 15th-largest in the United States.[11] Its growth rate of 21.1% between 2010 and 2020 made it one of the country's fastest-growing large cities. Seattle is a seaport city on the West Coast of the United States. It is the seat of King County, Washington. With a 2023 population of 755,078 it is the most populous city in both the state of Washington and the Pacific Northwest region of North America, and the 18th-most populous city in the United States. The Seattle metropolitan area's population is 4.02 million, making it the 15th-largest in the United States.[11] Its growth rate of 21.1% between 2010 and 2020 made it one of the country's fastest-growing large cities.")
        .environmentObject(AppState())
}


