//
//  ResizableTextEditor.swift
//  HeartTalk
//
//  Created by Jaspreet Bhullar on 07/06/25.
//

import SwiftUI

struct ResizableTextEditor: UIViewRepresentable {
    
    // MARK: - Properties
    @Binding var text: String
    @Binding var dynamicHeight: CGFloat

    private let maxHeight: CGFloat = 120  // Max height for the TextEditor

    // MARK: - Public Functions

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.backgroundColor = UIColor.clear
        textView.delegate = context.coordinator
        textView.isScrollEnabled = false  // Initially disabled
        textView.text = text
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        textView.showsVerticalScrollIndicator = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        // Fixed width to avoid horizontal stretching
        let screenWidth = UIScreen.main.bounds.width
        let maxWidth = screenWidth - 100  // Adjust if needed
        textView.widthAnchor.constraint(equalToConstant: maxWidth).isActive = true
        
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        
        // Recalculate height and apply scroll if needed
        ResizableTextEditor.recalculateHeight(view: uiView, result: $dynamicHeight, maxHeight: maxHeight)
        uiView.isScrollEnabled = dynamicHeight >= maxHeight
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    static func recalculateHeight(view: UITextView, result: Binding<CGFloat>, maxHeight: CGFloat) {
        let size = view.sizeThatFits(CGSize(width: view.bounds.width, height: .greatestFiniteMagnitude))
        DispatchQueue.main.async {
            result.wrappedValue = min(size.height, maxHeight)
        }
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: ResizableTextEditor

        init(_ parent: ResizableTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            ResizableTextEditor.recalculateHeight(view: textView, result: parent.$dynamicHeight, maxHeight: parent.maxHeight)
            textView.isScrollEnabled = parent.dynamicHeight >= parent.maxHeight
        }
    }
}
