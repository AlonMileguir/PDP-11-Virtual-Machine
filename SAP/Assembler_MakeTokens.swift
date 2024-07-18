
import Foundation


extension Assembler {
    
    func makeTokens() {
        for lineNumber in 0..<chunks.count {
            tokens.append([])
            let line = chunks[lineNumber]
            for chunk in line {
                if let token = makeToken(chunk) {
                    tokens[lineNumber].append(token)
                } else {
                    break
                }
            }
        }
    }
    
    func makeToken(_ item : String) -> Token? {
        let firstChar = item.prefix(1).lowercased()
        switch firstChar {
        case "#":
            return makeImmediateInt(item)
        case ";":
            return nil
        case "r":
            if item.count != 2 {
                break
            }
            return makeRegister(item)
        case "\"":
            return makeImmediateString(item)
        case ".":
            return makeDirective(item.lowercased())
        case "\\":
            return makeImmediateTuple(item)
        default:
            break
        }
        if String(item.suffix(1)) == ":" {
            return makeLabelDef(item.lowercased())
        }
        if idParameters[item.lowercased()] != nil {
            return makeInstruction(item.lowercased())
        }
        return makeLabel(item.lowercased())
    }
    
    func makeImmediateInt(_ item : String) -> Token {
        let short = item.suffix(item.count - 1)
        guard let number = Int(short) else {
            return Token()
        }
        return Token(TokenType.ImmediateInteger, number, nil, nil)
    }
    
    func makeRegister(_ item : String) -> Token {
        let short = item.suffix(item.count - 1)
        guard let number = Int(short) else {
            return Token()
        }
        guard number >= 0 && number < 10 else {
            return Token()
        }
        return Token(TokenType.Register, number, nil, nil)
    }
    
    func makeImmediateString(_ item : String) -> Token {
        var str = String(item.suffix(item.count - 1))
        let last = str.popLast()!
        if last != "\"" {
            str += String(last)
        }
        return Token(TokenType.ImmediateString, nil, str, nil)
    }
    
    func makeLabelDef(_ item : String) -> Token {
        let label = String(item.prefix(item.count - 1))
        return Token(TokenType.LabelDefinition, nil, label, nil)
    }
    
    func makeDirective(_ item : String) -> Token {
        guard let _ = idParameters[item] else {
            return Token()
        }
        return Token(TokenType.Directive, nil, item, nil)
    }
    
    func makeInstruction(_ item : String) -> Token {
        if item == "ret" {
            
        }
        guard let code = idParameters[item]?.code else {
            return Token()
        }
        return Token(TokenType.Instruction, code, item, nil)
    }
    
    func makeLabel(_ item : String) -> Token {
        return Token(TokenType.Label, nil, item, nil)
    }
    
    func makeImmediateTuple(_ item : String) -> Token {
        var tuple = String(item.suffix(item.count - 1))
        let last = tuple.popLast()!
        if last != "\\" {
            tuple += String(last)
        }
        let parts = Support.splitStringIntoParts(tuple)
        guard parts.count == 5 else {
            return Token()
        }
        //cs
        guard let cs = Int(parts[0]) else {return Token()}
        
        //ic
        guard parts[1].count == 1 else {return Token()}
        let ic = Support.characterToUnicodeValue(Character(parts[1]))
        
        //ns
        guard let ns = Int(parts[2]) else {return Token()}
        
        //oc
        guard parts[3].count == 1 else {return Token()}
        let oc = Support.characterToUnicodeValue(Character(parts[3]))
        
        //di
        let di = parts[4]
        guard di == "r" || di == "l" else {return Token()}
        let d = (di == "r") ? 1 : -1
        
        return Token(TokenType.ImmediateTuple, nil, nil, Tuple(cs, ic, ns, oc, d))
    }
}















