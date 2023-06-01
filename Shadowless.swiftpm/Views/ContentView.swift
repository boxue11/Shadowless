//
//  ContentView.swift
//  ShadowlessLamp
//
//  Created by Mars on 2023/3/9.
//

import SwiftUI
import ARKit
import AVFoundation

var audioPlayer: AVAudioPlayer?

struct ContentView: View {
    @StateObject var arModel = ARViewModel()
    
    @State var isNotSupportAR = !ARWorldTrackingConfiguration.isSupported
    @State var step = 1
    @State var showingCredits = true
    @State var currGround = 1
    @State var currCylinder = 3
    
    var body: some View {
        if step == 1 {
            WelcomeView(isNotSupportAR: $isNotSupportAR, step: $step)
        }
        else {
            makeiPadARView()
        }
    }
    
    func makeiPadARView() -> some View {
        HStack {
            ARVC(model: arModel)
                .ignoresSafeArea(.all)
            
            if step == 2 {
                makeStep1Sheet()
                    .frame(maxWidth: 400)
            }
            else if step == 3 {
                makeStep2Sheet()
                    .frame(maxWidth: 400)
            }
            else if step == 4 {
                makeStep3Sheet()
                    .frame(maxWidth: 400)
            }
            else if step == 5 {
                makeStep4Sheet()
                    .frame(maxWidth: 400)
            }
            else if step == 6 {
                makeStep5View()
                    .frame(maxWidth: 400)
            }
            else if step == 7 {
                makeStep6View()
                    .frame(maxWidth: 400)
            }
            else if step == 8 {
                makeStep7View()
                    .frame(maxWidth: 400)
            }
            else if step == 9 {
                makeStep8View()
                    .frame(maxWidth: 400)
            }
            else if step == 10 {
                makeStep9View()
                    .frame(maxWidth: 400)
            }
            else if step == 11 {
                makePlaygroundView()
                    .frame(maxWidth: 400)
            }
        }
        .statusBarHidden()
    }
    
    func makeARView() -> some View {
        ZStack {
            ARVC(model: arModel)
                .ignoresSafeArea(.all)
                .statusBarHidden()
            
            Text(arModel.arState.toString())
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundColor(Color(.white))
            
        }
        .sheet(isPresented: $showingCredits) {
            if step == 2 {
                makeStep1Sheet()
            }
            else {
                EmptyView()
            }
        }
    }
    
