//: # Prelude

import UIKit
import Foundation
////: # Case Study: Wrapping Core Image {#wrapping-core-image}
////: ## The Filter Type
//
//typealias Filter = CIImage -> CIImage
//
////: ## Building Filters
////: ### Blur
//
//func blur(radius: Double) -> Filter {
//    return { image in
//        let parameters = [
//            kCIInputRadiusKey: radius,
//            kCIInputImageKey: image
//        ]
//        guard let filter = CIFilter(name: "CIGaussianBlur",
//            withInputParameters: parameters) else { fatalError() }
//        guard let outputImage = filter.outputImage else { fatalError() }
//        return outputImage
//    }
//}
//
////: ### Color Overlay
//
//func colorGenerator(color: UIColor?) -> Filter {
//    return { _ in
//       guard let color = color else { fatalError() }
//        let c = CIColor(color: color)
//        let parameters = [kCIInputColorKey: c]
//        guard let filter = CIFilter(name: "CIConstantColorGenerator",
//            withInputParameters: parameters) else { fatalError() }
//        guard let outputImage = filter.outputImage else { fatalError() }
//        return outputImage
//    }
//}
//
//
//func compositeSourceOver(overlay: CIImage) -> Filter {
//    return { image in
//        let parameters = [
//            kCIInputBackgroundImageKey: image,
//            kCIInputImageKey: overlay
//        ]
//        guard let filter = CIFilter(name: "CISourceOverCompositing",
//            withInputParameters: parameters) else { fatalError() }
//        guard let outputImage = filter.outputImage else { fatalError() }
//        let cropRect = image.extent
//        return outputImage.imageByCroppingToRect(cropRect)
//    }
//}
//
//
//func colorOverlay(color: UIColor) -> Filter {
//    return { image in
//        let overlay = colorGenerator(color)(image)
//        return compositeSourceOver(overlay)(image)
//    }
//}
//
////: ## Composing Filters
//
//let image = CIImage(image:UIImage(named: "IMG_0739.jpg")!)
//
//
//let blurRadius = 5.0
//let overlayColor = UIColor.redColor().colorWithAlphaComponent(0.2)
//let blurredImage = blur(blurRadius)(image!)
////let overlaidImage = colorOverlay(overlayColor)(blurredImage)
//
////: ### Function Composition
//
////let result = colorOverlay(overlayColor)(blur(blurRadius)(image!))
//
//
//func composeFilters(filter1: Filter, _ filter2: Filter) -> Filter {
//    return { image in filter2(filter1(image)) }
//}
//
//
//let myFilter1 = composeFilters(blur(blurRadius), colorOverlay(overlayColor))
////let result1 = myFilter1(image!)
//
//
//infix operator >>> { associativity left }
//
//func >>> (filter1: Filter, filter2: Filter) -> Filter {
//    return { image in filter2(filter1(image)) }
//}
//
//
//let myFilter2 = blur(blurRadius) >>> colorOverlay(overlayColor)
////let result2 = myFilter2(image!)
//
////: ## Theoretical Background: Currying
//
//func add1(x: Int, _ y: Int) -> Int {
//    return x + y
//}
//
//
//func add2(x: Int) -> (Int -> Int) {
//    return { y in return x + y }
//}
//
//
//add1(1, 2)
//add2(1)(2)
//
//
//func add3(x: Int)(_ y: Int) -> Int {
//    return x + y
//}
//add3(1)(2)
//
//private func attribute1() -> NSMutableAttributedString? {
//
//    let font = UIFont(name: "HiraKakuProN-W3", size: 10) ?? UIFont.systemFontOfSize(10)
//
//    let style = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
//    style.alignment = NSTextAlignment.Center
//
//    let attr = [
//        NSForegroundColorAttributeName: UIColor.redColor(),
//        NSFontAttributeName: font,
//        NSParagraphStyleAttributeName: style,
//        ]
//
//    return NSMutableAttributedString(string: "てすと", attributes: attr)
//}
typealias Attribute = NSMutableAttributedString -> NSMutableAttributedString



func str(firstString:String) -> NSMutableAttributedString {
    return NSMutableAttributedString(string: firstString)
    
}
func color(color:UIColor) -> Attribute{
    return{aStr in
        let attr = [
            NSForegroundColorAttributeName:color
        ]
        aStr.addAttributes(attr, range:NSRange(location: 0 ,length: aStr.length) )
        return aStr
    }
    
}
func font(name: String,size: CGFloat) -> Attribute{
    return{aStr in
        let font = UIFont(name: name, size: size) ?? UIFont.systemFontOfSize(size)
        let attr = [
            NSFontAttributeName: font,
            ]
        aStr.addAttributes(attr, range:NSRange(location: 0 ,length: aStr.length) )
        return aStr
    }
}


infix operator >>> {associativity left}
infix operator > {associativity left}

func >>> (attribute1: Attribute ,attribute2: Attribute ) -> Attribute{
    return {attribute3 in attribute1(attribute2(attribute3))}
}
func / (attribute1: Attribute ,string: String ) -> NSMutableAttributedString{
    return attribute1(str(string))
}




//演算子の力
let red15 = font("HiraKakuProN-W3",size: 15)>>>color(UIColor.redColor())
let magenta23 = font("HiraKakuProN-W6",size:23)>>>color(UIColor.magentaColor())

red15 / "jiji"
magenta23 / "bobochi"


//: ## Discussion
/*
 
 フォントの設定について
 アトリビュートストリングではサイズと名前が同時に定義されているのでコンポーネントには分解できないですかね。
 
let font = UIFont(name: "HiraKakuProN-W3", size: 10) ?? UIFont.systemFontOfSize(10)
 */
