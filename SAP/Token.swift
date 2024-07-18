

import Foundation

enum TokenType {
    case Register
    case LabelDefinition
    case Label
    case ImmediateString
    case ImmediateInteger
    case ImmediateTuple
    case Instruction
    case Directive
    case BadToken
}
struct Token {
    let type: TokenType
    let intValue: Int?
    let stringValue: String?
    let tupleValue: Tuple?
    
    init(_ type : TokenType, _ intValue : Int?, _ stringValue : String?, _ tupleValue : Tuple?) {
        self.type = type
        self.intValue = intValue
        self.stringValue = stringValue
        self.tupleValue = tupleValue
    }
    
    init() {
        self.type = .BadToken
        self.intValue = nil
        self.stringValue = nil
        self.tupleValue = nil
    }
}
struct Tuple {
    let currentState: Int
    let inputCharacter: Int
    let newState: Int
    let outputCharacter: Int
    let direction: Int
    init(_ cs : Int, _ ic : Int, _ ns : Int, _ oc : Int, _ di : Int) {
        currentState = cs
        inputCharacter = ic
        newState = ns
        outputCharacter = oc
        direction = di
    }
}














