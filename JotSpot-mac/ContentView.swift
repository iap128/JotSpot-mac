//
//  ContentView.swift
//  JotSpot-mac
//
//  Created by Ryan Hunter on 9/25/25.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: JotSpot_macDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

#Preview {
    ContentView(document: .constant(JotSpot_macDocument()))
}
