import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();

  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Room'),
      ),
      body: body(),
    );
  }

  Widget body() {
    return Column(
      children: [
        Expanded(
          flex: 7,
          child: StreamBuilder(
              stream: db.collection('messages').snapshots(),
              builder: (context, snapshots) {
                if (snapshots.data == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                List messages = List.from(snapshots.data!.docs);

                messages.sort((a, b) =>
                    (a.data()['created'] as Timestamp)
                        .compareTo(b.data()['created'] as Timestamp) *
                    -1);

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var data = messages[index].data();

                    return messageTile(data['text'], data['from'],
                        (data['created'] as Timestamp).toDate());
                  },
                );
              }),
        ),
        Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(flex: 6, child: inputField()),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      onPressed: sendMessage,
                      icon: const Icon(Icons.send),
                    ),
                  )
                ],
              ),
            )),
      ],
    );
  }

  void sendMessage() async {
    String messageText = messageController.text;

    if (messageText.isNotEmpty) {
      await db.collection('messages').add({
        'text': messageController.text,
        'from': 'Gurgen',
        'created': Timestamp.fromDate(DateTime.now())
      });

      messageController.clear();
    }
  }

  Widget inputField() {
    return TextField(
      controller: messageController,
      decoration: const InputDecoration(
        hintText: 'Type Here...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
      ),
    );
  }

  Widget messageTile(String text, String from, DateTime date) {
    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      width: MediaQuery.of(context).size.width * 0.7,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'from $from ${date.toIso8601String()}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
