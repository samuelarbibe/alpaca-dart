import 'dart:async';

import 'package:http/http.dart' as http;
import 'requests/account.dart';
import 'requests/asset.dart';
import 'requests/calendar.dart';
import 'requests/clock.dart';
import 'requests/data/bars.dart';
import 'requests/order.dart';
import 'requests/position.dart';
import 'requests/watchlist.dart';

/// Alpaca REST API wrapper.
class AlpacaApi {
  final http.BaseClient _client;
  final String _baseUrl;
  final String _dataBaseUrl;
  final String _keyId;
  final String _secretKey;

  AlpacaApi({
    http.BaseClient client,
    String keyId,
    String secretKey,
    String baseUrl = 'api.alpaca.markets',
    String dataBaseUrl = 'data.alpaca.markets',
    String paperBaseUrl = 'paper-api.alpaca.markets',
    bool paperTrading = false,
  })  : _keyId = keyId,
        _secretKey = secretKey,
        _dataBaseUrl = dataBaseUrl,
        _client = client ?? http.Client(),
        _baseUrl = paperTrading ? paperBaseUrl : baseUrl;

  ///
  /// Account
  ///

  Future<http.Response> getAccount() => _executeAlpacaRequest(Account.get());

  Future<http.Response> getPortfolioHistory() =>
      _executeAlpacaRequest(Account.getPortfolioHistory());

  ///
  /// Calendar
  ///

  Future<http.Response> getCalendar({
    DateTime start,
    DateTime end,
  }) =>
      _executeAlpacaRequest(Calendar.get(
        start: start,
        end: end,
      ));

  ///
  /// Clock
  ///

  Future<http.Response> getClock() => _executeAlpacaRequest(Clock.get());

  ///
  /// Assets
  ///

  Future<http.Response> getAssets({
    String status,
    String assetClass,
  }) =>
      _executeAlpacaRequest(Asset.get(
        status: status,
        assetClass: assetClass,
      ));

  Future<http.Response> getAsset(String symbol) =>
      _executeAlpacaRequest(Asset.getOne(symbol));

  ///
  /// Positions
  ///

  Future<http.Response> getPositions() => _executeAlpacaRequest(Position.get());

  Future<http.Response> getPosition(String symbol) =>
      _executeAlpacaRequest(Position.getOne(symbol));

  Future<http.Response> closePosition(String symbol) =>
      _executeAlpacaRequest(Position.close(symbol));

  ///
  /// Orders
  ///

  Future<http.Response> cancelOrder(String orderId) =>
      _executeAlpacaRequest(Order.cancel(orderId));

  Future<http.Response> getOrder(String orderId) =>
      _executeAlpacaRequest(Order.getOne(orderId));

  Future<http.Response> getOrders({
    String status,
    int limit,
    DateTime after,
    DateTime until,
    String direction,
  }) =>
      _executeAlpacaRequest(Order.get(
        status: status,
        limit: limit,
        after: after,
        until: until,
        direction: direction,
      ));

  Future<http.Response> getOrderByClientOrderId(String clientOrderId) =>
      _executeAlpacaRequest(Order.getByClientOrderId(clientOrderId));

  Future<http.Response> createOrder(
    String symbol,
    String quantity,
    String side,
    String type,
    String timeInForce, {
    String limitPrice,
    String stopPrice,
    String clientOrderId,
  }) =>
      _executeAlpacaRequest(Order.create(
        symbol,
        quantity,
        side,
        type,
        timeInForce,
        limitPrice: limitPrice,
        stopPrice: stopPrice,
        clientOrderId: clientOrderId,
      ));

  ///
  /// Bars
  ///

  Future<http.Response> getBars(
    String timeframe,
    symbols, {
    int limit,
    DateTime start,
    DateTime end,
    DateTime after,
    DateTime until,
  }) =>
      _executeAlpacaRequest(Bars.get(
        timeframe,
        symbols,
        limit: limit,
        start: start,
        end: end,
        after: after,
        until: until,
      ));

  ///
  /// Watchlists
  ///

  Future<http.Response> getWatchlists() =>
      _executeAlpacaRequest(Watchlist.get());

  Future<http.Response> getWatchlist(String id) =>
      _executeAlpacaRequest(Watchlist.getOne(id));

  Future<http.Response> addToWatchlist(String watchlistId, String symbol) =>
      _executeAlpacaRequest(Watchlist.add(watchlistId, symbol));

  Future<http.Response> removeFromWatchlist(
          String watchlistId, String symbol) =>
      _executeAlpacaRequest(Watchlist.remove(watchlistId, symbol));

  /// Executes the given [AlpacaRequest].
  ///
  /// Calls the [BaseClient] to execute the request with the query parameter
  /// data in the request, after constructing the appropriate headers.
  Future<http.Response> _executeAlpacaRequest(AlpacaRequest request) async {
    // If params are empty, don't pass the empty map to Uri or we get a '?' at
    // the end of the url which is unnecessary and odd when testing.
    final params = request.params == null || request.params.isEmpty
        ? null
        : request.params;
    final uri = Uri.https(
        request is AlpacaDataRequest ? _dataBaseUrl : _baseUrl,
        request.path,
        params);
    final headers = {
      'APCA-API-KEY-ID': _keyId,
      'APCA-API-SECRET-KEY': _secretKey,
    }..addAll(
        request.method == 'DELETE' ? {} : {'content-type': 'application/json'});

    switch (request.method) {
      case 'DELETE':
        return _client.delete(uri, headers: headers);
      case 'POST':
        return _client.post(uri, body: request.params, headers: headers);
      case 'GET':
      default:
        return _client.get(uri, headers: headers);
    }
  }
}

/// Simple value class to hold request information.
class AlpacaRequest {
  final String path;
  final String method;
  final Map<String, String> params;

  AlpacaRequest._(this.path, [this.params, this.method]);

  AlpacaRequest.get(String path, [Map<String, String> params])
      : this._(path, params, 'GET');

  AlpacaRequest.post(String path, [Map<String, String> params])
      : this._(path, params, 'POST');

  AlpacaRequest.delete(String path, [Map<String, String> params])
      : this._(path, params, 'DELETE');
}

/// Simple value class to hold request information for Alpaca Data API requests.
class AlpacaDataRequest extends AlpacaRequest {
  AlpacaDataRequest(String path, [Map<String, String> params])
      : super.get(path, params);
}
