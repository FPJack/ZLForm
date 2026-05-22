import UIKit
import DifferenceKit
// MARK: - ZLFormDescriptorDelegate

@objc public protocol ZLFormDescriptorDelegate: NSObjectProtocol {
    @objc optional func formDescriptor(_ form: ZLFormDescriptor, didSelectFormRow formRow: ZLFormRowDescriptor)
    @objc optional func formDescriptor(_ form: ZLFormDescriptor, deselectFormRow formRow: ZLFormRowDescriptor)
    @objc optional func formDescriptor(_ form: ZLFormDescriptor, updateFormRow formRow: ZLFormRowDescriptor)
    @objc optional func formDescriptor(_ form: ZLFormDescriptor, showFormValidationError status: ZLFormValidationStatus)
    @objc optional func validationSuccess(for form: ZLFormDescriptor)
    @objc optional func formDescriptor(_ form: ZLFormDescriptor, showFormValidationErrors status: [ZLFormValidationStatus])
    @objc optional func validationAllSuccess(for form: ZLFormDescriptor)
    @objc optional func formDescriptor(_ form: ZLFormDescriptor, formSectionHasBeenRemoved formSection: ZLFormSectionDescriptor, at index: UInt)
    @objc optional func formDescriptor(_ form: ZLFormDescriptor, formSectionHasBeenAdded formSection: ZLFormSectionDescriptor, at index: UInt)
    @objc optional func formDescriptor(_ form: ZLFormDescriptor, formRowHasBeenAdded formRow: ZLFormRowDescriptor, at indexPath: IndexPath)
    @objc optional func formDescriptor(_ form: ZLFormDescriptor, formRowHasBeenRemoved formRow: ZLFormRowDescriptor, at indexPath: IndexPath)
}

// MARK: - ZLFormDescriptor

