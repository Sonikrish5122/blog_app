import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Authentication.dart';
import 'PhotoUploadPage.dart';
import 'Posts.dart';
import 'EditPostPage.dart';
import 'PostDetailsPage.dart'; // Import your new PostDetailsPage

class HomePage extends StatefulWidget {
  final Authentication auth;
  final VoidCallback? onSignedOut;

  HomePage({
    required this.auth,
    this.onSignedOut,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true; // Track loading state

  Future<List<Posts>> _fetchPosts() async {
    try {
      DatabaseReference postsRef =
          FirebaseDatabase.instance.ref().child("Posts");
      DatabaseEvent event = await postsRef.once();
      DataSnapshot snapshot = event.snapshot;

      List<Posts> posts = [];
      if (snapshot.value != null) {
        var values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, data) {
          Posts post = Posts(
            id: key,
            image: data['image'],
            description: data['description'],
            date: data['date'],
            time: data['time'],
            title: data['title'],
          );
          posts.add(post);
        });
      } else {
        print('No posts available');
      }
      return posts;
    } catch (error) {
      print('Error fetching posts: $error');
      throw error; // This will trigger the error state in FutureBuilder
    }
  }

  void _logoutUser() async {
    try {
      await widget.auth.signOut();
      if (widget.onSignedOut != null) {
        widget.onSignedOut!();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void _deletePost(String postId) {
    DatabaseReference postRef =
        FirebaseDatabase.instance.ref().child("Posts").child(postId);
    postRef.remove().then((_) {
      print("Post deleted");
      setState(() {
        // Optionally update the state to reflect the post deletion
      });
    }).catchError((error) {
      print("Error deleting post: $error");
    });
  }

  void _showDeleteDialog(String postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Post',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this post?',
            style: GoogleFonts.lato(fontSize: 16),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: GoogleFonts.lato(color: Colors.teal),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: GoogleFonts.lato(color: Colors.red),
              ),
              onPressed: () {
                _deletePost(postId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToEditPost(
      String postId, String currentImage, String currentDescription) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostPage(
          postId: postId,
          currentImage: currentImage,
          currentDescription: currentDescription,
        ),
      ),
    );

    if (result == true) {
      setState(() {
        // Refresh the post list
      });
    }
  }

  void _navigateToPostDetails(String image, String title, String description,
      String date, String time) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailsPage(
          image: image,
          title: title,
          description: description,
          date: date,
          time: time,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Blog HomePage",
          style: GoogleFonts.lobster(
            textStyle: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logoutUser,
          ),
        ],
      ),
      body: FutureBuilder<List<Posts>>(
        future: _fetchPosts(),
        builder: (BuildContext context, AsyncSnapshot<List<Posts>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error fetching posts: ${snapshot.error}",
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No Blog Post Available",
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            );
          } else {
            List<Posts> posts = snapshot.data!;
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (_, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _postCard(
                    posts[index].id,
                    posts[index].image,
                    posts[index].description,
                    posts[index].date,
                    posts[index].time,
                    posts[index].title,
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoUploadPage(auth: widget.auth),
            ),
          );
        },
        child: Icon(Icons.add_a_photo),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _postCard(String id, String image, String description, String date,
      String time, String title) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 180,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return Center(
                      child: Text(
                        'Error loading image',
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    );
                  },
                ),
              ),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.date_range, color: Colors.grey[700], size: 20),
                    SizedBox(width: 8),
                    Text(
                      date,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.access_time, color: Colors.grey[600], size: 20),
                    SizedBox(width: 8),
                    Text(
                      time,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.start,
            buttonPadding: EdgeInsets.symmetric(horizontal: 8),
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () => _navigateToPostDetails(
                    image, title, description, date, time),
                child: Text(
                  'View Details',
                  style: GoogleFonts.lato(fontSize: 16, color: Colors.white),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () => _navigateToEditPost(id, image, description),
                child: Text(
                  'Edit',
                  style: GoogleFonts.lato(fontSize: 16, color: Colors.white),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () => _showDeleteDialog(id),
                child: Text(
                  'Delete',
                  style: GoogleFonts.lato(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
