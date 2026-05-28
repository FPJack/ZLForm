ZLForm 使用手册（中文）
=================================

目录
----

1. 简介
2. 快速开始（最小示例）
3. 安装与工程设置（CocoaPods / workspace / 桥接头）
4. 核心概念与类型说明
5. 常见操作（创建 section / row / 展示）
6. DifferenceKit 差量刷新使用要点
7. 隐藏 / 显示 与 排序（tag）
8. 自定义 Cell（cellProvider / cellClass）
9. 自动高度与固定高度优先级
10. 组背景视图（背景始终在 cell 下面的策略）
11. Demo（AutoHeight / TagSort / Background）如何接入工程
12. 常见问题与排查（EXC_BAD_ACCESS、reloadRows、KVO、桥接等）
13. 进阶技巧与最佳实践
14. 联系与贡献

1. 简介
---------

ZLForm 是一个基于描述符驱动（descriptor-driven）的轻量级表单框架，用于在 Example 工程中快速构建基于 UITableView 的表单界面。核心特点：

- 使用 ZLFormDescriptor / ZLFormSectionDescriptor / ZLFormRowDescriptor 表示表单数据结构
- 使用 DifferenceKit 的 ArraySection 做增量更新（插入/删除/移动/局部刷新动画）
- 支持自定义 cell（通过 class 或 provider block），可以在 Swift/ObjC 混合项目中使用
- 支持按 tag 排序、按组/按行隐藏、组背景 view、以及 Auto Layout 自动高度

2. 快速开始（最小示例）
----------------------

Swift 最小示例（在某个 UIViewController 中）

```swift
// 假设 tableView 已经连好并且在 storyboard / 代码中创建
let form = ZLFormDescriptor(tableView: tableView)

let section = ZLFormSectionDescriptor(tag: "personal")
section.title = "个人信息"

let nameRow = ZLFormRowDescriptor.formRowDescriptor(tag: "name")
nameRow.title = "姓名"
nameRow.value = "张三"
nameRow.cellClass = ZLFormTextFieldCell.self // 或使用 cellProvider

let phoneRow = ZLFormRowDescriptor.formRowDescriptor(tag: "phone")
phoneRow.title = "电话"
phoneRow.cellProvider = { row in
	let cell = ZLTableViewCell(style: .value1, reuseIdentifier: row.tag)
	return cell
}

section.formRows = [nameRow, phoneRow]
form.append(sectionDescriptor: section)
```

Objective-C 最小示例（在某个 UIViewController 中）

```objc
ZLFormDescriptor *form = [[ZLFormDescriptor alloc] initWithTableView:self.tableView];

ZLFormSectionDescriptor *sec = [[ZLFormSectionDescriptor alloc] initWithTag:@"personal"];
sec.title = @"个人信息";

ZLFormRowDescriptor *r1 = [ZLFormRowDescriptor formRowDescriptorWithTag:@"name"];
r1.title = @"姓名";
r1.cellClass = [ZLFormTextFieldCell class];

[sec setFormRows:@[r1]];
[form appendSectionDescriptor:sec];
```

3. 安装与工程设置
-------------------

1) CocoaPods（Example）

```bash
cd /Users/admin/Desktop/多语言翻译/ZLForm/Example
pod install
open ZLForm.xcworkspace
```

注意：始终用 xcworkspace 打开工程（如果使用了 CocoaPods）。

2) Swift ↔ Objective‑C 桥接（如果 Swift 代码需要使用 ObjC 类）

- 在 Example target 中创建或使用已有桥接头（Bridging Header），例如 `ZLForm_Example-Bridging-Header.h`。
- 在桥接头中导入你希望 Swift 能访问的 ObjC 头：

```objc
#import "ZLTableViewCell.h"
#import "ZLFormRowDescriptor.h"
```

- 在 Xcode 的 Build Settings 中设置 `SWIFT_OBJC_BRIDGING_HEADER` 为该头文件的相对路径。

4. 核心概念与类型说明
----------------------

- ZLFormDescriptor
  - 管理整个表单，与 UITableView 绑定，拥有 `allSections`（全部数据）和 `formSections`（仅用于显示的可见数据）两个概念。
  - 提供差量刷新方法：`performDiffUpdate(target:)`（全量目标 diff），`syncAndReloadSection(_:)`（某组变化时触发）。

- ZLFormSectionDescriptor
  - 表示一组：包含 `title`、`tag`、`formRows`（完整行数据）、header/footer 视图与高度、`isHiddenSection`、`sectionBackgroundView`、`sectionBackgroundInsets` 等。

