import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(const MaxxApp());
}

class MaxxApp extends StatelessWidget {
  const MaxxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAXX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E27),
        fontFamily: 'monospace',
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const String apiKey = 'YOUR_GEMINI_API_KEY_HERE';

  late final GenerativeModel _model;
  late ChatSession _chat;
  final _controller = TextEditingController();

  final List<Map<String, String>> _messages = [
    {'role': 'assistant', 'content': 'Namaste Abbas Sir, MAXX online hai 🚀'},
  ];

  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-exp',
      apiKey: apiKey,
      systemInstruction: Content.system(
        'Tu MAXX hai — Abbas ka personal AI assistant. Owner: Abbas. '
        'Hindi + English mix me baat kar. Friendly, GF-type. "Boss" bolke address kar.',
      ),
    );
    _chat = _model.startChat();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _busy = true;
    });
    _controller.clear();

    try {
      final response = await _chat.sendMessage(Content.text(text));
      final reply = response.text ?? 'Kuch samajh nahi aaya Boss';
      setState(() {
        _messages.add({'role': 'assistant', 'content': reply});
        _busy = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'content': 'Error: $e'});
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Text(
          '⚡ M A X X',
          style: TextStyle(
            color: Color(0xFF00FFFF),
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF00FFFF) : const Color(0xFF1A1F3A),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                      border: isUser ? null : Border.all(color: const Color(0xFF00FFFF).withOpacity(0.4)),
                    ),
                    child: Text(
                      msg['content']!,
                      style: TextStyle(
                        color: isUser ? Colors.black : const Color(0xFF00FFCC),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(color: Color(0xFF00FFFF), backgroundColor: Color(0xFF1A1F3A)),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF0D1230),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Color(0xFF00FFFF)),
                    decoration: InputDecoration(
                      hintText: 'Type message...',
                      hintStyle: const TextStyle(color: Color(0xFF4A5578)),
                      filled: true,
                      fillColor: const Color(0xFF1A1F3A),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFF00FFFF)),
                      ),
                    ),
                    onSubmitted: _send,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF00FFFF)),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.black),
                    onPressed: () => _send(_controller.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
