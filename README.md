# ZLForm

[![Version](https://img.shields.io/cocoapods/v/ZLForm.svg?style=flat)](https://cocoapods.org/pods/ZLForm)
[![License](https://img.shields.io/cocoapods/l/ZLForm.svg?style=flat)](https://cocoapods.org/pods/ZLForm)
[![Platform](https://img.shields.io/cocoapods/p/ZLForm.svg?style=flat)](https://cocoapods.org/pods/ZLForm)

ZLForm 是一个基于 `UITableView` 的声明式表单库，使用 **DifferenceKit** 做差量刷新，支持 Swift 与 Objective-C 混合使用。它将表单建模为 `ZLFormDescriptor → [ZLFormSectionDescriptor] → [ZLFormRowDescriptor]` 的三层数据结构，开发者只需要维护"数据模型"，UI 的刷新（插入、删除、移动、reload）都由库内部计算 diff 并播放动画。

---

## 目录

- [特性](#特性)
- [环境要求](#环境要求)
- [安装](#安装)
- [快速上手](#快速上手)
- [核心概念](#核心概念)
- [API 详解](#api-详解)
  - [ZLFormDescriptor](#zlformdescriptor)
  - [ZLFormSectionDescriptor](#zlformsectiondescriptor)
  - [ZLFormRowDescriptor](#zlformrowdescriptor)
  - [ZLFormDescriptorCell 协议](#zlformdescriptorcell-协议)
  - [ZLFormBaseCell](#zlformbasecell)
- [常见场景与示例](#常见场景与示例)
  - [1. 动态添加 / 删除 Section / Row](#1-动态添加--删除-section--row)
  - [2. 隐藏 / 显示 Section 与 Row](#2-隐藏--显示-section-与-row)
  - [3. 按 tag 自动排序](#3-按-tag-自动排序)
  - [4. 自定义 Cell（cellClass / cellProvider）](#4-自定义-cellcellclass--cellprovider)
  - [5. 自动高度与固定高度混合](#5-自动高度与固定高度混合)
  - [6. Section 背景 View](#6-section-背景-view)
  - [7. 强制刷新单行内容](#7-强制刷新单行内容)
- [Objective-C 集成](#objective-c-集成)
- [Demo 工程](#demo-工程)
- [注意事项 / 踩坑指南](#注意事项--踩坑指南)
- [常见问题 FAQ](#常见问题-faq)
- [作者 / License](#作者--license)

---

## 特性

- ✅ 声明式 API，数据驱动 UI
- ✅ 基于 [DifferenceKit](https://github.com/ra1028/DifferenceKit) 的差量刷新，**只刷新变化的 row/section**，自带动画
- ✅ 支持 Section 和 Row 的 **隐藏 / 显示**（section 优先级高于 row）
- ✅ 支持按 **tag 自动排序**（同时更新底层数组顺序，diff 稳定）
- ✅ 支持 **AutoLayout 自适应高度**，外部设置的固定高度优先
- ✅ 支持 **Section 背景 View**，自动跟随 cell 增删动态调整 frame
- ✅ **Swift / Objective-C 混合调用**，Cell 可以用 OC 写，外部可以用 Swift 配置
- ✅ Cell 创建支持 `cellClass` 与 `cellProvider` block 两种方式，**block 优先**
- ✅ 防止误用：`init` 已被禁用，只能通过工厂方法创建

## 环境要求

- iOS 11.0+
- Xcode 12+
- Swift 5.0+
- 依赖：`DifferenceKit`、`SnapKit`、`Then`

## 安装

### CocoaPods

在 `Podfile` 中添加：

```ruby
use_frameworks!

target 'YourApp' do
  pod 'ZLForm'
end
```

然后执行：

```bash
pod install
```

> **必须使用 `use_frameworks!`**，因为 ZLForm 是 Swift 编写并依赖 SnapKit/DifferenceKit。

### 桥接头文件（OC 工程使用）

如果你的主工程是 Objective-C，需要在 Swift 文件中使用自定义 OC Cell，请创建桥接头：

1. 新建 `YourApp-Bridging-Header.h`
2. 在 Build Settings 中设置 `SWIFT_OBJC_BRIDGING_HEADER` 指向该文件
3. 在桥接头中 `#import "YourCustomCell.h"`

详见 [Objective-C 集成](#objective-c-集成) 章节。

---

## 快速上手

### Swift

```swift
import ZLForm

class MyFormVC: UIViewController {

    let tableView = UITableView(frame: .zero, style: .grouped)
    let formDescriptor = ZLFormDescriptor()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.bounds

        // 1. 把 tableView 交给 formDescriptor 管理（自动设 dataSource/delegate）
        formDescriptor.tableView = tableView

        // 2. 创建 section
        let section = ZLFormSectionDescriptor.formSection(title: "个人信息")

        // 3. 创建 row（必须用工厂方法，init 已禁用）
        let nameRow = ZLFormRowDescriptor.formRowDescriptor(tag: "name")
        nameRow.title = "姓名"
        nameRow.value = "张三" as NSObject

        let ageRow = ZLFormRowDescriptor.formRowDescriptor(tag: "age")
        ageRow.title = "年龄"
        ageRow.value = NSNumber(value: 18)

        // 4. 组装
        section.addFormRow(nameRow)
        section.addFormRow(ageRow)
        formDescriptor.addFormSection(section)
    }
}
```

### Objective-C

```objc
#import <ZLForm/ZLForm-Swift.h>

@interface MyFormVC ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ZLFormDescriptor *formDescriptor;
@end

@implementation MyFormVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];

    self.formDescriptor = [[ZLFormDescriptor alloc] init];
    self.formDescriptor.tableView = self.tableView;

    ZLFormSectionDescriptor *section = [ZLFormSectionDescriptor formSectionWithTitle:@"个人信息"];

    ZLFormRowDescriptor *nameRow = [ZLFormRowDescriptor formRowDescriptorWithTag:@"name"];
    nameRow.title = @"姓名";
    nameRow.value = @"张三";

    [section addFormRow:nameRow];
    [self.formDescriptor addFormSection:section];
}
@end
```

---

## 核心概念

### 三层数据结构

```
ZLFormDescriptor              ← 表单（对应 1 个 UITableView）
  ├─ ZLFormSectionDescriptor  ← 分组（对应 1 个 section）
  │    ├─ ZLFormRowDescriptor ← 行（对应 1 个 cell）
  │    └─ ...
  └─ ...
```

### DifferenceKit 差量刷新机制

ZLForm 内部用 `ArraySection<ZLFormSectionDescriptor, ZLFormRowDescriptor>` 维护"可见"数据：

```swift
public private(set) var formSections: [ArraySection<ZLFormSectionDescriptor, ZLFormRowDescriptor>] = []
```

所有增删改操作都会：
1. 构造一个 `target` 数组（期望的最终状态）
2. 通过 `StagedChangeset(source: formSections, target: target)` 计算分阶段差异
3. 调用 `tableView.reload(using: changeset, with: .automatic) { setData }` 让 DifferenceKit 自动播动画并在 `setData` 闭包中更新数据源

**这意味着：你只需要修改数据，UI 会自动以动画方式更新，不会调用 `reloadData()` 整表刷新。**

### 数据源分离

| 属性 | 含义 |
|------|------|
| `allSections` | 真实数据源（包含隐藏的 section / row） |
| `formSections` | 可见数据源（DifferenceKit 驱动，过滤掉 hidden） |

`buildVisibleTarget()` 负责把 `allSections` 过滤、排序后转成 `formSections`。

---

## API 详解

### ZLFormDescriptor

表单顶层容器，每个表单对应 1 个 `UITableView`。

#### 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `tableView` | `UITableView?` | 关联的 tableView，设置后自动接管 dataSource/delegate |
| `delegate` | `ZLFormDescriptorDelegate?` | 表单事件回调 |
| `allSections` | `[ZLFormSectionDescriptor]` | 所有 section（**只读**，含隐藏） |
| `formSections` | `[ArraySection<...>]` | 可见 section（**只读**，Swift only） |
| `sectionDescriptors` | `[ZLFormSectionDescriptor]` | OC 可访问的所有 section |
| `sortByTag` | `Bool` | 是否按 tag 自动排序所有 section 和 row，默认 `false` |

#### 方法

```swift
// 添加 section
func addFormSection(_ formSection: ZLFormSectionDescriptor)
func addFormSection(_ formSection: ZLFormSectionDescriptor, at index: Int)

// 删除 section
func removeFormSection(_ formSection: ZLFormSectionDescriptor)
func removeFormSection(at index: Int)

// 根据 tag 查找
func formSection(withTag tag: String) -> ZLFormSectionDescriptor?
func formRow(withTag tag: String) -> ZLFormRowDescriptor?

// 隐藏 / 显示变化后调用，触发差量刷新
func reloadVisibility()

// 同步某个 section 的 rows 后刷新（内部使用，外部一般不需要）
func syncAndReloadSection(_ formSection: ZLFormSectionDescriptor)

// 获取表单所有值（key = row.tag）
func formValues() -> [String: Any]
```

> ⚠️ **不要直接修改 `formSections`**。所有修改都应通过 `addFormSection` / `removeFormSection` / `reloadVisibility` 等方法，否则 DifferenceKit 的 source/target 会不一致，导致回退到 `reloadData()`。

### ZLFormSectionDescriptor

#### 创建

```swift
ZLFormSectionDescriptor.formSection()
ZLFormSectionDescriptor.formSection(title: "标题")
```

#### 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `tag` | `String` | 唯一标识，diff 用 |
| `title` | `String?` | section header 文字 |
| `footerTitle` | `String?` | section footer 文字 |
| `headerHeight` | `CGFloat` | header 高度，`0` 表示自动 |
| `footerHeight` | `CGFloat` | footer 高度，`0` 表示自动 |
| `headerView` | `UIView?` | 自定义 header view |
| `footerView` | `UIView?` | 自定义 footer view |
| `isHiddenSection` | `Bool` | 是否隐藏整组（**优先级高于 row 的 hidden**） |
| `sectionBackgroundView` | `UIView?` | 整组背景 view |
| `sectionBackgroundInsets` | `UIEdgeInsets` | 背景 view 距离首行/末行的偏移 |
| `formRows` | `[ZLFormRowDescriptor]` | 所有 row（含隐藏） |
| `formDescriptor` | `ZLFormDescriptor?` | 反向引用 |

#### 方法

```swift
func addFormRow(_ formRow: ZLFormRowDescriptor)
func addFormRow(_ formRow: ZLFormRowDescriptor, at index: Int)
func removeFormRow(_ formRow: ZLFormRowDescriptor)
func removeFormRow(at index: Int)
func formRow(withTag tag: String) -> ZLFormRowDescriptor?
```

### ZLFormRowDescriptor

#### 创建

```swift
// 必须使用工厂方法（init 已被禁用）
let row = ZLFormRowDescriptor.formRowDescriptor(tag: "name")
```

```objc
// OC 必须使用类方法（alloc/new/init 已 NS_UNAVAILABLE）
ZLFormRowDescriptor *row = [ZLFormRowDescriptor formRowDescriptorWithTag:@"name"];
```

#### 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `tag` | `String` | 唯一标识 |
| `title` | `String?` | 标题文本 |
| `value` | `NSObject?` | 数据值 |
| `placeholder` | `String?` | 占位提示 |
| `required` | `Bool` | 是否必填 |
| `disabled` | `Bool` | 是否禁用 |
| `height` | `CGFloat` | 固定高度，`0` 表示自动 |
| `isHiddenRow` | `Bool` | 是否隐藏该行 |
| `cellClass` | `AnyClass?` | Cell 类（必须实现 `ZLFormDescriptorCell` 协议） |
| `cellProvider` | `ZLCellProviderBlock?` | Cell 创建闭包（**优先级高于 cellClass**） |
| `valueMapperToDisplay` | `((ZLFormRowDescriptor, Any?) -> Any?)?` | value 转显示文本的转换器 |
| `sectionDescriptor` | `ZLFormSectionDescriptor?` | 反向引用 |
| `forceUpdateFlag` | `Int` | 修改它会让 `isContentEqual` 返回 false，触发 cell 重新刷新 |

#### 方法

```swift
// 获取最终展示高度（外部 height > cell.cellHeight > automaticDimension）
func effectiveHeight() -> CGFloat

// 拿到关联的 cell（懒加载创建）
func cell() -> UITableViewCell
```

### ZLFormDescriptorCell 协议

自定义 cell 必须实现此协议（除 `rowDescriptor` 外其余都是 optional）：

```swift
@objc public protocol ZLFormDescriptorCell {
    var rowDescriptor: ZLFormRowDescriptor? { get set }   // 必须

    @objc optional func configure()                        // 初始化时调用一次
    @objc optional func update()                           // 每次 cellForRow 调用
    @objc optional func cellHeight(for rowDescriptor: ZLFormRowDescriptor) -> CGFloat
    @objc optional func formDescriptorCellDidSelected(with tableView: UITableView)
}
```

### ZLFormBaseCell

库内置基类，默认提供 `titleLabel` + `detailLabel` 的简单展示。自定义 cell 可继承它，也可以直接实现协议。

```swift
open class ZLFormBaseCell: UITableViewCell, ZLFormDescriptorCell {
    public let titleLabel = UILabel()
    public let detailLabel = UILabel()
    open var rowDescriptor: ZLFormRowDescriptor?
    open func configure() { /* 子类重写 */ }
    open func update() { /* 子类重写 */ }
}
```

---

## 常见场景与示例

### 1. 动态添加 / 删除 Section / Row

```swift
// 添加 section（带动画）
let newSection = ZLFormSectionDescriptor.formSection(title: "新分组")
formDescriptor.addFormSection(newSection)

// 添加 row 到指定 section
let newRow = ZLFormRowDescriptor.formRowDescriptor(tag: "newRow")
newRow.title = "新行"
newSection.addFormRow(newRow)

// 删除
formDescriptor.removeFormSection(newSection)
newSection.removeFormRow(newRow)
```

> ⚙️ 内部全部走 DifferenceKit diff，UI 自动带 `.fade` 动画。

### 2. 隐藏 / 显示 Section 与 Row

```swift
// 隐藏单行
nameRow.isHiddenRow = true
formDescriptor.reloadVisibility()    // 触发 diff 刷新

// 隐藏整组（优先级高于 row）
infoSection.isHiddenSection = true
formDescriptor.reloadVisibility()
```

> 🔑 **优先级**：`section.isHiddenSection = true` 时，该 section 下所有 row（无论是否 `isHiddenRow`）都不展示。

### 3. 按 tag 自动排序

```swift
formDescriptor.sortByTag = true

// 之后任何 add/remove 都会自动按 tag 排序
let row = ZLFormRowDescriptor.formRowDescriptor(tag: "a_first")
section.addFormRow(row)
```

> 🔑 开启 `sortByTag` 后，`allSections` 和 `section.formRows` **数组本身的顺序**会被更新（不只是展示时排序），diff 计算稳定，不会出现"加在末尾但显示在中间"的诡异闪动。

### 4. 自定义 Cell（cellClass / cellProvider）

#### 方式一：cellClass

```swift
class MyCustomCell: ZLFormBaseCell {
    override func configure() {
        // 添加子视图、约束
    }
    override func update() {
        titleLabel.text = rowDescriptor?.title
    }
}

row.cellClass = MyCustomCell.self
```

#### 方式二：cellProvider（优先级更高）

```swift
row.cellProvider = { rowDesc in
    let cell = MyCustomCell(style: .default, reuseIdentifier: rowDesc.tag)
    return cell
}
```

> ✅ 当两者都设置时，**`cellProvider` 优先**，`cellClass` 被忽略。两者都未设置时使用 `ZLFormBaseCell` 兜底。

### 5. 自动高度与固定高度混合

```swift
// 固定高度
row1.height = 80

// 自动高度（不设 height，由 AutoLayout 撑开）
row2.height = 0          // 或不设
```

> 📐 **优先级**：`row.height > cell.cellHeight(for:) > UITableView.automaticDimension`。
>
> Header / Footer 同理：`section.headerHeight > 0` 时用固定值，否则 `automaticDimension`。

### 6. Section 背景 View

```swift
let bgView = UIView()
bgView.backgroundColor = .white
bgView.layer.cornerRadius = 12
bgView.layer.shadowOpacity = 0.1
bgView.layer.shadowRadius = 4
bgView.layer.shadowOffset = CGSize(width: 0, height: 2)

section.sectionBackgroundView = bgView
section.sectionBackgroundInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
```

> 🎨 **实现原理**：
> - 在 `willDisplay cell/header/footer` 时计算该 section 所有可见 row 的 union rect
> - 更新背景 view frame，并对所有背景 view 调用 `sendSubviewToBack`，保证 cell 在背景之上
> - 删除 row/section 后内部调用 `layoutAllSectionBackgroundViews()`，背景 frame 自动收缩
>
> ⚠️ **不使用 `layer.zPosition`**，因为 tableView 在重布局时会重排子视图层级，必须每次显示时主动 `sendSubviewToBack`。

### 7. 强制刷新单行内容

如果某行的 `value` 改变了，但你希望 UI 重新走一次 `cellForRowAt`：

```swift
row.value = "新值" as NSObject
row.forceUpdateFlag += 1     // 触发 isContentEqual 返回 false
section.formDescriptor?.syncAndReloadSection(section)
```

> ⚠️ **不要直接让 `isContentEqual` 永远返回 `false`**，否则 DifferenceKit 会对所有 row 执行 `reloadRows(at:with:.fade)`。由于本库每行持有同一个 cell 对象（不走 dequeue），fade 动画会导致 cell `alpha` 异常，看起来像消失了。
> 内部已做处理：内容变化的 row 用 `.none` 动画手动 reload，insert/delete 仍带 `.fade`。

---

## Objective-C 集成

### 1. 桥接头文件（OC 主工程 + Swift Cell）

如果在 Swift 文件中使用 OC 写的自定义 Cell：

`YourApp-Bridging-Header.h`：
```objc
#import "MyCustomCell.h"
```

Build Settings → `Objective-C Bridging Header` 设置路径：
```
$(SRCROOT)/YourApp/YourApp-Bridging-Header.h
```

### 2. OC 中使用 Swift 类

```objc
#import <ZLForm/ZLForm-Swift.h>

ZLFormDescriptor *desc = [[ZLFormDescriptor alloc] init];
ZLFormSectionDescriptor *sec = [ZLFormSectionDescriptor formSectionWithTitle:@"标题"];
ZLFormRowDescriptor *row = [ZLFormRowDescriptor formRowDescriptorWithTag:@"name"];
```

### 3. 禁用 `alloc/new/init`

为了防止 OC 直接 `[[ZLFormRowDescriptor alloc] init]`，库提供了一个分类头：

```objc
#import "ZLFormRowDescriptor+Unavailable.h"
// 之后 alloc/new/init 在编译期就会报错
```

只能用：
```objc
[ZLFormRowDescriptor formRowDescriptorWithTag:@"xxx"];
```

---

## Demo 工程

`Example/` 目录下包含多个示例控制器：

| 控制器 | 演示内容 |
|--------|---------|
| `ZLViewController` | 主入口，基础表单 + 动态隐藏 section/row |
| `ZLFormSubmitViewController` | 表单提交 + 取值 |
| `ZLFormSectionBackgroundViewController` | section 背景 view 动态适应 |
| `ZLFormAutoHeightViewController` | 自动高度 + 固定高度混合 |
| `ZLFormTagSortDemoViewController` | tag 自动排序 + 动态插入/删除 |

运行方式：

```bash
cd Example
pod install
open ZLForm.xcworkspace
```

---

## 注意事项 / 踩坑指南

### ⚠️ 1. 不要在 `setData` 闭包之外修改 `formSections`

DifferenceKit 的 `reload(using:with:setData:)` 会分多个阶段执行 diff，每个阶段都需要数据源处于正确的中间状态。如果你提前把 `formSections` 改成最终状态，DifferenceKit 检测到不一致会**回退到 `reloadData()` 整表刷新**，所有动画失效。

```swift
// ❌ 错误
formSections = newData
tableView.reload(using: changeset, with: .fade) { _ in }

// ✅ 正确（库内部已这样实现）
let target = buildVisibleTarget()
tableView.reload(using: StagedChangeset(source: formSections, target: target), with: .fade) { [weak self] data in
    self?.formSections = data
}
```

### ⚠️ 2. 不要同时实现 `UITableViewDataSource` / `UITableViewDelegate`

`formDescriptor.tableView = tableView` 会接管这两个协议。如果你自己再实现并覆盖，会导致 `numberOfRows` 等返回错误数据，引发 `EXC_BAD_ACCESS`（访问无效内存）。

如果需要监听 tableView 事件，请通过 `formDescriptor.delegate` 协议回调，而不是直接占用 dataSource/delegate。

### ⚠️ 3. KVO 使用 `NSKeyValueObservation` 无需手动移除

库内使用 Swift 4+ 的 `observe(\.keyPath)` 方式，`deinit` 时会自动移除观察，不需要在 `dealloc` 调 `removeObserver`。

### ⚠️ 4. SnapKit 是 Swift only

OC 文件中无法使用 SnapKit。如果你写 OC Cell，请用 `NSLayoutConstraint` 或 Masonry。

### ⚠️ 5. `isContentEqual` 不要永远返回 `false`

会导致 DifferenceKit 对每个 row 执行 reload 动画，由于本库不走 dequeue（同一 cell 对象），fade 动画会让 cell `alpha = 0` 看起来消失。需要强制刷新某行时，请用 `forceUpdateFlag += 1`。

### ⚠️ 6. Cell 引用避免循环

`rowDescriptor` 已经强引用 `_cell`，cell 内 `rowDescriptor` 属性是 weak 或受 row 生命周期约束的 strong（库内已处理）。**自定义 cell 不要再额外 strong 引用 row 之外的 ZLForm 对象。**

### ⚠️ 7. 自动高度必须确保约束完整

使用 `UITableView.automaticDimension` 时，cell 的 `contentView` 内所有子视图必须有完整的 top→bottom 约束链，否则会出现高度为 0 或异常。

```swift
// ✅ 正确
titleLabel.snp.makeConstraints { make in
    make.top.equalToSuperview().offset(10)
    make.leading.trailing.equalToSuperview().inset(16)
    make.bottom.equalToSuperview().offset(-10)  // 关键！
}
```

### ⚠️ 8. tag 必须唯一

`tag` 是 DifferenceKit 的 `differenceIdentifier`，**同一表单内 row/section 的 tag 必须唯一**，否则 diff 计算异常，可能导致动画错乱或崩溃。

### ⚠️ 9. `addFormSection` / `addFormRow` 之前要先关联

新建的 section 没加进 descriptor 之前调用 `addFormRow` 不会触发 UI 更新（因为没关联 tableView）。**先建好父子关系再操作 row**，或者在加完后再调用 `reloadVisibility()`。

```swift
// ✅ 推荐
let section = ZLFormSectionDescriptor.formSection()
section.addFormRow(row1)
section.addFormRow(row2)
formDescriptor.addFormSection(section)   // 最后一次性加入

// ⚠️ 也可以但会触发多次 diff
formDescriptor.addFormSection(section)
section.addFormRow(row1)   // 触发 diff
section.addFormRow(row2)   // 又触发 diff
```

### ⚠️ 10. 修改 `value` 不会自动刷新 UI

`value` 改变只是数据层变化。如需 UI 同步，要么 cell 内监听 row 属性（KVO），要么手动 `forceUpdateFlag += 1` 后调 `syncAndReloadSection`。

### ⚠️ 11. `syncAndReloadSection` 是同步执行

调用后 `formSections` 立即更新，tableView 的 section/row 数也同步变化。动画只是视觉过渡。如需在动画结束后做事，使用 `CATransaction.setCompletionBlock`。

### ⚠️ 12. Section 背景 view 不要自己 addSubview 到 tableView

`section.sectionBackgroundView = bgView` 后，库会自动管理它的添加/移除/布局。**不要自己再 addSubview**，否则会出现重复或位置错乱。

### ⚠️ 13. OC 中不要直接访问 `formSections`

`formSections` 的类型是 Swift 泛型 `[ArraySection<...>]`，OC 无法访问。需要遍历 section 请用 `sectionDescriptors`。

```objc
// ❌ 报错
self.formDescriptor.formSections;

// ✅ 正确
NSArray<ZLFormSectionDescriptor *> *sections = self.formDescriptor.sectionDescriptors;
```

---

## 常见问题 FAQ

**Q1：添加 row 时整张表都刷新了？**
A：检查是否在 `setData` 之外提前修改了 `formSections`，或者你重写的 `isContentEqual` 总是返回 false。详见注意事项 1 / 5。

**Q2：选中行时 `EXC_BAD_ACCESS`？**
A：通常是 dataSource 被双重设置或 `formRows` 与 `formSections.elements` 行数不一致。**移除你自己实现的 UITableViewDataSource**，让 `formDescriptor` 接管。

**Q3：隐藏 row 后背景 view 没缩小？**
A：库内 `performDiffUpdate` 和 `syncAndReloadSection` 完成后会调用 `layoutAllSectionBackgroundViews()`。如果你自定义了刷新逻辑，记得也要调一下。

**Q4：OC 中 `[ZLFormRowDescriptor alloc]` 不报错？**
A：导入 `ZLFormRowDescriptor+Unavailable.h` 即可在编译期阻止。

**Q5：自动高度 cell 显示高度为 0？**
A：检查 cell 内约束是否完整。`UITableView.automaticDimension` 需要从 contentView.top 到 contentView.bottom 有完整约束链。

**Q6：自定义 cell 没生效，显示成了默认样式？**
A：检查 `cellClass` 是否设置正确，或者 `cellProvider` 是否返回了非 nil 的 cell。**`cellProvider` 优先级高于 `cellClass`**。

**Q7：tag 排序后顺序不稳定？**
A：确保所有 row 的 tag 唯一且字符串可比较。库内用 `String <` 排序。

**Q8：编译报 `unknown type name 'nonnull'`？**
A：这是 Swift 生成 `-Swift.h` 时的格式问题。把 `#import <ZLForm/ZLForm-Swift.h>` 从 `.h` 移到 `.m` 文件即可。或用条件编译：

```objc
#if __has_include(<ZLForm/ZLForm-Swift.h>)
#import <ZLForm/ZLForm-Swift.h>
#endif
```

**Q9：`isHiddenRow` 设置了但 UI 没变化？**
A：必须显式调用 `formDescriptor.reloadVisibility()`，库不会自动 KVO 监听该属性。

**Q10：能否在 cell 内部直接修改 `rowDescriptor.value`？**
A：可以。但如果需要表单其他 row 联动（比如某行改变后另一行隐藏），需要在 cell 的 value 变化回调里调用 `formDescriptor.reloadVisibility()`。

**Q11：删除当前正在编辑的 row 会崩溃吗？**
A：库内部用 DifferenceKit 安全分阶段更新，不会崩。但如果 cell 内部还在用 `rowDescriptor`，请加 `guard let row = rowDescriptor else { return }`。

**Q12：可以一个 tableView 关联多个 formDescriptor 吗？**
A：不可以。一个 tableView 只能由一个 formDescriptor 接管，否则 dataSource/delegate 互相覆盖。

---


