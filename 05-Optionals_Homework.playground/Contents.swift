//: # Optionals

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

/*:
 # 5章の宿題

 以下の性質を持つ自前のオプショナル型`Option`を自作し、テストをすべてパスさせるんだ！！
 繰り返す、これは命令だ！
 
 1. Option は (some | none) の enum で表現するものとする。
 1. Option は Equatable を実装し、等値比較を可能とする。（これはXCTAssertでの成否をチェックするためのものである）
 1. Swift標準のOptionalが持つ以下のメソッドが定義されている。
    - map()
    - flatMap()
    - ??
 1. Swift言語でシンタックスシュガーとして実現されている以下機能に似た関数を持つ。
    - `ifLet2<A, B, R: Equatable>(_ a: Option<A>, _ b: Option<B>, _ match: @escaping (A, B) -> (R)) -> Option<R>`
 引数`a`と`b`が共に値（.some）であった場合にクロージャ`match`を実行し、その値を`.some`に包んで返す。そうでなければ`.none`を返す。
 */

enum Option<T: Equatable>: Equatable {
    case some(T)
    case none
}

func == <T: Equatable>(lhs: Option<T>, rhs: Option<T>) -> Bool {
    switch (lhs, rhs) {
    case (.some(let x), .some(let y)):
        return x == y
    case (.none, .none):
        return true
    case (.some(_), .none):
        return false
    case (.none, .some(_)):
        return false
    }
}

func ?? <T>(x: Option<T>, defaultExpr: @autoclosure () -> T) -> T {
    switch x {
    case .some(let x): return x
    case .none:        return defaultExpr()
    }
}

extension Option {
    func map<R>(_ transform: (T) -> R) -> Option<R> {
        switch self {
        case .some(let x):
            return .some(transform(x))
        case .none:
            return .none
        }
    }
    
    func flatMap<R>(_ transform: (T) -> Option<R>) -> Option<R> {
        switch self {
        case .some(let x):
            return transform(x)
        case .none:
            return .none
        }
    }
}

func ifLet2<A, B, R: Equatable>(_ a: Option<A>, _ b: Option<B>, _ match: @escaping (A, B) -> (R)) -> Option<R> {
    return a.flatMap { a2 in
        return b.flatMap { b2 in
            return Option.some(match(a2, b2))
        }
    }
}

class ExampleTests : XCTestCase {
    
    func test_map() {
        let x = Option.some(2)
        let r = x.map { $0 * 2 }
        XCTAssertEqual(r, Option.some(4))
    }
    
    func test_flatMap() {
        
        // use map()
        do {
            let x = Option.some("2")
            let r: Option<Option<Int>> = x.map {
                guard let n = Int($0) else { return .none }
                return .some(n)
            }
            XCTAssertEqual(r, Option.some(Option.some(2)))
        }
        
        // use flatMap()
        do {
            let x = Option.some("2")
            let r: Option<Int> = x.flatMap {
                guard let n = Int($0) else { return .none }
                return .some(n)
            }
            XCTAssertEqual(r, Option.some(2))
        }
    }
    
    func test_nilCoalescingOperator() {
        
        // some
        let someX: Option<Int> = .some(1)
        XCTAssertEqual(someX ?? 42, 1)

        // none
        let noneX: Option<Int> = .none
        XCTAssertEqual(noneX ?? 42, 42)
    }
    
    func test_ifLet() {
        
        let x = Option.some(1)
        let y = Option.some(2)
        let r: Option<Int> = ifLet2(x, y, { $0 + $1 })
        XCTAssertEqual(r, Option.some(3))
    }
}


//: ## Test execute

TestRunner().run(ExampleTests.self)
