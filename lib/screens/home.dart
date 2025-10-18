import 'package:flutter/material.dart';
import 'journal.dart';
import 'mood_tracking.dart';
import 'ai_chatbot.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userName;
  bool _isLoading = true, _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name');
      _termsAccepted = prefs.getBool('terms_accepted') ?? false;
      _isLoading = false;
    });
    if (!_termsAccepted && _userName != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showTermsDialog());
    }
  }

  Future<void> _saveUserData(String name, [bool acceptTerms = false]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    if (acceptTerms) await prefs.setBool('terms_accepted', true);
    setState(() {
      _userName = name;
      if (acceptTerms) _termsAccepted = true;
    });
  }

  void _showNameDialog() {
    String tempName = '';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Welcome to EmotiCare!'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('What do you want us to call you?'),
          const SizedBox(height: 16),
          TextField(
            autofocus: true,
            decoration: const InputDecoration(
                hintText: 'Enter your name or nickname',
                border: OutlineInputBorder()),
            onChanged: (value) => tempName = value,
            onSubmitted: (value) => _processName(value, context),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => _processName(tempName, context),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _processName(String value, BuildContext context) {
    if (value.trim().isNotEmpty) {
      _saveUserData(value.trim());
      Navigator.pop(context);
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Welcome to EmotiCare! 🌸'),
        content: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const Text(
                  'Before we begin, please review our important information:',
                  style: TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              _buildInfoSection('🔒 Your Privacy',
                  '• Journal entries and mood data stay securely on your device\n• No personal data is shared with external servers'),
              _buildInfoSection('🤖 AI Assistant',
                  '• Chat messages are processed by Groq AI services\n• Groq has its own privacy policy for data handling\n• Avoid sharing highly sensitive information in chats'),
              _buildInfoSection('⚕️ Important Note',
                  '• EmotiCare provides support but is not a substitute for professional therapy\n• For emergencies, contact the provided hotlines'),
              const SizedBox(height: 16),
              Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE6F3FF),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text(
                      'By continuing, you agree that you understand how your data is handled and the app\'s limitations.',
                      style:
                          TextStyle(fontSize: 12, color: Color(0xFF4682B4)))),
            ])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                _saveUserData(_userName!, true);
                Navigator.pop(context);
              },
              child: const Text('I Understand & Agree',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF4682B4)))),
        ],
      ),
    );
  }

  void _showFullTerms() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
              const Text('EmotiCare - Terms of Use',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF4682B4))),
              const SizedBox(height: 16),
              _buildTermSection('Data Privacy & Storage',
                  'All personal data including journal entries, mood tracking history, and user preferences are stored locally on your device. No personal data is transmitted to external servers except for chat messages sent to the AI assistant.'),
              _buildTermSection('AI Chatbot Services',
                  'Chat messages are processed by Groq\'s AI services. Groq has its own privacy policy and terms of service governing data handling. We recommend reviewing Groq\'s privacy policy for details on their data practices.'),
              _buildTermSection('Medical Disclaimer',
                  'EmotiCare is not a medical device and does not provide medical diagnosis, treatment, or crisis intervention. This app is designed for mental health support but is not a substitute for professional medical care.'),
              _buildTermSection('Emergency Resources',
                  'If you\'re experiencing a mental health emergency, please contact:\n• NCMH: 1553\n• Hopeline: (02) 8804-4673\n• Emergency: 911'),
              const SizedBox(height: 16),
              Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE6F3FF),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text(
                      'By using EmotiCare, you acknowledge that you have read and understood these terms.',
                      style:
                          TextStyle(fontSize: 12, color: Color(0xFF4682B4)))),
            ])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'))
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF4682B4))),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
        ]));
  }

  Widget _buildTermSection(String title, String content) {
    return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF4682B4))),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 12)),
        ]));
  }

  Widget _buildLogo() {
    return Column(children: [
      Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF87CEEB).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5))
              ]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: Image.asset('assets/images/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                        color: const Color(0xFF87CEEB),
                        borderRadius: BorderRadius.circular(60)),
                    child: const Icon(Icons.psychology,
                        size: 60, color: Colors.white))),
          )),
      const SizedBox(height: 20),
      Text(
          _userName != null
              ? 'Welcome to EmotiCare, $_userName! 👋'
              : 'Welcome to EmotiCare',
          style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4682B4)),
          textAlign: TextAlign.center),
      const SizedBox(height: 8),
      const Text('Your Therapy Assistant',
          style: TextStyle(fontSize: 16, color: Color(0xFF708090))),
    ]);
  }

  Widget _buildFeatureCard(
      String title, String subtitle, IconData icon, Widget screen) {
    return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: const Color(0xFFE6F3FF),
                  borderRadius: BorderRadius.circular(25)),
              child: Icon(icon, color: const Color(0xFF87CEEB), size: 25)),
          title: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF4682B4))),
          subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
          trailing: const Icon(Icons.arrow_forward_ios,
              color: Color(0xFF87CEEB), size: 16),
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => screen)),
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoading && _userName == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showNameDialog());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('EmotiCare',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF87CEEB),
        actions: [
          if (_userName != null)
            IconButton(
                icon: const Icon(Icons.person, color: Colors.white),
                onPressed: _showNameDialog,
                tooltip: 'Change Name'),
          IconButton(
              icon: const Icon(Icons.security, color: Colors.white),
              onPressed: _showFullTerms,
              tooltip: 'Terms & Conditions'),
        ],
      ),
      body: SafeArea(
          bottom: true,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFE6F3FF), Color(0xFFF0F8FF)])),
                  child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(children: [
                        _buildLogo(),
                        const SizedBox(height: 40),
                        Expanded(
                            child: Column(children: [
                          _buildFeatureCard(
                              '📔 Journal',
                              'Write your thoughts and feelings',
                              Icons.book,
                              const JournalScreen()),
                          const SizedBox(height: 16),
                          _buildFeatureCard(
                              '😊 Mood Tracker',
                              'Track your daily moods and emotions',
                              Icons.emoji_emotions,
                              const MoodTrackerScreen()),
                          const SizedBox(height: 16),
                          _buildFeatureCard(
                              '🤖 AI Assistant',
                              'Talk with our therapy assistant',
                              Icons.chat,
                              const AIChatbotScreen()),
                        ])),
                      ])))),
    );
  }
}
