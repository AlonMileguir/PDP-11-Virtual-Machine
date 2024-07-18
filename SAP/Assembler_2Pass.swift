

import Foundation


extension Assembler {
    
    
    func assembleTokens() {
        
        var declaredLabels : [String : Int] = [:]
        var usedLabels : [String : [Int]] = [:]
        
        var codeFile = [Int]()
        var lineStarts = [Int]()
        
        var nonDeclaredLabels = [String]()
        
        var error = false
        var errors = [Int : String]()
        
        var startInt = 0
        var startLabel : String? = nil
        
        Line: for lineNumber in 0..<tokens.count {
            lineStarts.append(codeFile.count)
            if tokens[lineNumber].count == 0 {
                continue
            }
            var currentIndex = 0
            var currentToken = tokens[lineNumber][currentIndex]
            
            if currentToken.type == TokenType.LabelDefinition {
                let label = currentToken.stringValue!
                declaredLabels[label] = codeFile.count
                currentIndex += 1
            }
            currentToken = tokens[lineNumber][currentIndex]
            var parms = [TokenType]()
            var name = ""
            var allocate = false
            switch currentToken.type {
            case .Directive:
                //special case for .start
                if currentToken.stringValue! == ".start" {
                    currentIndex += 1
                    currentToken = tokens[lineNumber][currentIndex]
                    if tokens[lineNumber].count == currentIndex + 1 {
                        let label = currentToken.stringValue!
                        if usedLabels[label] == nil {
                            usedLabels[label] = []
                        }
//                        usedLabels[label]!.append(codeFile.count)
                        startLabel = label
                        continue
                    } else {
                        errors[lineNumber] = "..........Illegal paramaters for directive .start"
                        error = true
                    }
                    continue
                }
                //special case for .allocate
                if currentToken.stringValue! == ".allocate" {
                    allocate = true
                }
                parms = idParameters[currentToken.stringValue!]!.parms
                name = "directive " + currentToken.stringValue!
            case .Instruction:
                let code = currentToken.intValue!
                parms = idParameters[currentToken.stringValue!]!.parms
                codeFile.append(code)
                name = "instruction " + currentToken.stringValue!
            default:
                
                errors[lineNumber] = "..........Expected Instruction or Directive"
                error = true
                continue Line
            }
            
            currentIndex += 1
            if tokens[lineNumber].count - currentIndex != parms.count {
                errors[lineNumber] = "..........Illegal paramaters for " + name
                error = true
                continue Line
            }
            
            for parm in parms {
                currentToken = tokens[lineNumber][currentIndex]
                currentIndex += 1
                if parm != currentToken.type {
                    errors[lineNumber] = "..........Illegal paramaters for " + name
                    error = true
                    continue Line
                }
                switch parm {
                case .Register:
                    codeFile.append(currentToken.intValue!)
                case .Label:
                    let label = currentToken.stringValue!
                    if usedLabels[label] == nil {
                        usedLabels[label] = []
                    }
                    usedLabels[label]!.append(codeFile.count)
                    codeFile.append(-1)
                case .ImmediateString:
                    var str = currentToken.stringValue!
                    codeFile.append(str.count)
                    while str.count > 0 {
                        codeFile.append(Support.characterToUnicodeValue(str.remove(at: str.startIndex)))
                    }
                case .ImmediateInteger:
                    if allocate {
                        for _ in 1...currentToken.intValue! {
                            codeFile.append(0)
                        }
                        break
                    }
                    codeFile.append(currentToken.intValue!)
                case .ImmediateTuple:
                    let tuple = currentToken.tupleValue!
                    codeFile.append(tuple.currentState)
                    codeFile.append(tuple.inputCharacter)
                    codeFile.append(tuple.newState)
                    codeFile.append(tuple.outputCharacter)
                    codeFile.append(tuple.direction)
                default:
                    continue
                }
            }
        }
        
        //adding labels
        for (label, locations) in usedLabels {
            if let value = declaredLabels[label] {
                for location in locations {
                    codeFile[location] = value
                }
            } else {
                nonDeclaredLabels.append(label)
                error = true
            }
        }
        
        if startLabel == nil {
            nonDeclaredLabels.append("..........The .Start label")
            error = true
        } else {
            if let start = declaredLabels[startLabel!] {
                startInt = start
            }
        }
        
        var numErrors = 0
        listingFile = ""
        if error {
            listingFile = ""
            for lineNumber in 0..<lines.count {
                listingFile += lines[lineNumber] + "\n"
                if let e = errors[lineNumber] {
                    listingFile += e + "\n"
                    numErrors += 1
                }
            }
            for e in nonDeclaredLabels {
                listingFile += "The label " + e + " was not declared\n"
                numErrors += 1
            }
            
            errorCount = numErrors
            return
        }
        errorCount = 0
        symbolTable = declaredLabels
        listingFile = ""
        for lineNumber in 0..<lines.count {
            let start = lineStarts[lineNumber]
            let end = (lineStarts.count - 1 > lineNumber) ? lineStarts[lineNumber + 1] - 1 : codeFile.count - 1
            var code = "\(start): "
            if start > end {
                listingFile += Support.fit(code,18,true) + "   " + lines[lineNumber] + "\n"
                continue
            }
            for n in start...end {
                code += String(codeFile[n]) + " "
            }
            listingFile += Support.fit(code, 18, true) + "   "
            listingFile += lines[lineNumber] + "\n"
        }
        codeFile.insert(startInt, at: 0)
        codeFile.insert(codeFile.count - 1, at: 0)
        assembledFile = codeFile
    }
    
    
}

