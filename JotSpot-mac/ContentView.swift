//
//  ContentView.swift
//  JotSpot-mac
//
//  Created by Ryan Hunter on 9/25/25.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: JotSpot_macDocument
	@State private var title: String = ""

    var body: some View {
		VStack {
			toolbar
				.padding()
			
			HStack {
				TextField("New Document", text: $title)
				Button("Name Document", action: {print(title)})
			}
			.padding(.horizontal)
			
			TextEditor(text: $document.text)
				.padding()
		}
		.toolbar {
			navBar
		}
    }
	
	var navBar: some View {
		HStack {
			Button("Colors", systemImage: "paintpalette", action: {print("colors")})
			Button("Fonts", systemImage: "textformat", action: {print("Fonts")})
			Button("Rate", systemImage: "star", action: {print("rate")})
			Button("Help", systemImage: "questionmark.circle", action: {print("help")})
		}
	}
	
	var toolbar: some View {
		HStack {
			Button(action: {print("undo")}) {
				Image(systemName: "arrow.uturn.backward")
			}
			Button(action: {print("save")}) {
				Image(systemName: "square.and.arrow.down")
			}
			Button(action: {print("open")}) {
				Image(systemName: "archivebox")
			}
			Button(action: {print("Copy")}) {
				Image(systemName: "document.on.document")
			}
			Button(action: {print("paste")}) {
				Image(systemName: "document.on.clipboard")
			}
			Button(action: {print("cut")}) {
				Image(systemName: "scissors")
			}
			Button(action: {print("print")}) {
				Image(systemName: "printer")
			}
			
		}
	}
}

#Preview {
    ContentView(document: .constant(JotSpot_macDocument()))
}
