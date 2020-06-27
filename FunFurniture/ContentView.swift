//
//  ContentView.swift

//
//  Created by Chislaine Cruz on 6/26/20.
//  Copyright © 2020 Chislaine Cruz. All rights reserved.
//  FunFurniture

import SwiftUI
import RealityKit
import ARKit
import FocusEntity

struct ContentView : View {
    @State private var isPlacementEnabled = false
    @State private var selectedModel : Model?
    @State private var modelConfirmedForPlacement : Model?
    @State private var isRemoveEnabled = false
    @State private var modelConfirmedForRemoval: Model?
    // dynamically get file names
    private var models: [Model] = {
        let fileManager = FileManager.default
        guard let path = Bundle.main.resourcePath, let files = try? fileManager.contentsOfDirectory(atPath: path) else {
            return []
        }
        var availModels: [Model] = []
        for fileName in files where fileName.hasSuffix("usdz"){
            let modelName = fileName.replacingOccurrences(of: ".usdz", with: "")
            let model = Model(modelName: modelName)
            availModels.append(model)
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
                if self.isRemoveEnabled {
                    //remove button on screen
//                    RemoveButtonView()
                } else {
                // pick models
                ModelPickerView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, models: self.models)
 
                }
            }
        }
    }
    
  
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmedForPlacement : Model?
    
    func makeUIView(context: Context) -> ARView {
        //this is where we use our custom ARView defined below
        let arView = CustomARView(frame: .zero)
        
       
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        //make sure this is properly tested before production
        if let model = self.modelConfirmedForPlacement{
            //making sure the model exists in the entity
            if let modelEntity = model.modelEntity{
                print("DEBUG: Adding model to the scene - \(model.modelName)")
                
                let anchorEntity = AnchorEntity(plane: .any)
                let clonedEntity = modelEntity.clone(recursive: true)
                clonedEntity.setScale(SIMD3<Float>(0.01, 0.01, 0.01), relativeTo: anchorEntity)
                clonedEntity.generateCollisionShapes(recursive: true)
                uiView.installGestures([.rotation, .translation],for: clonedEntity)
               
                anchorEntity.addChild(clonedEntity) //clone creates a clone of the model. Better for memory and performance
                
                uiView.scene.addAnchor(anchorEntity)
                
            } else {
                print("DEBUG: Unable to load ModelEntity for \(model.modelName)")
            }
            
            DispatchQueue.main.async {
                self.modelConfirmedForPlacement = nil
            }
        }
        //tapping on a model on the screen should pop up an x button that once pressed, removes it from the screen
        //anchorEntity.removeChild(entity)
        
        
        
    }

    
    
}

class CustomARView: ARView {
    let focusSquare = FESquare()
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        
        focusSquare.viewDelegate = self
        focusSquare.delegate = self
        focusSquare.setAutoUpdate(to: true)
        
        self.setupARView()
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupARView(){
        let config = ARWorldTrackingConfiguration()
               config.planeDetection = [.horizontal, .vertical]
               config.environmentTexturing = .automatic
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGestureRecognizer)
               
               if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh){
                   config.sceneReconstruction = .mesh
               }
               self.session.run(config)
    }
    
    @objc
    func handleTap(sender: UIGestureRecognizer){
        let tappedView = sender.view as! ARView
        let touchedLocation = sender.location(in: tappedView)
        let hitTest = tappedView.hitTest(touchedLocation)
        if !hitTest.isEmpty {
            let result = hitTest.first!
            print("Tapped on \(result)")
        }
    }
}

extension CustomARView: FEDelegate {
    func toTrackingState(){
        print("Tracking")
    }
    func toInitializingState() {
        print("Initializing")
    }
}

struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    var models: [Model]
    
    var body: some View {
            //scrollview showing each image
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 30){
                    ForEach(0 ..< self.models.count){
                        //on tap
                        index in
                        Button(action: {
                            print("DEBUG: Selected model with name: \(self.models[index].modelName)")
                            //if the user taps on thumbnail, the model is set
                            self.selectedModel = self.models[index]
                            self.isPlacementEnabled = true
                        }) {
                            //image settings
                            Image(uiImage: self.models[index].image)
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

//MARK: testing this
//struct RemoveButtonView: View {
//    @Binding var isRemoveEnabled: Bool
//    @Binding var modelConfirmedForRemoval: Model?
//    //@Binding var selectedModel
//    var body: some View {
//        HStack {
//            //remove model button
//            Button(action: {
//                print("Debug: Removing model from screen")
//                //self.modelConfirmedForRemoval = self.
//                self.isRemoveEnabled = false
//
//            })
//        }
//    }
//}

struct PlacementButtonsView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    @Binding var modelConfirmedForPlacement: Model?
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
