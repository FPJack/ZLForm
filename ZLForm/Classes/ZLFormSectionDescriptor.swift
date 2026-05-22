import UIKit
import DifferenceKit
public typealias ZLFormSectionHeaderFooterViewBlock = (_ sectionDescriptor: ZLFormSectionDescriptor) -> UIView?

@objcMembers
public class ZLFormSectionDescriptor: NSObject,Differentiable {
    
    public var headerHeight: CGFloat = 0
    public var headerViewBlock: ZLFormSectionHeaderFooterViewBlock?
    
    public var footerHeight: CGFloat = 0
    public var footerViewBlock: ZLFormSectionHeaderFooterViewBlock?
    
    public var sectionBackgroundView: UIView?
    
    public var sectionBackgroundInsets: UIEdgeInsets = .zero
    
    public var insertAnimation: UITableView.RowAnimation = .automatic
    public var deleteAnimation: UITableView.RowAnimation = .automatic
    
    public weak var formDescriptor: ZLFormDescriptor?
    
    public private(set) var formRows: [ZLFormRowDescriptor] = []
    
    public var hidden: Bool = false

    public var tag: String = ""
    
    // MARK: - Init
    
    public override init() {
        super.init()
    }
    
    public init(tag: String) {
        super.init()
        self.tag = tag
    }
    
    // MARK: - Row Management
    
    public func addFormRow(_ formRow: ZLFormRowDescriptor) {
        guard !formRows.contains(formRow) else { return }
        formRow.sectionDescriptor = self
        let index = formRows.count
        formRows.append(formRow)
        notifyRowAdded(formRow, at: index)
    }
    
    public func addFormRow(_ formRow: ZLFormRowDescriptor, afterRow: ZLFormRowDescriptor) {
        guard let index = formRows.firstIndex(of: afterRow) else { return }
        formRow.sectionDescriptor = self
        let insertIndex = index + 1
        formRows.insert(formRow, at: insertIndex)
        notifyRowAdded(formRow, at: insertIndex)
    }
    
    public func addFormRow(_ formRow: ZLFormRowDescriptor, beforeRow: ZLFormRowDescriptor) {
        guard let index = formRows.firstIndex(of: beforeRow) else { return }
        formRow.sectionDescriptor = self
        formRows.insert(formRow, at: index)
        notifyRowAdded(formRow, at: index)
    }
    
    public func removeFormRow(_ formRow: ZLFormRowDescriptor) {
        guard let index = formRows.firstIndex(of: formRow) else { return }
        formRows.remove(at: index)
        notifyRowRemoved(formRow, at: index)
    }
    
    public func removeFormRow(tag: String) {
        guard let row = formRow(tag: tag) else { return }
        removeFormRow(row)
    }
    
    public func formRow(tag: String) -> ZLFormRowDescriptor? {
        return formRows.first { $0.tag == tag }
    }
    
    // MARK: - Notifications
    
    private func notifyRowAdded(_ formRow: ZLFormRowDescriptor, at index: Int) {
        guard let descriptor = formDescriptor else { return }
        descriptor.syncAndReloadSection(self)
        if let sectionIndex = descriptor.formSections.firstIndex(where: { $0.model === self }) {
            let indexPath = IndexPath(row: index, section: sectionIndex)
            descriptor.delegate?.formDescriptor?(descriptor, formRowHasBeenAdded: formRow, at: indexPath)
        }
    }
    
    private func notifyRowRemoved(_ formRow: ZLFormRowDescriptor, at index: Int) {
        guard let descriptor = formDescriptor else { return }
        descriptor.syncAndReloadSection(self)
        if let sectionIndex = descriptor.formSections.firstIndex(where: { $0.model === self }) {
            let indexPath = IndexPath(row: index, section: sectionIndex)
            descriptor.delegate?.formDescriptor?(descriptor, formRowHasBeenRemoved: formRow, at: indexPath)
        }
    }
    
    // MARK: - Differentiable
    public var differenceIdentifier: String {
        return tag
    }
    public func isContentEqual(to source: ZLFormSectionDescriptor) -> Bool {
        return tag == source.tag
    }
}
