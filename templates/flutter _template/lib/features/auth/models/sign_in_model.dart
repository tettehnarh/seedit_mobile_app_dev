class SignInModel {
  final String email;
  final String password;

  SignInModel({
    this.email = '',
    this.password = '',
  });

  SignInModel copyWith({
    String? email,
    String? password,
  }) {
    return SignInModel(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
