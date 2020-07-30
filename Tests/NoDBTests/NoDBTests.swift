import XCTest
@testable import NoDB

final class NoDBTests: XCTestCase {
    
    var date = Date()
    
    func getRandomElements() -> [TestNoDBModel] {
        var objs: [TestNoDBModel] = []
        for i in 0..<2000 {
            let _id = "TestNoDB\(Int.random(in: 0..<20))"
            let randomInt = Int.random(in: 20...500)
            let time = Double(10 * i)
            let text = "Hi \(randomInt)"
            let objDate = date.addingTimeInterval(time)
            objs.append(TestNoDBModel(noDBIndex: nil, _id: _id, dateValue: objDate, intValue: randomInt, text: text))
        }
        return objs
    }
    
    func getOrderedElements() -> [TestNoDBModel] {
        var objs: [TestNoDBModel] = []
        for i in 0..<50 {
            let _id = "TestNoDB\(i)"
            let randomInt = i
            let time = Double(10 * i)
            let text = "Hi \(randomInt)"
            let boolValue = i < 25 ? true : false
            let objDate = date.addingTimeInterval(time)
            objs.append(TestNoDBModel(noDBIndex: nil, _id: _id, dateValue: objDate, intValue: randomInt, boolValue: boolValue, text: text))
        }
        return objs
    }
    
    func getElementsWithValuesDuplicated() -> [TestNoDBModel] {
        var objs: [TestNoDBModel] = []
        for i in 0..<3000 {
            let id = "TestNoDB\(i)"
            let intValue = i % 5
            let dateValue = date.addingTimeInterval(Double(i))
            let text = i > 1499 ? "First half" : "Last half"
            objs.append(TestNoDBModel(_id: id, dateValue: dateValue, intValue: intValue, text: text))
        }
        return objs
    }
    
    func testAddObjects(){
        let testNoDB = NoDB<TestNoDBModel>(name: "Test", idKey: "_id")
       
        var objsSaved: [TestNoDBModel] = []
        let promises = [expectation(description: "Save completion invoked")]
        let objs = getRandomElements()
        testNoDB.save(obj: objs) { objs in
            defer{ promises[0].fulfill() }
            guard let objs = objs else {
                return
            }
            objsSaved = objs
        }
        wait(for: promises, timeout: 10)
        XCTAssertTrue(objsSaved.count == 20)
    }
    
    func testAddOneAndDeleteObject(){
        let testNoDB = NoDB<TestNoDBModel>(name: "Test", idKey: "_id")
        let promises = [expectation(description: "Save completion invoked"),
                        expectation(description: "Find completion invoked")]
        var deletedObj: TestNoDBModel?
        let newElement = TestNoDBModel(noDBIndex: nil, _id: "TestNoDB\(20)", dateValue: date.addingTimeInterval(Double(2000) * 0.95 * 10) , intValue: 50, text: "Hi 50")
        testNoDB.save(obj: newElement) { obj in
            promises[0].fulfill()
        }
        testNoDB.delete("_id" == "TestNoDB20") { objs in
            deletedObj = objs?.first
            promises[1].fulfill()
        }
        wait(for: promises, timeout: 10)
        XCTAssertNotNil(deletedObj)
        XCTAssertEqual(deletedObj?._id, "TestNoDB20")
    }

    func testCleanDB(){
        let testNoDB = NoDB<TestNoDBModel>(name: "TestPersistent", idKey: "_id")
        let promises = [expectation(description: "Add elements"),
                        expectation(description: "Delete db completion invoked"),
                        expectation(description: "Find all after deletion completion invoked")]
        var countObjsSaved: Int?
        var allObjsInDatabase: [TestNoDBModel]? = []
        testNoDB.save(obj: getOrderedElements()) { objs in
            countObjsSaved = objs?.count
            testNoDB.saveDB {
                promises[0].fulfill()
            }
        }
        testNoDB.deleteDB {
            promises[1].fulfill()
        }
        testNoDB.find(nil) { (results) in
            allObjsInDatabase = results
            promises[2].fulfill()
        }
        wait(for: promises, timeout: 10)
        XCTAssertEqual(countObjsSaved, 50)
        XCTAssertNil(allObjsInDatabase)
    }
    
    
    func testIntExclusiveQuery(){
        let testNoDB = NoDB<TestNoDBModel>(name: "Test", idKey: "_id")
        let promise = expectation(description: "Find completion invoked")
        testNoDB.save(obj: getOrderedElements())
        var conditionAcomplishedByResults = true
        var objectsFoundWithIntValueLessThan: [TestNoDBModel]?
        testNoDB.find("intValue" < 10) { objs in
            defer { promise.fulfill() }
            objectsFoundWithIntValueLessThan = objs
            for obj in objectsFoundWithIntValueLessThan ?? [] {
                guard let intValue = obj.intValue, intValue < 10 else {
                    conditionAcomplishedByResults = false
                    break
                }
            }
        }
        wait(for: [promise], timeout: 20)
        XCTAssertTrue(conditionAcomplishedByResults)
        XCTAssertEqual(objectsFoundWithIntValueLessThan?.count, 10)
    }
    
