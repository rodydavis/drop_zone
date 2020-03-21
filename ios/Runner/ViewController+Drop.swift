//
//  ViewController+Drop.swift
//  Runner
//
//  Created by Rody Davis on 3/21/20.
//

import UIKit
import Foundation
import MobileCoreServices

extension FlutterViewController: UIDropInteractionDelegate {
    // MARK: - UIDropInteractionDelegate
    
    /**
         Ensure that the drop session contains a drag item with a data representation
         that the view can consume.
    */
    public func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        print("canHandle...")
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    // Update UI, as needed, when touch point of drag session enters view.
    public func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnter session: UIDropSession) {
        print("sessionDidEnter...")
        let dropLocation = session.location(in: view)
        updateLayers(forDropLocation: dropLocation)
    }
    
    /**
         Required delegate method: return a drop proposal, indicating how the
         view is to handle the dropped items.
    */
    public func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        print("sessionDidUpdate...")
        let dropLocation = session.location(in: view)
        updateLayers(forDropLocation: dropLocation)

        let operation: UIDropOperation
         let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.dropZoneFrame?.contains(dropLocation) ?? false {
            /*
                 If you add in-app drag-and-drop support for the .move operation,
                 you must write code to coordinate between the drag interaction
                 delegate and the drop interaction delegate.
            */
            operation = session.localDragSession == nil ? .copy : .move
        } else {
            // Do not allow dropping outside of the image view.
            operation = .cancel
        }

        return UIDropProposal(operation: operation)
    }
    
    /**
         This delegate method is the only opportunity for accessing and loading
         the data representations offered in the drag item.
    */
    public func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
         print("performDrop...")
        // Consume drag items (in this example, of type UIImage).
        session.loadObjects(ofClass: UIImage.self) { imageItems in
            let images = imageItems as! [UIImage]

            /*
                 If you do not employ the loadObjects(ofClass:completion:) convenience
                 method of the UIDropSession class, which automatically employs
                 the main thread, explicitly dispatch UI work to the main thread.
                 For example, you can use `DispatchQueue.main.async` method.
            */
            print("Dropping images...")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.receviedImage(image: images.first)
        }

        // Perform additional UI updates as needed.
        let dropLocation = session.location(in: view)
        updateLayers(forDropLocation: dropLocation)
    }
    
    // Update UI, as needed, when touch point of drag session leaves view.
    public func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession) {
        print("sessionDidExit...")
        let dropLocation = session.location(in: view)
        updateLayers(forDropLocation: dropLocation)
    }
    
    // Update UI and model, as needed, when drop session ends.
    public func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession) {
        print("sessionDidEnd...")
        let dropLocation = session.location(in: view)
        updateLayers(forDropLocation: dropLocation)
    }

    // MARK: - Helpers

    func updateLayers(forDropLocation dropLocation: CGPoint) {
        if view.frame.contains(dropLocation) {
            view.layer.borderWidth = 5.0
        } else {
            view.layer.borderWidth = 0.0
        }
    }
}
