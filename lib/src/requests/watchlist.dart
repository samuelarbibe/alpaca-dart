import '../alpaca_api.dart';

/// Contains all account-related requests.
class Watchlist {
  static AlpacaRequest get() => AlpacaRequest.get('/v2/watchlists');

  static AlpacaRequest getOne(String watchlistId) {
    if (watchlistId == null || watchlistId.isEmpty) {
      throw ArgumentError(
          'watchlist UID must be a non-empty String: $watchlistId');
    }

    return AlpacaRequest.get('/v2/watchlists/$watchlistId');
  }

  static AlpacaRequest add(String watchlistId, String symbol) {
    final params = {
      'symbol': symbol,
    }..removeWhere((k, v) => v == null || v.isEmpty);

    if (watchlistId == null || watchlistId.isEmpty) {
      throw ArgumentError(
          'watchlist UID must be a non-empty String: $watchlistId');
    }

    if (symbol == null || symbol.isEmpty) {
      throw ArgumentError('symbol must be a non-empty String: $symbol');
    }

    return AlpacaRequest.post('/v2/watchlists/$watchlistId', params);
  }

  static AlpacaRequest remove(String watchlistId, String symbol) {
    if (watchlistId == null || watchlistId.isEmpty) {
      throw ArgumentError(
          'watchlist UID must be a non-empty String: $watchlistId');
    }

    if (symbol == null || symbol.isEmpty) {
      throw ArgumentError('symbol must be a non-empty String: $symbol');
    }

    return AlpacaRequest.delete('/v2/watchlists/$watchlistId/$symbol');
  }
}
