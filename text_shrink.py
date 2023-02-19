import yake

kw_extractor = yake.KeywordExtractor(top=30, stopwords=None)

def shrink(text):
    print("Shrinking the text")
    print("Actual text length is",len(text))
    print("Shrunk text is ")

    if(len(text)>50):
        keywords = kw_extractor.extract_keywords(text)
        words = [i[0] for i in keywords ]
        word_str=' '.join(words)

        return word_str
    
    return text


