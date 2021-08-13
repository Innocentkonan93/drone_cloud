import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drone_cloud/API/firebase_api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class UploadingImage extends StatefulWidget {
  const UploadingImage({Key? key}) : super(key: key);

  @override
  _UploadingImageState createState() => _UploadingImageState();
}

class _UploadingImageState extends State<UploadingImage> {
  UploadTask? task;
  FirebaseFirestore _db = FirebaseFirestore.instance;

  File? file;
  List<File>? files;
  String? albumName;
  String? urlDownload;
  bool isLoading = false;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: true,
    );

    //

    if (result != null) {
      files = result.paths.map((path) => File(path!)).toList();
      setState(() {});
    } else {
      return;
    }
  }

  Future uploadFile(File file) async {
    final fileName = basename(file.path);

    final destination = 'CloudPhoto/$fileName';
    setState(() {});

    task = FirebaseApi.uploadTask(destination, file);

    final snapshot = await task!.whenComplete(() {});

    urlDownload = await snapshot.ref.getDownloadURL();

    _db.collection('dronecloud/FoSdzZu7wlge0cusGnqk/images/').add({
      "image_url": urlDownload,
      "upload_date": DateTime.now(),
    });
  }

  Future uploadMultiFile(List<File> _images) async {
    await Future.wait(_images.map((image) => uploadFile(image)));
    setState(() {
      files = null;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: isLoading
          ? Scaffold(
              body: Center(
                child: uploadStatus(task!),
              ),
            )
          : Scaffold(
              appBar: AppBar(
                title: Text('Télécgarement'),
              ),
              body: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  children: [
                    widgetButton(
                      context,
                      "Sélectionner Fichiers",
                      Icons.attach_file,
                      Colors.black54,
                      selectFile,
                    ),
                    Expanded(
                      child: files != null
                          ? SingleChildScrollView(
                              child: Wrap(
                                children: files!.map(
                                  (images) {
                                    return Container(
                                      height: 100,
                                      width: 100,
                                      margin: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: FileImage(images),
                                            fit: BoxFit.cover),
                                      ),
                                    );
                                    // return Text("${basename(images.path)}");
                                  },
                                ).toList(),
                              ),
                            )
                          : Center(
                              child: Text('Aucun fichier sélectionné'),
                            ),
                    )
                  ],
                ),
              ),
              bottomNavigationBar: Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: SafeArea(
                  child: widgetButton(
                    context,
                    "Téléverser",
                    Icons.file_upload,
                    Theme.of(context).primaryColor,
                    () async {
                      if (files!.length >= 5) {
                        setState(() {
                          isLoading = true;
                        });
                        await uploadMultiFile(files!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Téléchargement terminée"),
                            duration: Duration(seconds: 5),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Séléctionnez au moins 5 images",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            duration: Duration(seconds: 8),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                    },
                  ),
                ),
              ),
            ),
    );
  }
}

Widget widgetButton(
  BuildContext context,
  String title,
  IconData icon,
  Color color,
  VoidCallback onClick,
) {
  return Container(
    height: 40,
    // color: Theme.of(context).primaryColor,
    margin: EdgeInsets.symmetric(horizontal: 10),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(elevation: 0.0, primary: color),
      onPressed: onClick,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          SizedBox(
            width: 10,
          ),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget uploadStatus(UploadTask task) {
  return StreamBuilder<TaskSnapshot>(
    stream: task.snapshotEvents,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final snap = snapshot.data!;
        final progress = snap.bytesTransferred / snap.totalBytes;
        final poucentage = (progress * 100).toStringAsFixed(0);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator.adaptive(),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  '$poucentage %',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
                ),
              ],
            )
          ],
        );
      } else {
        return Container();
      }
    },
  );
}
