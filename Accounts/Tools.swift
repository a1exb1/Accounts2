//
//  Tools.swift
//  LessonManager_Dec_14
//
//  Created by Alex Bechmann on 25/12/2014.
//  Copyright (c) 2014 Alex Bechmann. All rights reserved.
//

import UIKit

class DateRange {
    let startDate:NSDate
    let endDate:NSDate
    var calendar = NSCalendar.currentCalendar()
    
    var minutes: Int {
        return calendar.components(.CalendarUnitMinute,
            fromDate: startDate, toDate: endDate, options: nil).minute
    }
    var hours: Int {
        return calendar.components(.CalendarUnitHour,
            fromDate: startDate, toDate: endDate, options: nil).hour
    }
    var days: Int {
        return calendar.components(.CalendarUnitDay,
            fromDate: startDate, toDate: endDate, options: nil).day
    }
    var months: Int {
        return calendar.components(.CalendarUnitMonth,
            fromDate: startDate, toDate: endDate, options: nil).month
    }
    init(startDate:NSDate, endDate:NSDate) {
        self.startDate = startDate
        self.endDate = endDate
    }
}

func -(lhs:NSDate, rhs:NSDate) -> DateRange {
    return DateRange(startDate: rhs, endDate: lhs)
}

enum DateComparison{
    case Earlier
    case Same
    case Later
}

enum LMDateFormat: String{
    case Date = "dd/MM/yyyy"
    case DateTime = "dd/MM/yyyy HH:mm"
    case DateTimeWithSeconds = "dd/MM/yyyy HH:mm:ss"
    case ISO8601 = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
}

extension UIColor
{
    
    convenience init(hexColorCode: String)
    {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if hexColorCode.hasPrefix("#")
        {
            let index   = advance(hexColorCode.startIndex, 1)
            let hex     = hexColorCode.substringFromIndex(index)
            let scanner = NSScanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            
            if scanner.scanHexLongLong(&hexValue)
            {
                if countElements(hex) == 6
                {
                    red   = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)  / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF) / 255.0
                }
                else if countElements(hex) == 8
                {
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                }
                else
                {
                    print("invalid hex code string, length should be 7 or 9")
                }
            }
            else
            {
                println("scan hex error")
            }
        }
        else
        {
            print("invalid hex code string, missing '#' as prefix")
        }
        
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
}

class Tools: NSObject {
   
    class func AddLoaderToView(view:UIView){
        var actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
        actInd.center = view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        actInd.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(actInd)
        actInd.addCenterYConstraint(toView: view)
        actInd.addCenterXConstraint(toView: view)
        actInd.startAnimating()
    }
    
    class func HideLoaderFromView(view:UIView){
        for v in view.subviews{
            if v is UIActivityIndicatorView{
                v.stopAnimating()
            }
        }
    }
    
    class func DateFromString(dateString:String) -> NSDate{
        var s = dateString.stringByReplacingOccurrencesOfString("\\", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil) as String?
        //s = dateString.stringByReplacingOccurrencesOfString("T", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        return dateFormatter.dateFromString(s!)!
    }
    
    class func DateFromString(dateString:String, format:String) -> NSDate{
        var s = dateString.stringByReplacingOccurrencesOfString("\\", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil) as String
        //s = dateString.stringByReplacingOccurrencesOfString("T", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.dateFromString(s)!
    }
    
    class func DateFromISO8601String(dateString:String) -> NSDate{
        var s = dateString.stringByReplacingOccurrencesOfString("\\", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil) as String
        //s = dateString.stringByReplacingOccurrencesOfString("T", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = LMDateFormat.ISO8601.rawValue
        
        var d:NSDate = dateFormatter.dateFromString(s)!
        return d.dateByAddingTimeInterval(NSTimeInterval(-secondsFromGMT()))!
    }
    
//    class func StringISO8601FromDate(var date:NSDate) -> String{
//        //var d = date.dateByAddingTimeInterval(NSTimeInterval(-secondsFromGMT()))!
//        return NSDate.ISOStringFromDate(date)
//    }
    
    class func StringFromDate(date:NSDate, format:String?) -> String{
        var f = format != nil ? format : "dd/MM/yyyy HH:mm:ss"
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = f
        return dateFormatter.stringFromDate(date)
    }
    
