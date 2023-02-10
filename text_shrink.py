import yake

kw_extractor = None

def init():
    kw_extractor = yake.KeywordExtractor(top=30, stopwords=None)

def shrink(text):
    keywords = kw_extractor.extract_keywords(text)
    words = [i[0] for i in keywords ]
    word_str=' '.join(words)
    return word_str


