//: # Prelude

import Foundation
import XCTest

//: # Thinking Functionally
//: ## Example: Battleship
//: # Prelude

typealias Distance = Double

struct Position {
    var x: Double
    var y: Double
}

func - (myP: Position ,otheP:Position) -> Position{
    return Position(x: myP.x - otheP.x ,y:myP.y - otheP.y)
}
func -= (myP: Int ,otheP:Int) -> Position{
    return Position(x: 5 , y: 5)
}
extension Position {
    func inRange(range: Distance) -> Bool {
        return sqrt(x * x + y * y) <= range
    }
}


struct Ship {
    var position: Position
    var firingRange: Distance
    var unsafeRange: Distance
}


extension Ship {
    func canEngageShip(target: Ship) -> Bool {
        let dx = target.position.x - position.x
        let dy = target.position.y - position.y
        let targetDistance = sqrt(dx * dx + dy * dy)
        return targetDistance <= firingRange
    }
}


extension Ship {
    func canSafelyEngageShip(target: Ship) -> Bool {
        let dx = target.position.x - position.x
        let dy = target.position.y - position.y
        let targetDistance = sqrt(dx * dx + dy * dy)
        return targetDistance <= firingRange && targetDistance > unsafeRange
    }
}


extension Ship {
    func canSafelyEngageShip1(target: Ship, friendly: Ship) -> Bool {
        let dx = target.position.x - position.x
        let dy = target.position.y - position.y
        let targetDistance = sqrt(dx * dx + dy * dy)
        let friendlyDx = friendly.position.x - target.position.x
        let friendlyDy = friendly.position.y - target.position.y
        let friendlyDistance = sqrt(friendlyDx * friendlyDx +
            friendlyDy * friendlyDy)
        return targetDistance <= firingRange
            && targetDistance > unsafeRange
            && (friendlyDistance > unsafeRange)
    }
}


extension Position {
    func minus(p: Position) -> Position {
        return Position(x: x - p.x, y: y - p.y)
    }
    var length: Double {
        return sqrt(x * x + y * y)
    }
}



extension Ship {
    func canSafelyEngageShip2(target: Ship, friendly: Ship) -> Bool {
        let targetDistance = target.position.minus(position).length
        let friendlyDistance = friendly.position.minus(target.position).length
        return targetDistance <= firingRange
            && targetDistance > unsafeRange
            && (friendlyDistance > unsafeRange)
    }
}

//: ## First-Class Functions

typealias Region = Position -> Bool


func circle(radius: Distance) -> Region {
    return { point in point.length <= radius }
}


func circle2(radius: Distance, center: Position) -> Region {
    return { point in (point - center).length <= radius }
}


func shift(region: Region, offset: Position) -> Region {
    return { point in region(point.minus(offset)) }
}


func invert(region: Region) -> Region {
    return { point in !region(point) }
}


func intersection(region1: Region, _ region2: Region) -> Region {
    return { point in region1(point) && region2(point) }
}

func union(region1: Region, _ region2: Region) -> Region {
    return { point in region1(point) || region2(point) }
}


func difference(region: Region, minus: Region) -> Region {
    return intersection(region, invert(minus))
}


extension Ship {
    func canSafelyEngageShip(target: Ship, friendly: Ship) -> Bool {
        let rangeRegion = difference(circle(firingRange),
                                     minus: circle(unsafeRange))
        let firingRegion = shift(rangeRegion, offset: position)
        let friendlyRegion = shift(circle(unsafeRange),
                                   offset: friendly.position)
        let resultRegion = difference(firingRegion, minus: friendlyRegion)
        return resultRegion(target.position)
    }
}



// １次関数の傾きを返す。
extension Ship {
    func katamuki(dotOnLine1: Position,dotOnLine2: Position) -> Double {
        return (dotOnLine2.y - dotOnLine1.y)/(dotOnLine2.x - dotOnLine1.x)
    }
}
extension Ship {
    func isZeroY(dotOnLine1: Position,dotOnLine2: Position) -> Bool {
        return (dotOnLine2.y - dotOnLine1.y)  == 0
    }
    func isZeroX(dotOnLine1: Position,dotOnLine2: Position) -> Bool {
        return (dotOnLine2.x - dotOnLine1.x) == 0
    }
}
// トライアングルの頂点方向に戦艦の座標があるかいなかを返す領域

