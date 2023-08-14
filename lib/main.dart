import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

late Box box;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  box = await Hive.openBox('testBox');
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController text = TextEditingController();
  TextEditingController editText = TextEditingController();
  bool isEdit = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, value, index) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onLongPress: (){
                        setState(() {
                          isEdit = true;
                        });
                      },
                      title: isEdit == false
                          ? Text(box.getAt(index))
                          : TextField(
                              controller: editText,
                            ),
                      trailing: IconButton(
                        icon: Icon(
                          isEdit == false ? Icons.delete : Icons.check,
                        ),
                        onPressed: () {
                          setState(
                            () {
                              if (isEdit) {
                                box.putAt(index, editText.value.text);
                                isEdit = false;
                              } else {
                                box.deleteAt(index);
                              }
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              Divider(
                height: 5,
                color: Colors.black,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: TextField(
                      controller: text,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        border: InputBorder.none,
                        label: Text('message'),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        box.add(text.value.text);
                        text.text = '';
                      });
                    },
                    icon: Icon(Icons.send),
                  )
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
