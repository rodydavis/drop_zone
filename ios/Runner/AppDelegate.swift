import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler, UIDropInteractionDelegate {
  var dropZoneEvents: FlutterEventChannel?
  var dropZoneChannel: FlutterMethodChannel?
  var dropZoneFrame: CGRect?
  private var events: FlutterEventSink?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
        if (self.dropZoneFrame == nil) {
            self.dropZoneFrame = self.window.frame
        }
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      dropZoneEvents = FlutterEventChannel(name: "drop_zone_stream", binaryMessenger: controller.binaryMessenger)
        dropZoneChannel = FlutterMethodChannel(name: "drop_zone", binaryMessenger: controller.binaryMessenger)
    dropZoneChannel?.setMethodCallHandler({
        [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
        guard call.method == "setDropZone" else {
          result(FlutterMethodNotImplemented)
          return
        }
        self?.updateFrame(result: result, args: call.arguments)
      })
     dropZoneEvents?.setStreamHandler(self)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func updateFrame(result: FlutterResult, args: Any?) {
        if let myArgs = args as? [String: Any],
        let top = myArgs["top"] as? Double,
        let left = myArgs["left"] as? Double,
         let width = myArgs["width"] as? Double,
         let height = myArgs["height"] as? Double {
            self.dropZoneFrame = CGRect(x: left, y: top, width: width, height: height)
         } else {
            self.dropZoneFrame = self.window.frame
         }
       result(true)
     }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.events = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
          NotificationCenter.default.removeObserver(self)
          events = nil
          return nil
    }
    func receviedFile(file: String) {
        events!(file)
    }
    
    func receviedImage(image: UIImage?) {
        if (image == nil) {return}
        let fileURL = AppDelegate.fileUrlPath("dropped_image.png")
        let path = fileURL.absoluteString
        receviedFile(file: path)
    }
    
    
    public static var folderUrl: URL {
        return FileManager.default.urls(for:.cachesDirectory, in: .userDomainMask)[0]
    }
    
    public static func fileUrlPath(_ fileName: String) -> URL {
        return self.folderUrl.appendingPathComponent(fileName)
    }
    
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
       let view = self.window.rootViewController!.view
       let dropLocation = session.location(in: view!)
       updateLayers(forDropLocation: dropLocation)
   }
   
   /**
        Required delegate method: return a drop proposal, indicating how the
        view is to handle the dropped items.
   */
   public func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
       print("sessionDidUpdate...")
        let view = self.window.rootViewController!.view
       let dropLocation = session.location(in: view!)
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
    let view = self.window.rootViewController!.view
       let dropLocation = session.location(in: view!)
       updateLayers(forDropLocation: dropLocation)
   }
   
   // Update UI, as needed, when touch point of drag session leaves view.
   public func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession) {
       print("sessionDidExit...")
    let view = self.window.rootViewController!.view
       let dropLocation = session.location(in: view!)
       updateLayers(forDropLocation: dropLocation)
   }
   
   // Update UI and model, as needed, when drop session ends.
   public func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession) {
       print("sessionDidEnd...")
    let view = self.window.rootViewController!.view
    let dropLocation = session.location(in: view!)
       updateLayers(forDropLocation: dropLocation)
   }

   // MARK: - Helpers

   func updateLayers(forDropLocation dropLocation: CGPoint) {
        let view = self.window.rootViewController!.view!
       if view.frame.contains(dropLocation) {
           view.layer.borderWidth = 5.0
       } else {
           view.layer.borderWidth = 0.0
       }
   }
}

