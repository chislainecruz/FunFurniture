//
//  ContentView.swift

//
//  Created by Chislaine Cruz on 6/26/20.
//  Copyright © 2020 Chislaine Cruz. All rights reserved.
//  FunFurniture

import SwiftUI
import RealityKit

struct ContentView : View {
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
            ARViewContainer()
            //get models on the screen
            ModelPickerView(models: self.models)
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

struct ModelPickerView: View {
    var models: [String]
    
    var body: some View {
            //scrollview showing each image
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 30){
                    ForEach(0 ..< self.models.count){
                        //on click
                        index in
                        Button(action: {
                            print("DEBUG: Selected model with name: \(self.models[index])")
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

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
