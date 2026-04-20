"""
Roman-script -> Devanagari phonetic transliteration for the English loanwords
that appear in Project Bodhi's code-switched Hindi content.

Not a general transliterator -- a curated lookup. MMS-TTS-Hindi's tokenizer
silently drops Roman characters, so without this module code-switched English
words vanish from the spoken output. Pre-transliterating them keeps them
audible. Map tuned against wave-1 corpus (verses 2/6/11/20/32,
sutras 1.1/1.2/1.33/2.3/2.16) -- 100% coverage of every English word that
appears in those ``hindi_explanation``/``hindi_example`` fields.
"""

from __future__ import annotations

import re

# Phonetic as a Hindi speaker would actually say it.
LOANWORD_MAP: dict[str, str] = {
    # tech / apps / digital
    "instagram": "इंस्टाग्राम", "reel": "रील", "reels": "रील्स", "slack": "स्लैक",
    "whatsapp": "व्हाट्सऐप", "iphone": "आईफ़ोन", "phone": "फ़ोन", "app": "ऐप",
    "notification": "नोटिफ़िकेशन", "notifications": "नोटिफ़िकेशन्स",
    "tab": "टैब", "tabs": "टैब्स", "email": "ईमेल", "message": "मैसेज",
    "reply": "रिप्लाई", "linkedin": "लिंक्डइन", "ferrari": "फेरारी",
    "algorithm": "एल्गोरिदम", "notion": "नोशन", "udemy": "यूडेमी",
    "zomato": "ज़ोमैटो", "scroll": "स्क्रॉल", "post": "पोस्ट", "feed": "फीड",
    "photo": "फोटो", "photos": "फोटोज़", "unread": "अनरीड", "series": "सीरीज़",
    "check": "चेक", "save": "सेव", "sign": "साइन", "up": "अप", "off": "ऑफ़",
    "order": "ऑर्डर",
    # work / career / life-admin
    "office": "ऑफ़िस", "meeting": "मीटिंग", "team": "टीम", "client": "क्लाइंट",
    "deadline": "डेडलाइन", "promotion": "प्रमोशन", "board": "बोर्ड",
    "ceo": "सीईओ", "quarterly": "क्वार्टरली", "report": "रिपोर्ट",
    "revenue": "रेवेन्यू", "projection": "प्रोजेक्शन", "startup": "स्टार्टअप",
    "kpi": "केपीआई", "metric": "मेट्रिक", "boss": "बॉस", "colleague": "कॉलीग",
    "joinee": "जॉइनी", "junior": "जूनियर", "college": "कॉलेज",
    "project": "प्रोजेक्ट", "projects": "प्रोजेक्ट्स", "task": "टास्क",
    "deliver": "डिलीवर", "hustle": "हसल", "productive": "प्रोडक्टिव",
    "effort": "एफर्ट", "stack": "स्टैक", "list": "लिस्ट", "items": "आइटम्स",
    "calendar": "कैलेंडर", "block": "ब्लॉक", "books": "बुक्स", "course": "कोर्स",
    "race": "रेस", "comment": "कमेंट", "raise": "रेज़",
    "performance": "परफॉर्मेंस",
    # time / temporal
    "monday": "मंडे", "tuesday": "ट्यूज़डे", "wednesday": "वेडनेसडे",
    "thursday": "थर्सडे", "friday": "फ्राइडे", "saturday": "सैटरडे",
    "sunday": "संडे", "second": "सेकंड", "minute": "मिनट", "minutes": "मिनट",
    "hour": "घंटा", "moment": "मोमेंट", "moments": "मोमेंट्स", "past": "पास्ट",
    "future": "फ़्यूचर",
    # body / food / health / misc
    "focus": "फ़ोकस", "coffee": "कॉफ़ी", "chai": "चाय", "lunch": "लंच",
    "sleep": "स्लीप", "bank": "बैंक", "balance": "बैलेंस",
    "therapist": "थेरेपिस्ट", "therapy": "थेरेपी", "session": "सेशन",
    "cortisol": "कॉर्टिसोल", "blood": "ब्लड", "pressure": "प्रेशर",
    "health": "हेल्थ", "bloating": "ब्लोटिंग", "overeating": "ओवरईटिंग",
    "sluggish": "स्लगिश", "feeling": "फीलिंग", "pleasure": "प्लेज़र",
    "stress": "स्ट्रेस", "killer": "किलर", "shortcut": "शॉर्टकट",
    "alarm": "अलार्म", "party": "पार्टी", "news": "न्यूज़",
    "traffic": "ट्रैफ़िक",
    # spiritual / cultural -- keep audible
    "shankara": "शंकर", "patanjali": "पतंजलि", "vipassana": "विपश्यना",
    "diwali": "दिवाली", "sutra": "सूत्र", "temple": "टेम्पल",
    "retreat": "रिट्रीट", "meditation": "मेडिटेशन", "spiritual": "स्पिरिचुअल",
    # abstract / emotional / relational
    "chance": "चांस", "capacity": "कैपेसिटी", "impossible": "इम्पॉसिबल",
    "odds": "ऑड्स", "lucky": "लकी", "form": "फॉर्म", "planet": "प्लैनेट",
    "perfect": "परफेक्ट", "perfectly": "परफेक्टली", "activity": "एक्टिविटी",
    "silence": "साइलेंस", "action": "एक्शन", "being": "बीइंग",
    "doing": "डूइंग", "gap": "गैप", "habits": "हैबिट्स",
    "generation": "जेनरेशन", "sunlight": "सनलाइट", "mind": "माइंड",
    "ready": "रेडी", "organized": "ऑर्गनाइज़्ड", "coded": "कोडेड",
    "colour": "कलर", "character": "कैरेक्टर", "screen": "स्क्रीन",
    "movie": "मूवी", "changes": "चेंजेस", "relationship": "रिलेशनशिप",
    "relationships": "रिलेशनशिप्स", "thoughts": "थॉट्स", "thought": "थॉट",
    "high": "हाई", "same": "सेम", "notice": "नोटिस", "witness": "विटनेस",
    "love": "लव", "story": "स्टोरी", "self": "सेल्फ", "obsession": "ऑब्सेशन",
    "random": "रैंडम", "practice": "प्रैक्टिस", "formula": "फॉर्मूला",
    "jealousy": "जेलसी", "genuinely": "जेन्युइनली",
    "consciously": "कॉन्शियसली", "copy": "कॉपी", "reaction": "रिऐक्शन",
    "react": "रिऐक्ट", "switch": "स्विच", "switches": "स्विचेस",
    "appreciation": "अप्रिसिएशन", "sad": "सैड", "trigger": "ट्रिगर",
    "identity": "आइडेंटिटी", "hurt": "हर्ट", "pattern": "पैटर्न",
    "tag": "टैग", "tagging": "टैगिंग", "fix": "फिक्स", "new": "न्यू",
    "decisions": "डिसिज़न्स", "choice": "चॉइस", "gestate": "जेस्टेट",
    "travel": "ट्रैवल", "try": "ट्राई", "headstand": "हेडस्टैंड",
    "mat": "मैट", "chair": "चेयर", "result": "रिज़ल्ट",
    # romanized Hindi filler
    "kal": "कल",
    # tiny english connectives inside quoted phrases like "is this it?"
    "is": "इज़", "this": "दिस", "it": "इट", "to": "टू", "do": "डू",
}

