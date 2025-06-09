//
//  ChatView.swift
//  HeartTalk
//
//  Created by Jaspreet Bhullar on 01/06/25.
//
import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var inputHeight: CGFloat = 40
    @State private var isDarkMode: Bool = false
    @FocusState private var isInputFocused: Bool
    @State private var showScrollToBottom: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        viewModel.resetChat()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title2)
                            .foregroundColor(.green)
                            .padding()
                    }

                    Spacer()

                    Button(action: {
                        isDarkMode.toggle()
                    }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .font(.title2)
                            .foregroundColor(isDarkMode ? .yellow : .blue)
                            .padding()
                    }
                }

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                MessageBubbleView(message: message, onEdit: { message in
                                    viewModel.userInput = message.text
                                    viewModel.editingMessage = message
                                })
                                .padding(.bottom)
                                .id(message.id)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                            if viewModel.isLoading {
                                HStack(spacing: 4) {
                                    ForEach(0..<3) { i in
                                        Circle()
                                            .frame(width: 6, height: 6)
                                            .foregroundColor(.gray)
                                            .scaleEffect(viewModel.isLoading ? 1.0 : 0.5)
                                            .animation(Animation.easeInOut(duration: 0.6).repeatForever().delay(Double(i) * 0.2), value: viewModel.isLoading)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        scrollToBottom(proxy: proxy)
                    }
                }

                Divider()

                HStack(spacing: 12) {
                    ZStack(alignment: .topLeading) {
                        
                        if viewModel.userInput.isEmpty {
                                Text("Ask anything...")
                                .foregroundColor(.black)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 14)
                            }

                        ResizableTextEditor(text: $viewModel.userInput, dynamicHeight: $inputHeight)
                            .frame(height: inputHeight)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                            .focused($isInputFocused)
                    }

                    Button(action: {
                        viewModel.sendMessage()
                    }) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(viewModel.userInput.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : Color.blue)
                            .clipShape(Circle())
                            .scaleEffect(viewModel.userInput.isEmpty ? 1.0 : 1.2)
                            .animation(.easeInOut(duration: 0.2), value: viewModel.userInput)
                    }
                    .disabled(viewModel.userInput.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding()
                .background(.ultraThinMaterial)
            }

            if showScrollToBottom {
                Button(action: {
                    if viewModel.messages.last != nil {
                        withAnimation(.easeOut(duration: 0.3)) {
                            // Scroll to last
                        }
                    }
                }) {
                    Image(systemName: "arrow.down")
                        .padding()
                        .background(.thinMaterial)
                        .clipShape(Circle())
                }
                .padding(.trailing, 16)
                .padding(.bottom, 90)
            }
        }
        .background(
            LinearGradient(colors: [Color(.systemGray6), Color(.systemBackground)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .contentShape(Rectangle())
        .onTapGesture {
            isInputFocused = false
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isInputFocused = true
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    func scrollToBottom(proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let last = viewModel.messages.last {
                withAnimation {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }
}

struct MessageBubbleView: View {
    let message: ChatMessage
    var onEdit: ((ChatMessage) -> Void)? = nil

    var body: some View {
        HStack(alignment: .top) {
            if message.isUser {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.text)
                        .padding(12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .cornerRadius(16)
                        .frame(maxWidth: 250, alignment: .trailing)
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = message.text
                            }) {
                                Label("Copy", systemImage: "doc.on.doc")
                            }

                            Button(action: {
                                onEdit?(message)
                            }) {
                                Label("Edit", systemImage: "pencil")
                            }
                        }

                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundColor(Color.primary.opacity(0.6))

                        Text(statusText)
                            .font(.caption2)
                            .foregroundColor(Color.primary.opacity(0.6))
                    }
                    .padding(.horizontal, 8)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text(message.text)
                        .padding(12)
                        .background(
                            Color(UIColor { trait in
                                trait.userInterfaceStyle == .dark
                                ? UIColor.secondarySystemBackground
                                : UIColor.black.withAlphaComponent(0.05)
                            })
                        )
                        .foregroundColor(.primary)
                        .font(.system(size: 16))
                        .cornerRadius(16)
                        .frame(maxWidth: 250, alignment: .leading)
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = message.text
                            }) {
                                Label("Copy", systemImage: "doc.on.doc")
                            }
                        }
                }
                Spacer()
            }
        }
        .padding(.horizontal)
    }

    var statusText: String {
        switch message.status {
        case .sent: return "Sent"
        case .delivered: return "Delivered"
        case .seen: return "Seen"
        }
    }
}
