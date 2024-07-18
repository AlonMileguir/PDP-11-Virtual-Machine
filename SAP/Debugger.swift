

import Foundation
 
 
extension VM {
    
    func debug() {
        
        var breakPointsEnabled = true
        
        End: while true {
            print("sdb (\(rPC), \(memory[rPC])) ", terminator: "")
            let input = readLine()!
            let words = Support.splitStringIntoParts(input)
            Next: switch words[0] {
            case "setbk":
                if let location = getAddress(words[1]) {
                    breakpoints.insert(location)
                } else {
                    print("\"\(words[1])\" is not a valid label")
                }
            case "rmbk":
                if let location = getAddress(words[1]) {
                    breakpoints.remove(location)
                } else {
                    print("\"\(words[1])\" is not a valid label")
                }
            case "clrbk":
                breakpoints.removeAll(keepingCapacity: true)
            case "pbk":
                print("Break Points:")
                for bk in breakpoints {
                    if let label = reverseSymbolTable[bk] {
                        print("\(bk) (\(label))")
                    } else {
                        print("\(bk)")
                    }
                }
            case "s":
                let commandCode = memory[rPC]
                commands[commandCode]()
                if let e = error {
                    print(e)
                }
            case "g":
                running = true
                while running {
                    let commandCode = memory[rPC]
                    commands[commandCode]()
                    if let e = error {
                        print(e)
                    }
                    if  breakPointsEnabled && breakpoints.contains(rPC) {
                        running = false
                        break Next
                    }
                }
            case "deas":
                var range : [Int] = [0,0]
                for n in 1...2 {
                    let label = words[n]
                    if let address = getAddress(label) {
                        range[n - 1] = address
                        continue
                    }
                    print("\(words[n + 1]) is not a label or int")
                    break Next
                }
                if range[0] < range[1] {
                    print(disassemble(range[0], range[1]))
                } else {
                    print("invalid range")
                }
            case "preg":
                printRegisters()
            case "pmem":
                var range : [Int] = [0,0]
                for n in 1...2 {
                    let label = words[n]
                    if let address = getAddress(label) {
                        range[n - 1] = address
                        continue
                    }
                    print("\(words[n + 1]) is not a label or int")
                    break Next
                }
                if range[0] < range[1] {
                    pmem(range[0], range[1])
                } else {
                    print("invalid range")
                }
                
            case "wreg":
                if Int(words[1]) == nil || Int(words[2]) == nil {
                    print("error")
                }
                let r = Int(words[1])!
                let n = Int(words[2])!
                registers[r] = n
            case "wmem":
                let location = getAddress(words[1])
                if location == nil {
                    print("\(words[1]) is not a label or int")
                    break Next
                }
                if let value = Int(words[2]) {
                    memory[location!] = value
                }
            case "wpc":
                if let n = Int(words[1]) {
                    rPC = n
                }
            case "pst":
                printSymbolTable()
            case "exit":
                break End
            case "enbk":
                 breakPointsEnabled = true
            case "disbk":
                 breakPointsEnabled = false
            default:
                break
            }
            
        }
    }
    
    func getAddress(_ label : String) -> Int? {
        var location : Int? = nil
        if let l = symbolTable[label] {
            location = l
        } else if let l = Int(label) {
            location = l
        }
        return location
    }
    
    func printSymbolTable() {
        for (label, value) in symbolTable {
            print(Support.fit("\(label):", 12, true) + "  " + "\(value)")
        }
    }
    
    func printRegisters() {
        for n in 0...9 {
            print("\(n): \(registers[n])")
        }
        print("rPC: \(rPC)")
    }
    
    func pmem(_ start: Int, _ end: Int) {
        for i in start...end {
            print("\(i): \(memory[i])")
        }
    }
    
    func disassemble(_ start : Int, _ end : Int) -> String {
        var file = ""
        var currentLabel = start
        while currentLabel <= end {
            var line = ""
            if let label = reverseSymbolTable[currentLabel] {
                line += label + ": "
            } else {
                line += "      "
            }
            let code = memory[currentLabel]
            guard let info = disassemblerTable[code] else {
                return file + "\n...found error in assembly"
            }
            let name = info.name
            let parms = info.parms
            let count = parms.count
            line += name + " "
            currentLabel += 1
            for i in 0..<count {
                let value = memory[currentLabel]
                let type = parms[i]
                switch type {
                case .ImmediateInteger:
                    line += "#\(value) "
                case .Register:
                    line += "r\(value) "
                case .Label:
                    if let label = reverseSymbolTable[value] {
                        line += label + " "
                    } else {
                        return file + "\n...found error in assembly"
                    }
                    line += reverseSymbolTable[value]! + " "
                default:
                    break
                    
                }
                currentLabel += 1
            }
            file += line + "\n"
        }
        
        return file
    }
    
    
 
}
 



