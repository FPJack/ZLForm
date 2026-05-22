import UIKit

// MARK: - ZLFormValidationStatus

@objcMembers
public class ZLFormValidationStatus: NSObject {
    public var msg: String = ""
    public var isValid: Bool = false
    public weak var rowDescriptor: ZLFormRowDescriptor?
    
    public init(msg: String, status: Bool, rowDescriptor: ZLFormRowDescriptor?) {
        self.msg = msg
        self.isValid = status
        self.rowDescriptor = rowDescriptor
        super.init()
    }
    
    @objc public class func formValidationStatus(msg: String, status: Bool, rowDescriptor: ZLFormRowDescriptor) -> ZLFormValidationStatus {
        return ZLFormValidationStatus(msg: msg, status: status, rowDescriptor: rowDescriptor)
    }
}

// MARK: - ZLFormValidator

@objcMembers
public class ZLFormValidator: NSObject {
    public var msg: String = ""
    public var validationBlock: ((Any?) -> Bool)?
    
    public init(msg: String, validationBlock: @escaping (Any?) -> Bool) {
        self.msg = msg
        self.validationBlock = validationBlock
        super.init()
    }
    
    public func validate(_ rowDescriptor: ZLFormRowDescriptor) -> ZLFormValidationStatus {
        var isValid = true
        if rowDescriptor.required {
            if let block = validationBlock {
                isValid = block(rowDescriptor.value)
            }
        }
        return ZLFormValidationStatus(msg: msg, status: isValid, rowDescriptor: rowDescriptor)
    }
}
