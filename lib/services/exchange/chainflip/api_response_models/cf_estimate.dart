class CFEstimate {
  final String from;
  final String to;
  final num amountFrom;
  final num amountTo;
  final String estimateType;

  CFEstimate({
    required this.from,
    required this.to,
    required this.amountFrom,
    required this.amountTo,
    required this.estimateType
  });

  factory CFEstimate.fromJson(Map<String, dynamic> json) {
    return CFEstimate(
      from: json['ingressAsset'] as String,
      to: json['egressAsset'] as String,
      amountFrom: json['ingressAmount'] as num,
      amountTo: json['egressAmount'] as num,
      estimateType: json['type'] as String,
    );
  }

  @override
  String toString() {
    return 'CFEstimate {'
        'type: $estimateType, '
        'ingressAsset: $from, '
        'egressAsset: $to, '
        'ingressAmount: $amountFrom, '
        'egressAmount: $amountTo '
        '}';
  }
}
