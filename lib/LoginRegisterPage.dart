import 'package:blog_app/Authentication.dart';
import 'package:blog_app/DialogBox.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginRegisterPage extends StatefulWidget {
  final Authentication auth;
  final VoidCallback? onSignedIn;

  LoginRegisterPage({
    required this.auth,
    this.onSignedIn,
  });

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

enum FormType { login, register }

class _LoginRegisterPageState extends State<LoginRegisterPage>
    with SingleTickerProviderStateMixin {
  DialogBox dialogBox = DialogBox();

  final formKey = GlobalKey<FormState>();
  FormType _formType = FormType.login;
  String _email = "";
  String _password = "";

  AnimationController? _controller;
  Animation<double>? _animation;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller!, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.easeInOut),
    );
    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        String? userId;
        if (_formType == FormType.login) {
          userId = await widget.auth.signIn(_email, _password);
          print("Login User Id  = " + userId!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login successful! Welcome back!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          userId = await widget.auth.signUp(_email, _password);
          print("Register User Id  = " + userId!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Account created successfully! You can now log in.'),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (widget.onSignedIn != null) {
          widget.onSignedIn!();
        }
      } catch (e) {
        dialogBox.information(context, "Error=", e.toString());
        print("Error" + e.toString());
      }
    }
  }

  void moveToRegister() {
    formKey.currentState?.reset();

    setState(() {
      _formType = FormType.register;
      _controller!.reset();
      _controller!.forward();
    });
  }

  void moveToLogin() {
    formKey.currentState?.reset();

    setState(() {
      _formType = FormType.login;
      _controller!.reset();
      _controller!.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Blog App",
          style: GoogleFonts.lobster(
            textStyle: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w400,
              letterSpacing: 2.0,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: FadeTransition(
        opacity: _animation!,
        child: ScaleTransition(
          scale: _scaleAnimation!,
          child: Container(
            // Use a full-screen container with gradient background
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade50, Colors.teal.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: createInputs() + createButton(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> createInputs() {
    return [
      const SizedBox(height: 20.0),
      logo(),
      const SizedBox(height: 20.0),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Email',
          labelStyle: TextStyle(color: Colors.teal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.teal),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.teal, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
        ),
        style: GoogleFonts.lato(),
        validator: (value) {
          return value?.isEmpty == true ? 'Email is required.' : null;
        },
        onSaved: (value) {
          _email = value ?? "";
        },
      ),
      const SizedBox(height: 20.0),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: TextStyle(color: Colors.teal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.teal),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.teal, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
        ),
        obscureText: true,
        style: GoogleFonts.lato(),
        validator: (value) {
          return value?.isEmpty == true ? 'Password is required.' : null;
        },
        onSaved: (value) {
          _password = value ?? "";
        },
      ),
      const SizedBox(height: 20.0),
    ];
  }

  Widget logo() {
    return Hero(
      tag: 'Hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 110.0,
        child: Image.asset('assets/Images/logo.png'),
      ),
    );
  }

  List<Widget> createButton() {
    if (_formType == FormType.login) {
      return [
        const SizedBox(height: 20.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: const Text("Login"),
          onPressed: validateAndSubmit,
        ),
        const SizedBox(height: 20.0),
        TextButton(
          child: const Text(
            "Don't have an account? Create Account",
            style: TextStyle(fontSize: 14, color: Colors.teal),
          ),
          onPressed: moveToRegister,
        ),
      ];
    } else {
      return [
        const SizedBox(height: 20.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: const Text("Create Account"),
          onPressed: validateAndSubmit,
        ),
        const SizedBox(height: 20.0),
        TextButton(
          child: const Text(
            "Already have an account? Login",
            style: TextStyle(fontSize: 14, color: Colors.teal),
          ),
          onPressed: moveToLogin,
        ),
      ];
    }
  }
}
