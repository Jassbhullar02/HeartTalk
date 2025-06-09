//
//  Extension + View.swift
//  HeartTalk
//
//  Created by Jaspreet Bhullar on 03/06/25.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
