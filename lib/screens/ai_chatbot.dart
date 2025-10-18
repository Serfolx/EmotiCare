import 'package:flutter/material.dart';
import '../services/groq.dart';

class AIChatbotScreen extends StatefulWidget {
  const AIChatbotScreen({super.key});
  @override
  State<AIChatbotScreen> createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'text':
          "Hello! I'm EmotiCare, your therapeutic assistant. 🌸\n\nI'm here to provide emotional support and mental health guidance.",
      'isUser': false,
      'isWelcome': true,
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages
          .add({'text': message, 'isUser': true, 'timestamp': DateTime.now()});
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await GroqService.getTherapeuticResponse(message);
      setState(() {
        _messages.add(
            {'text': response, 'isUser': false, 'timestamp': DateTime.now()});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'text': e.toString().replaceAll('Exception: ', ''),
          'isUser': false,
          'isError': true,
          'timestamp': DateTime.now()
        });
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _showDialog(
      {required String title,
      required Widget content,
      bool showResources = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: showResources
            ? SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    const Text('Please reach out for immediate help:'),
                    const SizedBox(height: 16),
                    ...GroqService.getEmergencyResourcesList().map((resource) =>
                        Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text('• $resource'))),
                  ]))
            : content,
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'))
        ],
      ),
    );
  }

  Widget _buildChatbotHeader() {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF87CEEB).withOpacity(0.1),
                  const Color(0xFFE6F3FF).withOpacity(0.1)
                ]),
            border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1))),
        child: Column(children: [
          _buildLogoImage(size: 80, iconSize: 40),
          const SizedBox(height: 16),
          const Text('EmotiCare Assistant',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4682B4))),
          const SizedBox(height: 4),
          const Text('Your AI Therapy Companion',
              style: TextStyle(fontSize: 14, color: Color(0xFF708090))),
        ]));
  }

  Widget _buildLogoImage({double size = 100, double iconSize = 50}) {
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size / 2),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF87CEEB).withOpacity(0.2),
                  blurRadius: size / 4,
                  offset: const Offset(0, 3))
            ]),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: Image.asset(
              'assets/images/chatbotlogo.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                      color: const Color(0xFF87CEEB),
                      borderRadius: BorderRadius.circular(size / 2)),
                  child: Icon(Icons.psychology,
                      size: iconSize, color: Colors.white)),
            )));
  }

  Widget _buildEmptyState() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      _buildLogoImage(size: 100, iconSize: 50),
      const SizedBox(height: 20),
      const Text('Hello! I\'m here to listen and support you.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center),
      const SizedBox(height: 8),
      const Text('You can talk to me in English or Filipino.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center),
    ]));
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['isUser'] ?? false,
        isWelcome = message['isWelcome'] ?? false,
        isError = message['isError'] ?? false;
    final color = isUser
        ? const Color(0xFF87CEEB)
        : isWelcome
            ? const Color(0xFFE8F5E8)
            : isError
                ? const Color(0xFFFFEBEE)
                : const Color(0xFFE6F3FF);

    return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser && !isWelcome)
                _buildLogoImage(size: 32, iconSize: 16),
              if (!isUser) const SizedBox(width: 8),
              Flexible(
                  child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(message['text'],
                                style: TextStyle(
                                    color: isUser
                                        ? Colors.white
                                        : Colors.black87)),
                            if (message['timestamp'] != null)
                              Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(_formatTime(message['timestamp']),
                                      style: TextStyle(
                                          color: isUser
                                              ? Colors.white70
                                              : Colors.grey.shade600,
                                          fontSize: 11))),
                          ]))),
              if (isUser) const SizedBox(width: 8),
              if (isUser)
                const CircleAvatar(
                    backgroundColor: Color(0xFF4682B4),
                    radius: 16,
                    child: Icon(Icons.person, color: Colors.white, size: 16)),
            ]));
  }

  String _formatTime(DateTime timestamp) =>
      '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EmotiCare Therapy'),
        backgroundColor: const Color(0xFF87CEEB),
        actions: [
          IconButton(
              icon: const Icon(Icons.wifi),
              onPressed: () => _showDialog(
                  title: 'Connection Help',
                  content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('If you\'re having connection issues:'),
                        SizedBox(height: 12),
                        Text('• Check your internet connection'),
                        Text('• Ensure you have mobile data or WiFi'),
                        Text('• Try switching between WiFi and mobile data'),
                        Text('• Restart the app'),
                        SizedBox(height: 12),
                        Text(
                            'The app requires internet connection to provide AI-powered support.'),
                      ])),
              tooltip: 'Connection Help'),
          IconButton(
              icon: const Icon(Icons.emergency),
              onPressed: () => _showDialog(
                  title: 'Emergency Resources',
                  content: const SizedBox(),
                  showResources: true),
              tooltip: 'Emergency Resources'),
        ],
      ),
      body: SafeArea(
          bottom: true,
          child: Column(children: [
            _buildChatbotHeader(),
            Expanded(
                child: _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) =>
                            _buildMessageBubble(_messages[index]))),
            if (_isLoading)
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(children: [
                    _buildLogoImage(size: 32, iconSize: 16),
                    const SizedBox(width: 12),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('EmotiCare is thinking...',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        ]),
                  ])),
            Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border(top: BorderSide(color: Colors.grey.shade300))),
                child: Row(children: [
                  Expanded(
                      child: TextField(
                          controller: _messageController,
                          maxLines: null,
                          decoration: InputDecoration(
                              hintText: 'Share your thoughts...',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none),
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12)),
                          onSubmitted: (_) => _sendMessage())),
                  const SizedBox(width: 8),
                  CircleAvatar(
                      backgroundColor: const Color(0xFF87CEEB),
                      child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: _sendMessage)),
                ])),
          ])),
    );
  }
}
