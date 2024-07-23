import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class EditPostPage extends StatefulWidget {
  final String postId;
  final String currentImage;
  final String currentDescription;

  const EditPostPage({
    Key? key,
    required this.postId,
    required this.currentImage,
    required this.currentDescription,
  }) : super(key: key);

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _formKey = GlobalKey<FormState>();
  File? _newImage;
  String? _newDescription;

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _newImage = pickedImage != null ? File(pickedImage.path) : null;
    });
  }

  Future<void> _updatePost() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // Handle image upload if a new image is picked
      String imageUrl = widget.currentImage;
      if (_newImage != null) {
        final imageRef = FirebaseStorage.instance
            .ref()
            .child("Post Images")
            .child(widget.postId + ".jpg");
        final uploadTask = imageRef.putFile(_newImage!);
        final snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      // Update the post in the database
      final postRef =
          FirebaseDatabase.instance.ref().child("Posts").child(widget.postId);
      await postRef.update({
        'image': imageUrl,
        'description': _newDescription ?? widget.currentDescription,
      });

      Navigator.pop(context, true); // Pass true to indicate an update occurred
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Post',
          style: GoogleFonts.lobster(
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        color: Colors.grey[200], // Full-screen background color
        width: MediaQuery.of(context).size.width, // Ensure full width
        height: MediaQuery.of(context).size.height, // Ensure full height
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: _newImage == null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.network(
                              widget.currentImage,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  height: 200,
                                  width: double.infinity,
                                  child:
                                      Center(child: Text('No image available')),
                                );
                              },
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.file(
                              _newImage!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16.0),
                  Center(
                    child: TextButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.camera_alt, color: Colors.teal),
                      label: Text(
                        'Change Image',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            color: Colors.teal,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.teal,
                        textStyle: GoogleFonts.poppins(
                          textStyle: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  TextFormField(
                    initialValue: widget.currentDescription,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      labelStyle: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: Colors.teal,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    maxLines: null,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _newDescription = value;
                    },
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: _updatePost,
                      child: Text(
                        'Update Post',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(
                            horizontal: 32.0, vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
