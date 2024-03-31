//
//  HomeViewModel.swift
//  Notes
//
//  Created by Surya on 31/03/24.
//

import Combine

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
