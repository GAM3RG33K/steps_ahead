import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<bool?> showToast(
  String message, {
  bool showLonger = false,
}) {
  return Fluttertoast.showToast(
      msg: message,
      toastLength: showLonger ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT);
}

Future<String?> getInputFromUser({
  required BuildContext context,
  required String title,
  String? message,
  String? hint,
  TextInputType keyboardType = TextInputType.text,
  bool Function(String? input)? validator,
}) async {
  TextEditingController controller = TextEditingController(text: message);

  return showDialog<String>(
    context: context,
    barrierDismissible: false, // User must tap button to dismiss
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: message),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final input = controller.text;
              bool isValid = true;
              if (validator != null) {
                isValid = validator(input);
              }
              if (isValid) {
                Navigator.pop(context, input);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid input')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      );
    },
  );
}

class InfoTile extends StatelessWidget {
  final BuildContext context;
  final String title;
  final IconData icon;
  final Color tileColor;
  final Color iconColor;
  final String? subtitle;
  final EdgeInsets padding;

  const InfoTile({
    super.key,
    required this.context,
    required this.title,
    required this.icon,
    required this.tileColor,
    required this.iconColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Card(
        color: tileColor,
        child: ListTile(
          enabled: false,
          dense: true,
          leading: CircleAvatar(
            backgroundColor: iconColor,
            child: Icon(
              icon,
              size: 24,
              color: tileColor,
            ),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: iconColor,
                ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: iconColor,
                      ),
                )
              : null,
        ),
      ),
    );
  }
}
