//
//  UnidicToken.swift
//  Mecab-Swift
//
//  Internal token type for the UniDic-backed tokenizer.
//  Mirrors `Token` but reads the 26-field UniDic feature CSV.
//

import Foundation
import mecab
import StringTools
import Dictionary

struct UnidicToken {

    let surface: String
    let features: [String]
    let partOfSpeech: PartOfSpeech
    let tokenDescription: UnidicTokenIndexProviding

    init?(node: mecab_node_t, tokenDescription: UnidicTokenIndexProviding & UnidicPartOfSpeechProviding) {
        guard let sPTR = node.surface else { return nil }
        let data = Data(bytes: sPTR, count: Int(node.length))
        guard let surface = String(data: data, encoding: .utf8),
              let parts = String(cString: node.feature, encoding: .utf8)?
                .split(separator: ",", omittingEmptySubsequences: false),
              parts.isEmpty == false
        else {
            return nil
        }

        self.surface = surface
        self.features = parts.map({ String($0) })

        let pos1 = self.features.count > tokenDescription.pos1Index
            ? self.features[tokenDescription.pos1Index]
            : ""
        self.partOfSpeech = tokenDescription.partOfSpeech(pos1: pos1)
        self.tokenDescription = tokenDescription
    }

    // UniDic uses "*" as a placeholder for an absent feature value.
    private func feature(at index: Int) -> String {
        guard features.count > index else { return "" }
        let value = features[index]
        return value == "*" ? "" : value
    }

    var original: String { surface }

    /// f[17] kana — kana surface form. Falls back to surface.
    var reading: String {
        let v = feature(at: tokenDescription.kanaIndex)
        return v.isEmpty ? surface : v
    }

    /// f[9] pron — pronunciation (with phonological changes). Falls back to reading.
    var pronunciation: String {
        let v = feature(at: tokenDescription.pronIndex)
        return v.isEmpty ? reading : v
    }

    /// f[7] lemma — dictionary form with notation. Falls back to surface.
    var dictionaryForm: String {
        let v = feature(at: tokenDescription.lemmaIndex)
        return v.isEmpty ? surface : v
    }

    /// f[6] lForm — katakana reading of the lemma.
    var lemmaReading: String {
        let v = feature(at: tokenDescription.lFormIndex)
        return v.isEmpty ? reading : v
    }

    /// f[23] aType — accent type (pitch). Empty when unknown.
    var accentType: String { feature(at: tokenDescription.aTypeIndex) }

    /// f[0..3] joined with "-", skipping placeholders.
    var partOfSpeechChain: String {
        [tokenDescription.pos1Index,
         tokenDescription.pos2Index,
         tokenDescription.pos3Index,
         tokenDescription.pos4Index]
            .map({ feature(at: $0) })
            .filter({ $0.isEmpty == false })
            .joined(separator: "-")
    }
}
