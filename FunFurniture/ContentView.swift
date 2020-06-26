//
//  ContentView.swift

//
//  Created by Chislaine Cruz on 6/26/20.
//  Copyright © 2020 Chislaine Cruz. All rights reserved.
//  FunFurniture

import SwiftUI
import RealityKit

struct ContentView : View {
    @State private var isPlacementEnabled = false
    @State private var selectedModel : String?
    @State private var modelConfirmedForPlacement : String?
    // dynamically get file names
    private var models: [String] = {
        let fileManager = FileManager.default
        guard let path = Bundle.main.resourcePath, let files = try? fileManager.contentsOfDirectory(atPath: path) else {
            return []
        }
        var availModels: [String] = []
        for fileName in files where fileName.hasSuffix("usdz"){
            let modelName = fileName.replacingOccurrences(of: ".usdz", with: "")
            availModels.append(modelName)
        }
        return availModels
    }()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
            
            if self.isPlacementEnabled {
                //get models on the screen
                PlacementButtonsView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
            } else {
                // pick models
                ModelPickerView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, models: self.models)
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmedForPlacement : String?
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        //make sure this is properly tested before production
        if let modelName = self.modelConfirmedForPlacement{
            print("debug: Adding model to scene - \(modelName)")
            DispatchQueue.main.async {
                self.modelConfirmedForPlacement = nil
            }
        }
    }
    
}

struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: String?
    var models: [String]
    
    var body: some View {
            //scrollview showing each image
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 30){
                    ForEach(0 ..< self.models.count){
                        //on tap
                        index in
                        Button(action: {
                            print("DEBUG: Selected model with name: \(self.models[index])")
                            //if the user taps on thumbnail, the model is set
                            self.selectedModel = self.models[index]
                            self.isPlacementEnabled = true
                        }) {
                            //image settings
                            Image(uiImage: UIImage(named: self.models[index])!)
                            .resizable()
                                .frame(height: 80)
                                .aspectRatio(1/1, contentMode: .fit)
                                .background(Color.white)
                            .cornerRadius(12)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
            } //styling the scroll bar
        .padding(20)
            .background(Color.black.opacity(0.4))
    }
}

struct PlacementButtonsView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: String?
    @Binding var modelConfirmedForPlacement: String?
    var body: some View {
        HStack {
            //Cancel Button
            Button(action: {
                print("Debug: Model placement cancel")
                self.resetPlacementParameters()
            }) {
                Image(systemName: "xmark")
                    .frame(width:60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                .cornerRadius(30)
                .padding(20)
                    
            }
            //Confirm button
            Button(action: {
                print("Debug: Model placement confirm")
                self.modelConfirmedForPlacement = self.selectedModel
                self.resetPlacementParameters()
            }) {
                Image(systemName: "checkmark")
                    .frame(width:60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                .cornerRadius(30)
                .padding(20)
                    
            }
        }
    }
    func resetPlacementParameters(){
        self.isPlacementEnabled = false
        self.selectedModel = nil
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
