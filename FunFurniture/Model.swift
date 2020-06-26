//
//  Model.swift
//  FunFurniture
//
//  Created by Chislaine Cruz on 6/26/20.
//  Copyright © 2020 Chislaine Cruz. All rights reserved.
//

import UIKit
import RealityKit
import Combine

class Model {
    var modelName: String
    var image: UIImage
    var modelEntity: ModelEntity?
    
    private var cancellable: AnyCancellable? = nil
    
    init(modelName: String) {
        self.modelName = modelName
        self.image = UIImage(named: modelName)!
        let filename = modelName + ".usdz"
        self.cancellable = ModelEntity.loadModelAsync(named: filename).sink(receiveCompletion: {loadCompletion in
            //Handle error
            print("Debug: Unable to load modelEntity for modelName: \(self.modelName) ")
        }, receiveValue: {modelEntity in
            //Get model entity
            self.modelEntity = modelEntity
            print("Debug: Successfully loaded modelEntity for modelName: \(self.modelName)")
        })
    }
}
