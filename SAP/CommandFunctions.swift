import Foundation
 
extension VM {
    
    //halt                  0
    func halt() {
        running = false
    }
    
    //clrr r1               1
    func clrr() {
        let types = [Type.register]
        guard let items = checkTypes(types) else {
            return
        }
        registers[items[0]] = 0
    }
    
    //clxr r1               2
    func clrx() {
        let types = [Type.address]
        guard let items = checkTypes(types) else {
            return
        }
        memory[registers[items[0]]] = 0
    }
    
    //clrm label            3
    func clrm() {
        let types = [Type.register]
        guard let items = checkTypes(types) else {
            return
        }
        memory[items[0]] = 0
    }
    
    //clrb r1 r2            4
    func clrb() {
        let types = [Type.address, Type.register]
        guard let items = checkTypes(types) else {
            return
        }
        let label = items[0]
        let count = registers[items[1]]
        guard count > 0 else {
            error = "@" + String(rPC - 3) + ": count cannot be negative"
            return
        }
        for i in label...label + count - 1 {
            memory[i] = 0
        }
        
    }
    
    //movir #123 r1         5
    func movir() {
        let types = [Type.immediate, Type.register]
        move(types: types)
    }
    
    //movrr r1 r2           6
    func movrr() {
        let types = [Type.register, Type.register]
        move(types: types)
    }
    
    //movrm r1 label        7
    func movrm() {
        let types = [Type.register, Type.label]
        move(types: types)
    }
       
    //movmr label r1        8
    func movmr() {
        let types = [Type.label, Type.register]
        move(types: types)
    }
    
    //movxr r1 r2           9
    func movxr() {
        let types = [Type.address, Type.register]
        move(types: types)
    }
       
    //movar label r1        10
    func movar() {
        let types = [Type.immediate, Type.register]
        move(types: types)
    }
    
    //movb r1 r2 r3         11
    func movb() {
        let types = [Type.address, Type.address, Type.register]
        guard let items = checkTypes(types) else {
            return
        }
        let source = items[0]
        let destination = items[1]
        let count = registers[items[2]]
        guard count > 0 else {
            error = "@" + String(rPC - 4) + ": count cannot be negative"
            return
        }
        for n in 0...count - 1 {
            memory[destination + n] = memory[source + n]
        }
        
        
    }
    
    //addir #1 r1           12
    func addir() {
        let types = [Type.immediate, Type.register]
        math(types: types, opperation: Math.add)
    }
    
    //addrr r1 r2           13
    func addrr() {
        let types : [Type] = [ .register, .register ]
        math(types: types, opperation: Math.add)
    }
    
    //addmr label r2        14
    func addmr() {
        let types = [Type.label, Type.register]
        math(types: types, opperation: Math.add)
    }
    
    //addxr r1 r2           15
    func addxr() {
        let types = [Type.address, Type.register]
        math(types: types, opperation: Math.add)
    }
    
    //subir #1 r1           16
    func subir() {
        let types = [Type.immediate, Type.register]
        math(types: types, opperation: Math.subtract)
    }
    
    //subrr r1 r2           17
    func subrr() {
        let types = [Type.register, Type.register]
        math(types: types, opperation: Math.subtract)
    }
    
    //submr label r2        18
    func submr() {
        let types = [Type.label, Type.register]
        math(types: types, opperation: Math.subtract)
    }
    
    //subxr r1 r2           19
    func subxr() {
        let types = [Type.address, Type.register]
        math(types: types, opperation: Math.subtract)
    }
    
    //mulir #123 r1         20
    func mulir() {
        let types = [Type.immediate, Type.register]
        math(types: types, opperation: Math.multiply)
    }
    
    //mulrr r1 r2           21
    func mulrr() {
        let types = [Type.register, Type.register]
        math(types: types, opperation: Math.multiply)
    }
    
    //mulmr label r1        22
    func mulmr() {
        let types = [Type.label, Type.register]
        math(types: types, opperation: Math.multiply)
    }
    
    //mulxr r1 r2           23
    func mulxr() {
        let types = [Type.address, Type.register]
        math(types: types, opperation: Math.multiply)
    }
    
