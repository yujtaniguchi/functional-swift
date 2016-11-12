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
    
    // TODO: Please implement `my_reversed` function.
}


//:# Test code - QuickCheck

// TODO: Please implement some QuickCheck's tests.

// example: 
//check(message: "配列の要素数は何回取得しても同じ値を返すこと（参照透過性）") { (xs: [Int]) in xs.count == xs.count }


//:# Test code - XCTest

class ArrayTests : XCTestCase {
    
    // example:
    //func test_foo() {
    //}
}


//: ## Test execute

TestRunner().run(ArrayTests.self)
