//
//  ContentView.swift
//  Notes
//
//  Created by Surya on 20/11/23.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject var vm = HomeViewModel()
    @State private var presentCreateOrEditNote = false

    var body: some View {
            VStack {
                switch vm.state {
                case .loading:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(2)

                case .completed(let notes):
                    List(notes) { note in
                        Text(note.note)
                            .swipeActions {
                                Button("Edit") {
                                    // Perform edit action
                                    presentCreateOrEditNote.toggle()
                                    // Set the note to be edited
                                    vm.setSelectedNoteForEdit(note)
                                }
                                .tint(.blue)
                                
                                Button("Delete") {
                                    // Perform delete action

                                    Task {
                                        print("Delete button tapped for item \(String(describing: index))")
                                        await vm.delete(id: note.id)
                                    }
                                }
                                .tint(.red)
                            }
                    }
                case .failed(let error):
                    Text(error.localizedDescription)
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        // Perform an action when the button is tapped
                         presentCreateOrEditNote.toggle()
                    }
                }
        }.task {
             await vm.fetchNotes()
        }
        .sheet(isPresented: $presentCreateOrEditNote) {
            NavigationStack {
                AddNoteView(note: vm.selectedNoteForEdit?.note ?? "") { noteText in
                    Task {
                        await vm.createOrUpdate(text: noteText)
                    }
                }
            }
        }
        .alert(item: $vm.toastMessage) { message in
            Alert(
                title: Text(message.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}

