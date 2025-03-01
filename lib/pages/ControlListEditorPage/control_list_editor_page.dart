import 'package:danmuji_flutter/widgets/obscure_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditableListParams {
  final String title;
  final List<dynamic> initialValue;
  final InputType inputType;
  final bool isObscured;
  final Function(List<dynamic>) onChanged;

  EditableListParams({
    required this.title,
    required this.initialValue,
    required this.inputType,
    this.isObscured = false,
    required this.onChanged,
  });
}

class EditableListPage extends StatelessWidget {
  // 使用 Get.arguments 接收 EditableListParams 类型的参数
  final EditableListParams params = Get.arguments;

  EditableListPage({super.key});

  @override
  Widget build(BuildContext context) {
    late RxList<dynamic> initialValueRX = params.initialValue.obs;
    return Scaffold(
      appBar: AppBar(title: Text(params.title)),
      body: Obx(
        () => ListView.builder(
          itemCount: initialValueRX.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: GestureDetector(
                onTap: () async {
                  await InputDialog(
                    title: '编辑',
                    initialValue: initialValueRX[index].toString(),
                    inputType: params.inputType,
                    isObscured: params.isObscured,
                    onChanged: (value) {
                      initialValueRX[index] = value;
                      params.onChanged(initialValueRX.toList());
                    },
                  ).show();
                },
                child: Text(initialValueRX[index].toString()),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, semanticLabel: '删除'),
                onPressed: () {
                  initialValueRX.removeAt(index);
                  params.onChanged(initialValueRX.toList());
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '添加新条目',
        onPressed: () async {
          // 添加一个新条目的逻辑
          await InputDialog(
            title: '添加新条目',
            initialValue: '',
            inputType: params.inputType,
            isObscured: params.isObscured,
            onChanged: (value) {
              initialValueRX.add(value);
              params.onChanged(initialValueRX.toList());
            },
          ).show();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
