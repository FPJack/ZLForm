ZLForm
=====

Overview
--------

ZLForm is a lightweight form framework used in the Example workspace. It provides a descriptor-driven way to build table-based forms with sections and rows, integrates with DifferenceKit for animated diffs, and supports: custom cells (by class or by provider block), per-row and per-section hiding, tag-based sorting, section background views, and automatic height usage via Auto Layout.

This README documents how to install and use the library and the Example app, explains key concepts implemented in the codebase, and covers common pitfalls and fixes discovered while integrating DifferenceKit and Objective-C code.

Checklist (what I'll cover)
---------------------------
- Installation (CocoaPods / workspace)
- Swift / Objective-C bridging tips (bridging header)
- Core types: ZLFormDescriptor, ZLFormSectionDescriptor, ZLFormRowDescriptor
- How to create sections/rows (factory) and prevent direct alloc/init from Swift / ObjC
- Using DifferenceKit diff updates correctly (performDiffUpdate / syncAndReloadSection)
- Hiding/showing sections & rows (priority rules)
- Tag-based sorting for sections and rows, and persisting sorted order
- Custom cell creation: cellClass vs cellProvider block (block has priority)
- Automatic cell/header/footer height (Auto Layout and external fixed heights)
- Section background views and ensuring they stay behind cells
- SnapKit notes (demo uses SnapKit; library avoids it)
- Demo controllers (AutoHeight, TagSort, Background demo) and how to add them to the project
- Troubleshooting & FAQ (EXC_BAD_ACCESS, reload vs diff, KVO, unexpected nil, bridging issues)

Installation
------------

Using the Example workspace

- The Example uses CocoaPods. Open the workspace file (not the project):

```bash
cd /Users/admin/Desktop/多语言翻译/ZLForm/Example
open ZLForm.xcworkspace
```

- If you changed Podfile or updated pods, run:

```bash
pod install
```

Notes
- The Example target includes SnapKit and other dev-only dependencies. The ZLForm library itself intentionally avoids requiring SnapKit so it can be consumed from ObjC/Swift without extra dependencies.

Swift / Objective-C interoperability
-----------------------------------

Bridging header (to access Objective-C cells from Swift)

- If you want Swift files in the Example to reference Objective-C classes like `ZLTableViewCell`, add them to the bridging header used by the Example target.
- Typical path: `ZLForm/ZLForm_Example-Bridging-Header.h` (or similar). Add:

```objc
#import "ZLTableViewCell.h"
// import other Objective-C headers you want to use from Swift
```

- Then, in Xcode, set `SWIFT_OBJC_BRIDGING_HEADER` in Build Settings to that header path (relative to project).

Core concepts and API
---------------------

Types
- ZLFormDescriptor
  - Central manager for a table form. Owns `allSections` (all data) and `formSections` (visible sections used by the table view).
  - Drives DifferenceKit updates via `performDiffUpdate(target:)` and `syncAndReloadSection(_:)`.

- ZLFormSectionDescriptor
		ZLForm
		=====

		概述
		----

		ZLForm 是一个用于示例工程的小型表单框架（descriptor 驱动）。它用描述符（section/row）构建基于 UITableView 的表单，集成了 DifferenceKit 做增量动画更新，并支持：自定义 cell（通过 class 或 provider block）、按行/按组隐藏、按 tag 排序、每组背景 view、以及基于 Auto Layout 的自动高度。

		本 README 详细说明如何安装与使用库与 Example，解释代码中关键实现点，并记录在与 DifferenceKit、Objective-C 互操作中遇到的常见问题与修复方法。

		目录（主要涵盖）
		-----------------
		- 安装（CocoaPods / workspace）
		- Swift 与 Objective‑C 互操作（桥接头）
		- 核心类型：`ZLFormDescriptor`、`ZLFormSectionDescriptor`、`ZLFormRowDescriptor`
		- 如何创建 section/row（工厂方法），以及禁止直接 alloc/init
		- 使用 DifferenceKit 做 diff 刷新（`performDiffUpdate` / `syncAndReloadSection`）的正确姿势
		- 隐藏显示规则（优先级）
		- 按 tag 排序（section 与 row），并持久化数组顺序
		- 自定义 cell：`cellProvider`（优先）与 `cellClass`
		- 自动高度（Auto Layout）与外部固定高度优先规则
		- section 背景 view 与保证背景始终在 cell 下面的方案
								ZLForm
								=+

								概述
								----

								ZLForm 是一个用于示例工程的小型表单框架（descriptor 驱动）。它用描述符（section/row）构建基于 UITableView 的表单，集成了 DifferenceKit 做增量动画更新，并支持：自定义 cell（通过 class 或 provider block）、按行/按组隐藏、按 tag 排序、每组背景 view、以及基于 Auto Layout 的自动高度。

								本 README 详细说明如何安装与使用库与 Example，解释代码中关键实现点，并记录在与 DifferenceKit、Objective-C 互操作中遇到的常见问题与修复方法。

								目录（主要涵盖）
								-----------------
								- 安装（CocoaPods / workspace）
								- Swift 与 Objective‑C 互操作（桥接头）
								- 核心类型：`ZLFormDescriptor`、`ZLFormSectionDescriptor`、`ZLFormRowDescriptor`
								- 如何创建 section/row（工厂方法），以及禁止直接 alloc/init
								- 使用 DifferenceKit 做 diff 刷新（`performDiffUpdate` / `syncAndReloadSection`）的正确姿势
								- 隐藏显示规则（优先级）
								- 按 tag 排序（section 与 row），并持久化数组顺序
								- 自定义 cell：`cellProvider`（优先）与 `cellClass`
								- 自动高度（Auto Layout）与外部固定高度优先规则
								- section 背景 view 与保证背景始终在 cell 下面的方案
																																ZLForm — 中文使用说明
																																======================

																																简介
																																----

																																ZLForm 是一个用于示例工程的轻量表单框架（描述符驱动）。通过 `ZLFormDescriptor`、`ZLFormSectionDescriptor`、`ZLFormRowDescriptor` 这组描述符构建表单，使用 DifferenceKit 做可动画的差量更新，支持自定义 cell、按行/组隐藏、按 tag 排序、组背景视图、以及基于 Auto Layout 的自动高度。

																																本文档涵盖安装、API、使用示例、Diff 更新注意事项、以及在 Swift/Objective‑C 混合工程中遇到的常见问题和解决方案。

																																目录
																																----

																																- 安装（CocoaPods / workspace）
																																- Swift 与 Objective‑C 互操作（桥接头）
																																- 核心概念与类型
																																- DifferenceKit 使用要点
																																- 隐藏/显示逻辑与排序
																																- 自定义 cell（cellProvider / cellClass）
																																- 自动高度与固定高度优先级
																																- 组背景视图及层级问题
																																- 示例代码片段
																																- 常见问题与排查建议

																																安装
																																----

																																打开 Example 工作区：

																																```bash
																																cd /Users/admin/Desktop/多语言翻译/ZLForm/Example
																																open ZLForm.xcworkspace
																																```

																																修改 Podfile 后运行：

																																```bash
																																pod install
																																```

																																注意：Example target 含有 SnapKit 等示例依赖，库本身尽量不依赖这些第三方以便在 ObjC/Swift 中无侵入使用。

																																Swift ↔ Objective‑C 互操作
																																-------------------------

																																桥接头（让 Swift 使用 ObjC 类）

																																如果 Swift 文件要使用 ObjC 实现的 cell（例如 `ZLTableViewCell`），请在 Example 的桥接头中加入：

																																```objc
																																#import "ZLTableViewCell.h"
																																```

																																并在 Xcode 的 Build Settings 中设置 `SWIFT_OBJC_BRIDGING_HEADER` 为该桥接头路径。

																																核心概念与类型
																																--------------

																																- `ZLFormDescriptor`：表单管理器，维护 `allSections`（完整数据）与 `formSections`（用于显示的可见数据）。负责把数据变化通过 DifferenceKit 应用到 UITableView 上。
																																- `ZLFormSectionDescriptor`：一组描述符，包含 `title`、`tag`、`formRows`（完整行数据）、header/footer、`isHiddenSection`、`sectionBackgroundView` 等。
																																- `ZLFormRowDescriptor`：单行描述符，包含 `tag`、`height`、`isHiddenRow`、`cellClass`、`cellProvider`（block）等。建议通过工厂方法创建：`ZLFormRowDescriptor.formRowDescriptor(tag: "xxx")`。

																																DifferenceKit 使用要点
																																--------------------

																																核心调用模式：

																																```swift
																																let changeset = StagedChangeset(source: old, target: new)
																																tableView.reload(using: changeset, with: .automatic) { data in
																																	self.formSections = data
																																}
																																```

																																重要规则：

																																- 在调用 `tableView.reload(using:changeset)` 之前不要直接修改 `formSections`。应当构造 `target`（目标状态），并让 `reload(using:)` 在 `setData` 闭包中按阶段赋值 `formSections`。
																																- 若提前修改数据源，DifferenceKit 会检测到不一致并回退到 `reloadData()`，导致整表刷新并丢失细粒度动画。

																																隐藏/显示与排序
																																----------------

																																- `allSections`：真实数据存储，包含隐藏项。
																																- `buildVisibleTarget()`：从 `allSections` 计算出只包含可见项的 `[ArraySection<Model, Element>]`，该结果传入 `performDiffUpdate(target:)` 应用动画。
																																- `isHiddenSection`（组级）优先于 `isHiddenRow`（行级）。
																																- `formDescriptor.sortByTag = true` 会同时对组和行按 tag 排序并更新底层数组顺序以保持一致性。

																																自定义 cell
																																------------

																																优先级：

																																1. `row.cellProvider`（block） — 最高优先级，直接返回 cell 实例。
																																2. `row.cellClass` — 指定类（Swift 或 ObjC），当 provider 为 nil 时使用。
																																3. 回退为 `ZLFormBaseCell`。

																																示例（ObjC）：

																																```objc
																																row.cellClass = [ZLTableViewCell class];
																																```

																																自动高度策略
																																--------------

																																- 外部显式设置的高度（`height > 0`）优先使用。
																																- 若未设置高度（`height == 0`），使用 `UITableView.automaticDimension` 并依赖 Auto Layout。
																																- 提供 `estimatedHeightForRowAt` 与 header/footer 的估算值以提升性能。

																																组背景视图与层级问题
																																---------------------

																																- 每组可以设置 `sectionBackgroundView` 与 `sectionBackgroundInsets`，库会根据首/末可见行计算背景的 frame。
																																- 为确保背景永远在 cell 下面：在 `willDisplay cell` / `willDisplayHeaderView` / `willDisplayFooterView` 中，每次都把背景 view `sendSubviewToBack`，不要只在初始化时插入一次。

																																示例代码片段
																																------------

																																添加 section 并动画：

																																```swift
																																let section = ZLFormSectionDescriptor(tag: "s1")
																																section.title = "个人信息"
																																section.formRows = [ZLFormRowDescriptor.formRowDescriptor(tag: "r1")]

																																descriptor.allSections.append(section)
																																let target = descriptor.buildVisibleTarget()
																																descriptor.performDiffUpdate(target: target)
																																```

																																切换行隐藏并动画：

																																```swift
																																row.isHiddenRow.toggle()
																																descriptor.reloadVisibility()
																																```

																																强制刷新某一行并希望触发 `cellForRowAt`（保留其他 insert/delete 的动画）：

																																1. 让 `isContentEqual(to:)` 对 DifferenceKit 返回 `true`（避免自动 `reloadRows`）。
																																2. 在 diff 完成后手动对需要刷新的 indexPaths 调用：

																																```swift
																																tableView.reloadRows(at: indexPathsToRefresh, with: .none)
																																```

																																常见问题与排查建议
																																------------------

																																Q：为什么 `titleLabel.text = row.title` 崩溃 EXC_BAD_ACCESS？
																																A：常见原因包括：cell 被提前释放、tableView 的 dataSource/delegate 在多个对象实现导致数据不一致、数据模型修改未正确走 diff 更新流程导致数组越界等。检查 dataSource 归属、对象引用关系与 diff 更新顺序。

																																Q：内容变更后 cell 消失直到滚动才显示？
																																A：DifferenceKit 会对内容变化的 item 执行 `reloadRows`，若你复用同一 cell 实例，UIKit 在 reload 动画期间可能对同一 view 做淡入淡出导致异常。推荐使用 dequeue 或禁用自动 reloadRows（由你手动 `reloadRows(at:with:.none)` 并做自定义动画）。

																																Q：KVO 的观察需要手动移除吗？
																																A：若使用 `NSKeyValueObservation`（Swift 的 `observe` 返回值），只要保存观察对象为属性，系统会在其释放时自动注销，无需手动 removeObserver。

																																Q：如何禁止 ObjC 端调用 `[[ZLFormRowDescriptor alloc] init]`？
																																A：在 Swift 端用 `@available(*, unavailable)`，在 ObjC 头里用 `NS_UNAVAILABLE` 标注 `-init` / `+new`，并在运行时用断言或 `fatalError` 做兜底。

																																开发建议
																																--------

																																- 始终用 `ZLForm.xcworkspace` 打开工程（CocoaPods）。
																																- 更新数据时遵循“构造 target → 计算 StagedChangeset → tableView.reload(using:) → 在 setData 中更新 formSections”的模式。
																																- 把 `allSections` 作为权威数据源，`formSections` 仅用于展示，方便实现隐藏、排序与差量刷新。

																																需要我做什么？
																																----------------

																																我可以：

																																- 增加一个更精简的快速开始示例（少于 50 行）；
																																- 在代码库中自动扫描 `formSections` 是否在 `setData` 之外被修改并添加注释或修复建议；
																																- 将 README 导出为 PDF 或其他语言版本。

																																告诉我你想要的扩展，我会继续补充。
