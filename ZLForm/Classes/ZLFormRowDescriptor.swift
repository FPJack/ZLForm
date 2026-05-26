import UIKit
import DifferenceKit
public typealias ZLOnChangeBlock = (_ oldValue: Any?, _ newValue: Any?, _ rowDescriptor: ZLFormRowDescriptor) -> Void
public typealias ZLConfigureCellBlock = (_ cell: UITableViewCell, _ value: Any?, _ rowDescriptor: ZLFormRowDescriptor) -> Void
public typealias ZLUpdateCellBlock = (_ cell: UITableViewCell, _ value: Any?, _ rowDescriptor: ZLFormRowDescriptor) -> Void
public typealias ZLCellProviderBlock = (_ rowDescriptor: ZLFormRowDescriptor) -> UITableViewCell

public typealias ZLValueMapperBlock = (_ row: ZLFormRowDescriptor,_ value: Any?) -> Any?

///row被点击
public typealias ZLFormRowDidSelectBlock = (_ rowDescriptor: ZLFormRowDescriptor, _ indexPath: IndexPath) -> Void


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
    public var didSelectBlock: ZLFormRowDidSelectBlock?
    
    public var disabled: Bool = false
    public var ignoreValue: Bool = false

    
    public var valueMapperToDisplay: ZLValueMapperBlock?
    public var storageValueMapper: ZLValueMapperBlock?
    public var placeholderValue: Any?
    public var hidden: Bool = false

    /// cell 展示出来的时候indexPath 会被赋值，默认为 nil，ZLFormDescriptor 会在展示 cell 的时候赋值为当前 cell 在 tableView 中的 indexPath。
    public internal(set) var indexPath: IndexPath?
    
    private var _cell: UITableViewCell?
    private var validators: [ZLFormValidator] = []
    private var observation: NSKeyValueObservation?
    
    public var cell: UITableViewCell  {
        if _cell == nil {
            let cell = createCell()
            if let cell = cell as? ZLFormDescriptorCell {
                cell.rowDescriptor = self
            }
           _cell = cell
        }
        return _cell!
    }
    // MARK: - Init
    
    private override init() {
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
    
    private func createCell() -> UITableViewCell  {
        if let provider = cellProvider  {
            return provider(self)
        }
        if let cls = cellClass as? UITableViewCell.Type {
            let cell = cls.init(style: .default, reuseIdentifier: tag)
            return cell
        }
        return ZLFormBaseCell(style: .default, reuseIdentifier: tag)
    }
    
    @objc public func cellForFormController(_ formController: UIViewController) -> UITableViewCell  {
        return cell
    }
    public func effectiveHeight() -> CGFloat {
        if let formCell = cell as? ZLFormDescriptorCell, let cellHeight = formCell.cellHeight?(for: self), cellHeight > 0 {
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
            return mapper(self,value)
        }
        return value
    }
    
    @objc public func valueForStorage() -> Any? {
        if let mapper = storageValueMapper {
            return mapper(self,value)
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
    private let uuid = UUID().uuidString
    
    public var differenceIdentifier: String {
        return tag.isEmpty ? uuid : tag
    }
    
    public var contentEqualHandler: ((ZLFormRowDescriptor, ZLFormRowDescriptor) -> Bool)?

    public func isContentEqual(to source: ZLFormRowDescriptor) -> Bool {

        if let handler = contentEqualHandler ?? source.contentEqualHandler {
            return handler(self, source)
        }
        return tag == source.tag &&
               title == source.title &&
               (value as? NSObject)?.isEqual(source.value) == true
    }
}
