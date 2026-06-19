//
//  Unidic.swift
//  Mecab-Swift
//
//  Created by KumikoOumae on 19/6/26.
//

import Foundation
import Dictionary

/**
A wrapper around unidic-lite. UniDic uses a 26-field feature CSV with a
different layout than IPADic; the field schema is declared in
`unidic-lite/dicrc` and mirrored on `UnidicTokenIndexProviding`.
*/
public struct Unidic: UnidicDictionaryProviding {

    public let url: URL

    public init() {
        self.url = Bundle.module.url(forResource: "unidic-lite", withExtension: nil)!
    }

    public var description: String {
        return "Dictionary: \(url), Type: UniDic"
    }

    // MARK: - Feature CSV indices (per unidic-lite/dicrc)

    public var pos1Index: Int { 0 }
    public var pos2Index: Int { 1 }
    public var pos3Index: Int { 2 }
    public var pos4Index: Int { 3 }
    public var cTypeIndex: Int { 4 }
    public var cFormIndex: Int { 5 }
    public var lFormIndex: Int { 6 }
    public var lemmaIndex: Int { 7 }
    public var orthIndex: Int { 8 }
    public var pronIndex: Int { 9 }
    public var orthBaseIndex: Int { 10 }
    public var pronBaseIndex: Int { 11 }
    public var goshuIndex: Int { 12 }
    public var iTypeIndex: Int { 13 }
    public var iFormIndex: Int { 14 }
    public var fTypeIndex: Int { 15 }
    public var fFormIndex: Int { 16 }
    public var kanaIndex: Int { 17 }
    public var kanaBaseIndex: Int { 18 }
    public var formIndex: Int { 19 }
    public var formBaseIndex: Int { 20 }
    public var iConTypeIndex: Int { 21 }
    public var fConTypeIndex: Int { 22 }
    public var aTypeIndex: Int { 23 }
    public var aConTypeIndex: Int { 24 }
    public var aModTypeIndex: Int { 25 }

    public func partOfSpeech(pos1: String) -> PartOfSpeech {
        switch pos1 {
        case "名詞", "代名詞":
            return .noun
        case "動詞":
            return .verb
        case "形容詞", "形状詞":
            return .adjective
        case "副詞":
            return .adverb
        case "助詞", "助動詞":
            return .particle
        case "接頭辞":
            return .prefix
        case "補助記号", "記号":
            return .symbol
        default:
            return .unknown
        }
    }
}
