import UIKit
import ZLForm
import SnapKit
#if canImport(ZLForm_Example)
import ZLForm_Example
#endif
@objc
public class ZLFormAutoHeightViewController: UIViewController, ZLFormDescriptorDelegate {
    
    private var tableView: UITableView!
    private var formDescriptor: ZLFormDescriptor!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "自适应高度Demo"
        view.backgroundColor = .systemGroupedBackground
        setupForm()
        setupTableView()
        
    }
    
    // MARK: - Setup
    
    private func setupForm() {
        formDescriptor = ZLFormDescriptor.formDescriptor()
        formDescriptor.delegate = self
        
        // Section 1 - 固定高度
        let section1 = ZLFormSectionDescriptor(tag: "fixedHeight")
        section1.headerViewBlock = { _ in
            let label = UILabel()
            label.text = "头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应头部高度自适应"
            label.numberOfLines = 0
            label.font = .boldSystemFont(ofSize: 16)
            return label
        }
        
        let row1 = ZLFormRowDescriptor.formRowDescriptor(tag: "fixed1")
        row1.title = "固定80pt"
        row1.value = "这行高度固定50pt" as NSString
        row1.height = 80
        row1.cellClass = ZLTableViewCell.self
        section1.addFormRow(row1)
        
        let row2 = ZLFormRowDescriptor.formRowDescriptor(tag: "fixed2")
        row2.title = "固定80pt"
        row2.value = "这行高度固定80pt" as NSString
        row2.height = 80
        row2.cellClass = ZLTableViewCell.self

        section1.addFormRow(row2)
        
        let row3 = ZLFormRowDescriptor.formRowDescriptor(tag: "fixed3")
        row3.title = "固定120pt"
        row3.value = "这行高度固定120pt，内容很多也不会撑开" as NSString
        row3.height = 120
        row3.cellClass = ZLTableViewCell.self

        section1.addFormRow(row3)
        
        formDescriptor.addFormSection(section1)
        
        // Section 2 - 自适应高度
        let section2 = ZLFormSectionDescriptor(tag: "autoHeight")
        section2.headerViewBlock = { _ in
            let container = UIView()
            
            let titleLabel = UILabel()
            titleLabel.text = "自适应高度 (不设置height，约束撑开)"
            titleLabel.font = .boldSystemFont(ofSize: 16)
            titleLabel.numberOfLines = 0
            container.addSubview(titleLabel)
            
            let subtitleLabel = UILabel()
            subtitleLabel.text = "下面的Cell没有设置height，高度完全由内部AutoLayout约束决定"
            subtitleLabel.font = .systemFont(ofSize: 13)
            subtitleLabel.textColor = .secondaryLabel
            subtitleLabel.numberOfLines = 0
            container.addSubview(subtitleLabel)
            
            titleLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(12)
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
            }
            
            subtitleLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(4)
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.bottom.equalToSuperview().offset(-12)
            }
            
            return container
        }
        
        let autoRow1 = ZLFormRowDescriptor.formRowDescriptor(tag: "auto1")
        autoRow1.title = "输入框"
        autoRow1.cellClass = ZLFormTextFieldCell.self
        autoRow1.placeholderValue = "自适应高度输入框" as NSString
        section2.addFormRow(autoRow1)
        
        let autoRow2 = ZLFormRowDescriptor.formRowDescriptor(tag: "auto2")
        autoRow2.title = "输入框2"
        autoRow2.cellClass = ZLFormTextFieldCell.self
        autoRow2.placeholderValue = "这个也是自适应" as NSString

        section2.addFormRow(autoRow2)
        
        formDescriptor.addFormSection(section2)
        
        // Section 3 - 混合使用
        let section3 = ZLFormSectionDescriptor(tag: "mixed")
        section3.headerHeight = 44
        section3.headerViewBlock = { _ in
            let label = UILabel(frame: CGRect(x: 15, y: 10, width: 300, height: 34))
            label.text = "混合使用 (固定+自适应)"
            label.font = .boldSystemFont(ofSize: 16)
            return label
        }
        
        let mixRow1 = ZLFormRowDescriptor.formRowDescriptor(tag: "mix1")
        mixRow1.title = "姓名"
        mixRow1.height = 60
        mixRow1.cellClass = ZLTableViewCell.self
        mixRow1.placeholderValue = "固定60pt高度" as NSString
        section3.addFormRow(mixRow1)
        
        let mixRow2 = ZLFormRowDescriptor.formRowDescriptor(tag: "mix2")
        mixRow2.title = "备注"
        mixRow2.placeholderValue = "自适应高度（未设置height）自适应高度（未设置height）自适应高度（未设置height）自适应高度（未设置height）自适应高度（未设置height）" as NSString
        mixRow2.cellClass = ZLTableViewCell.self

        section3.addFormRow(mixRow2)
        
        let mixRow3 = ZLFormRowDescriptor.formRowDescriptor(tag: "mix3")
        mixRow3.title = "地址"
        mixRow3.height = 100
        mixRow3.placeholderValue = "固定100pt高度" as NSString
        mixRow3.cellClass = ZLTableViewCell.self
        section3.addFormRow(mixRow3)
        
        let mixRow4 = ZLFormRowDescriptor.formRowDescriptor(tag: "mix4")
        mixRow4.title = "电话"
        mixRow4.placeholderValue = "1自适应高度自适应高度自适自适应高度自适应高度自适应高度自适应高度应高度自适应高度自适应高度自适应高度自适自适应高度自适应高度自适应高度自适应高度应高度自适应高度自适应高度自适应高度自适自适应高度自适应高度自适应高度自适应高度应高度自适应高度" as NSString
        mixRow4.cellClass = ZLTableViewCell.self
        section3.addFormRow(mixRow4)
        
        formDescriptor.addFormSection(section3)
        
        // Section 4 - Footer 自适应
        let section4 = ZLFormSectionDescriptor(tag: "footerAuto")
        section4.headerHeight = 44
        section4.headerViewBlock = { _ in
            let label = UILabel(frame: CGRect(x: 15, y: 10, width: 300, height: 34))
            label.text = "Footer自适应高度"
            label.font = .boldSystemFont(ofSize: 16)
            return label
        }
        section4.footerViewBlock = { _ in
            let container = UIView()
            
            let footerLabel = UILabel()
            footerLabel.text = "这是一个自适应高度的Footer View，内容由AutoLayout约束决定高度。可以包含多行文字，系统会自动计算。"
            footerLabel.font = .systemFont(ofSize: 13)
            footerLabel.textColor = .secondaryLabel
            footerLabel.numberOfLines = 0
            container.addSubview(footerLabel)
            
            footerLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.bottom.equalToSuperview().offset(-8)
            }
            
            return container
        }
        
        let footerRow = ZLFormRowDescriptor.formRowDescriptor(tag: "footerRow")
        footerRow.title = "示例行"
        footerRow.value = "下方Footer自适应" as NSString
        footerRow.height = 70
        footerRow.cellClass = ZLTableViewCell.self

        section4.addFormRow(footerRow)
        
        formDescriptor.addFormSection(section4)
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .systemGroupedBackground
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        formDescriptor.tableView = tableView
    
        
    }
    
    // MARK: - ZLFormDescriptorDelegate
    
    public func formDescriptor(_ form: ZLFormDescriptor, didSelectFormRow formRow: ZLFormRowDescriptor) {
        print("选中: \(formRow.tag) (height=\(formRow.height), effective=\(formRow.effectiveHeight()))")
    }
}
