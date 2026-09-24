import 'dictionary_entry.dart';

enum DictionaryLookupStatus {
  idle,
  loading,
  found,
  notFound,
  networkError,
  timeout,
  invalidResponse,
  apiError,
}

class DictionaryLookupResult {
  final DictionaryLookupStatus status;
  final DictionaryEntry? entry;

  const DictionaryLookupResult._(this.status, [this.entry]);

  const DictionaryLookupResult.found(DictionaryEntry entry)
    : this._(DictionaryLookupStatus.found, entry);

  const DictionaryLookupResult.notFound()
    : this._(DictionaryLookupStatus.notFound);

  const DictionaryLookupResult.networkError()
    : this._(DictionaryLookupStatus.networkError);

  const DictionaryLookupResult.timeout()
    : this._(DictionaryLookupStatus.timeout);

  const DictionaryLookupResult.invalidResponse()
    : this._(DictionaryLookupStatus.invalidResponse);

  const DictionaryLookupResult.apiError()
    : this._(DictionaryLookupStatus.apiError);
}

DictionaryLookupResult combineFailures(List<DictionaryLookupResult> results) {
  if (results.any((r) => r.status == DictionaryLookupStatus.notFound)) {
    return const DictionaryLookupResult.notFound();
  }
  if (results.any((r) => r.status == DictionaryLookupStatus.timeout)) {
    return const DictionaryLookupResult.timeout();
  }
  if (results.any((r) => r.status == DictionaryLookupStatus.networkError)) {
    return const DictionaryLookupResult.networkError();
  }
  if (results.any((r) => r.status == DictionaryLookupStatus.invalidResponse)) {
    return const DictionaryLookupResult.invalidResponse();
  }
  return const DictionaryLookupResult.apiError();
}
