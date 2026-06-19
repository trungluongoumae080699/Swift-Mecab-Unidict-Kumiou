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

The dictionary binaries are not bundled with this package — they exceed
GitHub's per-file size limit. Clients must download `unidic-lite` separately
and add it to their app bundle (or any container they can resolve a URL to),
then pass that URL to `init(url:)` or `init(bundle:resourceName:)`.
*/
public struct Unidic: UnidicDictionaryProviding {

    public let url: URL

    /// Initialize from an explicit URL pointing to a `unidic-lite` directory.
    /// The directory must contain `sys.dic`, `matrix.bin`, `char.bin`,
    /// `unk.dic`, and `dicrc`.
    public init(url: URL) {
        self.url = url
    }

    /// Locate a `unidic-lite` folder inside a bundle the client app controls.
    /// Defaults to `Bundle.main` and a folder named `"unidic-lite"`.
    /// Returns `nil` if the resource is missing.
    public init?(bundle: Bundle = .main, resourceName: String = "unidic-lite") {
        guard let url = bundle.url(forResource: resourceName, withExtension: nil) else {
            return nil
        }
        self.url = url
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