@objcMembers
public class ZLFormDescriptor: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    public private(set) var formSections: [ArraySection<ZLFormSectionDescriptor, ZLFormRowDescriptor>] = []
    
    /// ObjC-compatible accessor that returns section descriptors
    @objc public var sectionDescriptors: [ZLFormSectionDescriptor] {
        return formSections.map { $0.model }
    }
    
    public weak var delegate: ZLFormDescriptorDelegate?
    
    public weak var tableView: UITableView? {
        didSet {
            tableView?.dataSource = self
            tableView?.delegate = self
        }
    }
    
    public var sortByTag: Bool = false
    
    // MARK: - Init
    
    public override init() {
        super.init()
    }
    
    @objc public class func formDescriptor() -> ZLFormDescriptor {
        return ZLFormDescriptor()
    }
    
    // MARK: - Section Management
    
    private func sortSectionsIfNeeded() {
        guard sortByTag else { return }
        formSections.sort { $0.model.tag < $1.model.tag }
    }
    
    /// Computes a DifferenceKit diff between current formSections and the target,
    /// and applies animated updates. The data source is only mutated inside the setData closure.
    private func performDiffUpdate(target: [ArraySection<ZLFormSectionDescriptor, ZLFormRowDescriptor>]) {
        guard let tableView = tableView else {
            formSections = target
            return
        }
        let changeset = StagedChangeset(source: formSections, target: target)
        tableView.reload(using: changeset, with: .automatic) { [weak self] data in
            self?.formSections = data
        }
    }
    
    public func addFormSection(_ formSection: ZLFormSectionDescriptor) {
        guard !formSections.contains(where: { $0.model === formSection }) else { return }
        formSection.formDescriptor = self
        var target = formSections
        let arraySection = ArraySection(model: formSection, elements: formSection.formRows)
        target.append(arraySection)
        if sortByTag {
            target.sort { $0.model.tag < $1.model.tag }
        }
        performDiffUpdate(target: target)
        delegate?.formDescriptor?(self, formSectionHasBeenAdded: formSection, at: UInt(formSections.firstIndex(where: { $0.model === formSection }) ?? 0))
    }
    
    public func addFormSection(_ formSection: ZLFormSectionDescriptor, afterSection: ZLFormSectionDescriptor) {
        guard let idx = formSections.firstIndex(where: { $0.model === afterSection }) else { return }
        formSection.formDescriptor = self
        let insertIndex = idx + 1
        var target = formSections
        let arraySection = ArraySection(model: formSection, elements: formSection.formRows)
        target.insert(arraySection, at: insertIndex)
        performDiffUpdate(target: target)
        delegate?.formDescriptor?(self, formSectionHasBeenAdded: formSection, at: UInt(insertIndex))
    }
    
    public func addFormSection(_ formSection: ZLFormSectionDescriptor, beforeSection: ZLFormSectionDescriptor) {
        guard let idx = formSections.firstIndex(where: { $0.model === beforeSection }) else { return }
        formSection.formDescriptor = self
        var target = formSections
        let arraySection = ArraySection(model: formSection, elements: formSection.formRows)
        target.insert(arraySection, at: idx)
        performDiffUpdate(target: target)
        delegate?.formDescriptor?(self, formSectionHasBeenAdded: formSection, at: UInt(idx))
    }
    
    public func removeFormSection(at index: UInt) {
        let idx = Int(index)
        guard idx < formSections.count else { return }
        let section = formSections[idx].model
        var target = formSections
        target.remove(at: idx)
        performDiffUpdate(target: target)
        delegate?.formDescriptor?(self, formSectionHasBeenRemoved: section, at: index)
    }
    
    public func removeFormSection(_ formSection: ZLFormSectionDescriptor) {
        guard let idx = formSections.firstIndex(where: { $0.model === formSection }) else { return }
        var target = formSections
        target.remove(at: idx)
        performDiffUpdate(target: target)
        delegate?.formDescriptor?(self, formSectionHasBeenRemoved: formSection, at: UInt(idx))
    }
    
    // MARK: - Row Management (convenience)
    
    public func addFormRow(_ formRow: ZLFormRowDescriptor, beforeRow: ZLFormRowDescriptor) {
        guard let section = beforeRow.sectionDescriptor else { return }
        section.addFormRow(formRow, beforeRow: beforeRow)
    }
    
    public func addFormRow(_ formRow: ZLFormRowDescriptor, beforeRowTag tag: String) {
        guard let targetRow = self.formRow(tag: tag) else { return }
        addFormRow(formRow, beforeRow: targetRow)
    }
    
    public func addFormRow(_ formRow: ZLFormRowDescriptor, afterRow: ZLFormRowDescriptor) {
        guard let section = afterRow.sectionDescriptor else { return }
        section.addFormRow(formRow, afterRow: afterRow)
    }
    
    public func addFormRow(_ formRow: ZLFormRowDescriptor, afterRowTag tag: String) {
        guard let targetRow = self.formRow(tag: tag) else { return }
        addFormRow(formRow, afterRow: targetRow)
    }
    
    public func removeFormRow(_ formRow: ZLFormRowDescriptor) {
        formRow.sectionDescriptor?.removeFormRow(formRow)
    }
    
    public func removeFormRow(tag: String) {
        guard let row = formRow(tag: tag) else { return }
        removeFormRow(row)
    }
    
    public func formRow(tag: String) -> ZLFormRowDescriptor? {
        for section in formSections {
            if let row = section.model.formRow(tag: tag) {
                return row
            }
        }
        return nil
    }
    
    // MARK: - Reload
    
    public func reloadFormRow(_ formRow: ZLFormRowDescriptor) {
        guard let indexPath = indexPath(of: formRow) else { return }
        tableView?.reloadRows(at: [indexPath], with: .none)
    }
    
    public func indexPath(of formRow: ZLFormRowDescriptor) -> IndexPath? {
        guard let section = formRow.sectionDescriptor,
              let sectionIdx = formSections.firstIndex(where: { $0.model === section }),
              let rowIdx = section.formRows.firstIndex(of: formRow) else { return nil }
        return IndexPath(row: rowIdx, section: sectionIdx)
    }
    
    public func reloadFormSection(_ formSection: ZLFormSectionDescriptor) {
        guard let idx = formSections.firstIndex(where: { $0.model === formSection }) else { return }
        tableView?.reloadSections(IndexSet(integer: idx), with: .automatic)
    }
    
    /// Sync formRows into the ArraySection elements and perform DifferenceKit diff reload
    public func syncAndReloadSection(_ formSection: ZLFormSectionDescriptor) {
        guard let idx = formSections.firstIndex(where: { $0.model === formSection }) else { return }
        var target = formSections
        target[idx] = ArraySection(model: formSection, elements: formSection.formRows)
        guard let tableView = tableView else {
            formSections = target
            return
        }
        let changeset = StagedChangeset(source: formSections, target: target)
        tableView.reload(using: changeset, with: .automatic) { [weak self] data in
            self?.formSections = data
        }
    }
    
    // MARK: - Form Values
    
    public func formValues() -> [String: Any] {
        var result: [String: Any] = [:]
        for section in formSections {
            for row in section.model.formRows {
                if row.ignoreValue { continue }
                let value = row.valueForStorage()
                let key = row.key ?? row.tag
                if !key.isEmpty, let val = value {
                    result[key] = val
                }
            }
        }
        return result
    }
    
    // MARK: - Validation
    
    public func formValidationErrors() -> [ZLFormValidationStatus] {
        var result: [ZLFormValidationStatus] = []
        for section in formSections {
            for row in section.model.formRows {
                if row.ignoreValue { continue }
                let status = row.doValidation()
                if !status.isValid {
                    result.append(status)
                }
            }
        }
        return result
    }
    
    public func validation() {
        for section in formSections {
            for row in section.model.formRows {
                if row.ignoreValue { continue }
                let status = row.doValidation()
                if !status.isValid {
                    delegate?.formDescriptor?(self, showFormValidationError: status)
                    return
                }
            }
        }
        delegate?.validationSuccess?(for: self)
    }
    
    public func validationAll() {
        let errors = formValidationErrors()
        if errors.count > 0 {
            delegate?.formDescriptor?(self, showFormValidationErrors: errors)
        } else {
            delegate?.validationAllSuccess?(for: self)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return formSections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formSections[section].model.formRows.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = formSections[indexPath.section].model
        let row = section.formRows[indexPath.row]
        let cell = row.cell
        print(row.tag);
        row.updateCellBlock?(cell, row.value, row)
        (cell as ZLFormDescriptorCell).update()
        
        delegate?.formDescriptor?(self, updateFormRow: row)
        
        cell.titleLabel.text = row.title
        cell.detailLabel.text = row.valueForDisplay() as? String
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = formSections[indexPath.section].model.formRows[indexPath.row]
        return row.effectiveHeight()
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return formSections[section].model.headerHeight
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sec = formSections[section].model
        return sec.headerViewBlock?(sec)
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return formSections[section].model.footerHeight
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sec = formSections[section].model
        return sec.footerViewBlock?(sec)
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return formSections[section].model.tag
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = formSections[indexPath.section].model.formRows[indexPath.row]
        delegate?.formDescriptor?(self, didSelectFormRow: row)
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let row = formSections[indexPath.section].model.formRows[indexPath.row]
        delegate?.formDescriptor?(self, deselectFormRow: row)
    }
}