- ZLFormRowDescriptor
  - 表示一行：包含 `tag`、`title`、`value`、`height`、`isHiddenRow`、`cellClass`、`cellProvider`（block）等属性。
  - 推荐通过工厂方法创建：`ZLFormRowDescriptor.formRowDescriptor(tag:)`。库中对直接 alloc/init 有保护以避免误用。

5. 常见操作
------------

添加/删除/插入 section：

```swift
// append
form.append(sectionDescriptor: section)

// insert
form.insert(sectionDescriptor: newSection, at: 1)

// remove
form.remove(sectionDescriptor: section)
```

添加/删除/插入 row（对 section 的变更请调用 section 的 notify 方法或直接更新后调用 form.syncAndReloadSection(section)）：

```swift
section.formRows.append(newRow)
form.syncAndReloadSection(section)
```

6. DifferenceKit 差量刷新使用要点
-------------------------------

核心规则（非常重要）：

- 在调用 `tableView.reload(using: changeset, with: animation) { data in ... }` 前，不要提前修改 `formSections`。必须把 `target`（最终显示数组）传入，DifferenceKit 会在 `setData` 闭包中按阶段把当前阶段的数据回写给 `formSections`。
- 如果在调用前你已经把 `formSections` 改为目标状态，DifferenceKit 会检测到数据不一致并回退到 `reloadData()`，导致整表刷新，丢失增量动画效果。

典型用法：

```swift
let target = buildVisibleTarget() // 从 allSections 构造只包含可见项的 ArraySection 数组
let changeset = StagedChangeset(source: formSections, target: target)
tableView.reload(using: changeset, with: .automatic) { data in
	self.formSections = data
}
```

关于内容变化（content reload）和相同 cell 实例的问题：

- DifferenceKit 会对 `isContentEqual(to:)` 返回 false 的元素产生 reload 动作（调用 `reloadRows(at:with:)`）。
- 如果你的实现强持有并复用同一个 cell 实例（非 dequeue），UIKit 在 reload 动画期间对同一个 view 做淡入淡出可能导致不可见或其它渲染异常（表现为滑动后恢复）。

解决方案：

1. 优先使用 `dequeueReusableCell` 模式（推荐），让 reload 能创建新实例。
2. 或者让 DifferenceKit 不对内容变化触发 reload（让 `isContentEqual` 返回 true），在 diff 完成后手动调用 `tableView.reloadRows(at: indexPaths, with: .none)` 来触发 `cellForRowAt`，并用自定义动画（如 crossfade）更新内容。

7. 隐藏 / 显示 与 排序（tag）
--------------------------------

隐藏优先级：组隐藏 > 行隐藏。

实现策略：

- `allSections` 保存完整数据（包括被隐藏的项）。
- `buildVisibleTarget()` 根据 `isHiddenSection` 和 `isHiddenRow` 生成只包含可见项的 `[ArraySection<Model, Element>]`。
- 将这个 `target` 交给 `performDiffUpdate(target:)`，DifferenceKit 会在 tableView 上做增量动画。

按 tag 排序：

- 若 `formDescriptor.sortByTag = true`，在构建 target 前会对 `allSections` 以及每个 section 的 `formRows` 原地排序（修改底层数组顺序以保持一致性）。

注意：排序会改变底层数组顺序（persist），因此后续 insert/remove 等操作会基于排序后的数组。

8. 自定义 Cell（cellProvider / cellClass）
------------------------------------

优先级：

1. `cellProvider`：一个 block，外部可直接创建并返回一个 cell 实例（最高优先）。
2. `cellClass`：提供一个类引用（Swift 或 ObjC），框架将使用类创建 cell。
3. fallback：默认使用 `ZLFormBaseCell`。

示例：

```swift
row.cellProvider = { row in
	let cell = MyCustomCell(style: .default, reuseIdentifier: row.tag)
	return cell
}

// 或者：
row.cellClass = MyCustomCell.self
```

ObjC 示例：

```objc
row.cellClass = [ZLTableViewCell class];
```

提示：若 Swift 中无法识别 ObjC 类，确认该 ObjC 头已加入桥接头且文件被加入 Example target。

9. 自动高度与固定高度优先级
--------------------------------

- 若外部设置了 `row.height > 0`，则使用该固定高度（优先）。
- 否则返回 `UITableView.automaticDimension`，让 Auto Layout 决定高度。
- 同时实现 `estimatedHeightForRowAt`、`estimatedHeightForHeader/Footer` 来提升滚动性能。

10. 组背景视图（背景始终在 cell 下面的策略）
-------------------------------------------

需求：有时希望每组有一个圆角白卡背景，背景跟随组的行数量动态变高/变低，并且永远在 cell 下面，不遮挡 cell 内容。

实现要点：

