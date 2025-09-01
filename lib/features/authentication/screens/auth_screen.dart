import 'package:flutter/material.dart';
import 'package:listin/core/colors.dart';
import 'package:listin/features/authentication/services/auth_service.dart';
import 'package:listin/features/authentication/widgets/snackbar.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool isSignIn = true;

  final _formKey = GlobalKey<FormState>();

  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset("assets/icons/logo-icon.png", height: 64),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        (isSignIn)
                            ? "Welcome to Listin!"
                            : "Let's get started?",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      (isSignIn)
                          ? "Sign in to create your shopping list."
                          : "Register to start creating your shopping list with Listin.",
                      textAlign: TextAlign.center,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(label: Text("Email")),
                      validator: (value) {
                        if (value == null || value == "") {
                          return "Email value must be filled";
                        }
                        if (!value.contains("@") ||
                            !value.contains(".") ||
                            value.length < 4) {
                          return "Email value must be valid";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        label: Text("Password"),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 4) {
                          return "Enter a valid password.";
                        }
                        return null;
                      },
                    ),
                    Visibility(
                      visible: isSignIn,
                      child: TextButton(
                        onPressed: () {
                          forgotPasswordClicked();
                        },
                        child: const Text("Forgot my password."),
                      ),
                    ),
                    Visibility(
                      visible: !isSignIn,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _confirmController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              label: Text("Confirm password"),
                            ),
                            validator: (value) {
                              if (value == null || value.length < 4) {
                                return "Enter a valid password confirmation.";
                              }
                              if (value != _passwordController.text) {
                                return "Passwords must match.";
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              label: Text("Name"),
                            ),
                            validator: (value) {
                              if (value == null || value.length < 3) {
                                return "Enter a longer name.";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        sendButtonClicked();
                      },
                      child: Text((isSignIn) ? "Sign In" : "Register"),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isSignIn = !isSignIn;
                        });
                      },
                      child: Text(
                        (isSignIn)
                            ? "Don't have an account yet?\nClick here to register."
                            : "Already have an account?\nClick here to sign in",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: MyColors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  sendButtonClicked() {
    String email = _emailController.text;
    String password = _passwordController.text;
    String name = _nameController.text;

    if (_formKey.currentState!.validate()) {
      if (isSignIn) {
        _signInUser(email: email, password: password);
      } else {
        _registerUser(email: email, password: password, name: name);
      }
    }
  }

  _signInUser({required String email, required String password}) {
    authService.signInUser(email: email, password: password).then((
      String? error,
    ) {
      if (error != null) {
        showSnackBar(context: context, message: error);
      }
    });
  }

  _registerUser({
    required String email,
    required String password,
    required String name,
  }) {
    authService.registerUser(email: email, password: password, name: name).then(
      (String? error) {
        if (error != null) {
          showSnackBar(context: context, message: error);
        }
      },
    );
  }

  forgotPasswordClicked() {
    String email = _emailController.text;
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController resetPasswordController = TextEditingController(
          text: email,
        );
        return AlertDialog(
          title: const Text("Confirm the email for password reset"),
          content: TextFormField(
            controller: resetPasswordController,
            decoration: const InputDecoration(label: Text("Confirm email")),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                authService
                    .resetPassword(email: resetPasswordController.text)
                    .then((String? error) {
                      if (error == null) {
                        showSnackBar(
                          context: context,
                          message: "Reset email sent!",
                          isError: false,
                        );
                      } else {
                        showSnackBar(context: context, message: error);
                      }

                      Navigator.pop(context);
                    });
              },
              child: const Text("Reset password"),
            ),
          ],
        );
      },
    );
  }
}
