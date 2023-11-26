//
//  AddNoteView.swift
//  Notes
//
//  Created by Surya on 25/11/23.
//

import SwiftUI

struct AddNoteView: View {
    @State var note: String = ""
    var onSave: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            
            TextField("Enter your note",
                      text: $note)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .autocorrectionDisabled()

            Button("Save") {
                onSave(note)
                dismiss()
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle(note.isEmpty ?
                         "Create Note" : "Edit Note")
    }
}


#Preview {
    NavigationStack {
        AddNoteView(note: "") { _ in  }
    }
}