extension Ship {
    /*
     -parameter : dotOnline1  三角形の１辺を構成する任意の頂点Position①
     -parameter : dotOnline2  三角形の１辺を構成する任意の頂点のPosition②
     -parameter : dot 　　　　 上記辺上にない頂点のPosition
     
     任意のPositionの位置が上記の１辺を中心にしたときにdot側にあればtrue
     任意のPositionの位置が上記の１辺を中心にしたときにdotの反対側にある　-> false
     上記の辺を構成するはずの2点が同座標にある -> false (技がだせない)
     */
    func linear(dotOnLine1: Position,dotOnLine2: Position,dot: Position) -> Region {
           return { point in
            let isX = self.isZeroX(dotOnLine1, dotOnLine2: dotOnLine2)
            let isY = self.isZeroY(dotOnLine1, dotOnLine2: dotOnLine2)
            if isX == true && isY == true {
                print("技が出せない。")
                return false
            }else if isX == true {
                // 傾いてない。(x座標が常に同じ)
                return dotOnLine1.x < dot.x ?  dotOnLine1.x < point.x: point.x < dotOnLine1.x
            }else if isY == true {
                // 傾いてない。(y座標が常に同じ)
                return dotOnLine1.y < dot.y ?  dotOnLine1.y < point.y: point.y < dotOnLine1.y
            }else{
                // 傾いてる。y = ax + b の形)
                let katamuki1: Double = self.katamuki(dotOnLine1, dotOnLine2: dotOnLine2)
                let bbb =  dotOnLine1.y - katamuki1 * dotOnLine1.x
                let yAtDot = katamuki1 * dot.x + bbb
                let yAtPoint = katamuki1 * point.x + bbb
                return (yAtDot < dot.y ? point.y > yAtDot : point.y < yAtPoint)
            }
        }
    }
}
// バミューダトライアングルを返す。
extension Ship {
    func  bermudaTriangle(point1: Position,point2: Position,point3: Position) -> Region {
        let katamuki1 = linear(point1, dotOnLine2: point2, dot: point3)
        let katamuki2 = linear(point2, dotOnLine2: point3, dot: point1)
        let katamuki3 = linear(point3, dotOnLine2: point1, dot: point2)
        return {point in intersection(katamuki1, intersection(katamuki2,katamuki3))(point)}
    }
}

// トライアングルアタック フレンド2人と力を合わせて攻撃。
extension Ship {
    func triangleAttack(target: Ship, friendly1: Ship, friendly2: Ship) -> Bool {
        return  bermudaTriangle(position, point2: friendly1.position, point3:friendly2.position)(target.position)
    }
}
// 配置、攻撃する。。
var myShip: Ship =  Ship(position:Position(x:0,y:0),firingRange:20.0,unsafeRange:0.0)
var freShip1: Ship =  Ship(position:Position(x:0,y:30),firingRange:20.0,unsafeRange:0.0)
var freShip2: Ship =  Ship(position:Position(x:30,y:0),firingRange:20.0,unsafeRange:0.0)
var eneShip: Ship =  Ship(position:Position(x:14.9,y:15),firingRange:20.0,unsafeRange:0.0)

let isAttacked = myShip.triangleAttack(eneShip, friendly1:freShip1, friendly2:freShip2)
isAttacked == true ? print("攻撃完了") : print("ターゲットが領域外です。")

//: ## Type-Driven Development
//: ## Notes

//: ## Type-Driven Development
//: ## Notes

//: ## Test Foundation

class PlaygroundTestObserver : NSObject, XCTestObservation {
    @objc func testCase(testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {
        print("Test failed on line \(lineNumber): \(testCase.name), \(description)")
    }
}

let observer = PlaygroundTestObserver()
let center = XCTestObservationCenter.sharedTestObservationCenter()
center.addTestObserver(observer)

struct TestRunner {
    
    func runTests(testClass:AnyClass) {
        print("Running test suite \(testClass)")
        
        let tests = testClass as! XCTestCase.Type
        let testSuite = tests.defaultTestSuite()
        testSuite.runTest()
        let run = testSuite.testRun as! XCTestSuiteRun
        
        print("Ran \(run.executionCount) tests in \(run.testDuration)s with \(run.totalFailureCount) failures")
    }
}

//: ## Tests
class MyTests : XCTestCase {
    
    // TODO: Please write test case for rectangle() !!
    
    // failed sample
    func testShouldFail() {
        XCTFail("You must fail to succeed!")
    }
    
    func testShouldPass() {
        XCTAssertEqual(2 + 2, 4)
    }
}

TestRunner().runTests(MyTests)
