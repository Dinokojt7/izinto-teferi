class SignUpBody {
  String name;
  String email;
  String password;
  String phone;
  SignUpBody(
      {required this.name,
      required this.email,
      required this.password,
      required this.phone});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['f_name'] = this.name;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['password'] = this.password;
    return data;
  }
}
