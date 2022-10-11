import torch
import transformers
import itertools
import pandas as pd
import nltk
from nltk import pos_tag
from nltk import RegexpParser
# nltk.download("all")
import stanza
from ai4bharat.transliteration import XlitEngine


def extractPhrase(nlp,src):
  postags = []
  ners = []# REQUIRE THIS

  doc = nlp(src)

  #POS TAGGING
  for sent in doc.sentences:
    for word in sent.words:
      postags.append((word.text,word.xpos))
  #NER
  for sent in doc.sentences:
   for token in sent.tokens:
     if token.ner !="O":
      ners.append(token.text)

  filtered = [] # REQUIRE THIS
  
  for pt in postags:
    if pt[1]=="JJ" or pt[1]=="JJR" or pt[1]=="JJS":
      filtered.append(pt[0])

  grammar = "NP: {<DT>?<JJ>*<NN>}"
  cp = nltk.RegexpParser(grammar)
  
  nphrases = [] # REQUIRE THIS

  for np in cp.parse(postags):
    if type(np)==nltk.tree.Tree:
      if np.label() =="NP":
        for p in np:
          nphrases.append(p[0])

  return filtered,ners,nphrases
 
def getAlignedPhrase(phrases,nphrase):
  
  for p in phrases:
    if nphrase in p[0]:
      return p

model = transformers.BertModel.from_pretrained('bert-base-multilingual-cased')
tokenizer = transformers.BertTokenizer.from_pretrained('bert-base-multilingual-cased')

def generateCmg(src,tgt):
    
    # pre-processing
    sent_src, sent_tgt = src.strip().split(), tgt.strip().split()
    token_src, token_tgt = [tokenizer.tokenize(word) for word in sent_src], [tokenizer.tokenize(word) for word in sent_tgt]
    wid_src, wid_tgt = [tokenizer.convert_tokens_to_ids(x) for x in token_src], [tokenizer.convert_tokens_to_ids(x) for x in token_tgt]
    ids_src, ids_tgt = tokenizer.prepare_for_model(list(itertools.chain(*wid_src)), return_tensors='pt', model_max_length=tokenizer.model_max_length, truncation=True)['input_ids'], tokenizer.prepare_for_model(list(itertools.chain(*wid_tgt)), return_tensors='pt', truncation=True, model_max_length=tokenizer.model_max_length)['input_ids']
    sub2word_map_src = []
    for i, word_list in enumerate(token_src):
      sub2word_map_src += [i for x in word_list]
    sub2word_map_tgt = []
    for i, word_list in enumerate(token_tgt):
      sub2word_map_tgt += [i for x in word_list]
    
    # alignment
    align_layer = 8
    threshold = 1e-3
    model.eval()
    with torch.no_grad():
      out_src = model(ids_src.unsqueeze(0), output_hidden_states=True)[2][align_layer][0, 1:-1]
      out_tgt = model(ids_tgt.unsqueeze(0), output_hidden_states=True)[2][align_layer][0, 1:-1]
    
      dot_prod = torch.matmul(out_src, out_tgt.transpose(-1, -2))
    
      softmax_srctgt = torch.nn.Softmax(dim=-1)(dot_prod)
      softmax_tgtsrc = torch.nn.Softmax(dim=-2)(dot_prod)
    
      softmax_inter = (softmax_srctgt > threshold)*(softmax_tgtsrc > threshold)
    
    align_subwords = torch.nonzero(softmax_inter, as_tuple=False)
    align_words = set()
    for i, j in align_subwords:
      align_words.add( (sub2word_map_src[i], sub2word_map_tgt[j]) )
    
    # printing
    class color:
       PURPLE = '\033[95m'
       CYAN = '\033[96m'
       DARKCYAN = '\033[36m'
       BLUE = '\033[94m'
       GREEN = '\033[92m'
       YELLOW = '\033[93m'
       RED = '\033[91m'
       BOLD = '\033[1m'
       UNDERLINE = '\033[4m'
       END = '\033[0m'
    
    # for i, j in sorted(align_words):
      
    #   print(f'{color.BOLD}{color.BLUE}{sent_src[i]}{color.END}==={color.BOLD}{color.RED}{sent_tgt[j]}{color.END}')
    
    phrases = []
    
    for aw in align_words:
      phrases.append((sent_src[aw[0]],sent_tgt[aw[1]]))
    
    # forcing mr to en translation for some words
    
    # reading word list from csv and creating a map
    
    mr_word_list = pd.read_csv('https://raw.githubusercontent.com/mukta-strot/marathi-shabd/develop/database/db.csv')
    mr_word_list.drop(['tags', 'context', 'example', 'comment'], axis=1, inplace=True)
    
    en, mr = list(mr_word_list['en']), list(mr_word_list['mr'])
    en_mr_list = dict()
    for i in range(len(en)):
      if type(mr[i]) == str and type(en[i]) == str:
        en_mr_list[mr[i]] = en[i]
    
    # force translating en words to mr if not translated in above step
    translit_phrases = phrases.copy()
    for i in range(len(translit_phrases)):
      if type(translit_phrases[i][1]) != str or len(translit_phrases[i][1]) < 1:
        out = en_mr_list.get(translit_phrases[i][0])
        if out != None:
          translit_phrases[i] = (translit_phrases[i][0], out, 'c')
    phrases = translit_phrases
    list(set(translit_phrases))
    
    
    nlp = stanza.Pipeline(lang='en', processors='tokenize,mwt,pos,ner')
      
    #PHRASES (GROUP OF SMALL WORDS)
    l1,l2,l3 = extractPhrase(nlp,src)
    
    aux_src = sent_src.copy()
    aux_tgt = sent_tgt.copy()
    e = XlitEngine("mr", beam_width=10, rescore=True)
    
    translit_idx = []
    
    for ner in l2:
      aphrase = getAlignedPhrase(phrases,ner)
      if aphrase != None:
        
        idx = sent_tgt.index(aphrase[1])
        out = e.translit_word(aphrase[0], topk=1) 
        aux_tgt[idx]= out["mr"][0]
        translit_idx.append(idx)
    
    for np in l3:
      aphrase = getAlignedPhrase(phrases,np)
      if aphrase != None:
      
        idx = sent_tgt.index(aphrase[1])
        out = e.translit_word(aphrase[0], topk=1) 
        aux_tgt[idx]= out["mr"][0]
        translit_idx.append(idx)
    
    for tk in l1:
       aphrase = getAlignedPhrase(phrases,tk)
       if aphrase != None:
      
        idx = sent_tgt.index(aphrase[1])
        out = e.translit_word(aphrase[0], topk=1) 
        aux_tgt[idx]= out["mr"][0]
        translit_idx.append(idx)
  
    return " ".join(aux_tgt)
