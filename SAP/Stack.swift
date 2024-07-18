import Foundation

struct Stack<Element> : CustomStringConvertible, Sequence, IteratorProtocol {
    
    var stack : [Element] = []
    var size : Int
    var nextIndex = 0
    var capacity = 0
    var initial : Element
    
    init(_ size : Int, _ initial : Element) {
        self.size = size
        for _ in 1...size {
            stack.append(initial)
        }
        self.initial = initial
    }
    
    mutating func push(_ n : Element) {
        if !isFull() {
            stack[nextIndex] = n
            nextIndex += 1
            capacity += 1
        }
    }
    
    mutating func pop() -> Element? {
        guard !isEmpty() else {return nil}
        let n = stack[nextIndex - 1]
        nextIndex -= 1
        stack[nextIndex] = initial
        capacity -= 1
        return n
    }
    
    func isFull() -> Bool {
        if capacity == size {return true}
        return false
    }
    
    func isEmpty() -> Bool {
        if capacity == 0 {return true}
        return false
    }
    
    var description: String {
        guard capacity != 0 else {return "T [] B"}
        var items = ""
        
        for n in 0...capacity - 1 {
            items += "\(stack[n]), "
        }
        for _ in 1...2 {
            items.removeLast()
        }
        
        return "B [" + items + "] T"
        
    }
    
    
    var index = 0
    mutating func next() -> Element? {
        guard index < capacity else {index = 0;return nil}
        let element = stack[index]
        index += 1
        return element
    }
    
    
}
