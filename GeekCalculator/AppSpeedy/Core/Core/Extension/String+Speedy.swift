//
//  String+Speedy.swift
//  WorldClock
//
//  Created by 2020 on 2020/10/20.
//

import UIKit
extension String{
    // 根据字符串计算宽度或高度
    func size(WithFont font: UIFont, ConstrainedToWidth width: CGFloat) -> CGSize {
        let size = CGSize.init(width: width, height: 99999.0)
        let attributes = [NSAttributedString.Key.font : font]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let rect:CGRect = self.boundingRect(with: size, options:option, attributes: attributes,context:nil)
        return rect.size
    }
    
    /// 根据字符串计算所占高度
    func size(with attributes: [NSAttributedString.Key: Any]?, at maxWidth: CGFloat) -> CGSize {
        let rect: CGRect = self.boundingRect(with: CGSize.init(width: maxWidth, height: 999999), options:.usesLineFragmentOrigin, attributes:attributes,context:nil)
        return rect.size
    }
    
    /// 计算字符个数（英文 = 1，数字 = 1，汉语 = 2）
    func speedyNumberOfChars() -> Int {
        var number = 0
        guard self.count > 0 else {
            return 0
        }
        
        for i in 0...self.count - 1 {
            let c: unichar = (self as NSString).character(at: i)
            if (c >= 0x4E00) {
                number += 2
            }else {
                number += 1
            }
        }
        return number
    }
    /// 根据字符个数返回截取的字符串（英文 = 1，数字 = 1，汉语 = 2）
    func speedySubString(to index: Int) -> String {
        if self.count == 0 {
            return ""
        }
        
        var number = 0
        var strings: [String] = []
        for c in self {
            let subStr: String = "\(c)"
            let num = subStr.speedyNumberOfChars()
            
            number += num
            
            if number <= index {
                strings.append(subStr)
            } else {
                break
            }
        }
        
        var resultStr: String = ""
        for str in strings {
            resultStr = resultStr + "\(str)"
        }
        
        return resultStr
    }
}
