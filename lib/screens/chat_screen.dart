import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 이 파일의 모든곳에서 사용할 수 있도록 여기에 선언
final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String messageText;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  // void getMessages() async {
  //   final messages = await _firestore.collection('messages').getDocuments();
  //   for (var message in messages.documents) {
  //     print(message.data);
  //   }
  // }

  // //stream 이용해서 실시간으로 message 가져오기 메서드 --> StreamBuilder 에서 이 코드 씀
  // //snapshot()은 stream을 return 해줌
  // void messagesStream() async {
  //   await for (var snapshot in _firestore.collection('messages').snapshots()) {
  //     for (var message in snapshot.documents) {
  //       print(message.data);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close), // 닫기 버튼
              onPressed: () {
                _auth.signOut(); // 로그아웃
                Navigator.pop(context); // 이전 화면으로 돌아가기
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController, // 입력창에 TextController 선언
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear(); // 전송버튼 누를때, 입력창 비워주기
                      _firestore.collection('messages').add({
                        // collection: firebase 에서의 컬렉션 이름
                        'text': messageText,
                        'sender': loggedInUser.email,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 스트림 빌더(StreamBuilder)를 써서 스트림 처리를 해요.
    // 스트림 빌더를 써서 위젯 관리를 해요.
    // 스트림 빌더를 쓰면 setState() 를 쓰지 않고도 UI를 업데이트 할 수 있어요.
    // 또 항상 스트림의 최신값을 가져오니, 최신값을 확인할 필요가 없어요.
    return StreamBuilder<QuerySnapshot>( // 변수로 stream, builder 필요
        stream: _firestore
            .collection('messages')
            .snapshots(), // snapshots()는 stream을 return
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          final messages = snapshot.data.documents.reversed; // reversed: 거꾸로 저장 (스크롤 내릴 필요없게 하려고)
          List<MessageBubble> messageBubbles = []; // MessageBubble 위젯을 자료형으로 갖는다.

          for (var message in messages) {
            final messageText = message.data['text'];
            final messageSender = message.data['sender'];

            final currentUser = loggedInUser.email;

            final messageBubble =
            MessageBubble(
              sender: messageSender,
              text: messageText,
              isMe: currentUser == messageSender, // true or false
            );

            messageBubbles.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              reverse: true, // reverse: 거꾸로 저장 (스크롤 내릴 필요없게 하려고)
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: messageBubbles,
            ),
          );
        },
      );
  }
}


class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.isMe});

  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(sender, style: TextStyle(
            fontSize: 12.0,
            color: Colors.black54,
          )),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topRight: Radius.circular(30.0))
            ,
            elevation: 5.0, // This controls the size of the shadow below the material (and the opacity of the elevation overlay color if it is applied.)
            color: isMe ? Colors.lightBlueAccent : Colors.white, // 배경 색깔
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                //'$text from $sender',
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black54,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
