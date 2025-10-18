import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});
  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _journalController = TextEditingController();
  final List<String> _journalEntries = [];

  @override
  void initState() {
    super.initState();
    _loadJournalEntries();
  }

  Future<void> _loadJournalEntries() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() =>
        _journalEntries.addAll(prefs.getStringList('journal_entries') ?? []));
  }

  Future<void> _saveJournalEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('journal_entries', _journalEntries);
  }

  Future<void> _deleteJournalEntry(int index) async {
    setState(() => _journalEntries.removeAt(index));
    await _saveJournalEntries();
    _showSnackBar('Journal entry deleted');
  }

  Future<void> _clearAllJournalEntries() async {
    if (_journalEntries.isEmpty) return;

    final confirmDelete = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Clear All Entries'),
                  content: const Text(
                      'Are you sure you want to delete all journal entries? This action cannot be undone.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete All',
                            style: TextStyle(color: Colors.red))),
                  ],
                )) ??
        false;

    if (confirmDelete) {
      setState(() => _journalEntries.clear());
      await _saveJournalEntries();
      _showSnackBar('All journal entries deleted');
    }
  }

  Future<void> _addJournalEntry() async {
    if (_journalController.text.trim().isNotEmpty) {
      final entry =
          'Date: ${DateTime.now().toString().split(' ')[0]}\nTime: ${TimeOfDay.now().format(context)}\nEntry: ${_journalController.text.trim()}';
      setState(() => _journalEntries.insert(0, entry));
      await _saveJournalEntries();
      _journalController.clear();
      _showSnackBar('Journal entry saved!');
    }
  }

  void _showEntryOptions(int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) => Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete Entry',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteJournalEntry(index);
                  }),
              ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text('Cancel'),
                  onTap: () => Navigator.pop(context)),
            ]));
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        backgroundColor: const Color(0xFF87CEEB),
        actions: [
          if (_journalEntries.isNotEmpty)
            IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: _clearAllJournalEntries,
                tooltip: 'Clear All Entries')
        ],
      ),
      body: SafeArea(
          bottom: true,
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: [
                Expanded(
                    child: _journalEntries.isEmpty
                        ? const Center(
                            child: Text(
                                'No journal entries yet.\nStart writing your thoughts...',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey)))
                        : ListView.builder(
                            itemCount: _journalEntries.length,
                            itemBuilder: (context, index) => Dismissible(
                                  key: Key(_journalEntries[index]),
                                  background: Container(
                                      color: Colors.red,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      child: const Icon(Icons.delete,
                                          color: Colors.white)),
                                  direction: DismissDirection.endToStart,
                                  confirmDismiss: (direction) async =>
                                      await showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                title:
                                                    const Text('Delete Entry'),
                                                content: const Text(
                                                    'Are you sure you want to delete this journal entry?'),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, false),
                                                      child:
                                                          const Text('Cancel')),
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, true),
                                                      child: const Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red))),
                                                ],
                                              )),
                                  onDismissed: (direction) =>
                                      _deleteJournalEntry(index),
                                  child: Card(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.all(12.0),
                                        title: Text(_journalEntries[index],
                                            style:
                                                const TextStyle(fontSize: 14)),
                                        trailing: IconButton(
                                            icon: const Icon(Icons.more_vert),
                                            onPressed: () =>
                                                _showEntryOptions(index)),
                                      )),
                                ))),
                const SizedBox(height: 16),
                TextField(
                    controller: _journalController,
                    maxLines: 4,
                    decoration: InputDecoration(
                        hintText: 'Write your thoughts here...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.white)),
                const SizedBox(height: 16),
                Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ElevatedButton(
                      onPressed: _addJournalEntry,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF87CEEB),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: const Text('Save Entry'),
                    )),
              ]))),
    );
  }
}
