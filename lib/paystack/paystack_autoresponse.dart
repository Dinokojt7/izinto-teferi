// TODO(paystack-to-yoco): Paystack-specific response shape (authorization_url,
// access_code). Yoco's checkout API returns a different payload — this model
// (and its one caller in payment_page.dart) needs a Yoco equivalent, not just
// a rename.
class PayStackAuthResponse {
  final String authorization_url;
  final String access_code;
  final String reference;

  PayStackAuthResponse(
      {required this.authorization_url,
      required this.access_code,
      required this.reference});

  factory PayStackAuthResponse.fromJson(Map<String, dynamic> json) {
    return PayStackAuthResponse(
      authorization_url: json['authorization_url'],
      access_code: json['access_code'],
      reference: json['reference'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorization_url': authorization_url,
      'reference': reference,
      'access_code': access_code
    };
  }
}
