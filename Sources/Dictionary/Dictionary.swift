//
//  Dictionary.swift
//  
//
//  Created by Morten Bertz on 2021/06/22.
//

import Foundation

/**
 The protocol for the dictionary type. 
 */

public protocol DictionaryProviding:TokenIndexProviding, PartOfSpeechProviding   {
    var url:URL{get}
}

/**
 A protocol to find report the indices of various return values of the tokenizer
 */

public protocol TokenIndexProviding{
    var readingIndex:Int {get}
    var pronunciationIndex:Int {get}
    var dictionaryFormIndex:Int {get}
}


/**
 A protocol for Part-of-Speech tagging
 The ranges of the posID are taken from https://github.com/buruzaemon/natto/wiki/Node-Parsing-posid.
 https://github.com/m4p provided the impetus for this implementation
 An alternative (that potentially allows more granularity) would be to use the POS feature string at position 0.
 */
public protocol PartOfSpeechProviding {
    func partOfSpeech(posID:UInt16)->PartOfSpeech
}

// MARK: - UniDic

/**
 The protocol for UniDic-style dictionaries (e.g. unidic-lite).
 UniDic's feature CSV has 26 fields with a different layout than IPADic,
 so it needs its own protocol family rather than reusing `DictionaryProviding`.
 */
public protocol UnidicDictionaryProviding: UnidicTokenIndexProviding, UnidicPartOfSpeechProviding {
    var url: URL { get }
}

/**
 A protocol to report the indices of every field in the UniDic feature CSV.
 The 26 fields follow the layout declared in `unidic-lite/dicrc`.
 */
public protocol UnidicTokenIndexProviding {
    /// f[0] — Part of speech, level 1 (e.g. 名詞).
    var pos1Index: Int { get }
    /// f[1] — Part of speech, level 2.
    var pos2Index: Int { get }
    /// f[2] — Part of speech, level 3.
    var pos3Index: Int { get }
    /// f[3] — Part of speech, level 4.
    var pos4Index: Int { get }
    /// f[4] — Conjugation type (活用型).
    var cTypeIndex: Int { get }
    /// f[5] — Conjugation form (活用形).
    var cFormIndex: Int { get }
    /// f[6] — Lemma reading form (katakana of the lemma).
    var lFormIndex: Int { get }
    /// f[7] — Lemma / dictionary form with notation.
    var lemmaIndex: Int { get }
    /// f[8] — Orthographic surface form.
    var orthIndex: Int { get }
    /// f[9] — Pronunciation (katakana, with phonological changes).
    var pronIndex: Int { get }
    /// f[10] — Orthographic base form.
    var orthBaseIndex: Int { get }
    /// f[11] — Pronunciation base form.
    var pronBaseIndex: Int { get }
    /// f[12] — Word origin (和/漢/外/混/固/記号/不明).
    var goshuIndex: Int { get }
    /// f[13] — Initial-mora transformation type.
    var iTypeIndex: Int { get }
    /// f[14] — Initial-mora transformation form.
    var iFormIndex: Int { get }
    /// f[15] — Final-mora transformation type.
    var fTypeIndex: Int { get }
    /// f[16] — Final-mora transformation form.
    var fFormIndex: Int { get }
    /// f[17] — Kana surface form.
    var kanaIndex: Int { get }
    /// f[18] — Kana base form.
    var kanaBaseIndex: Int { get }
    /// f[19] — Surface form (general).
    var formIndex: Int { get }
    /// f[20] — Form base.
    var formBaseIndex: Int { get }
    /// f[21] — Initial-mora connection type.
    var iConTypeIndex: Int { get }
    /// f[22] — Final-mora connection type.
    var fConTypeIndex: Int { get }
    /// f[23] — Accent type (pitch accent number).
    var aTypeIndex: Int { get }
    /// f[24] — Accent connection type.
    var aConTypeIndex: Int { get }
    /// f[25] — Accent modification type.
    var aModTypeIndex: Int { get }
}

/**
 A protocol for Part-of-Speech tagging for UniDic-style dictionaries.
 UniDic's left-id/right-id scheme does not map to the IPADic posID ranges,
 and unidic-lite ships without `pos-id.def`, so classification is done from
 the pos1 feature string (f[0]) rather than a numeric ID.
 */
public protocol UnidicPartOfSpeechProviding {
    func partOfSpeech(pos1: String) -> PartOfSpeech
}