    func makeStep1Sheet() -> some View {
        VStack(spacing: 50) {
            Text("Step 1")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundColor(.purple)
            
            Text("First, find a horizontal plane by your camera until a blue crosshair icon appears.")
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
            
            Button(action: {
                step += 1
            }, label: {
                Text("OK, I found the crosshair.")
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.purple, lineWidth: 2)
                    )
            })
        }
        .padding(20)
        .presentationDetents([.fraction(0.35)])
    }
    
    func makeStep2Sheet() -> some View {
        VStack(spacing: 50) {
            Text("Step 2")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundColor(.purple)
            
            Text("Great! Now, use the crosshair to target a position and **tap it**. We will create a gray plane there as our scene.")
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
            
            Button(action: {
                step += 1
            }, label: {
                Text("Neat, I saw the plane.")
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.purple, lineWidth: 2)
                    )
            })
        }
        .padding(20)
        .presentationDetents([.fraction(0.35)])
    }
    
    func makeStep3Sheet() -> some View {
        VStack(spacing: 50) {
            Text("Step 3")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundColor(.purple)
            
            Text("Next, you can set a skin of the plane.")
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
            
            setGroundMaterial()
            
            Button(action: {
                step += 1
                arModel.isDisplayCylinder = true
            }, label: {
                Text("Cool, go next.")
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.purple, lineWidth: 2)
                    )
            })
        }
        .padding(20)
        .presentationDetents([.fraction(0.35)])
    }
    
    func makeStep4Sheet() -> some View {
        VStack(spacing: 50) {
            Text("Step 4")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundColor(.purple)
            
            Text("Can you see the cylinder above the plane? We will use it to observe its shadow from appearing to disappearing. Again, you can choose one of its skin below.")
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
            
            setCylinderMaterial()
            
            Button(action: {
                step += 1
                self.arModel.isDisplayTorus = true
                self.arModel.isDisplayLights = true
                
                let node = self.arModel.spotlightsMeta[0]
                node.isOn = true
                
                self.arModel.spotlightsMeta[0] = node
            }, label: {
                Text("I'm ready to learn the shadow.")
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.purple, lineWidth: 2)
                    )
            })
        }
        .padding(20)
        .presentationDetents([.fraction(0.35)])
    }
    
    func makeStep5View() -> some View {
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.systemPurple,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        let originalShadow = NSAttributedString(string: "Original Shadow", attributes: attributes)
        
        
        return VStack(spacing: 50) {
            Text("Step 5")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundColor(.purple)
            
            Text("Great! Now we placed a circle of spotlights above the cylinder. If we turn on one, there will be a deep black shadow on the ground. \n\nWe call it \(originalShadow).")
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
            
            Button(action: {
                step += 1
                let node = self.arModel.spotlightsMeta[1]
                node.isOn = true
                
                self.arModel.spotlightsMeta[1] = node
            }, label: {
                Text("Let's turn on another light.")
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.purple, lineWidth: 2)
                    )
            })
        }
        .padding(20)
        .presentationDetents([.fraction(0.35)])
    }
    
    func makeStep6View() -> some View {
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.systemPurple,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        let penumbra  = NSAttributedString(string: "Penumbra", attributes: attributes)
        
        
        return VStack(spacing: 50) {
            Text("Step 6")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundColor(.purple)
            
            Text("Well! Now we turned on two lights. \n\nThe overlapping part of the two shadows, which is particularly dark, is still the original shadow. \n\nThe rest gray part, which is less noticeable, is called \(penumbra).")
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
            
            
            Divider()
            
            Text("You can try turning off a light to compare the difference before and after.")
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
            
            Toggle(isOn: $arModel.spotlightsMeta[1].isOn) {
                
                if arModel.spotlightsMeta[1].isOn {
                    Image(systemName: "lightbulb.fill")
                }
                else {
                    Image(systemName: "lightbulb")
                }
            }
            .onChange(of: arModel.spotlightsMeta[1].isOn) { _ in
                playAudio()
            }
            
            Button(action: {
                step += 1
                
                for i in 0..<self.arModel.spotlightsMeta.count {
                    let tmp = self.arModel.spotlightsMeta[i]
                    tmp.isOn = true
                    self.arModel.spotlightsMeta[i] = tmp
                }
            }, label: {
                Text("Wow! What if we turn on more lights?")
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.purple, lineWidth: 2)
                    )
            })
        }
        .padding(20)
        .presentationDetents([.fraction(0.35)])
    }
    
    func makeStep7View() -> some View {
        return VStack(spacing: 50) {
            Text("Step 7")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundColor(.purple)
            
            Text("Isn't it amazing? Almost all **original shadows** are diminished. Only **penumbral shadows** are left on the ground.")
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
            
            
            Divider()
            
            Text("You can try turning off some of the lights to compare the difference before and after.")
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
            
            makeLightSwitchPanel()
            
            Button(action: {
                step += 1
            }, label: {
                Text("Can the penumbra dispear completely?")
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.purple, lineWidth: 2)
                    )
            })
        }
        .padding(20)
        .presentationDetents([.fraction(0.35)])
    }
    
    func makeStep8View() -> some View {
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue,
            NSAttributedString.Key.underlineColor: UIColor.systemPurple
        ]
        
        let disappear  = NSAttributedString(string: "disappear completely", attributes: attributes)
        let tooLight  = NSAttributedString(string: "too light to see", attributes: attributes)
        
        let attr2: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.systemPurple,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        let originalShadow = NSAttributedString(string: "original shadows", attributes: attr2)
        let penumbra = NSAttributedString(string: "penumbras", attributes: attr2)
        
        
        return VStack(spacing: 50) {
            Text("Step 8")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundColor(.purple)
            
            Text("Sure, let's try to increase the luminosity of the lights and observe what happens 😀.")
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
            
            makeLuminositySlider()
            
            Divider()
            
            Text("As you can see, if we arrange the lights with **enough luminosity** in a circle, the \(originalShadow) will \(disappear), and the \(penumbra) will be \(tooLight).")
                .lineSpacing(12)
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
            
            Button(action: {
                step += 1
            }, label: {
                Text("What can we learn from this discovery?")
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.purple, lineWidth: 2)
                    )
            })
        }
        .padding(20)
        .presentationDetents([.fraction(0.35)])
    }
    
    func makeStep9View() -> some View {
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue,
            NSAttributedString.Key.underlineColor: UIColor.systemPurple
        ]
        
        let arentShadowless  = NSAttributedString(string: "aren't actually \"shadowless\"", attributes: attributes)
        
        return VStack(spacing: 50) {
            Text("Conclusion")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundColor(.purple)
            
            Text("Now, you should understand that shadowless \(arentShadowless). It only **diminishes** the original shadow and make it **less noticeable**.")
                .lineSpacing(12)
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
            
            Text("And this is the principle of the light in the operating room.")
                .lineSpacing(12)
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
            
            Divider()
            
            Text("Hope you enjoy this little experiment and you can go to the playground to try different configurations.")
                .lineSpacing(12)
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
            
            Button(action: {
                step += 1
            }, label: {
                Text("Go to Playground")
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.purple, lineWidth: 2)
                    )
            })
        }
        .padding(20)
        .presentationDetents([.fraction(0.35)])
    }
    
    func makePlaygroundView() -> some View {
        return VStack(spacing: 30) {
            Text("Playground")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundColor(.purple)
            
            Text("Try different configurations to observe how the shadows are diminished.")
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
            
            Divider()
            
            Group {
                VStack(alignment: .leading) {
                    Text("Ground material")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                    setGroundMaterialMin()
                }
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Cylinder material")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                    setCylinderMaterialMin()
                }
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Light switches")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                    makeLightSwitchPanel()
                }
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Luminosity slider")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                    makeLuminositySlider()
                }
                
            }
            
            Divider()
            
            Button(action: {
                reset()
                arModel.reset()
            }, label: {
                Text("Back to the start")
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.purple, lineWidth: 2)
                    )
            })
        }
        .padding(20)
        .presentationDetents([.fraction(0.35)])
    }
}

