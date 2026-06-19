//
//  UnidicTokenizer.swift
//  Mecab-Swift
//
//  Parallel tokenizer for UniDic-style dictionaries (e.g. unidic-lite).
//  Mirrors `Tokenizer` but operates on `UnidicDictionaryProviding` and
//  returns `UnidicAnnotation`. No CoreFoundation system-tokenizer fallback —
//  the UniDic tokenizer always goes through mecab.
//

import mecab
import Foundation
import StringTools
import Dictionary

/**
 A morphological analyzer for Japanese, backed by a UniDic-style dictionary.
*/
public final class UnidicTokenizer {

    public enum Transliteration {
        case hiragana
        case katakana
        case romaji
    }

    public enum TokenizerError: Error {
        case initializationFailure(String)

        public var localizedDescription: String {
            switch self {
            case .initializationFailure(let error):
                return error
            }
        }
    }

    private let dictionary: UnidicDictionaryProviding
    private let _mecab: OpaquePointer

    public static var version: String {
        return String(cString: mecab_version(), encoding: .utf8) ?? ""
    }

    public init(dictionary: UnidicDictionaryProviding) throws {
        self.dictionary = dictionary
        let tokenizer = try dictionary.url.withUnsafeFileSystemRepresentation({ path -> OpaquePointer in
            guard let path = path,
                  let dictPath = String(cString: path)
                    .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            else {
                throw TokenizerError.initializationFailure("URL Conversion Failed \(dictionary)")
            }
            guard let tokenizer = mecab_new2("-d \(dictPath)") else {
                let error = String(cString: mecab_strerror(nil), encoding: .utf8) ?? ""
                throw TokenizerError.initializationFailure("Opening Dictionary Failed \(dictionary) \(error)")
            }
            return tokenizer
        })
        self._mecab = tokenizer
    }

    deinit {
        mecab_destroy(_mecab)
    }

    /**
     Tokenizes Japanese text into `UnidicAnnotation`s.
    */
    public func tokenize(text: String,
                         transliteration: Transliteration = .hiragana) -> [UnidicAnnotation] {
        let tokens = text.precomposedStringWithCanonicalMapping.withCString({ s -> [UnidicToken] in
            var tokens = [UnidicToken]()
            var node = mecab_sparse_tonode(self._mecab, s)
            while true {
                guard let n = node else { break }
                if let token = UnidicToken(node: n.pointee, tokenDescription: self.dictionary) {
                    tokens.append(token)
                }
                node = UnsafePointer(n.pointee.next)
            }
            return tokens
        })

        var annotations = [UnidicAnnotation]()
        var searchRange = text.startIndex..<text.endIndex
        for token in tokens {
            let searchString = token.original
            if searchString.isEmpty { continue }
            if let foundRange = text.range(of: searchString, options: [], range: searchRange, locale: nil) {
                let annotation = UnidicAnnotation(token: token, range: foundRange, transliteration: transliteration)
                annotations.append(annotation)
                if foundRange.upperBound < text.endIndex {
                    searchRange = foundRange.upperBound..<text.endIndex
                }
            }
        }
        return annotations
    }

    /**
     Convenience: produce `FuriganaAnnotation`s for the parts of `text` that contain Kanji.
    */
    public func furiganaAnnotations(for text: String,
                                    transliteration: Transliteration = .hiragana,
                                    options: [Annotation.AnnotationOption] = [.kanjiOnly]) -> [FuriganaAnnotation] {
        return self.tokenize(text: text, transliteration: transliteration)
            .filter({ $0.base.isEmpty == false })
            .compactMap({ $0.furiganaAnnotation(options: options, for: text) })
    }

    /**
     Convenience: wrap Kanji runs in `<ruby>` tags using UniDic readings.
    */
    public func addRubyTags(to htmlText: String,
                            transliteration: Transliteration = .hiragana,
                            options: [Annotation.AnnotationOption] = [.kanjiOnly]) -> String {
        let furigana = self.furiganaAnnotations(for: htmlText,
                                                transliteration: transliteration,
                                                options: options)
        var outString = ""
        var endIDX = htmlText.startIndex
        for annotation in furigana {
            outString += htmlText[endIDX..<annotation.range.lowerBound]
            let original = htmlText[annotation.range]
            outString += "<ruby>\(original)<rt>\(annotation.reading)</rt></ruby>"
            endIDX = annotation.range.upperBound
        }
        outString += htmlText[endIDX..<htmlText.endIndex]
        return outString
    }
}
