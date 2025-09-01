import 'package:flutter/material.dart';
import 'package:listin/features/authentication/services/auth_service.dart';

showPasswordConfirmationDialog({
  required BuildContext context,
  required String email,
}) {
  showDialog(
    context: context,
    builder: (context) {
      TextEditingController passwordConfirmationController =
          TextEditingController();
      return AlertDialog(
        title: Text("Do you want to remove the account with email $email?"),
        content: SizedBox(
          height: 175,
          child: Column(
            children: [
              const Text(
                "To confirm account removal, please enter your password:",
              ),
              TextFormField(
                controller: passwordConfirmationController,
                obscureText: true,
                decoration: const InputDecoration(label: Text("Password")),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AuthService()
                  .deleteAccount(password: passwordConfirmationController.text)
                  .then((String? error) {
                    if (error == null) {
                      Navigator.pop(context);
                    }
                  });
            },
            child: const Text("DELETE ACCOUNT"),
          ),
        ],
      );
    },
  );
}
