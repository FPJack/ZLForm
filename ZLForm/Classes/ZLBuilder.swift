//
//  ZLBuilder.swift
//  ZLForm
//
//  Created by admin on 2026/5/27.
//

import Foundation

@resultBuilder
public struct FormBuilder {
    public static func buildBlock(_ components: ZLFormSectionDescriptor...) -> [ZLFormSectionDescriptor] {
        components
    }
}

@resultBuilder
public struct SectionBuilder {
    public static func buildBlock(_ components: ZLFormRowDescriptor...) -> [ZLFormRowDescriptor] {
        components
    }
}
