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
                                        print("Delete button tapped for item \(index)")
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

extension String: Error {}

enum HomeState {
    case loading
    case completed([Note])
    case failed(Error)
}

struct ToastMessage: Identifiable {
    var id = UUID()
    var message: String
}


@MainActor
class HomeViewModel: ObservableObject {
    
    @Published var state: HomeState = .loading
    @Published var toastMessage: ToastMessage?
    var selectedNoteForEdit: Note?

    let service = HomeService()
    
    init() {
    }
    
    func fetchNotes() async {
        do {
            let notes = try await service.fetchNotes()
            state = .completed(notes)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
    
    func createOrUpdate(text: String) async {
        if let id = selectedNoteForEdit?._id {
            do {
                try await service.update(id: id, text: text)
                toastMessage = ToastMessage(message: "Note added")
                await fetchNotes()
                selectedNoteForEdit = nil
            } catch {
                toastMessage = ToastMessage(message: "updation failed: \(error.localizedDescription)")
            }
        } else {
            do {
                try await service.create(text: text)
                toastMessage = ToastMessage(message: "Note added")
                await fetchNotes()
            } catch {
                toastMessage = ToastMessage(message: "creating failed: \(error.localizedDescription)")
            }
        }
    }
    func delete(id: String) async {
        do {
            try await service.delete(id: id)
            toastMessage = ToastMessage(message: "Note Deleted")
            await fetchNotes()
        } catch {
            await fetchNotes()

//            toastMessage = ToastMessage(message: "deletion failed: \(error.localizedDescription)")
        }
    }
    
    func showToast(message: String) {
        // Show a toast alert with the provided message
        toastMessage = ToastMessage(message: message)
    }
    
    func setSelectedNoteForEdit(_ note: Note?) {
        selectedNoteForEdit = note
    }

}

class HomeService {
    let url = URL(string: "http://localhost:3000/notes")!
    
    func fetchNotes() async throws -> [Note] {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let notes = try decoder.decode([Note].self, from: data)
            return notes
        } catch {
            print("Error fetching notes: \(error)")
            throw error
        }
    }
    
    func create(text: String) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let dict = [
            "note": text
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)

        request.httpBody = jsonData
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw NSError(domain: "com.yourapp", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create note"])
        }
    }
    
    func update(id: String, text: String) async throws {
           var request = URLRequest(url: url.appendingPathComponent(id))
           request.httpMethod = "PATCH"
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           let dict = [
               "note": text
           ]
           let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)

           request.httpBody = jsonData
           
           let (_, response) = try await URLSession.shared.data(for: request)
           guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
               throw NSError(domain: "com.yourapp", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to update note"])
           }
       }
       
       func delete(id: String) async throws {
           var request = URLRequest(url: url.appendingPathComponent(id))
           request.httpMethod = "DELETE"
           
           let (_, response) = try await URLSession.shared.data(for: request)
           guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
               throw NSError(domain: "com.yourapp", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to delete note"])
           }
       }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}

struct Note: Identifiable, Decodable {
    var id: String { _id }
    let _id: String
    let note: String
    
    static var mock: [Note] {
        [
            Note(_id: "1", note: "first note"),
            Note(_id: "2", note: "second note"),
        ]
    }
}
