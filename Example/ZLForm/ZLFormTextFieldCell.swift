import UIKit
import ZLForm
import SnapKit

@objcMembers
public class ZLFormTextFieldCell: ZLFormBaseCell, UITextFieldDelegate {
    
    public private(set) var textField: UITextField!
    
    open override func configure() {
        super.configure()
        selectionStyle = .none
        
        textField = UITextField()
        textField.textAlignment = .right
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.textColor = .darkText
        textField.returnKeyType = .done
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        contentView.addSubview(textField)
        
        // Hide detailLabel
        detailLabel.isHidden = true
        
        titleLabel.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
        }
        
        textField.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(36)
        }
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
