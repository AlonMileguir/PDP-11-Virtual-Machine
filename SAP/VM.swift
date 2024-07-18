
import Foundation

class VM {
    
    //misc
    var running = false
    var error : String? = nil
    
    //registers
    var rPC : Int
    var rCP : Int
    var rST : Int
    var stack : Stack<Int>
    var registers : [Int]
    
    //files
    var assembledFile = false
    var memoryLength : Int
    var memory : [Int]
    
    var commands : Array<() -> ()> = []
    
    //debugger
    var breakpoints = Set<Int>()
    var debugging = false
    var symbolTable : [String : Int] = [:]
    var reverseSymbolTable : [Int : String] = [:]
    var disassemblerTable : [Int : (name : String, parms : [TokenType])] = [:]
    
    //assembler
    var assembler = Assembler()
    var currentPath = ""
    
    init(_ memoryLength : Int) {
        self.stack = Stack<Int>(500,0)
        self.rPC = 0
        self.rCP = 0
        self.rST = 0
        self.memoryLength = memoryLength
        self.memory = Array(repeating: 0, count: memoryLength)
        registers = Array(repeating: 0, count: 10)
        setUp()
    }
    
    func startUI() {
        
        End: while true {
            print("Command...", terminator: "")
            let input = readLine()!
            let words = Support.splitStringIntoParts(input)
            switch words[0] {
            case "debug":
                if assembledFile {
                    debug()
                } else {
                    print("No file is assembled")
                }
            case "path":
                currentPath = words[1]
            case "asm":
                assembleFile(words[1])
            case "quit":
                break End
            case "printlst":
                print(assembler.listingFile)
            case "run":
                if assembledFile {
                    runVM()
                } else {
                    print("No file is assembled")
                }
            case "printsym":
                if let table = assembler.symbolTable {
                    for (label, value) in table {
                        print(Support.fit("\(label):", 12, true) + "  " + "\(value)")
                    }
                } else {
                    print("No Symbol table is available")
                }
            case "printbin":
                if let file = assembler.assembledFile {
                    for i in file {
                        print(i)
                    }
                } else {
                    print("No binary file is available")
                }
            default:
                let _ = 0
            }
            
        }
    }
    
    func assembleFile(_ name : String) {
        assembler.assembleFile(path: name)
        if let file = assembler.assembledFile {
            assembledFile = true
            loadMemory(saveData: file)
            symbolTable = assembler.symbolTable!
            for (name, value) in symbolTable {
                reverseSymbolTable[value] = name
            }
            for (name, info) in assembler.idParameters {
                let code = info.code
                let parms = info.parms
                disassemblerTable[code] = (name, parms)
            }
        } else {
            assembledFile = false
            print("\nCould not Assemble: \(assembler.errorCount) errors\n")
        }
    }
    
    func runVM() {
        running = true
        while running {
            if let e = error {
                print(e)
                break;
            }
            let commandCode = memory[rPC]
            commands[commandCode]()
        }
    }
    
    func loadMemory(saveData : [Int]) {
        rPC = Int(saveData[1])
        for n in 2...saveData.count - 1 {
            memory[n - 2] = Int(saveData[n])
        }
        
    }
    
    func output(_ s : String) {
        print(s, terminator : "")
    }
    
    let registerError = ": Bad Register Access"
    let memoryError = ": Bad Memory Access"
    func dummyFunc() {}


