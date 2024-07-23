import 'package:blog_app/HomePage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Authentication.dart';

class PhotoUploadPage extends StatefulWidget {
  final Authentication auth;

  const PhotoUploadPage({Key? key, required this.auth}) : super(key: key);

  @override
  State<PhotoUploadPage> createState() => _PhotoUploadPageState();
}

class _PhotoUploadPageState extends State<PhotoUploadPage>
    with SingleTickerProviderStateMixin {
  File? sampleImage;
  final formKey = GlobalKey<FormState>();
  late String url;
  String? _myValue;
  String? _title; // Add this line
  final uuid = Uuid();

  // Animation controller
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller and animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future getImage() async {
    final tempImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      sampleImage = tempImage != null ? File(tempImage.path) : null;
    });
    _controller.forward(); // Trigger animation when image is selected
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void uploadStatusImage() async {
    if (validateAndSave()) {
      final Reference postImageRef =
      FirebaseStorage.instance.ref().child("Post Images");

      var timeKey = DateTime.now();
      final UploadTask uploadTask =
      postImageRef.child(timeKey.toString() + ".jpg").putFile(sampleImage!);

      var imageUrl = await (await uploadTask).ref.getDownloadURL();

      url = imageUrl.toString();
      print("Image Url = $url");
      goToHome();
      saveToDatabase(url);
    }
  }

  void saveToDatabase(String url) {
    var dbTimeKey = DateTime.now();
    var formatDate = DateFormat('MMM d, yyyy');
    var formatTime = DateFormat('EEEE, hh:mm aaa');
    String date = formatDate.format(dbTimeKey);
    String time = formatTime.format(dbTimeKey);

    String postId = uuid.v4(); // Generate a unique ID for each post

    DatabaseReference ref = FirebaseDatabase.instance.ref();
    var data = {
      "id": postId,
      "image": url,
      "description": _myValue,
      "date": date,
      "time": time,
      "title": _title // Add this line
    };
    ref.child("Posts").child(postId).set(data);
  }

  void goToHome() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return HomePage(auth: widget.auth);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Blog",
          style: GoogleFonts.lobster(
            textStyle: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Container(
        color: Colors.grey[50], // Full-screen background color
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: sampleImage == null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Select Image",
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              )
                  : FadeTransition(
                opacity: _animation,
                child: enableUpload(),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Add Image',
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add_photo_alternate),
      ),
    );
  }

  Widget enableUpload() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white, // Background color for the form section
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.file(
                sampleImage!,
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.9,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: "Title", // Add this line
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: (value) {
                  return value!.isEmpty ? 'Title is required' : null; // Add this line
                },
                onSaved: (value) {
                  _title = value; // Add this line
                },
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                maxLines: null,
                validator: (value) {
                  return value!.isEmpty ? 'Description Is Required' : null;
                },
                onSaved: (value) {
                  _myValue = value;
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 12,
                backgroundColor: Colors.teal,
                padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                textStyle: const TextStyle(fontSize: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                // Button scale animation
                _controller.forward().then((_) {
                  uploadStatusImage();
                });
              },
              child: const Text("Add A New Post",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
