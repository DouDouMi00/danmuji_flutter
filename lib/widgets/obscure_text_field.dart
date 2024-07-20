//widgets/obscure_text_field.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum InputType { intInputType, doubleInputType, stringInputType }

class InputDialogParams {
  final String title;
  final dynamic initialValue;
  final InputType inputType;
  final bool isObscured;
  final Function(dynamic) onSaved;
  final num? minValue;
  final num? maxValue;

  InputDialogParams({
    required this.title,
    required this.initialValue,
    required this.inputType,
    this.isObscured = false,
    required this.onSaved,
    this.minValue,
    this.maxValue,
  });
}

class InputNumberDialog extends StatefulWidget {
  final InputDialogParams params;

  const InputNumberDialog({super.key, required this.params});

  @override
  // ignore: library_private_types_in_public_api
  _InputNumberDialogState createState() => _InputNumberDialogState();
}

class _InputNumberDialogState extends State<InputNumberDialog> {
  late TextEditingController _controller;
  late bool _isObscured;
  late dynamic parsedValue;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.params.initialValue.toString());
    _isObscured = widget.params.isObscured;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.params.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.params.minValue != null && widget.params.maxValue != null)
            Text(
              '数值范围: ${widget.params.minValue} - ${widget.params.maxValue}',
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  obscureText: _isObscured,
                  keyboardType: widget.params.inputType ==
                              InputType.intInputType ||
                          widget.params.inputType == InputType.doubleInputType
                      ? TextInputType.number
                      : TextInputType.text,
                  decoration:
                      InputDecoration(hintText: '请输入${widget.params.title}'),
                ),
              ),
              if (widget.params.isObscured)
                IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                ),
            ],
          ),
        ],
      ),
      actions: [
        // 取消按钮
        TextButton(
          child: const Text('取消'),
          onPressed: () {
            Get.back();
          },
        ),
        TextButton(
          child: const Text('保存'),
          onPressed: () {
            if (_controller.text.isEmpty) {
              // 显示错误对话框，提示输入不能为空
              Get.dialog(
                AlertDialog(
                  title: const Text('错误'),
                  content: const Text('输入不能为空，请输入有效值。'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            } else {
              dynamic value;
              if (widget.params.inputType == InputType.intInputType ||
                  widget.params.inputType == InputType.doubleInputType) {
                try {
                  if (widget.params.inputType == InputType.intInputType) {
                    parsedValue = int.parse(_controller.text);
                  } else {
                    parsedValue = double.parse(_controller.text);
                  }
                  if (widget.params.minValue != null &&
                      parsedValue < widget.params.minValue!) {
                    // 显示错误对话框
                    Get.dialog(
                      AlertDialog(
                        title: const Text('错误'),
                        content: const Text('数值小于最小值'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                    return;
                  }
                  if (widget.params.maxValue != null &&
                      parsedValue > widget.params.maxValue!) {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('错误'),
                        content: const Text('数值大于最大值'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                    return;
                  }
                  value = parsedValue;
                } catch (e) {
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
                  return;
                }
              } else {
                value = _controller.text;
              }
              // 如果我们到达这里，说明输入有效，可以保存
              widget.params.onSaved(value);
              Get.back();
            }
          },
        ),
      ],
    );
  }
}

void showInputNumberDialog(InputDialogParams params) {
  Get.dialog(InputNumberDialog(params: params));
}

class RadioDialogParams {
  final String title;
  final dynamic initialValue;
  final Function(dynamic) onSaved;
  final List<Map<String, dynamic>> valueOptions;
  RadioDialogParams({
    required this.title,
    required this.initialValue,
    required this.onSaved,
    required this.valueOptions,
  });
}

class RadioDialog extends StatefulWidget {
  final RadioDialogParams params;

  const RadioDialog({super.key, required this.params});

  @override
  // ignore: library_private_types_in_public_api
  _RadioDialogState createState() => _RadioDialogState();
}

class _RadioDialogState extends State<RadioDialog> {
  late String _title;
  late dynamic _initialValue;
  late List<Map<String, dynamic>> _valueOptions;

  @override
  void initState() {
    super.initState();
    _title = widget.params.title;
    _initialValue = widget.params.initialValue;
    _valueOptions = widget.params.valueOptions;
  }

  void _save() {
    widget.params.onSaved(_initialValue);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_title),
      content: SingleChildScrollView(
        child: ListBody(
          children: _valueOptions.map((option) {
            return RadioListTile(
              title: Text(option['title']),
              value: option['value'],
              groupValue: _initialValue,
              onChanged: (newValue) {
                setState(() {
                  _initialValue = newValue!;
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('取消'),
          onPressed: () {
            Get.back();
          },
        ),
        TextButton(
          onPressed: _save,
          child: const Text('保存'),
        ),
      ],
    );
  }
}

void showRadioDialog(RadioDialogParams params) {
  Get.dialog(RadioDialog(params: params));
}