//
//  Theme.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2014-04-12.
//
//  ---------------------------------------------------------------------------
//
//  © 2014-2024 1024jp
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import AppKit.NSColor
import ColorCode

struct Theme: Equatable {
    
    struct Style: Equatable {
        
        var color: NSColor
        
        fileprivate static let invalidColor: NSColor = .gray
    }
    
    
    struct SystemDefaultStyle: Equatable {
        
        var color: NSColor
        var usesSystemSetting: Bool
    }
    
    
    struct Metadata: Equatable, Codable {
        
        var author: String?
        var distributionURL: String?
        var license: String?
        var description: String?
        
        var isEmpty: Bool {
            
            [self.author, self.distributionURL, self.license, self.description].compactMap({ $0 }).isEmpty
        }
    }
    
    
    
    // MARK: Public Properties
    
    /// Name of the theme
    var name: String?
    
    // basic colors
    var text: Style
    var background: Style
    var invisibles: Style
    var selection: SystemDefaultStyle
    var insertionPoint: SystemDefaultStyle
    var lineHighlight: Style
    
    var keywords: Style
    var commands: Style
    var types: Style
    var attributes: Style
    var variables: Style
    var values: Style
    var numbers: Style
    var strings: Style
    var characters: Style
    var comments: Style
    
    var metadata: Metadata?
    
    
    
    // MARK: Lifecycle
    
    init(name: String? = nil) {
        
        self.name = name
        
        self.text = Style(color: .textColor)
        self.background = Style(color: .textBackgroundColor)
        self.invisibles = Style(color: .init(white: 0.7, alpha: 1))
        self.selection = SystemDefaultStyle(color: .selectedTextBackgroundColor, usesSystemSetting: true)
        self.insertionPoint = SystemDefaultStyle(color: .textColor, usesSystemSetting: true)
        self.lineHighlight = Style(color: .init(white: 0.95, alpha: 1))
        
        self.keywords = Style(color: .gray)
        self.commands = Style(color: .gray)
        self.types = Style(color: .gray)
        self.attributes = Style(color: .gray)
        self.variables = Style(color: .gray)
        self.values = Style(color: .gray)
        self.numbers = Style(color: .gray)
        self.strings = Style(color: .gray)
        self.characters = Style(color: .gray)
        self.comments = Style(color: .gray)
    }
    
    
    init(contentsOf fileURL: URL) throws {
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        
        self = try decoder.decode(Theme.self, from: data)
        self.name = fileURL.deletingPathExtension().lastPathComponent
    }
    
    
    
    // MARK: Public Methods
    
    /// Is background color dark?
    var isDarkTheme: Bool {
        
        guard
            let textColor = self.text.color.usingColorSpace(.genericRGB),
            let backgroundColor = self.background.color.usingColorSpace(.genericRGB)
        else { return false }
        
        return backgroundColor.lightnessComponent < textColor.lightnessComponent
    }
    
    
    /// Insertion point color to use.
    var effectiveInsertionPointColor: NSColor {
        
        self.insertionPoint.usesSystemSetting ? .textInsertionPointColor : self.insertionPoint.color
    }
    
    
    /// The selection color to use.
    var selectionColor: NSColor {
        
        if self.selection.usesSystemSetting {
            NSColor(name: nil) { [isDarkTheme = self.isDarkTheme] appearance in
                if isDarkTheme == appearance.isDark {
                    .selectedTextBackgroundColor
                } else {
                    .selectedTextBackgroundColor.solve(for: appearance.appearance(for: isDarkTheme))
                }
            }
        } else {
            self.selection.color
        }
    }
    
    
    /// The selection color to use for inactive views.
    var unemphasizedSelectionColor: NSColor? {
        
        if self.selection.usesSystemSetting {
            return NSColor(name: nil) { [isDarkTheme = self.isDarkTheme] appearance in
                if isDarkTheme == appearance.isDark {
                    .unemphasizedSelectedContentBackgroundColor
                } else {
                    .unemphasizedSelectedContentBackgroundColor.solve(for: appearance.appearance(for: isDarkTheme))
                }
            }
        } else {
            guard let color = self.selection.color.usingColorSpace(.genericRGB) else { return nil }
            
            return NSColor(calibratedWhite: color.lightnessComponent, alpha: 1.0)
        }
    }
}



// MARK: - Codable

extension Theme: Codable { }



extension Theme.Style: Codable {
    
    private enum CodingKeys: String, CodingKey {
        
        case color
    }
    
    
    init(from decoder: any Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let colorCode = try container.decode(String.self, forKey: .color)
        let color = NSColor(colorCode: colorCode) ?? Theme.Style.invalidColor
        
        self.init(color: color)
    }
    
    
    func encode(to encoder: any Encoder) throws {
        
        guard let color = self.color.usingColorSpace(.genericRGB) else {
            throw EncodingError.invalidValue(self.color, .init(codingPath: [CodingKeys.color],
                                                               debugDescription: "The color could not be converted to the generic color space."))
        }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let type: ColorCodeType = (color.alphaComponent == 1) ? .hex : .hexWithAlpha
        try container.encode(color.colorCode(type: type), forKey: .color)
    }
}



extension Theme.SystemDefaultStyle: Codable {
    
    private enum CodingKeys: String, CodingKey {
        
        case color
        case usesSystemSetting
    }
    
    
    init(from decoder: any Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let colorCode = try container.decode(String.self, forKey: .color)
        let color = NSColor(colorCode: colorCode) ?? Theme.Style.invalidColor
        
        let usesSystemSetting = try container.decodeIfPresent(Bool.self, forKey: .usesSystemSetting) ?? false
        
        self.init(color: color, usesSystemSetting: usesSystemSetting)
    }
    
    
    func encode(to encoder: any Encoder) throws {
        
        guard let color = self.color.usingColorSpace(.genericRGB) else {
            throw EncodingError.invalidValue(self.color, .init(codingPath: [CodingKeys.color],
                                                               debugDescription: "The color could not be converted to the generic color space."))
        }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(color.colorCode(type: .hex), forKey: .color)
        try container.encode(self.usesSystemSetting, forKey: .usesSystemSetting)
    }
}
