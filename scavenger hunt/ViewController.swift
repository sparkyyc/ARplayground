//
//  ViewController.swift
//  scavenger hunt
//
//  Created by Christa Sparks on 12/13/18.
//  Copyright © 2018 Christa Sparks. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
//    var savedMaps: [NSDictionary] = []
    
    var currentHunt = "First Hunt"
    
//    var worldMapURL: URL = {
//        do {
//            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//                .appendingPathComponent("worldMapURL")
//        } catch {
//            fatalError("Error getting world map URL from document directory.")
//        }
//    }()
    
    let defaults = UserDefaults.standard
    
    

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var huntField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        configureLighting()
        addTapGestureToSceneView()
    }
    
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didReceiveTapGesture(_:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func didReceiveTapGesture(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        guard let hitTestResult = sceneView.hitTest(location, types: [.featurePoint, .estimatedHorizontalPlane]).first
            else { return }
        let anchor = ARAnchor(transform: hitTestResult.worldTransform)
        sceneView.session.add(anchor: anchor)
    }
    
    func generateSphereNode() -> SCNNode {
        let sphere = SCNSphere(radius: 0.05)
        let sphereNode = SCNNode()
        sphereNode.position.y += Float(sphere.radius)
        sphereNode.geometry = sphere
        return sphereNode
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetTrackingConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    @IBAction func resetBarButtonItemDidTouch(_ sender: UIButton) {
        resetTrackingConfiguration()
    }
    
    @IBAction func saveBarButtonItemDidTouch(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Add New Name", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "\(self.currentHunt)"
        }
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            self.currentHunt = firstTextField.text!
            print(self.currentHunt)
            self.getTheCurrentWorldMap()
            
        })
        //            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
        //                (action : UIAlertAction!) -> Void in })
        //            alertController.addTextField { (textField : UITextField!) -> Void in
        //                textField.placeholder = "Enter First Name"
        //            }
        
        alertController.addAction(saveAction)
        //            alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    func getTheCurrentWorldMap() {
        
        sceneView.session.getCurrentWorldMap { (worldMap, error) in
            guard let worldMap = worldMap else {
                return self.setLabel(text: "Error getting current world map.")
            }
            
            
            do {
                try self.archive(worldMap: worldMap)
                DispatchQueue.main.async {
                    self.setLabel(text: "World map is saved.")
                }
            } catch {
                fatalError("Error saving world map: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func loadBarButtonItemDidTouch(_ sender: UIButton) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        print(defaults.array(forKey: "allHunts"))
        if let maps = defaults.array(forKey: "allHunts") {
            if maps.count > 0 {
                let saved1 = maps[0]
                alert.addAction(UIAlertAction(title: "\(saved1)", style: .default) { _ in
                    let dict = self.defaults.dictionary(forKey: "\(saved1)")
                    let worldMapData = dict?["data"]! as? Data
                    let worldMap = self.unarchive(worldMapData: worldMapData!)
                    self.resetTrackingConfiguration(with: worldMap)
                })
            }
            
            if maps.count > 1 {
                let saved2 = maps[1]
                alert.addAction(UIAlertAction(title: "\(saved2)", style: .default) { _ in
                    
                    let dict = self.defaults.dictionary(forKey: "\(saved2)")
                    let worldMapData = dict?["data"]! as? Data
                    let worldMap = self.unarchive(worldMapData: worldMapData!)
                    self.resetTrackingConfiguration(with: worldMap)
                })
            }
            
            if maps.count > 2 {
                let saved3 = maps[2]
                alert.addAction(UIAlertAction(title: "\(saved3)", style: .default) { _ in
                    
                    let dict = self.defaults.dictionary(forKey: "\(saved3)")
                    let worldMapData = dict?["data"]! as? Data
                    let worldMap = self.unarchive(worldMapData: worldMapData!)
                    self.resetTrackingConfiguration(with: worldMap)
                })
            }
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        })

        present(alert, animated: true)
        
    }
    
//    func getWorldMapData() {
//        guard let worldMapData = retrieveWorldMapData(from: worldMapURL),
//            let worldMap = unarchive(worldMapData: worldMapData) else { return }
//        resetTrackingConfiguration(with: worldMap)
//    }
    
    func resetTrackingConfiguration(with worldMap: ARWorldMap? = nil) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        if let worldMap = worldMap {
            configuration.initialWorldMap = worldMap
            setLabel(text: "Found saved world map.")
        } else {
            setLabel(text: "Move camera around to map your surrounding space.")
        }
        
        sceneView.debugOptions = [.showFeaturePoints]
        sceneView.session.run(configuration, options: options)
    }
    
    func setLabel(text: String) {
        label.text = text
    }
    
    func archive(worldMap: ARWorldMap) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
        let dictionary : NSDictionary = [
            "name": "\(self.currentHunt)",
            "data": data]
//        savedMaps.append(dictionary)
//        print(savedMaps)
//        try data.write(to: self.worldMapURL, options: [.atomic])
        
        if var allHunts = defaults.array(forKey: "allHunts") {
            print(allHunts)
            UserDefaults.standard.removeObject(forKey: "allHunts")
            allHunts.append(self.currentHunt)
            defaults.set(allHunts, forKey: "allHunts")
            print(defaults.array(forKey: "allHunts"))
        } else {
            defaults.set(["\(self.currentHunt)"], forKey: "allHunts")
        }
        
        defaults.set(dictionary, forKey: "\(self.currentHunt)")
        
    }
    
//    func retrieveWorldMapData(from url: URL) -> Data? {
//        do {
//            return try Data(contentsOf: self.worldMapURL)
//        } catch {
//            self.setLabel(text: "Error retrieving world map data.")
//            return nil
//        }
//    }
    
    
    func unarchive(worldMapData data: Data) -> ARWorldMap? {
        guard let unarchievedObject = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data),
            let worldMap = unarchievedObject else { return nil }
        return worldMap
    }

    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard !(anchor is ARPlaneAnchor) else { return }
        let sphereNode = generateSphereNode()
        DispatchQueue.main.async {
            node.addChildNode(sphereNode)
        }
    }
    
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension UIColor {
    open class var transparentWhite: UIColor {
        return UIColor.white.withAlphaComponent(0.70)
    }
}