    func testIntInclusiveQuery(){
        let testNoDB = NoDB<TestNoDBModel>(name: "Test", idKey: "_id")
        testNoDB.save(obj: getOrderedElements())
        let promise = expectation(description: "Find completion invoked")
        var conditionAcomplishedByResults = true
        var objectsFoundWithIntValueGreaterOrEqual: [TestNoDBModel]?
        testNoDB.find("intValue" >= 10) { objs in
            objectsFoundWithIntValueGreaterOrEqual = objs
            defer { promise.fulfill() }
            for obj in objectsFoundWithIntValueGreaterOrEqual ?? [] {
                guard let intValue = obj.intValue, intValue >= 10 else {
                    conditionAcomplishedByResults = false
                    break
                }
            }
        }
        wait(for: [promise], timeout: 10)
        XCTAssertTrue(conditionAcomplishedByResults)
        XCTAssertEqual(objectsFoundWithIntValueGreaterOrEqual?.count, 40)
    }
    
    func testUpdateExistingObjects(){
        let testNoDB = NoDB<TestNoDBModel>(name: "Test", idKey: "_id")
        testNoDB.save(obj: getOrderedElements())
        let promises = [expectation(description: "Get elementes to change completion"),
                        expectation(description: "save objects with updated values completion")]
        var objects: [TestNoDBModel] = []
        testNoDB.find("intValue" < 10) { (objs) in
            defer {promises[0].fulfill()}
            guard let objs = objs else {
                return
            }
            objects = objs
        }
        wait(for: [promises[0]], timeout: 10)
        for (index, obj) in objects.enumerated() {
            let objModified = TestNoDBModel(_id: obj._id, intValue: index * 10)
            objects[index] = objModified
        }
        var intValues: [Int] = []
        testNoDB.save(obj: objects) { objs in
            for obj in objs ?? [] {
                guard let intValue = obj.intValue, intValue > 9 else {
                    continue
                }
                intValues.append(intValue)
            }
            promises[1].fulfill()
        }
        wait(for: [promises[1]], timeout: 10)
        XCTAssertGreaterThan(intValues.min() ?? 9, 9)
        XCTAssertEqual(intValues.count, 9)
    }
    
    func testFindSpecificId(){
        let testNoDB = NoDB<TestNoDBModel>(name: "Test", idKey: "_id")
        testNoDB.save(obj: getOrderedElements())
        let promise = expectation(description: "Find element completion")
        var objsFound: [TestNoDBModel]?
        testNoDB.find("_id" == "TestNoDB20") { objs in
            objsFound = objs
            promise.fulfill()
        }
        wait(for: [promise], timeout: 10)
        XCTAssertNotNil(objsFound)
        XCTAssertEqual(objsFound?.count, 1)
        XCTAssertEqual(objsFound?.first?._id, "TestNoDB20")
    }
    
