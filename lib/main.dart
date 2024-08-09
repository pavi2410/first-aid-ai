import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

const String _apiKey = String.fromEnvironment('API_KEY');

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'First Aid AI',
      theme: ThemeData(
        primarySwatch: Colors.red,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.red,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
      ),
      themeMode: ThemeMode.system,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final GenerativeModel _model;
  final TextEditingController _textController = TextEditingController();
  bool _loading = false;
  String _generatedText = '';
  final List<String> _recentQueries = [];

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
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('First Aid AI', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get Instant First Aid Advice',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enter your emergency situation or first aid question below:',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'E.g., How to treat a burn?',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loading
                          ? null
                          : () => _generateResponse(_textController.text),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Get Advice'),
                    ),
                    const SizedBox(height: 24),
                    if (_generatedText.isNotEmpty) ...[
                      Text(
                        'First Aid Instructions:',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: MarkdownBody(data: _generatedText),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      'Recent Queries:',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._recentQueries.map((query) => ListTile(
                          title: Text(query),
                          leading: const Icon(Icons.history),
                          onTap: () {
                            _textController.text = query;
                            _generateResponse(query);
                          },
                        )),
                  ],
                ),
              ),
            ),
            const SafetyButtonsBar(),
          ],
        ),
      ),
    );
  }

  Future<void> _generateResponse(String prompt) async {
    if (prompt.isEmpty) return;

    setState(() {
      _loading = true;
      _generatedText = '';
    });

    try {
      var response = await _model.generateContent([Content.text(prompt)]);
      var text = response.text;

      setState(() {
        _generatedText =
            text ?? 'Sorry, I couldn\'t generate a response. Please try again.';
        _loading = false;
        if (!_recentQueries.contains(prompt)) {
          _recentQueries.insert(0, prompt);
          if (_recentQueries.length > 5) _recentQueries.removeLast();
        }
      });
    } catch (e) {
      setState(() {
        _generatedText =
            'An error occurred. Please check your internet connection and try again.';
        _loading = false;
      });
    }
  }
}

class SafetyButtonsBar extends StatelessWidget {
  const SafetyButtonsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSafetyButton(
            context,
            icon: Icons.phone,
            label: 'Call 911',
            onPressed: () => _launchURL('tel:911'),
            color: Colors.red,
          ),
          _buildSafetyButton(
            context,
            icon: Icons.contacts,
            label: 'ICE Contacts',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ICE Contacts feature coming soon!')),
              );
            },
            color: Colors.blue,
          ),
          _buildSafetyButton(
            context,
            icon: Icons.map,
            label: 'Nearby Help',
            onPressed: () =>
                _launchURL('https://www.google.com/maps/search/hospital'),
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          icon: Icon(icon, color: Colors.white),
          label: Text(label, style: const TextStyle(color: Colors.white)),
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }
}
