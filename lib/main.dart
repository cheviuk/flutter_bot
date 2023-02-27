// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_console/flutter_console.dart';
import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

final log = Logger(
  printer: PrettyPrinter(
      methodCount: 2,
      // number of method calls to be displayed
      errorMethodCount: 1,
      // number of method calls if stacktrace is provided
      lineLength: 120,
      // width of the output
      colors: true,
      // Colorful log messages
      printEmojis: true,
      // Print an emoji for each log message
      printTime: true // Should each log print contain a timestamp
      ),
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bot',
      theme: ThemeData.dark(),
      home: const MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final navKey = GlobalKey<NavigatorState>();
  final String token = "5122013259:AAH-nvktXt8YPprWrKnrJsD6FFBKIgq1lFAklen";
  late Telegram telegram;
  late TeleDart teleDart;
  bool status = false;
  late BuildContext context;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    
    this.context = context;

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          OutlinedButton(
            onPressed: status ? null : startBot,
            child: const Icon(Icons.play_arrow),
          ),
          OutlinedButton(
            onPressed: showLog,
            child: const Icon(Icons.terminal),
          )
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text('Bot')
          ],
        ),
      ),
    );
  }

  startBot() async {
    final username = (await Telegram(token).getMe()).username;
    if (username != null) {
      teleDart = TeleDart(token, Event(username));
    } else {
      log.e('username: null');
      return;
    }
    teleDart.start();

    teleDart
        .onMessage(entityType: 'bot_command', keyword: 'start')
        .listen((message) {
      log.d("bot_command: start");
      teleDart.sendMessage(message.chat.id, "Response Message");
    });

    teleDart.onCommand('glory').listen((message) {
      log.d('onCommand: glory');
      message.reply('to Ukraine!');
    });

    teleDart.onCommand(RegExp('hello', caseSensitive: false)).listen((message) {
      log.d('onCommand: hello');
      message.reply('hi!');
    });

    teleDart
        .onMessage(keyword: 'dart')
        .where((message) => message.text?.contains('telegram') ?? false)
        .listen((message) {
      log.d('onMessage: ${message.text}');
      message.replyPhoto(
          //  io.File('example/dash_paper_plane.png'),
          'https://raw.githubusercontent.com/DinoLeung/TeleDart/master/example/dash_paper_plane.png',
          caption: 'This is how Dash found the paper plane');
      message.replyPhoto(
          //  io.File('example/dash_paper_plane.png'),
          'https://raw.githubusercontent.com/DinoLeung/TeleDart/master/example/dash_paper_plane.png',
          caption: 'This is how Dash found the paper plane');
    });

    teleDart.onInlineQuery().listen((inlineQuery) {
      log.d('onInlineQuery: ${inlineQuery.query}');
      inlineQuery.answer([
        InlineQueryResultArticle(
            id: 'ping',
            title: 'ping',
            input_message_content: InputTextMessageContent(
                message_text: '*pong*', parse_mode: 'MarkdownV2')),
        InlineQueryResultArticle(
            id: 'ding',
            title: 'ding',
            input_message_content: InputTextMessageContent(
                message_text: '*_dong_*', parse_mode: 'MarkdownV2')),
      ]);
    });

    status = true;



    log.i('Bot started.');

    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values.
    });
  }

  void showLog() {
    ConsoleStream logStream = ConsoleStream();
    OverlayState overlayState = Overlay.of(this.context)!;
    ConsoleOverlay().show(baseOverlay:overlayState, contentStream: logStream, y: 300);
    pushLog(logStream);
  }

  void pushLog(ConsoleStream cr) {
    cr.push('Show Log: ${DateTime.now().millisecondsSinceEpoch}');
    Future.delayed(const Duration(milliseconds: 1000), () {
      pushLog(cr);
    });
  }
}
