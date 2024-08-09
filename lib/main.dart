import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

const String _apiKey = String.fromEnvironment('API_KEY');

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'First Aid AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'First Aid AI'),
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
  late final GenerativeModel _model;
  final TextEditingController _textController = TextEditingController();
  bool loading = false;
  String generatedText = '';

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: _apiKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textFieldDecoration = InputDecoration(
      contentPadding: const EdgeInsets.all(15),
      hintText: 'Enter a prompt...',
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_apiKey),
              SizedBox(height: 20),
              TextField(
                autofocus: true,
                decoration: textFieldDecoration,
                controller: _textController,
              ),
              SizedBox(height: 20),
              loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        generateResponse(_textController.text);
                      },
                      child: Text('Get First Aid Advice'),
                    ),
              SizedBox(height: 40),
              // Placeholder for AI response
              MarkdownBody(data: generatedText == ''
                  ? 'First Aid Instructions Will Appear Here'
                  : generatedText),
              SizedBox(height: 40),
              // Placeholder for emergency buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Call emergency services
                    },
                    child: Text('Call 911'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red, // Make it red for emergency
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Access ICE contacts
                    },
                    child: Text('ICE Contacts'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> generateResponse(String prompt) async {
    setState(() {
      loading = true;
      generatedText = '';
    });
    var response = await _model.generateContent([Content.text(prompt)]);
    var text = response.text;

    setState(() {
      generatedText = text ?? 'we failed you :(';
      loading = false;
    });
  }
}