    //divir #123 r1         24
    func divir() {
        let types = [Type.immediate, Type.register]
        math(types: types, opperation: Math.divide)
    }
    
    //divrr r1 r2           25
    func divrr() {
        let types = [Type.register, Type.register]
        math(types: types, opperation: Math.divide)
    }
    
    //divmr label r1        26
    func divmr() {
        let types = [Type.label, Type.register]
        math(types: types, opperation: Math.divide)
    }
    
    //divxr r1 r2           27
    func divxr() {
        let types = [Type.address, Type.register]
        math(types: types, opperation: Math.divide)
    }
    
    //jmp label             28
    func jmp() {
        let types = [Type.label]
        guard let items = checkTypes(types) else {
            return
        }
        let label = items[0]
        rPC = label
    }
    
    //sojz r1 label         29
    func sojz() {
        let types = [Type.register, Type.label]
        guard let items = checkTypes(types) else {
            return
        }
        let r = items[0]
        let label = items[1]
        registers[r] -= 1
        if registers[r] == 0 {
            rPC = label
        }
    }
    
    //sojnz r1 label        30
    func sojnz() {
        let types = [Type.register, Type.label]
        guard let items = checkTypes(types) else {
            return
        }
        let r = items[0]
        let label = items[1]
        registers[r] -= 1
        if registers[r] != 0 {
            rPC = label
        }
    }
    
    //aojz r1 label         31
    func aojz() {
        let types = [Type.register, Type.label]
        guard let items = checkTypes(types) else {
            return
        }
        let r = items[0]
        let label = items[1]
        registers[r] += 1
        if registers[r] == 0 {
            rPC = label
        }
    }
    
    //aojnz r1 label        32
    func aojnz() {
        let types = [Type.register, Type.label]
        guard let items = checkTypes(types) else {
            return
        }
        let r = items[0]
        let label = items[1]
        registers[r] += 1
        if registers[r] != 0 {
            rPC = label
        }
    }
 
    //cmpir #123            33
    func cmpir() {
        let types = [Type.immediate, Type.register]
        comp(types: types)
    }
    
    //cmprr r1 r2           34
    func cmprr() {
        let types = [Type.register, Type.register]
        comp(types: types)
    }
 
    //compmr label r1       35
    func cmpmr() {
        let types = [Type.label, Type.register]
        comp(types: types)
    }
    
    //jmpn label            36
    func jmpn() {
        let types = [Type.label]
        guard let items = checkTypes(types) else {
            return
        }
        let label = items[0]
        if rCP < 0 {
            rPC = label
        }
    }
    
    //jmpz label            37
    func jmpz() {
        let types = [Type.label]
        guard let items = checkTypes(types) else {
            return
        }
        let label = items[0]
        if rCP == 0 {
            rPC = label
        }
    }
    
    //jmpp label            38
    func jmpp() {
        let types = [Type.label]
        guard let items = checkTypes(types) else {
            return
        }
        let label = items[0]
        if rCP > 0 {
            rPC = label
        }
    }
    
    //jsr label             39
    func jsr() {
        let types = [Type.label]
        guard let items = checkTypes(types) else {
            return
        }
        let label = items[0]
        if stack.capacity + 6 > stack.size {
            error = "@" + String(rPC) + registerError
            return
        }
        stack.push(rPC)
        for r in 5...9 {
            stack.push(registers[r])
        }
        rPC = label
    }
    
    //ret                   40
    func ret() {
        if stack.capacity < 6 {
            error = "@" + String(rPC) + registerError
            return
        }
        for n in 0...4 {
            registers[9 - n] = stack.pop()!
        }
        rPC = stack.pop()!
    }
    
    //push r1               41
    func push() {
        if stack.isFull() {
            error = "@" + String(rPC) + " Stack Overflow"
            return
        }
        let types = [Type.register]
        guard let items = checkTypes(types) else {
            return
        }
        let register = items[0]
        stack.push(registers[register])
    }
    
