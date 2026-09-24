class DictionaryEndpoints {
  DictionaryEndpoints._();

  static const entryEndpoint =
      'https://api.dictionaryapi.dev/api/v2/entries/en/';
  static const suggestionEndpoint = 'https://api.datamuse.com/sug';
  static const wiktionaryDefinitionEndpoint =
      'https://en.wiktionary.org/api/rest_v1/page/definition/';
  static const wiktionaryMediaEndpoint =
      'https://en.wiktionary.org/api/rest_v1/page/media-list/';

  static const headers = <String, String>{
    'User-Agent': 'LingoLearn/1.0 (Flutter)',
    'Accept': 'application/json',
  };
  static const wiktionaryHeaders = <String, String>{
    'User-Agent': 'LingoLearn/1.0 (Flutter; educational language app)',
    'Accept': 'application/json',
  };

  static const requestTimeout = Duration(seconds: 12);
  static const primaryBudget = Duration(seconds: 3);
  static const wiktionaryBudget = Duration(seconds: 4);
  static const connectTimeout = Duration(seconds: 6);
  static const isolateParseThreshold = 16 * 1024;
}
