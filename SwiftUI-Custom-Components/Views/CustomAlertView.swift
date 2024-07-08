//
//  CustomAlertView.swift
//  ToDoList-SwiftUI
//
//  Created by Bo Zhong on 7/8/24.
//

import SwiftUI

struct CustomAlertView<T: Hashable, M: View>: View {
    @Binding private var isPresented: Bool
    @State private var titleKey: LocalizedStringKey
    @State private var actionTextKey: LocalizedStringKey
    
    private var data: T?
    private var actionWithValue: ((T) -> ())?
    private var messageWithValue: ((T) -> M)?
    
    private var action: (() -> ())?
    private var message: (() -> M)?
    
    @State private var isAnimating: Bool = false
    private let animationDuration = 0.5
    
    init(
        _ titleKey: LocalizedStringKey,
        _ isPresented: Binding<Bool>,
        presenting data: T?,
        actionTextKey: LocalizedStringKey,
        action: @escaping (T) -> (),
        @ViewBuilder message: @escaping (T) -> M
    ) {
        _titleKey = State(wrappedValue: titleKey)
        _actionTextKey = State(wrappedValue: actionTextKey)
        _isPresented = isPresented
        
        self.data = data
        self.action = nil
        self.message = nil
        self.actionWithValue = action
        self.messageWithValue = message
    }
    
    var CancelButton: some View {
        Button {
            dismissAlert()
        } label: {
            Text("Cancel")
                .font(.headline)
                .foregroundStyle(.tint)
                .padding()
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .background(Material.regular)
                .background(.gray)
                .clipShape(RoundedRectangle(cornerRadius: 30))
            
        }
    }
    
    var DoneButton: some View {
        Button(action: {
            if let data, let actionWithValue {
                actionWithValue(data)
            } else if action != nil {
                dismissAlert()
            }
        }, label: {
            Text(actionTextKey)
                .font(.headline)
                .foregroundStyle(.tint)
                .padding()
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .background(Material.regular)
                .clipShape(RoundedRectangle(cornerRadius: 30))
        })
    }
    
    var body: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()
                .opacity(isPresented ? 0.6 : 0)
                .zIndex(1)
            
            VStack {
                // TODO: Alert
            }
            .padding()
            if isAnimating{
                VStack {
                    VStack {
                        Text(titleKey)
                            .font(.title2).bold()
                            .foregroundStyle(.tint)
                            .padding(8)
                        
                        Group {
                            if let data, let messageWithValue {
                                messageWithValue(data)
                            } else if let message {
                                message()
                            }
                        }
                        .multilineTextAlignment(.center)
                        
                        HStack {
//                            CancelButton
                            DoneButton
                        }
                        .fixedSize(horizontal: false, vertical: false)
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 35))
                }
                .padding()
                .transition(.slide)
                .zIndex(2)
            }
        }
        .onAppear(perform: {
            displayAlert()
        })
        .ignoresSafeArea()
        .zIndex(.greatestFiniteMagnitude)
        
    }
    
    func dismissAlert() {
        withAnimation(.easeInOut(duration: animationDuration)){
            isAnimating = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            isPresented = false
        }
    }
    
    func displayAlert(){
        withAnimation(.easeInOut(duration: animationDuration)){
            isAnimating = true
        }
    }
}


extension CustomAlertView where T == Never {
    init(
        _ titleKey: LocalizedStringKey,
        _ isPresented: Binding<Bool>,
        actionTextKey: LocalizedStringKey,
        action: @escaping () -> (),
        @ViewBuilder message: @escaping () -> M
    ) where T == Never {
        _titleKey = State(wrappedValue: titleKey)
        _actionTextKey = State(wrappedValue: actionTextKey)
        _isPresented = isPresented
        
        self.data = nil
        self.action = action
        self.message = message
        self.actionWithValue = nil
        self.messageWithValue = nil
    }
}

extension View {
    func customAlert<M>(
        _ titleKey: LocalizedStringKey,
        isPresented: Binding<Bool>,
        actionText: LocalizedStringKey,
        action: @escaping () -> (),
        @ViewBuilder message: @escaping () -> M
    ) -> some View where M: View {
        fullScreenCover(isPresented: isPresented) {
            CustomAlertView(titleKey, isPresented, actionTextKey: actionText, action: action, message: message)
                .presentationBackground(.clear)
        }
        .transaction { transaction in
            if isPresented.wrappedValue {
                transaction.disablesAnimations = true
                
                transaction.animation = .linear(duration: 0.1)
            }
        }
    }
    
}

struct ExampleData: Hashable {
    let name: String
}

extension View {
    func customAlert<M, T: Hashable>(
        _ titleKey: LocalizedStringKey,
        isPresented: Binding<Bool>,
        presenting data: T?,
        actionText: LocalizedStringKey,
        action: @escaping (T) -> (),
        @ViewBuilder message: @escaping (T) -> M
    ) -> some View where M: View {
        fullScreenCover(isPresented: isPresented, content: {
            CustomAlertView(
                titleKey, isPresented,
                presenting: data,
                actionTextKey: actionText,
                action: action,
                message: message)
            .presentationBackground(.clear)
        })
    }
}

#Preview {
    CustomAlertView(
        LocalizedStringKey("Alert Title"),
        .constant(true),
        presenting: ExampleData(name: "Example Name"),
        actionTextKey: LocalizedStringKey("OK"),
        action: { data in
            print("Action with data: \(data.name)")
        }, message: { data in
            Text("Message with data: \(data.name)")
        }
    )
}
