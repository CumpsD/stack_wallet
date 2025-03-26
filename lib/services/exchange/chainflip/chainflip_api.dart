import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../exceptions/exchange/exchange_exception.dart';
import '../../../external_api_keys.dart';
import '../../../networking/http.dart';
import '../../../utilities/logger.dart';
import '../../../utilities/prefs.dart';
import '../exchange_response.dart';
import 'api_response_models/cf_currency.dart';
import 'api_response_models/cf_estimate.dart';

class ChainflipAPI {
  ChainflipAPI._();

  // TODO: Move to external api keys
  static const authority = "chainflip-broker.io";
  static const apiKey = "6ba154d4-e219-472a-9674-5fa5b1300ccf";
  static const commissionBps = "20";

  static const Map<String, String> cfToSwCurrencyMap = {
    'btc.btc': 'BTC',
    'dot.dot': 'DOT',
    'eth.arb': 'ETHARB',
    'eth.eth': 'ETH',
    'flip.eth': 'FLIP',
    'sol.sol': 'SOL',
    'usdc.arb': 'USDCARB',
    'usdc.eth': 'USDC',
    'usdc.sol': 'USDCSOL',
    'usdt.eth': 'USDTERC20',
  };

  static const Map<String, String> swToCfCurrencyMap = {
    'BTC': 'btc.btc',
    'DOT': 'dot.dot',
    'ETHARB': 'eth.arb',
    'ETH': 'eth.eth',
    'FLIP': 'flip.eth',
    'SOL': 'sol.sol',
    'USDCARB':  'usdc.arb',
    'USDC': 'usdc.eth',
    'USDCSOL': 'usdc.sol',
    'USDTERC20': 'usdt.eth',
  };

  static ChainflipAPI? _instance;
  static ChainflipAPI get instance => _instance ??= ChainflipAPI._();

  final _client = HTTP();

  Uri _buildUri({required String endpoint, Map<String, String>? params}) {
    return Uri.https(authority, "/$endpoint", params);
  }

  Future<dynamic> _makeGetRequest(Uri uri) async {
    Logging.instance.log(
      "Chainflip._makeGetRequest(): $uri",
      level: LogLevel.Info,
    );

    int code = -1;
    try {
      final response = await _client.get(
        url: uri,
        headers: {
          'Accept': 'application/json',
        },
        proxyInfo: null,
      );

      code = response.code;

      final parsed = jsonDecode(response.body);

      return parsed;
    } catch (e, s) {
      Logging.instance.log(
        "ChainflipAPI._makeRequest($uri) HTTP:$code threw: $e\n$s",
        level: LogLevel.Error,
      );
      rethrow;
    }
  }

  // ============= API ===================================================

  // GET List of supported currencies
  // https://chainflip-broker.io/assets
  Future<ExchangeResponse<List<CFCurrency>>> getSupportedCurrencies() async {
    final uri = _buildUri(
      endpoint: "assets",
    );

    try {
      final json = await _makeGetRequest(uri);

      final jsonCurrencies = Map<String, dynamic>.from(json as Map)["assets"] as List<dynamic>;

      final List<CFCurrency> currencies = jsonCurrencies
          .map((item) => CFCurrency.fromJson(Map<String, dynamic>.from(item as Map), cfToSwCurrencyMap))
          .toList();

      return ExchangeResponse(value: currencies);
    } catch (e, s) {
      Logging.instance.log(
        "Chainflip.getSupportedCurrencies(): $e\n$s",
        level: LogLevel.Error,
      );
      return ExchangeResponse(
        exception: ExchangeException(
          e.toString(),
          ExchangeExceptionType.generic,
        ),
      );
    }
  }

  // GET Get estimate
  // https://chainflip-broker.io/quotes?apikey=XXX&sourceAsset=btc.btc&destinationAsset=usdt.eth&amount=1
  Future<ExchangeResponse<CFEstimate>> getEstimate({
    required String amountFrom,
    required String from,
    required String to,
  }) async {
    Logging.instance.log(
      "Chainflip.getEstimate(): $from -> $to",
      level: LogLevel.Info,
    );

    final uri = _buildUri(
      endpoint: "quotes",
      params: {
        "apikey": apiKey,
        "commissionBps": commissionBps,
        "sourceAsset": swToCfCurrencyMap[from]!,
        "destinationAsset": swToCfCurrencyMap[to]!,
        "amount": amountFrom,
      },
    );

    try {
      final json = await _makeGetRequest(uri);

      try {
        if (json is Map<String, dynamic>) {
          final potentialError = Map<String, dynamic>.from(json as Map);
          if (potentialError != null) {
            final errorMessage = potentialError["detail"] as String?;

            if (errorMessage != null) {
              return ExchangeResponse(
                exception: ExchangeException(
                  errorMessage,
                  ExchangeExceptionType.generic,
                ),
              );
            }
          }
        }

        final List<dynamic> jsonEstimates = json as List<dynamic>;

        final List<CFEstimate> estimates = jsonEstimates
            .map((item) => CFEstimate.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
  
        CFEstimate? dcaEstimate = estimates.cast<CFEstimate?>().firstWhere(
          (estimate) => estimate?.estimateType == "dca",
          orElse: () => null,
        );

        if (dcaEstimate != null) {
          return ExchangeResponse(
            value: dcaEstimate
          );
        }

        CFEstimate? regularEstimate = estimates.cast<CFEstimate?>().firstWhere(
          (estimate) => estimate?.estimateType == "regular",
          orElse: () => null,
        );

        if (regularEstimate != null) {
          return ExchangeResponse(
            value: regularEstimate
          );
        }

        return ExchangeResponse(
          exception: ExchangeException(
            "No estimates found",
            ExchangeExceptionType.generic,
          ),
        );
      } catch (_) {
        Logging.instance.log(
          "Chainflip.getEstimate() response was: $json",
          level: LogLevel.Error,
        );
        rethrow;
      }
    } catch (e, s) {
      Logging.instance.log(
        "Chainflip.getEstimate() exception: $e\n$s",
        level: LogLevel.Error,
      );
      return ExchangeResponse(
        exception: ExchangeException(
          e.toString(),
          ExchangeExceptionType.generic,
        ),
      );
    }
  }
}