import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FindFriendsScreen extends StatelessWidget {
  const FindFriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Friends'),
        backgroundColor: Colors.green[900],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final currentUser = snapshot.data!.data() as Map<String, dynamic>;
          final friends = List<String>.from(currentUser['friends'] ?? []);
          final sentRequests = List<String>.from(currentUser['sentRequests'] ?? []);
          final receivedRequests = List<String>.from(currentUser['receivedRequests'] ?? []);

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').where('uid', isNotEqualTo: uid).snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) return const SizedBox();
              final users = snap.data!.docs;

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final userId = user['uid'];

                  bool isFriend = friends.contains(userId);
                  bool requestSent = sentRequests.contains(userId);
                  bool requestReceived = receivedRequests.contains(userId);

                  return ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text(user['name'] ?? "Unknown"),
                    subtitle: Text(isFriend
                        ? 'Friend'
                        : requestSent
                        ? 'Request Sent'
                        : requestReceived
                        ? 'Accept Request'
                        : ''),
                    trailing: isFriend
                        ? null
                        : requestReceived
                        ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _acceptRequest(uid, userId),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _declineRequest(uid, userId),
                        ),
                      ],
                    )
                        : IconButton(
                      icon: const Icon(Icons.person_add),
                      onPressed: () => _sendRequest(uid, userId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _sendRequest(String fromUid, String toUid) async {
    final fromRef = FirebaseFirestore.instance.collection('users').doc(fromUid);
    final toRef = FirebaseFirestore.instance.collection('users').doc(toUid);

    await fromRef.update({'sentRequests': FieldValue.arrayUnion([toUid])});
    await toRef.update({'receivedRequests': FieldValue.arrayUnion([fromUid])});
  }

  void _acceptRequest(String currentUid, String otherUid) async {
    final currentRef = FirebaseFirestore.instance.collection('users').doc(currentUid);
    final otherRef = FirebaseFirestore.instance.collection('users').doc(otherUid);

    await currentRef.update({
      'friends': FieldValue.arrayUnion([otherUid]),
      'receivedRequests': FieldValue.arrayRemove([otherUid])
    });
    await otherRef.update({
      'friends': FieldValue.arrayUnion([currentUid]),
      'sentRequests': FieldValue.arrayRemove([currentUid])
    });
  }

  void _declineRequest(String currentUid, String otherUid) async {
    final currentRef = FirebaseFirestore.instance.collection('users').doc(currentUid);
    final otherRef = FirebaseFirestore.instance.collection('users').doc(otherUid);

    await currentRef.update({'receivedRequests': FieldValue.arrayRemove([otherUid])});
    await otherRef.update({'sentRequests': FieldValue.arrayRemove([currentUid])});
  }
}
