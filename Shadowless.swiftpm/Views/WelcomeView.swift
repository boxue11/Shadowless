//
//  WelcomeView.swift
//  ShadowlessLamp
//
//  Created by Mars on 2023/4/8.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var isNotSupportAR: Bool
    @Binding var step: Int
    
    let gradient = LinearGradient(gradient: Gradient(colors: [.red, .yellow]), startPoint: .leading, endPoint: .trailing)
    var body: some View {
        var font = UIFont.systemFont(ofSize: 88, weight: .bold)
        if let descriptor = font.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: 88)
        }
        
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.systemPurple,
            NSAttributedString.Key.font: font
        ]
        let shadowless  = NSAttributedString(string: "Shadowless", attributes: attributes)
        
        return ZStack(alignment: .center) {
            
            Color.black.opacity(0.5).ignoresSafeArea(.all)
            
            GeometryReader { proxy in
                VStack {
                    Spacer()
                    
                    Text("Welcome to \n\(shadowless)")
                        .font(.system(size: 88, weight: .bold, design: .rounded))
                        .foregroundColor(Color(.white))
                        .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 2)
                    
                    Spacer()
                    
                    
                    Text("This is an AR based interactive app that helps you understand how the shadow is diminished by several light sources from different directions.")
                        .font(.system(size: 30, weight: .regular, design: .rounded))
                        .foregroundColor(Color(.white))
                        .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 2)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 30)
                        .frame(maxWidth: proxy.size.width * 0.8)
                        .background(
                            Color.black.opacity(0.4)
                                .cornerRadius(12)
                        )
                        .padding(.bottom, 50)
                    
                    if !isNotSupportAR {
                        Button(action: {
                            step += 1
                        }) {
                            HStack {
                                Image(systemName: "hand.tap.fill")
                                Text("Let's begin")
                            }
                            .font(.system(size: 30, weight: .medium, design: .rounded))
                            .foregroundColor(.blue)
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.purple, lineWidth: 2)
                            )
                        }
                        .shadow(color: .purple, radius: 10, x: 5, y: 5)
                    }
                    
                    Spacer()
                    
                    Text("Powered by **ARKit** and **SwiftUI**.")
                        .foregroundColor(Color(UIColor.lightGray))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
            }
            
        }
        .background(
            Image("Shadowless-bg").resizable().aspectRatio(contentMode: .fill).ignoresSafeArea(.all)
        )
        .alert("Oops!", isPresented: $isNotSupportAR) {
            
        } message: {
            Text("ARConfig: AR World Tracking is not supported on this device!! ")
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(isNotSupportAR: .constant(true), step: .constant(1))
    }
}
