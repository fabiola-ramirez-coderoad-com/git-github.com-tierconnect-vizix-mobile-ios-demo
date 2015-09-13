//
//  TagFinderViewController.swift
//  TagFinderSwift
//
//  Created by Fabiola Ramirez on 9/10/15.
//  Copyright (c) 2015 Fabiola Ramirez. All rights reserved.
//

import UIKit

class TagFinderViewController: UIViewController,TSLInventoryCommandTransponderReceivedDelegate, TSLSelectReaderProtocol {
    
    
   
    var accessoryList: NSArray = NSArray()
    var commander:TSLAsciiCommander?
    var inventoryResponder:TSLInventoryCommand?
    var currentAccessory:EAAccessory?
    var transpondersSeen:Int = 0
    var partialResultMessage:String = ""
    // ...
    var tags:NSMutableArray = NSMutableArray()
    var epcTag:String = ""
    
    
    @IBOutlet weak var findTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var selectReaderButton: UIButton!
    @IBOutlet weak var sliderView: UISlider!
    
    
    @IBOutlet weak var oneView: UIView!
    @IBOutlet weak var twoView: UIView!
    @IBOutlet weak var threeView: UIView!
    @IBOutlet weak var fourView: UIView!
    @IBOutlet weak var fiveView: UIView!
    @IBOutlet weak var sixView: UIView!
    @IBOutlet weak var sevenView: UIView!
    @IBOutlet weak var eightView: UIView!
    @IBOutlet weak var nineView: UIView!
    @IBOutlet weak var tenView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        commander = TSLAsciiCommander()
        var loggerResponder:TSLLoggerResponder = TSLLoggerResponder()
        commander?.addResponder(loggerResponder)
        commander?.addSynchronousResponder();
        
        inventoryResponder = TSLInventoryCommand()
        inventoryResponder?.transponderReceivedDelegate = self
        inventoryResponder?.captureNonLibraryResponses = true
        commander?.addResponder(inventoryResponder)
        transpondersSeen = 0
        partialResultMessage = ""
        
        
        
        epcTag = self.findTextField.text
        println(" value of TextField \(epcTag)")
        
