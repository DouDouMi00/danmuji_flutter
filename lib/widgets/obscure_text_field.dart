//widgets/obscure_text_field.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 定义输入类型枚举
enum InputType { intInputType, doubleInputType, stringInputType }

/// 表示一个输入对话框的参数类。
/// 该类包含了配置输入对话框所需的各种参数，如标题、初始值、输入类型等。
class InputDialog {
  /// 输入对话框的标题，显示在对话框的顶部。
  final String title;

  /// 输入框的初始值，可以是任意类型，具体取决于输入类型。
  final dynamic initialValue;

  /// 输入类型，指定用户可以输入的数据类型，如整数、浮点数或字符串。
  final InputType inputType;

  /// 输入框的提示文本，用于提示用户输入的内容。
  final String? hintText;

  /// 指示输入框是否为密码输入框，若为 true 则输入内容会被隐藏。
  final bool isObscured;

  /// 输入值的最小值，仅适用于数值输入类型。
  final num? minValue;

  /// 输入值的最大值，仅适用于数值输入类型。
  final num? maxValue;

  /// 指示是否允许输入为空，若为 true 则输入框可以不输入内容。
  final bool allowEmpty;

  /// 输入值变化时的回调函数，接收一个参数为新输入值。
  final Function(dynamic)? onChanged;

  /// 构造函数，用于创建一个 [InputDialog] 实例。
  ///
  /// 必需参数:
  /// [title] - 输入对话框的标题，显示在对话框的顶部。
  /// [initialValue] - 输入框的初始值，可以是任意类型，具体取决于输入类型。
  /// [inputType] - 输入类型，指定用户可以输入的数据类型，如整数、浮点数或字符串。
  ///
  /// 可选参数:
  /// [hintText] - 输入框的提示文本，用于提示用户输入的内容，默认为 null。
  /// [isObscured] - 指示输入框是否为密码输入框，若为 true 则输入内容会被隐藏，默认为 false。
  /// [minValue] - 输入值的最小值，仅适用于数值输入类型，默认为 null。
  /// [maxValue] - 输入值的最大值，仅适用于数值输入类型，默认为 null。
  /// [allowEmpty] - 指示是否允许输入为空，若为 true 则输入框可以不输入内容，默认为 false。
  /// [onChanged] - 输入值变化时的回调函数，接收一个参数为新输入值。

  InputDialog({
    required this.title,
    required this.initialValue,
    required this.inputType,
    this.hintText,
    this.isObscured = false,
    this.minValue,
    this.maxValue,
    this.allowEmpty = false,
    this.onChanged,
  });

  /// 显示输入对话框的方法
  Future<dynamic> show() {
    final TextEditingController controller =
        TextEditingController(text: initialValue?.toString());

    // 构建 helperText
    String? helperText;
    if (minValue != null && maxValue != null) {
      helperText = '输入值范围: $minValue - $maxValue';
    } else if (minValue != null) {
      helperText = '输入值不能小于 $minValue';
    } else if (maxValue != null) {
      helperText = '输入值不能大于 $maxValue';
    }

    // 使用 obs 创建响应式变量
    final isVisible = (!isObscured).obs;

    return Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => TextField(
                controller: controller,
                obscureText: !isVisible.value,
                keyboardType: inputType == InputType.intInputType
                    ? TextInputType.number
                    : inputType == InputType.doubleInputType
                        ? const TextInputType.numberWithOptions(decimal: true)
                        : TextInputType.text,
                decoration: InputDecoration(
                  hintText: hintText,
                  helperText: helperText, // 显示最大最小值提示
                  suffixIcon: isObscured
                      ? IconButton(
                          icon: Icon(
                            isVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            isVisible.value = !isVisible.value;
                          },
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: null),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final input = controller.text;
              if (input.isEmpty) {
                if (allowEmpty) {
                  // 判断输入类型返回默认值
                  if (inputType == InputType.intInputType) {
                    onChanged?.call(0);
                    Get.back(result: 0);
                  }
                  if (inputType == InputType.doubleInputType) {
                    onChanged?.call(0.0);
                    Get.back(result: 0.0);
                  }
                  if (inputType == InputType.stringInputType) {
                    onChanged?.call('');
                    Get.back(result: '');
                  }
                } else {
                  showErrorDialog('错误', '输入不能为空');
                }
              } else {
                switch (inputType) {
                  case InputType.intInputType:
                    final intValue = int.tryParse(input);
                    if (intValue == null) {
                      showErrorDialog('错误', '请输入有效的整数');
                    } else if (minValue != null && intValue < minValue!) {
                      showErrorDialog('错误', '输入的值不能小于 $minValue');
                    } else if (maxValue != null && intValue > maxValue!) {
                      showErrorDialog('错误', '输入的值不能大于 $maxValue');
                    } else {
                      onChanged?.call(intValue);
                      Get.back(result: intValue);
                    }
                    break;
                  case InputType.doubleInputType:
                    final doubleValue = double.tryParse(input);
                    if (doubleValue == null) {
                      showErrorDialog('错误', '请输入有效的小数');
                    } else if (minValue != null && doubleValue < minValue!) {
                      showErrorDialog('错误', '输入的值不能小于 $minValue');
                    } else if (maxValue != null && doubleValue > maxValue!) {
                      showErrorDialog('错误', '输入的值不能大于 $maxValue');
                    } else {
                      Get.back(result: doubleValue);
                      onChanged?.call(doubleValue);
                    }
                    break;
                  case InputType.stringInputType:
                    onChanged?.call(input);
                    Get.back(result: input);
                    break;
                }
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

// 抽取显示错误对话框的函数
void showErrorDialog(String title, String content) {
  Get.dialog(
    AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        ElevatedButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

class RadioDialog {
  /// 单选对话框的标题，显示在对话框的顶部。
  final String title;

  /// 单选框的选项列表，每个选项是一个包含 'title' 和 'value' 的 Map。
  final List<Map<String, String>> valueOptions;

  /// 初始选中的值
  final String initialValue;

  /// 输入值变化时的回调函数，接收一个参数为新输入值。
  final Function(dynamic)? onChanged;

  /// 构造函数，用于创建一个 [RadioDialog] 实例。
  ///
  /// 必需参数:
  /// [title] - 单选对话框的标题，显示在对话框的顶部。
  /// [valueOptions] - 单选框的选项列表，每个选项是一个包含 'title' 和 'value' 的 Map。
  ///
  /// 可选参数:
  /// [initialValue] - 初始选中的值，默认为 null。
  RadioDialog({
    required this.title,
    required this.valueOptions,
    required this.initialValue,
    this.onChanged,
  });

  /// 显示单选对话框的方法
  Future<dynamic> show() {
    final selectedValue = initialValue.obs;
    return Get.dialog(
      AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: valueOptions.map((option) {
              return Obx(() => RadioListTile(
                    title: Text(option['title'] ?? ''),
                    value: option['value'],
                    groupValue: selectedValue.value,
                    onChanged: (newValue) {
                      selectedValue.value = newValue as String;
                      onChanged?.call(newValue);
                      Get.back(result: newValue);
                    },
                  ));
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: null),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
}
