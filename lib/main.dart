import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebChat',
      theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Rubik',
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 97, 88, 231)))),
      home: const MyHomePage(title: 'WebChat App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List messages = [];
  ScrollController controller = ScrollController();
  TextEditingController messageText = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 3), (timer) {
      getMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          child: Column(
            children: [
              DrawerHeader(
                  child: Column(
                children: const [
                  Icon(
                    Icons.chat_rounded,
                    color: Color.fromARGB(255, 97, 88, 231),
                    size: 60,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "WebChat App",
                    style: TextStyle(fontSize: 30),
                  ),
                ],
              )),
              ListTile(
                onTap: (() async {
                  SharedPreferences sp = await SharedPreferences.getInstance();
                  showDialog(
                      context: context,
                      builder: ((context) {
                        TextEditingController name = TextEditingController();
                        name.text = sp.getString("name") ?? "";
                        return AlertDialog(
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("CANCEL")),
                            TextButton(
                                onPressed: () {
                                  if (name.text.isNotEmpty) {
                                    sp.setString("name", name.text);
                                  }
                                  Navigator.pop(context);
                                },
                                child: const Text("SAVE")),
                          ],
                          title: const Text("Set Name"),
                          content: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: 70,
                            child: TextField(
                              controller: name,
                              decoration: const InputDecoration(
                                hintText: 'Enter your name...',
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 97, 88, 231)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 97, 88, 231),
                                      width: 3.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 97, 88, 231),
                                      width: 3.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                ),
                              ),
                            ),
                          ),
                        );
                      }));
                }),
                leading: const Icon(Icons.edit_rounded),
                title: const Text(
                  "Edit Name",
                  style: TextStyle(fontSize: 16),
                ),
              )
            ],
          ),
        ),
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                      child: messages.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.chat_rounded,
                                    color:
                                        const Color.fromARGB(255, 97, 88, 231)
                                            .withAlpha(150),
                                    size:
                                        MediaQuery.of(context).size.width * 0.1,
                                  ),
                                  Text(
                                    "No Messages",
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: const Color.fromARGB(
                                                255, 97, 88, 231)
                                            .withAlpha(150)),
                                  ),
                                  Text(
                                    "Start the conversation by typing below",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: const Color.fromARGB(
                                                255, 97, 88, 231)
                                            .withAlpha(150)),
                                  )
                                ],
                              ),
                            )
                          : ListView(
                              controller: controller,
                              children: buildMessages())),
                  SizedBox(
                      height: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: 50,
                            child: TextField(
                              controller: messageText,
                              decoration: const InputDecoration(
                                hintText: 'Enter your message...',
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 97, 88, 231)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 97, 88, 231),
                                      width: 3.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 97, 88, 231),
                                      width: 3.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            height: 50,
                            width: 50,
                            child: FloatingActionButton(
                              onPressed: () async {
                                SharedPreferences sp =
                                    await SharedPreferences.getInstance();
                                if (messageText.text.isNotEmpty) {
                                  Uri url = Uri.parse(
                                      "https://web-chat-server.glitch.me/posts");
                                  setState(() {
                                    loading = true;
                                  });
                                  await http.post(url,
                                      headers: {
                                        "Content-Type": "application/json"
                                      },
                                      body: jsonEncode({
                                        "username":
                                            sp.getString("name") ?? "Guest",
                                        "message": messageText.text,
                                        "postedOn": getDate()
                                      }));
                                  messageText.clear();
                                  getMessages();
                                  setState(() {
                                    loading = false;
                                  });
                                  controller.animateTo(
                                      controller.position.maxScrollExtent,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut);
                                }
                              },
                              backgroundColor:
                                  const Color.fromARGB(255, 97, 88, 231),
                              child: loading
                                  ? const SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.send_rounded,
                                      size: 20,
                                    ),
                            ),
                          )
                        ],
                      )),
                ],
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 80),
                  child: Visibility(
                    visible: messages.isNotEmpty,
                    child: FloatingActionButton(
                        tooltip: "Go Down",
                        backgroundColor: Colors.grey.shade200,
                        onPressed: () {
                          controller.animateTo(
                              controller.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut);
                        },
                        mini: true,
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color.fromARGB(255, 97, 88, 231),
                        )),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void getMessages() async {
    Uri url = Uri.parse("https://web-chat-server.glitch.me/posts");
    http.Response res = await http.get(url);
    messages = jsonDecode(res.body);
    setState(() {});
  }

  String getDate() {
    DateTime now = DateTime.now();
    return addZero(now.day) +
        addZero(now.month) +
        now.year.toString() +
        addZero(now.hour) +
        addZero(now.minute);
  }

  String addZero(int val) {
    if (val.toString().length == 1) {
      return "0$val";
    } else {
      return val.toString();
    }
  }

  List<Widget> buildMessages() {
    List<Widget> list = [];
    for (var element in messages) {
      list.add(message(
          element["message"], element["username"], element["postedOn"]));
      list.add(const SizedBox(
        height: 10,
      ));
    }
    return list;
  }

  Widget message(String message, String name, String postedOn) {
    Radius radius = const Radius.circular(15);
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width * 0.3,
                maxWidth: MediaQuery.of(context).size.width * 0.9),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 97, 88, 231),
                borderRadius: BorderRadius.only(
                    topLeft: radius,
                    topRight: radius,
                    bottomLeft: radius,
                    bottomRight: Radius.zero)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 30,
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withAlpha(100),
                        child: Text(
                          name.split("")[0],
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      name,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  formatDate(postedOn),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      fontSize: 14, color: Colors.white.withAlpha(100)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(String raw) {
    List<String> data = raw.split("");
    return "${data[0]}${data[1]} ${getMonth(data[2] + data[3])} ${data[4]}${data[5]}${data[6]}${data[7]} ${convert24to12("${data[8]}${data[9]}${data[10]}${data[11]}")}";
  }

  String convert24to12(String time) {
    return TimeOfDay(
            hour: int.parse(time.split("")[0] + time.split("")[1]),
            minute: int.parse(time.split("")[2] + time.split("")[3]))
        .format(context);
  }

  String getMonth(String month) {
    List<String> months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "November",
      "December",
    ];
    return months[int.parse(month) - 1];
  }
}
