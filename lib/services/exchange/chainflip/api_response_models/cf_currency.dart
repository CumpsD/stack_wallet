class CFCurrency {
  final String id;
  final String ticker;
  final String name;
  final String image;
  final String network;
  final num minAmount;

  CFCurrency({
    required this.id,
    required this.ticker,
    required this.name,
    required this.image,
    required this.network,
    required this.minAmount,
  });

  factory CFCurrency.fromJson(Map<String, dynamic> json, Map<String, String> currencyMap) {
    return CFCurrency(
      id: json["id"] as String,
      ticker: currencyMap[json['id'] as String] ?? "",
      name: json['name'] as String,
      image: json['assetLogo'] as String,
      network: json['network'] as String,
      minAmount: json['minimalAmount'] as num,
    );
  }

  // TODO: Add minAmount, usdPrice (for slippage)

  @override
  String toString() {
    return 'CFCurrency {'
        'ticker: $ticker, '
        'name: $name, '
        'image: $image, '
        'network: $network, '
        'minimalAmount: $minAmount'
        '}';
  }
}
