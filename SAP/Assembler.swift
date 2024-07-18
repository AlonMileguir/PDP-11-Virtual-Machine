
import Foundation


class Assembler {
    
    var lines : [String] = []
    var chunks : [[String]] = []
    var tokens : [[Token]] = []
    var idParameters : [String : (parms : [TokenType], code : Int)] = [:]
    
    
    var listingFile : String = ""
    var symbolTable : [String : Int]? = nil
    var assembledFile : [Int]? = nil
    var errorCount = 0;
    
    func assembleFile(path : String) {
        lines = []
        chunks = []
        tokens = []
        listingFile = ""
        assembledFile = nil
        symbolTable = nil
        readFile(path: path)
        chunkLines()
        makeTokens()
        assembleTokens()
    }
    
    init() {
        idParameters = [
            "halt":       ([], 0),
            "clrr":       ([TokenType.Register], 1),
            "clrx":       ([TokenType.Register], 2),
            "clrm":       ([TokenType.Label], 3),
            "clrb":       ([TokenType.Register, TokenType.Register], 4),
            "movir":      ([TokenType.ImmediateInteger, TokenType.Register], 5),
            "movrr":      ([TokenType.Register, TokenType.Register], 6),
            "movrm":      ([TokenType.Register, TokenType.Label], 7),
            "movmr":      ([TokenType.Label, TokenType.Register], 8),
            "movxr":      ([TokenType.Register, TokenType.Register], 9),
            "movar":      ([TokenType.Label, TokenType.Register], 10),
            "movb":       ([TokenType.Register, TokenType.Register, TokenType.Register], 11),
            "addir":      ([TokenType.ImmediateInteger, TokenType.Register], 12),
            "addrr":      ([TokenType.Register, TokenType.Register], 13),
            "addmr":      ([TokenType.Label, TokenType.Register], 14),
            "addxr":      ([TokenType.Register, TokenType.Register], 15),
            "subir":      ([TokenType.ImmediateInteger, TokenType.Register], 16),
            "subrr":      ([TokenType.Register, TokenType.Register], 17),
            "submr":      ([TokenType.Label, TokenType.Register], 18),
            "subxr":      ([TokenType.Register, TokenType.Register], 19),
            "mulir":      ([TokenType.ImmediateInteger, TokenType.Register], 20),
            "mulrr":      ([TokenType.Register, TokenType.Register], 21),
            "mulmr":      ([TokenType.Label, TokenType.Register], 22),
            "mulxr":      ([TokenType.Register, TokenType.Register], 23),
            "divir":      ([TokenType.ImmediateInteger, TokenType.Register], 24),
            "divrr":      ([TokenType.Register, TokenType.Register], 25),
            "divmr":      ([TokenType.Label, TokenType.Register], 26),
            "divxr":      ([TokenType.Register, TokenType.Register], 27),
            "jmp":        ([TokenType.Label], 28),
            "sojz":       ([TokenType.Register, TokenType.Label], 29),
            "sojnz":      ([TokenType.Register, TokenType.Label], 30),
            "aojz":       ([TokenType.Register, TokenType.Label], 31),
            "aojnz":      ([TokenType.Register, TokenType.Label], 32),
            "cmpir":      ([TokenType.ImmediateInteger, TokenType.Register], 33),
            "cmprr":      ([TokenType.Register, TokenType.Register], 34),
            "cmpmr":      ([TokenType.Label, TokenType.Register], 35),
            "jmpn":       ([TokenType.Label], 36),
            "jmpz":       ([TokenType.Label], 37),
            "jmpp":       ([TokenType.Label], 38),
            "jsr":        ([TokenType.Label], 39),
            "ret":        ([], 40),
            "push":       ([TokenType.Register], 41),
            "pop":        ([TokenType.Register], 42),
            "stackc":     ([TokenType.Register], 43),
            "outci":      ([TokenType.ImmediateInteger], 44),
            "outcr":      ([TokenType.Register], 45),
            "outcx":      ([TokenType.Register], 46),
            "outb":       ([TokenType.Register, TokenType.Register], 47),
            "readi":      ([TokenType.Register, TokenType.Register], 48),
            "printi":     ([TokenType.Register], 49),
            "readc":      ([TokenType.Register], 50),
            "readln":     ([TokenType.Label, TokenType.Register], 51),
            "brk":        ([], 52),
            "movrx":      ([TokenType.Register, TokenType.Register], 53),
            "movxx":      ([TokenType.Register, TokenType.Register], 54),
            "outs":       ([TokenType.Label], 55),
            "nop":        ([], 56),
            "jmpne":      ([TokenType.Label], 57),
            
            ".tuple":     ([TokenType.ImmediateTuple], -1),
            ".string":    ([TokenType.ImmediateString], -1),
            ".integer":   ([TokenType.ImmediateInteger], -1),
            ".start":     ([TokenType.Label],-1),
            ".allocate":  ([TokenType.ImmediateInteger],-1)
        ]
    }
    
    func readFile(path : String) -> Bool {
        guard let file = Support.readTextFile(path).fileText else {
            return false
        }
        lines = Support.splitStringIntoLines(file)
        return true
    }
    
    func chunkLines() {
        for lineNumber in 0..<lines.count {
            chunks.append([])
            var line = lines[lineNumber]
            //print(line)
            var currentChunk = ""
            var endChar = " "
            while line.count > 0 {
                let c = String(line.remove(at: line.startIndex))
                switch c {
                case endChar:
                    if currentChunk != "" {
                        if endChar != " " {
                            currentChunk += c
                        }
                        chunks[lineNumber].append(currentChunk)
                        currentChunk = ""
                    }
                case "\"":
                    currentChunk += c
                    endChar = (endChar == " ") ? "\"" : endChar
                case "\\":
                    currentChunk += c
                    endChar = (endChar == " ") ? "\\" : endChar
                default:
                    currentChunk += c
                }
            }
            if currentChunk != "" {
                //print(currentChunk)
                chunks[lineNumber].append(currentChunk)
            }
        }
        
        
    }
    
    func tokenString(_ token : Token) -> String {
        switch token.type {
        case .LabelDefinition:
            return "LabelDef"
        case .ImmediateTuple:
            return "ImmediateTuple"
        case .ImmediateString:
            return "ImmediateString"
        case .ImmediateInteger:
            return "ImmediateInteger"
        case .Register:
            return "Register"
        case .Directive:
            return "Directive"
        case .Instruction:
            return "Instruction"
        case .BadToken:
            return "**BadeToken**"
        case .Label:
            return "Label"
        }
    }
    
    func printTokens() {
        for line in tokens {
            for token in line {
                print(tokenString(token), terminator : " ")
            }
            print()
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}



































