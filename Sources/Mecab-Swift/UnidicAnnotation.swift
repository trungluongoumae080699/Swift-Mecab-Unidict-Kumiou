//
//  UnidicAnnotation.swift
//  Mecab-Swift
//
//  Public annotation type returned by `UnidicTokenizer`.
//  Parallel to `Annotation`, but surfaces UniDic-only fields
//  (pronunciation, lemma reading, accent type, POS chain).
//

import Foundation
import StringTools
import Dictionary

public struct UnidicAnnotation: Equatable, FuriganaAnnotating {

    public let base: String
    public let reading: String
    public let pronunciation: String
    public let dictionaryForm: String
    public let lemmaReading: String
    public let partOfSpeech: PartOfSpeech
    public let partOfSpeechChain: String
    public let accentType: String
    public let range: Range<String.Index>
    let transliteration: UnidicTokenizer.Transliteration

    init(token: UnidicToken, range: Range<String.Index>, transliteration: UnidicTokenizer.Transliteration) {
        self.init(
            base: token.original,
            reading: token.reading,
            pronunciation: token.pronunciation,
            dictionaryForm: token.dictionaryForm,
            lemmaReading: token.lemmaReading,
            partOfSpeech: token.partOfSpeech,
            partOfSpeechChain: token.partOfSpeechChain,
            accentType: token.accentType,
            range: range,
            transliteration: transliteration
        )
    }

    init(base: String,
         reading: String,
         pronunciation: String,
         dictionaryForm: String,
         lemmaReading: String,
         partOfSpeech: PartOfSpeech,
         partOfSpeechChain: String,
         accentType: String,
         range: Range<String.Index>,
         transliteration: UnidicTokenizer.Transliteration) {
        self.base = base
        self.range = range
        self.partOfSpeech = partOfSpeech
        self.partOfSpeechChain = partOfSpeechChain
        self.accentType = accentType
        self.transliteration = transliteration

        switch transliteration {
        case .katakana:
            self.reading = reading
            self.pronunciation = pronunciation
            self.dictionaryForm = dictionaryForm
            self.lemmaReading = lemmaReading
        case .hiragana:
            self.reading = reading.hiraganaString
            self.pronunciation = pronunciation.hiraganaString
            self.dictionaryForm = dictionaryForm.hiraganaString
            self.lemmaReading = lemmaReading.hiraganaString
        case .romaji:
            self.reading = reading.romanizedString(method: .hepburn)
            self.pronunciation = pronunciation.romanizedString(method: .hepburn)
            self.dictionaryForm = dictionaryForm.romanizedString(method: .hepburn)
            self.lemmaReading = lemmaReading.romanizedString(method: .hepburn)
        }
    }

    @inlinable public var containsKanji: Bool {
        return self.base.containsKanjiCharacters
    }

    public func furiganaAnnotation(for string: String) -> FuriganaAnnotation {
        return FuriganaAnnotation(reading: self.reading, range: self.range)
    }

    /// Reuses `Annotation.AnnotationOption` so callers can share filter sets across IPADic and UniDic.
    public func furiganaAnnotation(options: [Annotation.AnnotationOption] = [.kanjiOnly],
                                   for string: String) -> FuriganaAnnotation? {
        for case let Annotation.AnnotationOption.filter(disallowed, strict) in options {
            let kanji = Set(self.base.kanjiCharacters)
            if strict == true, disallowed.isDisjoint(with: kanji) == false {
                return nil
            } else if strict == false, disallowed.isSuperset(of: kanji) {
                return nil
            }
        }

        if options.contains(.kanjiOnly) {
            guard self.containsKanji else { return nil }
            return self.furiganaAnnotation(for: string, kanjiOnly: true)
        } else {
            return FuriganaAnnotation(reading: self.reading, range: self.range)
        }
    }
}

extension UnidicAnnotation: CustomStringConvertible {
    public var description: String {
        return "Base: \(base), reading: \(reading), pron: \(pronunciation), POS: \(partOfSpeech), aType: \(accentType)"
    }
}
