//
//  SortPatternError+Localization.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2018-01-05.
//
//  ---------------------------------------------------------------------------
//
//  © 2018-2024 1024jp
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
import LineSort

extension SortPatternError: @retroactive LocalizedError {
    
    public var errorDescription: String? {
        
        switch self {
            case .emptyPattern:
                String(localized: "Empty pattern",
                       table: "PatternSort",
                       comment: "error message (“pattern” is a regular expression pattern)")
            case .invalidRegularExpressionPattern:
                String(localized: "Invalid pattern",
                       table: "PatternSort",
                       comment: "error message (“pattern” is a regular expression pattern)")
        }
    }
}
