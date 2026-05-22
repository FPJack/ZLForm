import UIKit
import ZLForm

@objcMembers
public class ZLFormTextFieldCell: ZLFormBaseCell, UITextFieldDelegate {
    
    public private(set) var textField: UITextField!
    
    open override func configure() {
        super.configure()
        selectionStyle = .none
        
        textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textAlignment = .right
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.textColor = .darkText
        textField.returnKeyType = .done
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        contentView.addSubview(textField)
        
        // Hide detailLabel
        detailLabel.isHidden = true
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 80),
            
            textField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textField.heightAnchor.constraint(equalToConstant: 36),
        ])
    }
    
    open override func update() {
        super.update()
        guard let row = rowDescriptor else { return }
        titleLabel.text = row.title
        textField.text = row.value as? String
        textField.placeholder = row.placeholderValue as? String
        textField.isEnabled = !row.disabled
    }
    
    // MARK: - UITextFieldDelegate
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let oldValue = rowDescriptor?.value
        rowDescriptor?.value = textField.text
        rowDescriptor?.onChangeBlock?(oldValue, textField.text, rowDescriptor!)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