    //pop r1                42
    func pop() {
        if stack.isEmpty() {
            error = "@" + String(rPC) + " Stack Overflow"
            return
        }
        let types = [Type.register]
        guard let items = checkTypes(types) else {
            return
        }
        let register = items[0]
        registers[register] = stack.pop()!
    }
    
    //stackc r1             43
    func stackc() {
        let types = [Type.register]
        guard let items = checkTypes(types) else {
            return
        }
        let r = items[0]
        registers[r] = 0
        if stack.isFull() {
            registers[r] = 1
        }
        if stack.isEmpty() {
            registers[r] = 2
        }
    }
    
    //outci #123            44
    func outci() {
        let types = [Type.immediate]
        guard let items = checkTypes(types) else {
            return
        }
        let i = items[0]
        output(String(Support.unicodeValueToCharacter(i)))
    }
    
    //outcr r1              45
    func outcr() {
        let types = [Type.register]
        guard let items = checkTypes(types) else {
            return
        }
        let register = items[0]
        output(String(Support.unicodeValueToCharacter(registers[register])))
    }
    
    //outcx r1              46
    func outcx() {
        let types = [Type.address]
        guard let items = checkTypes(types) else {
            return
        }
        let address = items[0]
        output(String(Support.unicodeValueToCharacter(memory[address])))
    }
    
    //outcb r1 r2           47
    func outcb() {
        let types = [Type.address, Type.register]
        guard let items = checkTypes(types) else {
            return
        }
        let label = items[0]
        let count = items[1]
        guard count > 0 else {
            error = "@" + String(rPC - 3) + ": count cannot be negative"
            return
        }
        for m in label..<label + count {
            output(String(Support.unicodeValueToCharacter(memory[m])))
        }
        
    }
    
    //readi r1 r2           48
    func readi() {
        let types = [Type.register, Type.register]
        guard let items = checkTypes(types) else {
            return
        }
        let r1 = items[0]
        let r2 = items[1]
        let input = readLine()!
        if let n = Int(input) {
            registers[r1] = n
            registers[r2] = 0
        } else {
            registers[r2] = 1
        }
    }
    
    //printi r1             49
    func printi() {
        let types = [Type.register]
        guard let items = checkTypes(types) else {
            return
        }
        let register = items[0]
        output(String(registers[register]))
    }
    
    //readc r1              50
    func readc() {
        let types = [Type.register]
        guard let items = checkTypes(types) else {
            return
        }
        let r = items[0]
        var input = readLine()!
        let c = (input.count > 0) ? input.remove(at: input.startIndex) : " "
        registers[r] = Support.characterToUnicodeValue(c)
    }
    
    //readln label r1       51
    func readln() {
        let types = [Type.label, Type.register]
        guard let items = checkTypes(types) else {
            return
        }
        let label = items[0]
        let r = items[1]
        let count = registers[r]
        var line = readLine()!
        guard label + count < memory.count else {
            error = "@" + String(rPC - 2) + memoryError
            return
        }
        memory[label] = count
        for n in label + 1...label + count {
            if line.count == 0 {
                memory[n] = Support.characterToUnicodeValue(" ")
                continue
            }
            memory[n] = Support.characterToUnicodeValue(line.remove(at: line.startIndex))
        }
    }
    
    //brk                   52
    func brk() {
        debugging = true
        rPC += 1
    }
    
    //movrx r1 r2           53
    func movrx() {
        let types = [Type.register, Type.address]
        move(types: types)
    }
    
    //movxx r1 r2           54
    func movxx() {
        let types = [Type.address, Type.address]
        move(types: types)
    }
    
    //outs label            55
    func outs() {
        let types = [Type.label]
        guard let items = checkTypes(types) else {
            return
        }
        let label = items[0]
        var s = ""
        for n in label + 1...label + memory[label] {
            s += String(Support.unicodeValueToCharacter(memory[n]))
        }
        output(s)
    }
    
    //nop                   56
    func nop() {
        rPC += 1
    }
    
    //jmpne label           57
    func jmpne() {
        let types = [Type.label]
        guard let items = checkTypes(types) else {
            return
        }
        let label = items[0]
        if rCP != 0 {
            rPC = label
        }
        
    }
    
    
    
    
    
}


