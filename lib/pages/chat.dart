import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Messaging(),
    );
  }
}

class Message {
  final String text;
  final bool isMe;

  Message({required this.text, required this.isMe});
}

class Messaging extends StatefulWidget {
  const Messaging({super.key});

  @override
  State<Messaging> createState() => _ChatPageState();
}

class _ChatPageState extends State<Messaging> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(Message(text: text, isMe: true));
    });

    _controller.clear();

    // Optional: fake reply
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _messages.add(Message(text: "Reply: $text", isMe: false));
      });
    });
  }

  Widget _buildMessage(Message msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: msg.isMe ?Color(0xFFad2a2a): Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: msg.isMe ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222429),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(color: Colors.white),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFad2a2a)),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}