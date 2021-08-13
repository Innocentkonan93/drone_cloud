import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewImage extends StatefulWidget {
  final int index;
  ViewImage(this.index);

  @override
  _ViewImageState createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  FirebaseFirestore _db = FirebaseFirestore.instance;
  PageController _controller = PageController();

  @override
  void initState() {
    _controller = PageController(initialPage: widget.index);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _db
            .collection("dronecloud/FoSdzZu7wlge0cusGnqk/images/")
            .orderBy("upload_date")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          return Center(
            child: snapshot.data!.docs.length == 0
                ? Center(child: Text("Aucun photo"))
                : PageView.builder(
                    controller: _controller,
                    itemBuilder: (context, i) {
                      final imageDate = snapshot.data!.docs[i];
                      return GestureDetector(
                        onVerticalDragUpdate: (details) {
                          if (details.delta.dy > 5) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.2),
                            ),
                          ),
                          width: double.infinity,
                          height: 200,
                          child: CachedNetworkImage(
                              imageUrl: imageDate['image_url']),
                        ),
                      );
                    },
                    itemCount: snapshot.data!.docs.length,
                  ),
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SafeArea(
          child: Row(
            children: [],
          ),
        ),
      ),
    );
  }
}