        self.viewCustomeDefault()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        commander?.halt()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
       
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "commanderChangedState",
            name: TSLCommanderStateChangedNotification,
            object: commander)
        
        accessoryList = EAAccessoryManager.sharedAccessoryManager().connectedAccessories
        
        
    }
    
    
    override func viewWillDisappear (animated : Bool){
        super.viewWillDisappear(animated);
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
    
    
    @IBAction func goReaders(sender: UIButton) {
        
        var viewController:TSLSelectReaderViewController?
        viewController = self.storyboard?.instantiateViewControllerWithIdentifier("tSLSelectReaderViewController") as? TSLSelectReaderViewController
        viewController?.delegate = self
        var navigationController :UINavigationController = UINavigationController(rootViewController: viewController!)
        
        self.presentViewController(navigationController, animated: true, completion: nil)
        
        
    }
  
    
    func didSelectReaderForRow (row : NSInteger){
        
        println("si llega desde la otera vita")
        
        self.dismissViewControllerAnimated(true) { () -> Void in
            self.commander?.disconnect()
            
            if(self.accessoryList.count > 0){
                self.currentAccessory = self.accessoryList.objectAtIndex(row) as? EAAccessory
                self.commander?.connect(self.currentAccessory)
                
            }
            
            
            
            self.initAndShowConnectedReader()
        }
        
    }
    
    
    func initAndShowConnectedReader (){
        
       println("initAndShowConnectedReader")
        println(">>1")
        if(commander?.isConnected == true){
            println(">>2")
            println("is connected")
            
            self.selectReaderButton.setTitle(currentAccessory?.serialNumber, forState: UIControlState.Normal)
            var resetCommand : TSLFactoryDefaultsCommand?
            resetCommand = TSLFactoryDefaultsCommand.synchronousCommand()
            
            self.commander?.executeCommand(resetCommand)
            
            println(">>3")
            if(resetCommand?.isSuccessful == true){
            println(">>4")
                
                println("Reader reset to Factory Defaults\n")
            }else {
                println("!!! Unable to reset reader to Factory Defaults !!!\n")
            }
            var versionCommand : TSLVersionInformationCommand?
            versionCommand = TSLVersionInformationCommand.synchronousCommand()
            self.commander?.executeCommand(versionCommand)
            var batteryCommand : TSLBatteryStatusCommand?
            batteryCommand = TSLBatteryStatusCommand.synchronousCommand()
            self.commander?.executeCommand(batteryCommand)
            
            println("mostrando datos actuales del Reader")
            println(" Manufacturer: \(versionCommand!.manufacturer)")
            println(" Serial Number: \(versionCommand!.serialNumber)")
            println(" ASCII Protocl: \(versionCommand!.asciiProtocol)")
            var stringBattery: String = String(format: "%d", batteryCommand!.batteryLevel)
            println(" Battery Level: \(stringBattery)")
            
            
            
        } else {
            
            println("no connected")
            
            self.selectReaderButton.setTitle("Select Reader", forState: UIControlState.Normal)
            
        }
    }
    
    
    
    func transponderReceived(epc: String!, crc: NSNumber!, pc: NSNumber!, rssi: NSNumber!, fastId: NSData!, moreAvailable: Bool) {
        
        println("transponderReceived")
        println("epc :\(epc), crc: \(crc), pc: \(pc), rssi: \(rssi) , fastId: \(fastId)")
    
        self.addTagWithEPC(epc , crc: 0, pc: 0, rssi: rssi, fastId: NSData())
        
        /*
        partialResultMessage = partialResultMessage.stringByAppendingFormat("%-28s %4d\n", epc.utf8 , rssi.integerValue)
        
        println("tag number: \(epc.utf8)")
        println("rssi number is: \(rssi.integerValue)")
        
        if (fastId != 0 ) {
        partialResultMessage = partialResultMessage.stringByAppendingFormat("%-6@  %@\n","TID:", TSLBinaryEncoding.toBase16String(fastId))
        }
        
        transpondersSeen++
        
        if(!moreAvailable){
        
        partialResultMessage = partialResultMessage.stringByAppendingFormat("\nTransponders seen: %4d\n\n", transpondersSeen)
        transpondersSeen = 0
        }
        
        if(transpondersSeen < 3 || transpondersSeen % 10 == 0 ){
        
        //falta la liena de abajo
        // [self performSelectorOnMainThread: @selector(updateResults:) withObject:_partialResultMessage waitUntilDone:NO];
            
        partialResultMessage = ""
        }
       */
        
    }
    
    func updateResults ( message : NSString ){
        println("updateResults")
        println(">> \(message)")
    }
    
 
    func commanderChangedState (){
        println("commanderChangedState")
        println(">>1")
        if(commander?.isConnected == false) {
        println(">>2")
            self.selectReaderButton.setTitle("Select Reader", forState: UIControlState.Normal)
        }
        else{
            println(">>3")

            //falta
            self.setReaderOutputPower()
        }
    }
    
    
    func setReaderOutputPower (){
        println("setReaderOutputPower")
        println(">>1")
        if(commander?.isConnected == true){
            println(">>2")
            //falta
            var value : Int32 = Int32(self.outputPowerFromSliderValue(self.sliderView.value))
            var command : TSLInventoryCommand?
            command = TSLInventoryCommand.synchronousCommand()
            command?.takeNoAction = TSL_TriState_YES
            command?.outputPower = value
            commander?.executeCommand(command)
            
        }else{
            println(">>3")
        }
    }
    
    
    func outputPowerFromSliderValue(value : Float) -> Int {
        
        let minPower = TSLInventoryCommand.minimumOutputPower()
        let maxPower = TSLInventoryCommand.maximumOutputPower()
        let range = maxPower - minPower
        

        var variable : Float = Float(value) * Float(range) + Float(minPower) + 0.5
        return Int(variable)
    }
    
    
    func addTagWithEPC(epc : NSString, crc : NSNumber, pc : NSNumber, rssi : NSNumber, fastId : NSData){
        
        if( epcTag == epc  ){
            let newTag:Tag = Tag()
            newTag.epc = epc as String
            newTag.rssi = rssi
            println("the star number is:\(newTag.epc)")
            var value:Int = Int(newTag.rssi)
            println("the negative number is:\(value)")
            let minRSSI: Float = -70
            let maxRSSI: Float = -35
            let maximum : Float = 100
            var range : Float = ((Float(value) - minRSSI) / (maxRSSI -  minRSSI) * maximum)
            var rangeInt: Int = Int(range)
            println(rangeInt)
            var rssiString:String = "";
            rssiString = String(format: "%i%@",rangeInt,"%")
            self.resultLabel.text = rssiString
            self.viewCustome(rangeInt)
        } else{
            println("don't come in range")
        }
        
    }
    
    
    @IBAction func scan(sender: UIButton) {
        
        if(commander?.isConnected == true){
            var invCommand: TSLInventoryCommand = TSLInventoryCommand()
            invCommand.includeTransponderRSSI = TSL_TriState_YES
            var value : Int = Int(self.outputPowerFromSliderValue(self.sliderView.value))
            invCommand.outputPower = Int32(value)
    
            commander?.executeCommand(invCommand)
            println(">>7")
        }else{
            println(">>8")
        }
        
        
    }
    
    func holamundo(){
        println("hola mundo")
    }
    
    
    func viewCustomeDefault(){
    
    self.oneView.layer.cornerRadius = 9
    self.oneView.alpha = 0.1
    self.twoView.layer.cornerRadius = 9
    self.twoView.alpha = 0.1
    self.threeView.layer.cornerRadius = 9
    self.threeView.alpha = 0.1
    self.fourView.layer.cornerRadius = 9
    self.fourView.alpha = 0.1
    self.fiveView.layer.cornerRadius = 9
    self.fiveView.alpha = 0.1
    self.sixView.layer.cornerRadius = 9
    self.sixView.alpha = 0.1
    self.sevenView.layer.cornerRadius = 9
    self.sevenView.alpha = 0.1
    self.eightView.layer.cornerRadius = 9
    self.eightView.alpha = 0.1
    self.nineView.layer.cornerRadius = 9
    self.nineView.alpha = 0.1
    self.tenView.layer.cornerRadius = 9
    self.tenView.alpha = 0.1
    
    }
    
    func animationAppear (view : UIView)
    {
    
       UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
         view.alpha = 1;
       }) { (Bool) -> Void in
        }
    }

    
    func animationDisappear(view : UIView){
     
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            view.alpha = 0.1;
            }) { (Bool) -> Void in
        }
    }
    
    func viewCustome(value : Int){
        
        if( value >= 0 && value <= 20){
            
            self.animationAppear(self.oneView)
            self.animationAppear(self.twoView)
            self.animationDisappear(self.threeView)
            self.animationDisappear(self.fourView)
            self.animationDisappear(self.fiveView)
            self.animationDisappear(self.sixView)
            self.animationDisappear(self.sevenView)
            self.animationDisappear(self.eightView)
            self.animationDisappear(self.nineView)
            self.animationDisappear(self.tenView)
            
        } else if(value >= 21 && value <= 40){
            self.animationAppear(self.oneView)
            self.animationAppear(self.twoView)
            self.animationAppear(self.threeView)
            self.animationAppear(self.fourView)
            self.animationDisappear(self.fiveView)
            self.animationDisappear(self.sixView)
            self.animationDisappear(self.sevenView)
            self.animationDisappear(self.eightView)
            self.animationDisappear(self.nineView)
            self.animationDisappear(self.tenView)
        }else if(value >= 41 && value <= 60){
            self.animationAppear(self.oneView)
            self.animationAppear(self.twoView)
            self.animationAppear(self.threeView)
            self.animationAppear(self.fourView)
            self.animationAppear(self.fiveView)
            self.animationAppear(self.sixView)
            self.animationDisappear(self.sevenView)
            self.animationDisappear(self.eightView)
            self.animationDisappear(self.nineView)
            self.animationDisappear(self.tenView)
        }else if(value >= 61 && value <= 80){
            self.animationAppear(self.oneView)
            self.animationAppear(self.twoView)
            self.animationAppear(self.threeView)
            self.animationAppear(self.fourView)
            self.animationAppear(self.fiveView)
            self.animationAppear(self.sixView)
            self.animationAppear(self.sevenView)
            self.animationAppear(self.eightView)
            self.animationDisappear(self.nineView)
            self.animationDisappear(self.tenView)
        } else if(value >= 81 && value <= 94){
            self.animationAppear(self.oneView)
            self.animationAppear(self.twoView)
            self.animationAppear(self.threeView)
            self.animationAppear(self.fourView)
            self.animationAppear(self.fiveView)
            self.animationAppear(self.sixView)
            self.animationAppear(self.sevenView)
            self.animationAppear(self.eightView)
            self.animationAppear(self.nineView)
            self.animationDisappear(self.tenView)
        } else if(value >= 95 && value <= 100){
            self.animationAppear(self.oneView)
            self.animationAppear(self.twoView)
            self.animationAppear(self.threeView)
            self.animationAppear(self.fourView)
            self.animationAppear(self.fiveView)
            self.animationAppear(self.sixView)
            self.animationAppear(self.sevenView)
            self.animationAppear(self.eightView)
            self.animationAppear(self.nineView)
            self.animationAppear(self.tenView)
        }
        
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
