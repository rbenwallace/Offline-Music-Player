//
//  Tests_Library.swift
//  Tests iOS
//
//  Created by Ben Wallace on 2022-04-02.
//

@testable import Offline_Music_Player
import XCTest

class Tests_Library: XCTestCase {
    var persistenceController: PersistenceController!
    var model: Model!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController()
        model = Model()
    }
    
    override func tearDown() {
        persistenceController = nil
        model = nil
        super.tearDown()
    }
    
    func testDescription() throws {
        //
    }
}
