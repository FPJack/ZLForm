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
    
    public private(set) var allSections: [ZLFormSectionDescriptor] = []
    
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
        allSections.sort { $0.tag < $1.tag }
        for section in allSections {
            section.sortRowsByTagIfNeeded()
        }
    }
    
    private func buildVisibleTarget() -> [ArraySection<ZLFormSectionDescriptor, ZLFormRowDescriptor>] {
        return allSections
            .filter { !$0.hidden }
            .map { section in
                var visibleRows = section.formRows.filter { !$0.hidden }
                if sortByTag {
                    visibleRows.sort { $0.tag < $1.tag }
                }
                return ArraySection(model: section, elements: visibleRows)
            }
    }
    

    private func performDiffUpdate(target: [ArraySection<ZLFormSectionDescriptor, ZLFormRowDescriptor>]) {
        guard let tableView = tableView else {
            formSections = target
            return
        }
        let changeset = StagedChangeset(source: formSections, target: target)
        tableView.reload(using: changeset, with: .automatic) { [weak self] data in
            self?.formSections = data
        }
        // Update all section background views after diff completes
        layoutAllSectionBackgroundViews()
    }
    
    /// Recomputes visibility and applies animated diff to tableView.
    /// Call this after changing `hidden` on any section or row.
    public func reloadVisibility() {
        let target = buildVisibleTarget()
        performDiffUpdate(target: target)
    }
    
    public func addFormSection(_ formSection: ZLFormSectionDescriptor) {
        guard !allSections.contains(where: { $0 === formSection }) else { return }
        formSection.formDescriptor = self
        allSections.append(formSection)
        sortSectionsIfNeeded()
        let target = buildVisibleTarget()
        performDiffUpdate(target: target)
        delegate?.formDescriptor?(self, formSectionHasBeenAdded: formSection, at: UInt(formSections.firstIndex(where: { $0.model === formSection }) ?? 0))
    }
    
    public func addFormSection(_ formSection: ZLFormSectionDescriptor, afterSection: ZLFormSectionDescriptor) {
        guard let idx = allSections.firstIndex(where: { $0 === afterSection }) else { return }
        formSection.formDescriptor = self
        allSections.insert(formSection, at: idx + 1)
        sortSectionsIfNeeded()
        let target = buildVisibleTarget()
        performDiffUpdate(target: target)
        delegate?.formDescriptor?(self, formSectionHasBeenAdded: formSection, at: UInt(formSections.firstIndex(where: { $0.model === formSection }) ?? 0))
    }
    
    public func addFormSection(_ formSection: ZLFormSectionDescriptor, beforeSection: ZLFormSectionDescriptor) {
        guard let idx = allSections.firstIndex(where: { $0 === beforeSection }) else { return }
        formSection.formDescriptor = self
        allSections.insert(formSection, at: idx)
        sortSectionsIfNeeded()
        let target = buildVisibleTarget()
        performDiffUpdate(target: target)
        delegate?.formDescriptor?(self, formSectionHasBeenAdded: formSection, at: UInt(formSections.firstIndex(where: { $0.model === formSection }) ?? 0))
    }
    
    public func removeFormSection(at index: UInt) {
        let idx = Int(index)
        guard idx < allSections.count else { return }
        let section = allSections[idx]
        allSections.remove(at: idx)
        sortSectionsIfNeeded()
        let target = buildVisibleTarget()
        performDiffUpdate(target: target)
        delegate?.formDescriptor?(self, formSectionHasBeenRemoved: section, at: index)
    }
    
    public func removeFormSection(_ formSection: ZLFormSectionDescriptor) {
        guard let idx = allSections.firstIndex(where: { $0 === formSection }) else { return }
        allSections.remove(at: idx)
        sortSectionsIfNeeded()
        let target = buildVisibleTarget()
        performDiffUpdate(target: target)
        delegate?.formDescriptor?(self, formSectionHasBeenRemoved: formSection, at: UInt(idx))
    }
    
    // MARK: - Row Management (convenience)
    
    public func addFormRow(_ formRow: ZLFormRowDescriptor, beforeRow: ZLFormRowDescriptor) {
        guard let section = beforeRow.sectionDescriptor else { return }
        section.addFormRow(formRow, beforeRow: beforeRow)
        sortSectionsIfNeeded()
    }
    
    public func addFormRow(_ formRow: ZLFormRowDescriptor, beforeRowTag tag: String) {
        guard let targetRow = self.formRow(tag: tag) else { return }
        addFormRow(formRow, beforeRow: targetRow)
        sortSectionsIfNeeded()
    }
    
    public func addFormRow(_ formRow: ZLFormRowDescriptor, afterRow: ZLFormRowDescriptor) {
        guard let section = afterRow.sectionDescriptor else { return }
        section.addFormRow(formRow, afterRow: afterRow)
        sortSectionsIfNeeded()
    }
    
    public func addFormRow(_ formRow: ZLFormRowDescriptor, afterRowTag tag: String) {
        guard let targetRow = self.formRow(tag: tag) else { return }
        addFormRow(formRow, afterRow: targetRow)
        sortSectionsIfNeeded()
    }
    
    public func removeFormRow(_ formRow: ZLFormRowDescriptor) {
        formRow.sectionDescriptor?.removeFormRow(formRow)
        sortSectionsIfNeeded()
    }
    
    public func removeFormRow(tag: String) {
        guard let row = formRow(tag: tag) else { return }
        removeFormRow(row)
        sortSectionsIfNeeded()
    }
    
    public func formRow(tag: String) -> ZLFormRowDescriptor? {
        for section in allSections {
            if let row = section.formRow(tag: tag) {
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
              let rowIdx = formSections[sectionIdx].elements.firstIndex(of: formRow) else { return nil }
        return IndexPath(row: rowIdx, section: sectionIdx)
    }
    
    public func reloadFormSection(_ formSection: ZLFormSectionDescriptor) {
        guard let idx = formSections.firstIndex(where: { $0.model === formSection }) else { return }
        tableView?.reloadSections(IndexSet(integer: idx), with: .automatic)
    }
    
    public func syncAndReloadSection(_ formSection: ZLFormSectionDescriptor) {
        let target = buildVisibleTarget()
        guard let tableView = tableView else {
            formSections = target
            return
        }
        let changeset = StagedChangeset(source: formSections, target: target)
        tableView.reload(using: changeset, with: .automatic) { [weak self] data in
            self?.formSections = data
        }
        layoutAllSectionBackgroundViews()
    }
    
    // MARK: - Form Values
    
    public func formValues() -> [String: Any] {
        var result: [String: Any] = [:]
        for section in allSections {
            for row in section.formRows {
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
        for section in allSections {
            for row in section.formRows {
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
        for section in allSections {
            for row in section.formRows {
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
        return formSections[section].elements.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = formSections[indexPath.section].elements[indexPath.row]
        let cell = row.cell
        
        row.updateCellBlock?(cell, row.value, row)
        cell.update()
        
        delegate?.formDescriptor?(self, updateFormRow: row)
        
        let nCell = cell as! ZLFormBaseCell
        nCell.titleLabel.text = row.title
        nCell.detailLabel.text = row.value as? String ?? row.placeholderValue as? String
        
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = formSections[indexPath.section].elements[indexPath.row]
        return row.effectiveHeight()
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = formSections[indexPath.section].elements[indexPath.row]
        return row.height > 0 ? row.height : 44.0
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let h = formSections[section].model.headerHeight
        return h > 0 ? h : UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        let h = formSections[section].model.headerHeight
        return h > 0 ? h : 10.0
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sec = formSections[section].model
        return sec.headerViewBlock?(sec) ?? UIView()
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let h = formSections[section].model.footerHeight
        return h > 0 ? h : UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        let h = formSections[section].model.footerHeight
        return h > 0 ? h : 10.0
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sec = formSections[section].model
        return sec.footerViewBlock?(sec) ?? UIView()
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return formSections[section].model.tag
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = formSections[indexPath.section].elements[indexPath.row]
        delegate?.formDescriptor?(self, didSelectFormRow: row)
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let row = formSections[indexPath.section].elements[indexPath.row]
        delegate?.formDescriptor?(self, deselectFormRow: row)
    }
    
    // MARK: - Section Background View
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        layoutSectionBackgroundView(for: section, in: tableView)
    }
    
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        layoutSectionBackgroundView(for: section, in: tableView)
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let sectionModel = formSections[indexPath.section].model
        if sectionModel.sectionBackgroundView != nil {
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
        }
        layoutSectionBackgroundView(for: indexPath.section, in: tableView)
    }
    
    private func layoutSectionBackgroundView(for section: Int, in tableView: UITableView) {
        guard section < formSections.count else { return }
        let sectionModel = formSections[section].model
        guard let bgView = sectionModel.sectionBackgroundView else { return }
        
        if bgView.superview != tableView {
            tableView.addSubview(bgView)
        }
        tableView.sendSubviewToBack(bgView)
        
        for s in formSections {
            if let bg = s.model.sectionBackgroundView, bg.superview == tableView {
                tableView.sendSubviewToBack(bg)
            }
        }

        let sectionRect = tableView.rect(forSection: section);
        let insets = sectionModel.sectionBackgroundInsets
        UIView.animate(withDuration: 0.1) {
            bgView.frame = CGRect(
                x: sectionRect.origin.x + insets.left,
                y: sectionRect.origin.y + insets.top,
                width: sectionRect.width - insets.left - insets.right,
                height: sectionRect.height - insets.top - insets.bottom
            )
        }
    }
    
    private func layoutAllSectionBackgroundViews() {
        guard let tableView = tableView else { return }
        
        for section in allSections {
            guard let bgView = section.sectionBackgroundView else { continue }
            let isVisible = formSections.contains(where: { $0.model === section })
            bgView.isHidden = !isVisible
        }
        
        for idx in 0..<formSections.count {
            layoutSectionBackgroundView(for: idx, in: tableView)
        }
    }
}