extension ContentView {
    func setGroundMaterial() -> some View {
        VStack {
            HStack {
                Button(action: {
                    self.arModel.groundImage = "road_gray"
                    currGround = 1
                }, label: {
                    Image("road_gray")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: 120)
                        .cornerRadius(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(currGround == 1 ? Color.purple : Color.clear, lineWidth: 6)
                        )
                })
            }
            
            HStack {
                Button(action: {
                    self.arModel.groundImage = "road_athletics"
                    currGround = 2
                }, label: {
                    Image("road_athletics").resizable().aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(currGround == 2 ? Color.purple : Color.clear, lineWidth: 6)
                        )
                })
                
                Button(action: {
                    self.arModel.groundImage = "road_green"
                    currGround = 3
                }, label: {
                    Image("road_green").resizable().aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(currGround == 3 ? Color.purple : Color.clear, lineWidth: 6)
                        )
                })
            }
        }
    }
    
    func setGroundMaterialMin() -> some View {
        HStack {
            Button(action: {
                self.arModel.groundImage = "road_gray"
                currGround = 1
            }, label: {
                Image("road_gray").resizable().aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(currGround == 1 ? Color.purple : Color.clear, lineWidth: 6)
                    )
            })
            
            Button(action: {
                self.arModel.groundImage = "road_athletics"
                currGround = 2
            }, label: {
                Image("road_athletics").resizable().aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(currGround == 2 ? Color.purple : Color.clear, lineWidth: 6)
                    )
            })
            
            Button(action: {
                self.arModel.groundImage = "road_green"
                currGround = 3
            }, label: {
                Image("road_green").resizable().aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(currGround == 3 ? Color.purple : Color.clear, lineWidth: 6)
                    )
            })
        }
    }
    
    func setCylinderMaterial() -> some View {
        Grid {
            GridRow {
                Button(action: {
                    currCylinder = 1
                    self.arModel.cylinderImage = "cy_black_grid"
                }, label: {
                    Image("cy_black_grid").resizable().aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(currCylinder == 1 ? Color.purple : Color.clear, lineWidth: 6)
                        )
                })
                
                Button(action: {
                    currCylinder = 2
                    self.arModel.cylinderImage = "cy_black"
                }, label: {
                    Image("cy_black").resizable().aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(currCylinder == 2 ? Color.purple : Color.clear, lineWidth: 6)
                        )
                })
            }
            
            GridRow {
                Button(action: {
                    currCylinder = 3
                    self.arModel.cylinderImage = "cy_golden_flower"
                }, label: {
                    Image("cy_golden_flower").resizable().aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(currCylinder == 3 ? Color.purple : Color.clear, lineWidth: 6)
                        )
                })
                
                Button(action: {
                    currCylinder = 4
                    self.arModel.cylinderImage = "cy_metal_pattern"
                }, label: {
                    Image("cy_metal_pattern").resizable().aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(currCylinder == 4 ? Color.purple : Color.clear, lineWidth: 6)
                        )
                })
            }
        }
    }
    
    func setCylinderMaterialMin() -> some View {
        HStack {
            Button(action: {
                currCylinder = 1
                self.arModel.cylinderImage = "cy_black_grid"
            }, label: {
                Image("cy_black_grid").resizable().aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(currCylinder == 1 ? Color.purple : Color.clear, lineWidth: 6)
                    )
            })
            
            Button(action: {
                currCylinder = 2
                self.arModel.cylinderImage = "cy_black"
            }, label: {
                Image("cy_black").resizable().aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(currCylinder == 2 ? Color.purple : Color.clear, lineWidth: 6)
                    )
            })
            
            Button(action: {
                currCylinder = 3
                self.arModel.cylinderImage = "cy_golden_flower"
            }, label: {
                Image("cy_golden_flower").resizable().aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(currCylinder == 3 ? Color.purple : Color.clear, lineWidth: 6)
                    )
            })
            
            Button(action: {
                currCylinder = 4
                self.arModel.cylinderImage = "cy_metal_pattern"
            }, label: {
                Image("cy_metal_pattern").resizable().aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(currCylinder == 4 ? Color.purple : Color.clear, lineWidth: 6)
                    )
            })
        }
    }
    
    
    func makeLightSwitchPanel() -> some View {
        Grid(horizontalSpacing: 20, verticalSpacing: 20) {
            ForEach(0..<self.arModel.numberOfLights / 2, id: \.self) { i in
                GridRow {
                    makeLightSwitcher(no: i * 2)
                    makeLightSwitcher(no: i * 2 + 1)
                }
            }
        }
    }
    
    func makeLuminositySlider() -> some View {
        VStack {
            Slider(value: $arModel.luminosity, in: 50...1200, step: 1)
                .tint(.purple)
            HStack {
                Image(systemName: "dial.low")
                Spacer()
                Spacer()
                Image(systemName: "dial.medium")
                Spacer()
                Image(systemName: "dial.high")
            }
            .foregroundColor(.purple)
            .font(.body)
        }
    }
    
    func reset() {
        step = 1
        showingCredits = true
        currGround = 1
        currCylinder = 3
    }
}

extension ContentView {
    func playAudio() {
        guard let url = Bundle.main.url(forResource: "switch", withExtension: "wav") else {
            print("Error: Audio file not found")
            return
        }
        print("Playing")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func makeLightSwitcher(no: Int) -> some View {
        Toggle(isOn: $arModel.spotlightsMeta[no].isOn) {
            HStack {
                if arModel.spotlightsMeta[no].isOn {
                    Image(systemName: "lightbulb.fill")
                }
                else {
                    Image(systemName: "lightbulb")
                }
                
                Text("\(no + 1)")
            }
            .font(.system(size: 20, weight: .regular, design: .rounded))
            .foregroundColor(.primary)
        }
        .onChange(of: arModel.spotlightsMeta[no].isOn) { _ in
            print("Toggle switcher")
            playAudio()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
