//: Playground - noun: a place where people can play

import UIKit
import XCTest


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
        
        if run.totalFailureCount == 0 {
            print("✅ Congratulation !! 🌟")
        } else {
            print("❌ Try again...")
        }
    }
}


//: ## Tests

class ExampleTests : XCTestCase {
    
    // Language -> Language simbol
    typealias LanguageToSimbol = [String: String]
    
    let dictionary: LanguageToSimbol = [
        "Java"      : "コーヒー",
        "Swift"     : "ツバメ",
        "C++"       : "++",
        "C"         : "C",
        "OCaml"     : "ラクダ",
        ]
    
    func test_mapValue() {
        
        let result: LanguageToSimbol = dictionary.mapValue{ $0 + "!" }
        XCTAssertEqual(result["Java"],  "コーヒー!")
        XCTAssertEqual(result["Swift"], "ツバメ!")
        XCTAssertEqual(result["C++"],   "++!")
        XCTAssertEqual(result["C"],     "C!")
        XCTAssertEqual(result["OCaml"], "ラクダ!")
    }
    
    func test_filterByKey() {
        
        let result: LanguageToSimbol = dictionary.filterByKey{ $0.hasPrefix("C") }
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result["C++"], "++")
        XCTAssertEqual(result["C"],   "C")
    }
    
    func test_reduceValue() {
        let result: Int = dictionary.reduceValue(0){ return $0 + $1.characters.count }
        XCTAssertEqual(result, 13)
    }
}


extension Dictionary {
    //  宮坂の亀さんコード
    //    func mapValue(arr:(String) -> String) -> [String:String] {
    //        var result1 :[String:String] = [:]
    //        for x in self {
    //            result1["\(x.key)"] = arr(x.value as! String)
    //        }
    //        return result1
    //    }
    //
    //    func filterByKey(arr:(String) -> Bool) -> [String:String] {
    //        var result1 :[String:String] = [:]
    //        print(self)
    //        for x in self {
    //            if arr(x.key as! String) == true {
    //                result1["\(x.key)"] = x.value as? String
    //            }
    //        }
    //        return result1
    //    }
    //
    //    func reduceValue(_ val: Int,arr:(Int,String) -> Int) -> Int {
    //        var result1 = val
    //        for x in self {
    //            print(result1)
    //            result1 =  arr(result1,x.value as! String)
    //        }
    //        return result1
    //    }
    // 宮坂の亀さんコード終了
    
    // 細沼さんの瞬足コード(conglaturation)
    //        func mapValue(transform: (Value) -> Value) -> Dictionary<Key, Value> {
    //                    var result: [Key: Value] = [:]
    //                    for (key, value) in self {
    //                            result[key] = transform(value)
    //                        }
    //                    return result
    //                }
    //
    //            func filterByKey(isInclude: (Key) -> Bool) -> Dictionary<Key, Value> {
    //                    var result: [Key: Value] = [:]
    //                    for (key, value) in self where isInclude(key) {
    //                            result[key] = value
    //                        }
    //                    return result
    //                }
    //
    //            func reduceValue<R>(_ initial: R, reduce: (R, Value) -> R) -> R {
    //                    var result: R = initial
    //                    for (_, value) in self {
    //                            result = reduce(result, value)
    //                       }
    //                    return result
    //                }
    //  細沼さんの瞬足コード終わり
    
    
    // 宮坂のドーピングコード
    func mapValue(transform:(Value) -> Value) -> [Key:Value] {
        var result1 :[Key:Value] = [:]
        for (key , value) in self {
            result1[key] = transform(value)
        }
        return result1
    }
    
    func filterByKey(isInclude:(Key) -> Bool) -> [Key:Value] {
        var result1 :[Key:Value] = [:]
        for (key, value) in self where isInclude(key){
            result1[key] = value
        }
        return result1
    }
    
    func reduceValue<R>(_ val: R,transform:(R,Value) -> R) -> R {
        var result1 = val
        for (_,value) in self {
            result1 =  transform(result1,value)
        }
        return result1
    }
    
    // 宮坂のドーピングコードおわり
}


//: ## Test execute


TestRunner().run(ExampleTests.self)
