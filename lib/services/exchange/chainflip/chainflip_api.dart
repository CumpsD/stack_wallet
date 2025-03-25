import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../exceptions/exchange/exchange_exception.dart';
import '../../../external_api_keys.dart';
import '../../../networking/http.dart';
import '../../../utilities/logger.dart';
import '../../../utilities/prefs.dart';
import '../exchange_response.dart';
import 'api_response_models/cf_estimate.dart';

class ChainflipAPI {
  ChainflipAPI._();

  // TODO: Move to external api keys
  static const authority = "chainflip-broker.io";
  static const apiKey = "6ba154d4-e219-472a-9674-5fa5b1300ccf";
  static const commissionBps = "20";

  static ChainflipAPI? _instance;
  static ChainflipAPI get instance => _instance ??= ChainflipAPI._();

  final _client = HTTP();

  Uri _buildUri({required String endpoint, Map<String, String>? params}) {
    return Uri.https(authority, "/$endpoint", params);
  }

  Future<dynamic> _makeGetRequest(Uri uri) async {
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

  // GET Get estimate
  // https://chainflip-broker.io/quotes?apikey=XXX&sourceAsset=btc.btc&destinationAsset=usdt.eth&amount=1'
  Future<ExchangeResponse<CFEstimate>> getEstimate({
    required String amountFrom,
    required String from,
    required String to,
  }) async {
    final uri = _buildUri(
      endpoint: "quotes",
      params: {
        "apikey": apiKey,
        "commissionBps": commissionBps,
        "sourceAsset": "btc.btc",
        "destinationAsset": "eth.eth",
        "amount": amountFrom,
      },
    );

    try {
      final json = await _makeGetRequest(uri);

      try {
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