    func setUp() {
        commands = Array(repeating: dummyFunc, count: 58)
        commands[0] = halt
        commands[1] = clrr
        commands[2] = clrx
        commands[3] = clrm
        commands[4] = clrb
        commands[5] = movir
        commands[6] = movrr
        commands[7] = movrm
        commands[8] = movmr
        commands[9] = movxr
        commands[10] = movar
        commands[11] = movb
        commands[12] = addir
        commands[13] = addrr
        commands[14] = addmr
        commands[15] = addxr
        commands[16] = subir
        commands[17] = subrr
        commands[18] = submr
        commands[19] = subxr
        commands[20] = mulir
        commands[21] = mulrr
        commands[22] = mulmr
        commands[23] = mulxr
        commands[24] = divir
        commands[25] = divrr
        commands[26] = divmr
        commands[27] = divxr
        commands[28] = jmp
        commands[29] = sojz
        commands[30] = sojnz
        commands[31] = aojz
        commands[32] = aojnz
        commands[33] = cmpir
        commands[34] = cmprr
        commands[35] = cmpmr
        commands[36] = jmpn
        commands[37] = jmpz
        commands[38] = jmpp
        commands[39] = jsr
        commands[40] = ret
        commands[41] = push
        commands[42] = pop
        commands[43] = stackc
        commands[44] = outci
        commands[45] = outcr
        commands[46] = outcx
        commands[47] = outcb
        commands[48] = readi
        commands[49] = printi
        commands[50] = readc
        commands[51] = readln
        commands[52] = brk
        commands[53] = movrx
        commands[54] = movxx
        commands[55] = outs
        commands[56] = nop
        commands[57] = jmpne

    }
    
    func getValue(type : Type, n : Int) -> Int {
        switch type {
        case .register:
            return registers[n]
        case .label:
            return memory[n]
        case .immediate:
            return n
        case .address:
            return memory[n]
        }
    }
    
    func moveTo(type : Type, n : Int, toMove : Int) {
        switch type {
        case .register:
            registers[n] = toMove
        case .label:
            memory[n] = toMove
        case .address:
            memory[n] = toMove
        default:
            error = "??"
        }
    }
    
    func move(types : [Type]) {
        if types[1] == .address {
            
        }
        guard let locations = checkTypes(types) else {
            return
        }
        let L1 = locations[0]
        let L2 = locations[1]
        let toMove = getValue(type: types[0], n : L1)
        moveTo(type: types[1], n: L2, toMove: toMove)
    }
    
    func math(types : [Type], opperation : Math) {
        guard let locations = checkTypes(types) else {
            return
        }
        let L1 = locations[0]
        let L2 = locations[1]
        let toAdd = getValue(type: types[0], n: L1)
        switch opperation {
        case .add:
            registers[L2] += toAdd
        case .subtract:
            registers[L2] -= toAdd
        case .multiply:
            registers[L2] *= toAdd
        case .divide:
            registers[L2] /= toAdd
        }
    }
    
    func comp(types : [Type]) {
        guard let locations = checkTypes(types) else {
            return
        }
        let toUse = getValue(type: types[0], n: locations[0])
        let r = locations[1]
        rCP = toUse - registers[r]
    }
    
    func checkTypes(_ types : [Type]) -> [Int]? {
        var items : [Int] = []
        let count = types.count
        guard rPC + count < memory.count else {
            error = "@" + String(rPC) + memoryError
            return nil
        }
        
        for step in 1...types.count {
            switch types[step - 1] {
            case .register:
                let r = memory[rPC + step]
                guard r >= 0 && r < 10 else {
                    error = "@" + String(rPC) + registerError
                    return nil
                }
                items.append(r)
            case .label:
                let label = memory[rPC + step]
                guard label >= 0 && label < memory.count else {
                    error = "@" + String(rPC) + memoryError
                    return nil
                }
                items.append(label)
            case .immediate:
                let i = memory[rPC + step]
                items.append(i)
            case .address:
                let r = memory[rPC + step]
                guard r >= 0 && r < 10 else {
                    error = "@" + String(rPC) + registerError
                    return nil
                }
                let label = registers[r];
                guard label >= 0 && label < memory.count else {
                    error = "@" + String(rPC) + memoryError
                    return nil
                }
                items.append(label)
            }
            
            
        }
        
        rPC += count + 1
        return items
        
        
    }
    
    
    
}




