    func testFindWithSpecificValue(){
        let testNoDB = NoDB<TestNoDBModel>(name: "Test", idKey: "_id")
        testNoDB.save(obj: getOrderedElements())
        let promise = expectation(description: "Find element completion")
        var conditionAcomplishedByResults = true
        var objsFound: [TestNoDBModel]?
        testNoDB.find("text" == "Hi 31") { (objs) in
            objsFound = objs
            for obj in objsFound ?? [] {
                guard let text = obj.text, text == "Hi 31" else {
                    conditionAcomplishedByResults = false
                    break
                }
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 10)
        XCTAssertTrue(conditionAcomplishedByResults)
        XCTAssertEqual(objsFound?.count, 1)
    }
    
    func testDateExclusiveQuery(){
        let testNoDB = NoDB<TestNoDBModel>(name: "Test", idKey: "_id")
        testNoDB.save(obj: getOrderedElements())
        let promises = [expectation(description: "Find all objs completion invoked"),
                       expectation(description: "Find objects with date completion invoked")]
        var objsFoundWithGreaterDate: [TestNoDBModel]?
        var conditionAcomplishedByResults = true
        var testDate: Date?
        testNoDB.find("intValue" == 24) { allObjs in
            testDate = allObjs?.first?.dateValue
            promises[0].fulfill()
        }
        wait(for: [promises[0]], timeout: 10)
        XCTAssertNotNil(testDate)
        guard let foundDate = testDate else { return }
        testNoDB.find("dateValue" <= foundDate) { objsFound in
            objsFoundWithGreaterDate = objsFound
            defer { promises[1].fulfill() }
            for obj in objsFoundWithGreaterDate ?? [] {
                guard let date = obj.dateValue, date <= foundDate else {
                    conditionAcomplishedByResults = false
                    break
                }
            }
        }
        wait(for: [promises[1]], timeout: 10)
        XCTAssertTrue(conditionAcomplishedByResults)
        XCTAssertEqual(objsFoundWithGreaterDate?.count, 25)
    }

    func testDateInclusiveQuery(){
        let testNoDB = NoDB<TestNoDBModel>(name: "Test", idKey: "_id")
        testNoDB.save(obj: getOrderedElements())
        let promises = [expectation(description: "Find all objs completion"),
                       expectation(description: "Find objects with date completion")]
        var objsFoundWithLessthanDate: [TestNoDBModel]?
        var conditionAcomplishedByResults = true
        var testDate: Date?
        testNoDB.find("intValue" == 24) { allObjs in
            testDate = allObjs?.first?.dateValue
            promises[0].fulfill()
        }
        wait(for: [promises[0]], timeout: 10)
        XCTAssertNotNil(testDate)
        guard let foundDate = testDate else { return }
        testNoDB.find("dateValue" > foundDate) { objsFound in
            objsFoundWithLessthanDate = objsFound
            defer { promises[1].fulfill() }
            for obj in objsFoundWithLessthanDate ?? [] {
                guard let date = obj.dateValue, date > foundDate else {
                    conditionAcomplishedByResults = false
                    break
                }
            }
        }
        wait(for: [promises[1]], timeout: 10)
        XCTAssertTrue(conditionAcomplishedByResults)
        XCTAssertEqual(objsFoundWithLessthanDate?.count, 25)
    }
    
    func testIntInclusiveQueryWhenTheresDuplicated() {
        let testNoDB = NoDB<TestNoDBModel>(name: "Test", idKey: "_id")
        testNoDB.save(obj: getElementsWithValuesDuplicated())
        let promises = [expectation(description: "Find objects completion")]
        var objsFound: [TestNoDBModel]?
        var conditionAcomplishedByResults = true
        testNoDB.find("intValue" == 0) { objs in
            objsFound = objs
            for obj in objsFound ?? [] {
                guard let intValue = obj.intValue, intValue == 0 else {
                    conditionAcomplishedByResults = false
                    break
                }
            }
            promises[0].fulfill()
        }
        wait(for: promises, timeout: 10)
        XCTAssertNotNil(objsFound)
        XCTAssertEqual(objsFound?.count, 600)
        XCTAssertTrue(conditionAcomplishedByResults)
    }
    
    func testIntExclusiveQueryWhenTheresDuplicated() {
        let testNoDB = NoDB<TestNoDBModel>(name: "Test", idKey: "_id")
        testNoDB.save(obj: getElementsWithValuesDuplicated())
        let promises = [expectation(description: "Find objects completion")]
        var objsFound: [TestNoDBModel]?
        var conditionAcomplishedByResults = true
        testNoDB.find("intValue" <= 3) { objs in
            objsFound = objs
            for obj in objsFound ?? [] {
                guard let intValue = obj.intValue, intValue <= 3 else {
                    conditionAcomplishedByResults = false
                    break
                }
            }
            promises[0].fulfill()
        }
        wait(for: promises, timeout: 10)
        XCTAssertNotNil(objsFound)
        XCTAssertEqual(objsFound?.count, 2400)
        XCTAssertTrue(conditionAcomplishedByResults)
    }
    
    func testStringInclusiveQueryWhenTheresDuplicated(){
        let testNoDB = NoDB<TestNoDBModel>(name: "Test", idKey: "_id")
        testNoDB.save(obj: getElementsWithValuesDuplicated())
        let promises = [expectation(description: "Find objects completion")]
        var objsFound: [TestNoDBModel]?
        var conditionAcomplishedByResults = true
        testNoDB.find("text" == "Last half") { (objs) in
            objsFound = objs
            for obj in objsFound ?? [] {
                guard let text = obj.text, text == "Last half" else {
                    conditionAcomplishedByResults = false
                    break
                }
            }
            promises[0].fulfill()
        }
        wait(for: promises, timeout: 10)
        XCTAssertEqual(objsFound?.count, 1500)
        XCTAssertTrue(conditionAcomplishedByResults)
    }
    
    func testDeleteWithValue(){
        let testNoDB = NoDB<TestNoDBModel>(name: "Test", idKey: "_id")
        testNoDB.save(obj: getElementsWithValuesDuplicated())
        let promises = [expectation(description: "Delete objects completion"),
                        expectation(description: "Find remaining objs completion")]
        var conditionAcomplishedByResults = true
        var deletedObjs: [TestNoDBModel]?
        testNoDB.delete("text" == "First half") { objs in
            deletedObjs = objs
            for obj in deletedObjs ?? [] {
                guard let text = obj.text, text == "First half" else {
                    conditionAcomplishedByResults = false
                    break
                }
            }
            promises[0].fulfill()
        }
        var countObjsSaved: Int?
        testNoDB.find(nil) { (objs) in
            countObjsSaved = objs?.count
            promises[1].fulfill()
        }
        wait(for: promises, timeout: 10)
        XCTAssertEqual(deletedObjs?.count, 1500)
        XCTAssertEqual(countObjsSaved, 1500)
        XCTAssertTrue(conditionAcomplishedByResults)
    }
    
    func testBoolQuery(){
        
    }
    
    func testDateInclusiveInequalityQuery(){
        let testNoDB = NoDB<TestNoDBModel>(name: "Test", idKey: "_id")
        testNoDB.save(obj: getElementsWithValuesDuplicated())
        let promises = [expectation(description: "Find objects with date completion")]
        var objsFoundWithLessthanDate: [TestNoDBModel]?
        var conditionAcomplishedByResults = true
        let foundDate = date.addingTimeInterval(Double(1499))
        testNoDB.find("dateValue" <= foundDate) { objsFound in
            objsFoundWithLessthanDate = objsFound
            defer { promises[0].fulfill() }
            for obj in objsFoundWithLessthanDate ?? [] {
                guard let date = obj.dateValue, date <= foundDate else {
                    conditionAcomplishedByResults = false
                    break
                }
            }
        }
        wait(for: promises, timeout: 10)
        XCTAssertEqual(objsFoundWithLessthanDate?.count, 1500)
        XCTAssertTrue(conditionAcomplishedByResults)
    }
    
    func testBoolExclusiveQuery() {
        let testNoDB = NoDB<TestNoDBModel>(name: "Test", idKey: "_id")
        testNoDB.save(obj: getOrderedElements())
        let promises = [expectation(description: "Find objects with Bool value completion")]
        var objsFoundWithEqualBoolValue: [TestNoDBModel]?
        var conditionAcomplishedByResults = true
        testNoDB.find("boolValue" ==  true) { (objs) in
            objsFoundWithEqualBoolValue = objs
            for obj in objs ?? [] {
                guard let boolValue = obj.boolValue, boolValue == true else {
                    conditionAcomplishedByResults = false
                    break
                }
            }
            promises[0].fulfill()
        }
        wait(for: promises, timeout: 10)
        XCTAssertEqual(objsFoundWithEqualBoolValue?.count, 25)
        XCTAssertTrue(conditionAcomplishedByResults)
    }
//    
//    func testModifyValues(){
//        let testNoDB = NoDB<TestNoDBModel>(name: "Test", idKey: "_id")
//        testNoDB.save(obj: getOrderedElements())
//        let promises = [expectation(description: "Object mofified completion")]
//        var initialNewIntValue: Int? = 6
//        var existingObjToModify = TestNoDBModel(noDBIndex: nil, _id: "TestNoDB1890", intValue: initialNewIntValue)
//        testNoDB.save(obj: existingObjToModify) {
//            
//        }
//        testNoDB.save(obj: )
//    }

    static var allTests = [
        ("testAddObjects", testAddObjects),
    ]
}