# Whole-word regex. Roman letters only.
_WORD_RE = re.compile(r"[A-Za-z]+")

# Last-resort letter-by-letter fallback for unknown words (crude but better
# than a silent drop). Proper fix: add the word to LOANWORD_MAP.
_LETTER_FALLBACK: dict[str, str] = {
    "a": "अ", "b": "ब", "c": "क", "d": "ड", "e": "ए", "f": "फ़", "g": "ग",
    "h": "ह", "i": "आइ", "j": "ज", "k": "क", "l": "ल", "m": "म", "n": "न",
    "o": "ओ", "p": "प", "q": "क्यू", "r": "र", "s": "स", "t": "ट", "u": "यू",
    "v": "व", "w": "व", "x": "एक्स", "y": "य", "z": "ज़",
}


def transliterate_for_tts(text: str) -> str:
    """Replace known English loanwords with their Devanagari phonetic form.

    Unknown Roman-letter words fall back to letter-by-letter phonetics so the
    TTS engine voices *something* rather than silently dropping them.
    """

    def _sub(m: "re.Match[str]") -> str:
        original = m.group(0)
        mapped = LOANWORD_MAP.get(original.lower())
        return mapped if mapped is not None else _fallback(original)

    return _WORD_RE.sub(_sub, text)


def _fallback(word: str) -> str:
    return "".join(_LETTER_FALLBACK.get(c.lower(), c) for c in word)
