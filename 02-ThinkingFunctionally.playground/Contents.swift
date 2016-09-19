//: # Prelude

import Foundation
import XCTest

//: # Thinking Functionally
//: ## Example: Battleship

typealias Distance = Double

struct Position {
    var x: Double
    var y: Double
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
    func minus(_ p: Position) -> Position {
        return Position(x: x - p.x, y: y - p.y)
    }
    var length: Double {
        return sqrt(x * x + y * y)
    }
}


func - (lhs: Position, rhs: Position) -> Position {
    return lhs.minus(rhs)
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


extension Ship {
    func canSafelyEngageShip3(target: Ship, friendly: Ship) -> Bool {
        let targetDistance = (target.position - position).length
        let friendlyDistance = (friendly.position - target.position).length
        return targetDistance <= firingRange
            && targetDistance > unsafeRange
            && (friendlyDistance > unsafeRange)
    }
}


//: ## First-Class Functions

typealias Region = (Position) -> Bool


func circle(_ radius: Distance) -> Region {
    return { point in point.length <= radius }
}


func circle2(radius: Distance, center: Position) -> Region {
    return { point in point.minus(center).length <= radius }
}


func shifted(_ region: @escaping Region, to: Position) -> Region {
    return { point in region(point.minus(to)) }
}


func inverted(_ region: @escaping Region) -> Region {
    return { point in !region(point) }
}


func intersection(_ region1: @escaping Region, _ region2: @escaping Region) -> Region {
    return { point in region1(point) && region2(point) }
}

func union(region1: @escaping Region, _ region2: @escaping Region) -> Region {
    return { point in region1(point) || region2(point) }
}


func difference(from region: @escaping Region, minus: @escaping Region) -> Region {
    return intersection(region, inverted(minus))
}


extension Ship {
    func canSafelyEngage(target: Ship, friendly: Ship) -> Bool {
        let rangeRegion    = difference(from: circle(firingRange), minus: circle(unsafeRange))
        let firingRegion   = shifted(rangeRegion, to: position)
        let friendlyRegion = shifted(circle(unsafeRange), to: friendly.position)
        let resultRegion   = difference(from: firingRegion, minus: friendlyRegion)
        return resultRegion(target.position)
    }
}


//: ## My extension

struct Regions {
    static func rectangle(width: Distance, height: Distance) -> Region {
        return { point in
            let left:   Distance =  (width / 2.0) * (-1.0)
            let right:  Distance =  (width / 2.0) * (+1.0)
            let top:    Distance = (height / 2.0) * (+1.0)
            let bottom: Distance = (height / 2.0) * (-1.0)
            return left   <= point.x && point.x <= right
                && bottom <= point.y && point.y <= top
        }
    }
}


//: ## Type-Driven Development
//: ## Notes

//: ## Test Foundation

class PlaygroundTestObserver : NSObject, XCTestObservation {
    @objc func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {
        print("Test failed on line \(lineNumber): \(testCase.name), \(description)")
    }
}

let observer = PlaygroundTestObserver()
let center = XCTestObservationCenter.shared()
center.addTestObserver(observer)

struct TestRunner {
    
    func run(_ testClass: AnyClass) {
        print("Running test suite \(testClass)")
        
        let tests = testClass as! XCTestCase.Type
        let testSuite = tests.defaultTestSuite()
        testSuite.run()
        let run = testSuite.testRun as! XCTestSuiteRun
        
        print("Ran \(run.executionCount) tests in \(run.testDuration)s with \(run.totalFailureCount) failures")
    }
}

//: ## Tests
class RectangleTests : XCTestCase {

    let rectangle = Regions.rectangle(width: 10, height: 6)

    // Assert: normal-case
    func test_rectangle() {

        // in-range
        XCTAssertTrue(rectangle(Position(x:  0, y:  0))) // origin
        XCTAssertTrue(rectangle(Position(x: -5, y:  3))) // top left
        XCTAssertTrue(rectangle(Position(x: +5, y:  3))) // top right
        XCTAssertTrue(rectangle(Position(x: -5, y: -3))) // bottom left
        XCTAssertTrue(rectangle(Position(x: +5, y: -3))) // bottom right
        
        // out-range
        XCTAssertFalse(rectangle(Position(x: -6, y:  4))) // top left
        XCTAssertFalse(rectangle(Position(x: +6, y:  4))) // top right
        XCTAssertFalse(rectangle(Position(x: -6, y: -4))) // bottom left
        XCTAssertFalse(rectangle(Position(x: +6, y: -4))) // bottom right
    }
    
    // Assert: invert region
    func test_rectangle_invert() {
        let iRect = inverted(rectangle)
        
        // out-range
        XCTAssertFalse(iRect(Position(x:  0, y:  0))) // origin
        XCTAssertFalse(iRect(Position(x: -5, y:  3))) // top left
        XCTAssertFalse(iRect(Position(x: +5, y:  3))) // top right
        XCTAssertFalse(iRect(Position(x: -5, y: -3))) // bottom left
        XCTAssertFalse(iRect(Position(x: +5, y: -3))) // bottom right
        
        // in-range
        XCTAssertTrue(iRect(Position(x: -6, y:  4))) // top left
        XCTAssertTrue(iRect(Position(x: +6, y:  4))) // top right
        XCTAssertTrue(iRect(Position(x: -6, y: -4))) // bottom left
        XCTAssertTrue(iRect(Position(x: +6, y: -4))) // bottom right
    }
}

TestRunner().run(RectangleTests.self)
