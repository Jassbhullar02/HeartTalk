//
//  ChatViewModel.swift
//  HeartTalk
//
//  Created by Jaspreet Bhullar on 01/06/25.
//
import Foundation
import SwiftUI

class ChatViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var messages: [ChatMessage] = []
    @Published var userInput: String = ""
    @Published var isLoading: Bool = false
    @Published var editingMessage: ChatMessage? = nil
    
    private let apiService = CohereAPIService()
    
    init() {
        // Show welcome message from AI
        let welcome = ChatMessage(
            text: "Hey! I'm here to chat, guide, or just listen — whatever's on your mind 💬",
            isUser: false,
            status: .sent
        )
        messages.append(welcome)
    }
    
    // MARK: - Public Functions

    func sendMessage() {
        let trimmedText = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        if let editing = editingMessage {
            // If editing an old message
            if let index = messages.firstIndex(where: { $0.id == editing.id }) {
                messages[index].text = trimmedText
                
                // Also update AI response after the edited user message
                if index + 1 < messages.count, !messages[index + 1].isUser {
                    isLoading = true
                    apiService?.sendMessage(trimmedText) { [weak self] response in
                        DispatchQueue.main.async {
                            self?.isLoading = false
                            guard let self = self, let response = response else { return }
                            withAnimation {
                                let botMessage = ChatMessage(text: response, isUser: false, status: .sent)
                                self.messages.append(botMessage)
                            }
                        }
                    }
                }
            }
            editingMessage = nil
            userInput = ""
            return
        }
        
        // New message flow
        let userMessage = ChatMessage(text: trimmedText, isUser: true, status: .sent)
        messages.append(userMessage)
        userInput = ""
        isLoading = true
        
        apiService?.sendMessage(trimmedText) { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoading = false
                guard let self = self, let response = response else { return }
                withAnimation {
                    let botMessage = ChatMessage(text: response, isUser: false, status: .sent)
                    self.messages.append(botMessage)
                }
            }
        }
    }
    
    func startEditing(_ message: ChatMessage) {
        editingMessage = message
        userInput = message.text
    }
    
    func resetChat() {
        messages.removeAll()
        editingMessage = nil
        userInput = ""
        
        // Show welcome message again
        let welcome = ChatMessage(
            text: "Hey! I'm here to chat, guide, or just listen — whatever's on your mind 💬",
            isUser: false,
            status: .sent
        )
        messages.append(welcome)
    }
}
