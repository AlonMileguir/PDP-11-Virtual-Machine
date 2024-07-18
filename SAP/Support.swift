

import Foundation

class Support {
    static func readTextFile(_ path: String) -> (message: String?, fileText: String?) {
        let text: String
        do {
            text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
        }
        catch {
            return ("\(error)", nil)
        }
        return(nil, text)
    }
     
     
    static func writeTextFile(_ path: String, data: String) -> String? {
        let url = NSURL.fileURL(withPath: path)
        do {
            try data.write(to: url, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            return "Failed writing to URL: \(url), Error: " + error.localizedDescription
        }
        return nil
    }

    static func splitStringIntoLines(_ expression : String) -> [String] {
        return expression.split{$0 == "\n"}.map{String($0)}
    }
    
    static func splitStringIntoParts(_ expression: String)-> [String] {
        return expression.split{$0 == " "}.map{String($0)}
    }
    
    
    static func characterToUnicodeValue(_ c: Character) -> Int{
        let s = String(c)
        return Int(s.unicodeScalars[s.unicodeScalars.startIndex].value)
    }
    static func unicodeValueToCharacter(_ n: Int) -> Character{
        return Character(UnicodeScalar(n)!)
    }
    
    static func fit(_ s : String, _ size : Int, _ right : Bool) -> String {
        var result = ""
        let sSize = s.count
        if sSize == size {
            return s
        }
        if size < sSize {
            return String(s.prefix(size))
        }
        result = s;
        var addon = "";
        let num = size - sSize;
        for _ in 0..<num {
            addon += " ";
        }
        if (right){
            return result + addon;
        }
        return addon + result;
        
    }
}