    class func StringFromDateWithFormat(date:NSDate, format:String) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(date)
    }
    
    class func DateFromJSONTimestamp(timestampString:String) -> NSDate{
        var s = timestampString.stringByReplacingOccurrencesOfString("/Date(", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil) as String
        s = s.stringByReplacingOccurrencesOfString("/", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var int:Double = (s as NSString).doubleValue
        return NSDate(timeIntervalSince1970: int)
    }
    
    class func imageWithColor(color:UIColor, size:CGSize) -> UIImage
    {
        UIGraphicsBeginImageContext(size)
        var rPath:UIBezierPath = UIBezierPath(rect:CGRectMake(0.0, 0.0, size.width, size.height))
        color.setFill()
        rPath.fill()
        var image:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    
    class func CloneView(view:UIView) -> UIView{
        var v:UIView = UIView(frame: view.frame)
        v.autoresizingMask = view.autoresizingMask;
        
        for v1 in view.subviews {
            var v2:UIView = UIView(frame: v1.frame);
            v2.autoresizingMask = v1.autoresizingMask;
            v.addSubview(v2)
        }
        
        return v
    }
    
    class func AddBorderToView(view:UIView, color:UIColor, width:CGFloat){
        view.layer.borderColor = color.CGColor
        view.layer.borderWidth = width
    }
    
    class func AddRightBorderToView(view:UIView, color:UIColor, width:CGFloat){
        var border = CALayer()
        border.borderColor = color.CGColor
        border.frame = CGRect(x: view.bounds.width - width, y: 0, width:  width, height: view.bounds.size.height + 800)
        
        border.borderWidth = width
        view.layer.addSublayer(border)
        view.layer.masksToBounds = true
    }
    
    class func AddTopBorderToView(view:UIView, color:UIColor, height:CGFloat){
        var border = CALayer()
        border.borderColor = color.CGColor
        border.frame = CGRect(x: 0, y: 0, width:  view.bounds.size.width, height: height)
        
        border.borderWidth = height
        view.layer.addSublayer(border)
        view.layer.masksToBounds = true
    }
    
    class func MinWidthForStaticSideBar() -> CGFloat{
        return 700
    }
    
    class func SideBarWidth() -> CGFloat{
        return 220
    }
    
    class func CompareDates(date1:NSDate, date2:NSDate) -> DateComparison{
        if (date1.compare(date2) == NSComparisonResult.OrderedDescending) {
        return DateComparison.Earlier
        }
        else if (date1.compare(date2) == NSComparisonResult.OrderedAscending) {
        return DateComparison.Later
        }
        else {
        return DateComparison.Same
        }
    }
    
    class func applyPlainShadow(view: UIView) {
        var layer = view.layer
        
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 10)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 5
    }
    
    class func applyCurvedShadow(view: UIView) {
        let size = view.bounds.size
        let width = size.width
        let height = size.height
        let depth = CGFloat(11.0)
        let lessDepth = 0.8 * depth
        let curvyness = CGFloat(5)
        let radius = CGFloat(1)
        
        var path = UIBezierPath()
        
        // top left
        path.moveToPoint(CGPoint(x: radius, y: height))
        
        // top right
        path.addLineToPoint(CGPoint(x: width - 2*radius, y: height))
        
        // bottom right + a little extra
        path.addLineToPoint(CGPoint(x: width - 2*radius, y: height + depth))
        
        // path to bottom left via curve
        path.addCurveToPoint(CGPoint(x: radius, y: height + depth),
            controlPoint1: CGPoint(x: width - curvyness, y: height + lessDepth - curvyness),
            controlPoint2: CGPoint(x: curvyness, y: height + lessDepth - curvyness))
        
        var layer = view.layer
        layer.shadowPath = path.CGPath
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = radius
        layer.shadowOffset = CGSize(width: 0, height: -3)
    }
    
    class func applyHoverShadow(view: UIView) {
        let size = view.bounds.size
        let width = size.width
        let height = size.height
        
        var ovalRect = CGRect(x: 5, y: height + 5, width: width - 10, height: 15)
        var path = UIBezierPath(roundedRect: ovalRect, cornerRadius: 10)
        
        var layer = view.layer
        layer.shadowPath = path.CGPath
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    class func AddShadowToView(view:UIView){
        var shadowLayer:CALayer = CALayer()
        shadowLayer.shadowOffset = CGSizeMake(0, 3)
        shadowLayer.shadowRadius = 8.0
        shadowLayer.shadowOpacity = 0.8
        shadowLayer.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.6).CGColor;
        shadowLayer.shadowPath = UIBezierPath(rect:view.bounds).CGPath;
        shadowLayer.frame = view.layer.bounds;
        //Add the shadow layer to the existing view layer.
        view.layer.insertSublayer(shadowLayer, atIndex: 0)
    }
    
    class func GetValueFromPlist(plist:String, value:String) -> String?{
        let dict = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource(plist, ofType: "plist")!)
        return dict?.objectForKey(value)? as String?
    }
    
    class func SetValueInPlist(plist:String, key:String, value:String) -> Bool{
        var rc = false
        
        var path = NSBundle.mainBundle().pathForResource(plist, ofType: "plist")
        if var dict = NSMutableDictionary(contentsOfFile: path!) {
            dict.setValue(value, forKey: key)
            dict.writeToFile(path!, atomically: false)
        }
        return rc
    }
    
    class func HasValue(obj:AnyObject?) -> Bool{
        var rc = false
        if obj != nil{
            rc = true
            if obj is String{
                if (obj is String){
                    if (obj as String) == ""{
                        rc = false;
                    }
                }
            }
        }
        return rc
    }
    
    class func GetFirstDateOfMonthFromDate(date:NSDate) -> NSDate{
        var gregorian:NSCalendar = NSCalendar(identifier: NSGregorianCalendar)!
        
        var comp = gregorian.components(.YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit, fromDate: date)
        comp.day = 1
        return gregorian.dateFromComponents(comp)!
    }
    
    class func BegginingOfDay(date:NSDate) -> NSDate{
        var gregorian:NSCalendar = NSCalendar(identifier: NSGregorianCalendar)!
    
        var comp = gregorian.components(.YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit, fromDate: date)
    
        return gregorian.dateFromComponents(comp)!
    }
    
    class func defaultCalender() -> NSCalendar{
        return NSCalendar(calendarIdentifier: "gregorian")!
    }

    class func TextFieldViewForEditingMode(bounds: CGRect) -> TextFieldViewWithTextField{
        var editView:UIView = UIView()
        editView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width - 155, height: bounds.height))
        var textField = UITextField(frame: CGRect(x: editView.bounds.origin.x, y: editView.frame.origin.y, width: editView.bounds.width - 20, height: editView.bounds.height))
        textField.textAlignment = NSTextAlignment.Right
        editView.addSubview(textField)
        var rc = TextFieldViewWithTextField()
        rc.view = editView
        rc.textField = textField
        return rc
    }
    
    class func ShowAlertControllerOK(message:String, completionHandler:(response: Int) -> ()){
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            // ...
            completionHandler(response: 1)
        }
        alertController.addAction(OKAction)
        
        Tools.TopMostController().presentViewController(alertController, animated: true){}
    }
    
    class func ShowAlertController(message:String, completionHandler:(response: Int) -> ()){
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            completionHandler(response: 0)
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            // ...
            //completionHandler(response: 1)
        }
        //alertController.addAction(OKAction)
        
        let destroyAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
            completionHandler(response: 1)
        }
        alertController.addAction(destroyAction)
        
        Tools.TopMostController().presentViewController(alertController, animated: true){}
    }
    
    class func ShowAlertControllerWithButtonTitle(confirmBtnTitle:String, confirmBtnStyle:UIAlertActionStyle, message:String, completionHandler:(response: Int) -> ()){
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            completionHandler(response: 0)
        }
        alertController.addAction(cancelAction)
        
        let destroyAction = UIAlertAction(title: confirmBtnTitle, style: confirmBtnStyle) { (action) in
            completionHandler(response: 1)
        }
        alertController.addAction(destroyAction)
        
        Tools.TopMostController().presentViewController(alertController, animated: true){}
    }
    
    class func TopMostController() -> UIViewController
    {
        var topController = UIApplication.sharedApplication().keyWindow!.rootViewController;
        while ((topController!.presentedViewController) != nil) {
            topController = topController!.presentedViewController;
        }
        return topController!
    }
    
    class func secondsFromGMT() -> Int { return NSTimeZone.localTimeZone().secondsFromGMT }
    
    class func Device() -> UIUserInterfaceIdiom{
        return UIDevice.currentDevice().userInterfaceIdiom
    }
    
    class func GetValueFromPlistDocuments(plist:String, key:String) -> String?{
        // getting path to GameData.plist
        var rc = ""
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as String
        let path = documentsDirectory.stringByAppendingPathComponent("\(plist).plist")
        let fileManager = NSFileManager.defaultManager()
        //check if file exists
        if(!fileManager.fileExistsAtPath(path)) {
            // If it doesn't, copy it from the default file in the Bundle
            if let bundlePath = NSBundle.mainBundle().pathForResource(plist, ofType: "plist") {
                let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
                //println("Bundle GameData.plist file is --> \(resultDictionary?.description)")
                fileManager.copyItemAtPath(bundlePath, toPath: path, error: nil)
                //println("copy")
            } else {
                //println("GameData.plist not found. Please, make sure it is part of the bundle.")
            }
        } else {
            //println("GameData.plist already exits at path.")
            // use this to delete file from documents directory
            //fileManager.removeItemAtPath(path, error: nil)
        }
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        //println("Loaded GameData.plist file is --> \(resultDictionary?.description)")
        var myDict = NSDictionary(contentsOfFile: path)
        if let dict = myDict {
            //loading values
            rc = dict.objectForKey(key) as String!
            //...
        } else {
            //println("WARNING: Couldn't create dictionary from GameData.plist! Default values will be used!")
        }
        return rc
    }
    
    class func SetValueInPlistDocuments(plist:String, key:String, value:String){
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as NSString
        let path = documentsDirectory.stringByAppendingPathComponent("\(plist).plist")
        var dict: NSMutableDictionary = [key: value]
        //saving values
        dict.setObject(value, forKey: key)
        //...
        //writing to GameData.plist
        dict.writeToFile(path, atomically: false)
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        //println("Saved GameData.plist file is --> \(resultDictionary?.description)")
    }

}

class TextFieldViewWithTextField{
    var view:UIView = UIView()
    var textField:UITextField = UITextField()
}

extension UIColor{
    class func randomColor() -> UIColor{
        var randomRed:CGFloat = CGFloat(drand48())
        var randomGreen:CGFloat = CGFloat(drand48())
        var randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }
}

extension String{
    mutating func replace(string:String, withString:String) -> String {
        self = self.stringByReplacingOccurrencesOfString(string, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
        return self
    }
}



