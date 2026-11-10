class WalletModel {
  final int totalCoins;
  final int subscriptionCoins;
  final int purchasedCoins;
  final ExpiringCoinsInfo? expiringSoon;

  WalletModel({
    required this.totalCoins,
    required this.subscriptionCoins,
    required this.purchasedCoins,
    this.expiringSoon,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      totalCoins: json['totalCoins'] ?? 0,
      subscriptionCoins: json['subscriptionCoins'] ?? 0,
      purchasedCoins: json['purchasedCoins'] ?? 0,
      expiringSoon: json['expiringSoon'] != null
          ? ExpiringCoinsInfo.fromJson(json['expiringSoon'])
          : null,
    );
  }
}

class ExpiringCoinsInfo {
  final int amount;
  final DateTime? expiresAt;

  ExpiringCoinsInfo({required this.amount, this.expiresAt});

  factory ExpiringCoinsInfo.fromJson(Map<String, dynamic> json) {
    return ExpiringCoinsInfo(
      amount: json['amount'] ?? 0,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }
}