1. 每个 `ZLFormSectionDescriptor` 支持 `sectionBackgroundView` 和 `sectionBackgroundInsets`。
2. 在 `willDisplay cell`、`willDisplayHeaderView`、`willDisplayFooterView` 等回调中重新计算该组所有可见行的 union rect，然后更新背景 view 的 frame。
3. 因为 UITableView 的内部会调整 subviews 布局，单次 `insertSubview(bgView, at: 0)` 不足以保证背景永远在底层。建议每次布局时调用 `tableView.sendSubviewToBack(bgView)` 或把所有背景都 `sendSubviewToBack` 一次，确保背景在渲染层级中处于最底部。

11. Demo（AutoHeight / TagSort / Background）如何接入工程
-----------------------------------------------------

- 新增 .m/.h/.swift 文件后请在 Xcode 的 File Inspector 中勾选 Example target（Target Membership）。
- Swift 文件若要访问 ObjC 类型，请在桥接头 import 相应的头文件并在 Build Settings 设置桥接头路径。

如果你将 demo 文件手动复制到工程中但出现找不到类或符号的错误，请检查：

1. 文件是否真的在 Example target 的 Compile Sources 中；
2. 如果是 Swift 文件，是否正确设置了 bridging header 导入需要的 ObjC 头；
3. 是否使用 workspace 打开工程（不是 xcodeproj）。

12. 常见问题与排查建议
----------------------

Q：`titleLabel.text = row.title` 为什么崩溃 EXC_BAD_ACCESS？

A：常见原因：

- cell 对象被提前释放（使用了弱引用或没有被 tableView 正确持有）；
- tableView 的 dataSource/delegate 在多个对象上实现，造成数据来源不一致；
- 你在调用 diff 刷新前就修改了 `formSections`，导致数据不一致和数组越界；
- cell 被错误地 typecast 或者 header/footer 与 cell 的重用冲突。

排查步骤：

1. 确认 `formDescriptor` 是 tableView 的唯一 dataSource/delegate；
2. 搜索项目中是否有直接访问 `formSections` 并在 `reload(using:)` 之前修改它的代码；
3. 在崩溃时查看崩溃堆栈，定位到哪一行的访问导致 EXC_BAD_ACCESS（通常是消息发送到已释放对象）。

Q：我强制把 `isContentEqual` 返回 false，然后调用 `syncAndReloadSection`，为什么 cell 消失了但滑动后又出现？

A：DifferenceKit 会把内容变更的元素标记为需要 reload，进而调用 `reloadRows(at:with:)`。如果你在 descriptor 中强持有并复用同一个 cell 实例，UIKit 对同一 view 做 reload 动画会产生渲染异常（淡出/淡入同一个 view）。滑动时 tableView 会重新请求 cell 并恢复显示。

解决：

- 不要在 `isContentEqual` 中盲目返回 false；仅在内容真正变化需要由系统 reload 时才返回 false；
- 或在 diff 完成后对需要刷新的 indexPaths 手动调用 `reloadRows(at:with:.none)`，并在 `cellForRowAt` 中正确更新内容。

Q：KVO 的观察需要手动移除吗？

A：如果使用 Swift 的 `observe` 返回的 `NSKeyValueObservation` 对象，只要把该对象保存在属性上（不要被提前释放），系统会在该观察对象释放时自动注销 KVO；无需手动 `removeObserver`。

Q：如何编译时阻止 ObjC 调用 `[[ZLFormRowDescriptor alloc] init]`？

A：Swift 的 `@available(*, unavailable)` 能阻止 Swift 层调用，但 ObjC 端仍然可以编译并调用。为了在 ObjC 编译期禁止调用，需要在 ObjC 头中把 `-init`、`+new` 标记为 `NS_UNAVAILABLE`。另外运行时也应加断言或 `fatalError` 做兜底。

13. 进阶技巧与最佳实践
----------------------

- 建议使用 dequeue 机制并尽量避免在 descriptor 中强持有 cell 对象，以免与系统的 reload/动画机制冲突。
- 将 `allSections` 作为权威数据，`formSections` 仅作为 UI 的可见快照，这样能更容易支持隐藏、排序与撤销操作。
- 对于频繁更新（大量 insert/delete）的场景，考虑分组构建 target 并尽量减少不必要的 content reload（只做 insert/delete/move）。

14. 联系与贡献
----------------

如果你希望我为仓库：

- 添加一个 <50 行的快速上手示例；
- 自动扫描代码找出在 `setData` 之外修改 `formSections` 的位置并提出修复建议；
- 将 README 输出为 PDF 或制作中/英文双语版本；

请告诉我你需要的项，我会继续为你实现并提交修改。

-- 结束 --

