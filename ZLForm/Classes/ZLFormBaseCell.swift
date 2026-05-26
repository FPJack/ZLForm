import UIKit

// MARK: - ZLFormDescriptorCell Protocol

@objc public protocol ZLFormDescriptorCell: NSObjectProtocol {
    var rowDescriptor: ZLFormRowDescriptor? { get set }
    @objc optional func configure()
    @objc optional func update()
    @objc optional func cellHeight(for rowDescriptor: ZLFormRowDescriptor) -> CGFloat
    @objc optional func formDescriptorCellDidSelected(with formController: UIViewController)
}

// MARK: - ZLFormBaseCell

@objc
open class ZLFormBaseCell: UITableViewCell, ZLFormDescriptorCell {
    @objc public weak var rowDescriptor: ZLFormRowDescriptor?
    
   
    public required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        configure()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
        configure()
    }
    
    open func setupSubviews() {
        
    }
    
    open func configure() {}
    
    open func update() {}
}
