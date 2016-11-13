import Foundation
import XCTest


//:# 宿題
//
// 1. 配列を反転させる関数（`reversed`の自作版。以後`my_reversed`と表記）に対する、QuickCheck用のテストコードを1つ書きなさい。❌
// 2. `my_reversed`の定義をArrayのextensionとして作成し、中身は`return Array(self.dropFirst())`とし、QuickCheckのテストがパスしないことを確認しなさい。❌
// 3. `my_reversed`の中身を`return self.reversed()`とし、QuickCheckのテストがパスすることを確認しなさい。✅
// 4. `my_reversed`の中身を自作し、QuickCheckのテストがパスすることを確認しなさい。✅
// 5. QuickCheckのテストを1つ以上追加し、いずれのテストも成功することを確認しなさい。✅
// 6. QuickCheckのテストがパスするにも関わらず、正しく反転しない実装を書きなさい。✅
// 7. XCTestによるテストを作成し、6.で書いた実装がパスしないことをテストしてください。❌
// 8. 可能であればリファクタリングし、コードを読みやすくした上で、ここまでのすべてのテストがパスする実装を書きなさい。✅
//
// ✅・・・コンパイルが成功し、テストもパスする状態
// ❌・・・コンパイルエラー、あるいはテストが失敗状態
//


//:# Product code

extension Array {
    func my_reversed() -> [Element] {
        guard let (head, tail) = headTail() else { return [] }
        var reversed = tail.my_reversed()
        reversed.append(head)
        return reversed
    }
    
    private func headTail() -> (Element, [Element])? {
        guard let head = self.first else { return nil }
        let tail = Array(self.dropFirst())
        return (head, tail)
    }
}


//:# Test code - QuickCheck

check(message: "配列を反転して反転すると、元の配列と一致すること") { (xs: [Int]) in
    xs == xs.my_reversed().my_reversed()
}

check(message: "配列を反転して得られた先頭要素は、元の配列の末尾の要素と一致すること") { (xs: [Int]) in
    guard !xs.isEmpty else { return true } // 空の場合は検証しない
    return xs.my_reversed().first! == xs.last!
}

check(message: "配列を反転して得られた結果の要素数は、元の配列の要素数と一致すること") { (xs: [Int]) in
    xs.count == xs.my_reversed().count
}


//:# Test code - XCTest

class ArrayTests : XCTestCase {
    
    func test_my_reversed() {
        let xs: [Int] = [1, 2, 3, 4, 5]
        XCTAssertEqual(xs.my_reversed(), [5, 4, 3, 2, 1])
    }
}


//: ## Test execute

TestRunner().run(ArrayTests.self)
