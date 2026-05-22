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
    
    @objc public private(set) var titleLabel: UILabel!
    @objc public private(set) var detailLabel: UILabel!
    
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
    
    private func setupSubviews() {
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)

        contentView.addSubview(titleLabel)
        
        detailLabel = UILabel()
        detailLabel.numberOfLines = 0
        detailLabel.font = UIFont.systemFont(ofSize: 15)
        detailLabel.textColor = .gray
        detailLabel.textAlignment = .right
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(detailLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.4),
            
            detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            detailLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            detailLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            detailLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
        ])
    }
    
    open func configure() {}
    
    open func update() {}
}
