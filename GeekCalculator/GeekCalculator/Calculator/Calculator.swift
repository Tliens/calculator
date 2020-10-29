//
//  Calculator.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

enum Operator {
    case addition
    case subtraction
    case multiplication
    case division
}

enum CalculatorCommand {
    case clear
    case changeSign
    case percent
    case operation(Operator)
    case equal
    case addNumber(Character)
    case addDot
}

enum CalculatorState {
    case oneOperand(screen: String)
    case oneOperandAndOperator(operand: Double, operator: Operator,screen: String)
    case twoOperandsAndOperator(operand: Double, operator: Operator, screen: String)
}

// 是否有效点击了 =
var CalculatorClickEqual = false
var CalculatorFloatCount = 0

extension CalculatorState {
    static let initial = CalculatorState.oneOperand(screen: "0")

    func mapScreen(transform: (String) -> String) -> CalculatorState {
        switch self {
        case let .oneOperand(screen):
            if CalculatorClickEqual{
                CalculatorClickEqual = false
                return .oneOperand(screen: transform("0"))
            }else{
                return .oneOperand(screen: transform(screen))
            }
        case let .oneOperandAndOperator(operand, operat, screen):
            return .twoOperandsAndOperator(operand: operand, operator: operat, screen: transform(screen))
        case let .twoOperandsAndOperator(operand, operat, screen):
            return .twoOperandsAndOperator(operand: operand, operator: operat, screen: transform(screen))
        }
    }

    var screen: String {
        switch self {
        case let .oneOperand(screen):
            return screen
        case let .oneOperandAndOperator(_, _, screen):
            return screen
        case let .twoOperandsAndOperator(_, _, screen):
            return screen
        }
    }

    var sign: String {
        switch self {
        case .oneOperand:
            return ""
        case let .oneOperandAndOperator(_, o,_):
            return o.sign
        case let .twoOperandsAndOperator(_, o, _):
            return o.sign
        }
    }
    
    
}


extension CalculatorState {
    static func reduce(state: CalculatorState, _ x: CalculatorCommand) -> CalculatorState {
        switch x {
        case .clear:
            return CalculatorState.initial
        case .addNumber(let c):
            return state.mapScreen { $0.effective == "0" ? String(c) : $0 + String(c) }
        case .addDot:
            return state.mapScreen { $0.effective.range(of: ".") == nil ? $0 + "." : $0 }
        case .changeSign:
            return state.mapScreen { char -> String in
                if char.count > 0,Int(char.effective) != 0,Int(char.effective) != nil{
                    let array = char.split(separator: " ")
                    if array.count > 1{
                        var temp = char
                        temp.removeLast()
                        return temp + String(format: "%.\(CalculatorFloatCount)f", -(Double(char.effective) ?? 0))
                    }else{
                        return String(format: "%.\(CalculatorFloatCount)f", -(Double(char.effective) ?? 0))
                    }
                }else{
                    return char
                }
            }
        case .percent:
            return state.mapScreen { char -> String in
                if char.count > 0,Int(char.effective) != 0{
                    let array = char.split(separator: " ")
                    if array.count > 1{
                        var temp = char
                        temp.removeLast()
                        if char.hasDecimals{
                            return temp + String(format: "%.\(CalculatorFloatCount)f", (Double(char.effective) ?? 0.0) / 100.0)
                        }else{
                            return temp + String(format: "%.0f", (Double(char.effective) ?? 0.0) / 100.0)
                        }
                    }else{
                        if char.hasDecimals{
                            return String(format: "%.\(CalculatorFloatCount)f", (Double(char.effective) ?? 0.0) / 100.0)
                        }else{
                            return String(format: "%.0f", (Double(char.effective) ?? 0.0) / 100.0)
                        }
                    }
                }else{
                    return "0"
                }
            }
        case .operation(let o):
            switch state {
            case let .oneOperand(screen):
                if CalculatorClickEqual{
                    return .oneOperandAndOperator(operand: screen.effective.doubleValue, operator: o, screen: screen.effective + o.sign)
                }else{
                    return .oneOperandAndOperator(operand: screen.doubleValue, operator: o, screen: screen + o.sign)
                }
            case let .oneOperandAndOperator(operand, _,screen):
                let newscreen = screen.removeToNumber
                return .oneOperandAndOperator(operand: operand, operator: o, screen: newscreen + o.sign)
            case let .twoOperandsAndOperator(operand, oldOperator, screen):
                let newscreen = screen.removeToNumber
                return .twoOperandsAndOperator(operand: oldOperator.perform(operand, screen.effective.doubleValue), operator: o, screen: newscreen + o.sign)
            }
        case .equal:
            switch state {
            case let .twoOperandsAndOperator(operand, operat, screen):
                let result = operat.perform(operand, screen.effective.doubleValue)
                CalculatorClickEqual = true
                if operat != .division{
                    if screen.hasDecimals{
                        return .oneOperand(screen: screen + " = " + String(format: "%.\(CalculatorFloatCount)f", result))
                    }else{
                        return .oneOperand(screen: screen + " = " + String(format: "%.0f", result))
                    }
                }else{
                    return .oneOperand(screen: screen + " = " + String(format: "%.4f", result))
                }
                
            default:
                return state
            }
        }
    }
}
extension String{
    var effective:String{
        let arr = self.split(separator: " ")
        if let last = arr.last{
            return String(last)
        }else{
            return self
        }
    }
    var hasDecimals:Bool{
        let arr = self.split(separator: " ")
        var isDecimals = false
        CalculatorFloatCount = 0
        for item in arr{
            let childs = item.split(separator: ".")
            if childs.count > 1,Int(childs[1])! > 0{
                CalculatorFloatCount = max(childs[1].count, CalculatorFloatCount)
                isDecimals =  true
            }
        }
        return isDecimals
    }
    //"3 + " 移除 " + "
    var removeThree:String{
        var new = self
        new.removeLast()
        new.removeLast()
        new.removeLast()
        return new
    }
    var removeToNumber:String{
        var new = self
        while Int(String(new.last!)) == nil {
            new.removeLast()
        }
        return new
    }
}
extension Operator {
    var sign: String {
        switch self {
        case .addition:         return " + "
        case .subtraction:      return " - "
        case .multiplication:   return " × "
        case .division:         return " ÷ "
        }
    }
    
    var perform: (Double, Double) -> Double {
        switch self {
        case .addition:         return (+)
        case .subtraction:      return (-)
        case .multiplication:   return (*)
        case .division:         return (/)
        }
    }
}

private extension String {
    var doubleValue: Double {
        guard let double = Double(self) else {
           return Double.infinity
        }
        return double
    }
}
