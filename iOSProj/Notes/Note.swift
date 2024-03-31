//
//  Note.swift
//  Notes
//
//  Created by Surya on 31/03/24.
//

import Foundation

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

