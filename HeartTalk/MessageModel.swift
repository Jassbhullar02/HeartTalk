//
//  MessageModel.swift
//  HeartTalk
//
//  Created by Jaspreet Bhullar on 01/06/25.
//

import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    var text: String
    let isUser: Bool
    var status: MessageStatus = .sent // Default
}

enum MessageStatus {
    case sent, delivered, seen
}
