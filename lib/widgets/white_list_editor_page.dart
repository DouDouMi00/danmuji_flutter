import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/widgets/obscure_text_field.dart';

class EditableListParams {
  final String title;
  final List<dynamic> initialValue;
  final InputType inputType;
  final bool isObscured;
  final Function(dynamic) onSaved;

  EditableListParams({
    required this.title,
    required this.initialValue,
    required this.inputType,
    this.isObscured = false,
    required this.onSaved,
  });
}

class EditableListPage extends StatefulWidget {
  final EditableListParams params;
  const EditableListPage({super.key, required this.params});

  @override
  // ignore: library_private_types_in_public_api
  _EditableListPageState createState() => _EditableListPageState();
}

class _EditableListPageState extends State<EditableListPage> {
  late List<dynamic> listData; // 初始化数据
  late Function(List<dynamic>) onSaved;
  late String title;
  late InputType inputType;
  late bool isObscured;

  @override
  void initState() {
    super.initState();
    final params = Get.arguments as EditableListParams;
    listData = params.initialValue;
    inputType = params.inputType;
    isObscured = params.isObscured;
    onSaved = params.onSaved;
    title = params.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EditableList(
        list: listData,
        inputType: inputType,
        isObscured: isObscured,
        onListChanged: (newList) {
          setState(() {
            listData = newList;
            onSaved(listData);
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 添加一个新条目的逻辑
          setState(() {
            showInputNumberDialog(InputDialogParams(
              title: '添加新条目',
              initialValue: '',
              inputType: inputType,
              isObscured: isObscured,
              onSaved: (value) {
                setState(() {
                  listData.add(value);
                  onSaved(listData);
                });
              },
            ));
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// 假设 EditableList 是一个自定义的可编辑列表组件
class EditableList extends StatefulWidget {
  final List<dynamic> list;
  final Function(List<dynamic>) onListChanged;
  final InputType inputType;
  final bool isObscured;

  const EditableList(
      {super.key,
      required this.list,
      required this.onListChanged,
      this.inputType = InputType.stringInputType,
      this.isObscured = false});

  @override
  // ignore: library_private_types_in_public_api
  _EditableListState createState() => _EditableListState();
}

class _EditableListState extends State<EditableList> {
  List<dynamic> _list = [];

  @override
  void initState() {
    super.initState();
    _list = widget.list;
  }

  void _showInputDialog(int index) {
    InputDialogParams params = InputDialogParams(
      title: '编辑',
      initialValue: _list[index].toString(),
      inputType: widget.inputType,
      isObscured: widget.isObscured,
      onSaved: (value) {
        setState(() {
          _list[index] = value;
          widget.onListChanged(_list);
        });
      },
    );
    showInputNumberDialog(params);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _list.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: GestureDetector(
            onTap: () => _showInputDialog(index),
            child: Text(_list[index].toString()),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _list.removeAt(index);
                widget.onListChanged(_list);
              });
            },
          ),
        );
      },
    );
  }
}
