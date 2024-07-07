import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ObscureTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool initiallyObscured;
  final Function(String) onFieldSubmitted;

  const ObscureTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.initiallyObscured = true,
    required this.onFieldSubmitted,
  });

  @override
  State<ObscureTextField> createState() => _ObscureTextFieldState();
}

class _ObscureTextFieldState extends State<ObscureTextField> {
  bool _isObscured = true;

  void _toggleObscure() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _isObscured,
      decoration: InputDecoration(
        labelText: widget.labelText,
        suffixIcon: InkWell(
          onTap: _toggleObscure,
          child: Icon(
            _isObscured ? Icons.visibility_off : Icons.visibility,
            color: Theme.of(context).inputDecorationTheme.hintStyle?.color ??
                Colors.grey,
          ),
        ),
      ),
      onFieldSubmitted: widget.onFieldSubmitted,
    );
  }
}

void showInputNumberDialog(Map<String, dynamic> params) {
  final String title = params['title'] ?? '标题空';
  final String initialValue = params['initialValue'] ?? '';
  final Function(String) onSaved = params['onSaved'] ?? ((_) {});

  final TextEditingController controller =
      TextEditingController(text: initialValue);

  Get.dialog(
    AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(hintText: '请输入$title'),
      ),
      actions: [
        TextButton(
          child: const Text('取消'),
          onPressed: () {
            Get.back();
          },
        ),
        TextButton(
          child: const Text('保存'),
          onPressed: () {
            if (controller.text.isNotEmpty && isNumeric(controller.text)) {
              onSaved(controller.text);
              Get.back();
            } else {
              Get.dialog(
                AlertDialog(
                  title: const Text('错误'),
                  content: const Text('请输入有效的数字'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ],
    ),
  );
}

// 辅助函数，检查字符串是否为数字
bool isNumeric(String str) {
  return int.tryParse(str) != null;
}
