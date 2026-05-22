import UIKit
import DifferenceKit
public typealias ZLOnChangeBlock = (_ oldValue: Any?, _ newValue: Any?, _ rowDescriptor: ZLFormRowDescriptor) -> Void
public typealias ZLConfigureCellBlock = (_ cell: UITableViewCell, _ value: Any?, _ rowDescriptor: ZLFormRowDescriptor) -> Void
public typealias ZLUpdateCellBlock = (_ cell: UITableViewCell, _ value: Any?, _ rowDescriptor: ZLFormRowDescriptor) -> Void
public typealias ZLCellProviderBlock = (_ rowDescriptor: ZLFormRowDescriptor) -> (UITableViewCell & ZLFormDescriptorCell)

@objcMembers
public class ZLFormRowDescriptor: NSObject, Differentiable {
    
    public var cellClass: AnyClass?
    public var cellProvider: ZLCellProviderBlock?
    public var height: CGFloat = 0
    public var tag: String = ""
    public var key: String?
    public var title: String?
    @objc public dynamic var value: Any?
    public weak var sectionDescriptor: ZLFormSectionDescriptor?
    
    public var onChangeBlock: ZLOnChangeBlock?
    public var configureCellBlock: ZLConfigureCellBlock?
    public var updateCellBlock: ZLUpdateCellBlock?
    
    public var insertAnimation: UITableView.RowAnimation = .automatic
    public var deleteAnimation: UITableView.RowAnimation = .automatic
    
    public var disabled: Bool = false
    public var ignoreValue: Bool = false

    
    public var valueMapperToDisplay: ((Any?) -> Any?)?
    public var storageValueMapper: ((Any?) -> Any?)?
    public var placeholderValue: Any?
    public var hidden: Bool = false
    
    private var _cell: (UITableViewCell & ZLFormDescriptorCell)?
    private var validators: [ZLFormValidator] = []
    private var observation: NSKeyValueObservation?
    
    public var cell: (UITableViewCell & ZLFormDescriptorCell) {
        if _cell == nil {
            _cell = createCell()
            _cell?.rowDescriptor = self
        }
        return _cell!
    }
    // MARK: - Init
    
    public override init() {
        super.init()
        setupKVO()
    }
    
    public init(tag: String) {
        super.init()
        self.tag = tag
        setupKVO()
    }
    
    @objc public class func formRowDescriptor(tag: String) -> ZLFormRowDescriptor {
        return ZLFormRowDescriptor(tag: tag)
    }
    private func setupKVO() {
        observation = observe(\.value, options: [.old, .new]) { [weak self] _, change in
            guard let self = self, self.sectionDescriptor != nil else { return }
            let oldVal = change.oldValue as? Any
            let newVal = change.newValue as? Any
            self.onChangeBlock?(oldVal, newVal, self)
        }
    }
    
    // MARK: - Cell
    
    private func createCell() -> (UITableViewCell & ZLFormDescriptorCell) {
        if let provider = cellProvider {
            return provider(self)
        }
        if let cls = cellClass as? (UITableViewCell & ZLFormDescriptorCell).Type {
            let cell = cls.init(style: .default, reuseIdentifier: tag)
            return cell
        }
        return ZLFormBaseCell(style: .default, reuseIdentifier: tag)
    }
    
    @objc public func cellForFormController(_ formController: UIViewController) -> (UITableViewCell & ZLFormDescriptorCell) {
        return cell
    }
    public func effectiveHeight() -> CGFloat {
        if let cellHeight = (cell as ZLFormDescriptorCell).cellHeight?(for: self), cellHeight > 0 {
            return cellHeight
        }
        if height > 0 {
            return height
        }
        return UITableView.automaticDimension
    }
    
    // MARK: - Value
    
    @objc public func valueForDisplay() -> Any? {
        if let mapper = valueMapperToDisplay {
            return mapper(value)
        }
        return value
    }
    
    @objc public func valueForStorage() -> Any? {
        if let mapper = storageValueMapper {
            return mapper(value)
        }
        return value
    }
    
    // MARK: - Validators
    
    public func addValidator(_ validator: ZLFormValidator) {
        validators.append(validator)
    }
    
    public func removeValidator(_ validator: ZLFormValidator) {
        validators.removeAll { $0 === validator }
    }
    
    @objc public func addValidator(_ msg: String, validationBlock: @escaping (Any?) -> Bool) {
        let validator = ZLFormValidator(msg: msg, validationBlock: validationBlock)
        addValidator(validator)
    }
    
    @objc public func doValidation() -> ZLFormValidationStatus {
        for validator in validators {
            let status = validator.validate(self)
            if !status.isValid {
                return status
            }
        }
        return ZLFormValidationStatus(msg: "", status: true, rowDescriptor: self)
    }
    
    
    // MARK: - Differentiable
    public var differenceIdentifier: String {
        return tag
    }
    public func isContentEqual(to source: ZLFormRowDescriptor) -> Bool {
        return tag == source.tag;
    }
}