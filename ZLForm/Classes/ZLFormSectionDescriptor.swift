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
    
    public weak var formDescriptor: ZLFormDescriptor?
    
    public private(set) var formRows: [ZLFormRowDescriptor] = []
    
    public var hidden: Bool = false
    
    /// section 展示出来的时候赋值，默认为 -1，表示未赋值。ZLFormDescriptor 会在展示 section 的时候赋值为当前 section 在 formSections 中的 index。
    public var section: Int = -1

    public var tag: String = ""
    
    public var title: String?
    
    @objc public dynamic var value: Any?


    // MARK: - Init
    
    private override init() {
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
        descriptor.reloadDiff()
        if let sectionIndex = descriptor.formSections.firstIndex(where: { $0.model === self }) {
            let indexPath = IndexPath(row: index, section: sectionIndex)
            descriptor.delegate?.formDescriptor?(descriptor, formRowHasBeenAdded: formRow, at: indexPath)
        }
    }
    
    private func notifyRowRemoved(_ formRow: ZLFormRowDescriptor, at index: Int) {
        guard let descriptor = formDescriptor else { return }
        descriptor.reloadDiff()
        if let sectionIndex = descriptor.formSections.firstIndex(where: { $0.model === self }) {
            let indexPath = IndexPath(row: index, section: sectionIndex)
            descriptor.delegate?.formDescriptor?(descriptor, formRowHasBeenRemoved: formRow, at: indexPath)
        }
    }
    
    // MARK: - Sorting
    
    /// Sorts formRows by tag. Called by ZLFormDescriptor when sortByTag is true.
    public func sortRowsByTagIfNeeded() {
        formRows.sort { $0.tag < $1.tag }
    }
    
    // MARK: - Differentiable
    private let uuid = UUID().uuidString

    public var differenceIdentifier: String {
        return tag.isEmpty ? uuid : tag
    }
    public var contentEqualHandler: ((ZLFormSectionDescriptor, ZLFormSectionDescriptor) -> Bool)?

    public func isContentEqual(to source: ZLFormSectionDescriptor) -> Bool {
        if let handler = contentEqualHandler ?? source.contentEqualHandler {
            return handler(self, source)
        }
        return tag == source.tag &&
               title == source.title &&
               (value as? NSObject)?.isEqual(source.value) == true

    }
}
