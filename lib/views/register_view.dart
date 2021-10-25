import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/auth_class.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final picker = ImagePicker();
  File? _imageFile;
  late TextEditingController _emailController,
      _reemailController,
      _passwordController,
      _repasswordController,
      _firstnameController,
      _lastnameController,
      _bioController,
      _hometownController,
      _yearController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _emailController = TextEditingController();
    _reemailController = TextEditingController();
    _passwordController = TextEditingController();
    _repasswordController = TextEditingController();
    _firstnameController = TextEditingController();
    _lastnameController = TextEditingController();
    _bioController = TextEditingController();
    _hometownController = TextEditingController();
    _yearController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _reemailController.dispose();
    _passwordController.dispose();
    _repasswordController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _bioController.dispose();
    _hometownController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Register"),
        ),
        body: Form(
            key: _formKey,
            child: ListView(padding: const EdgeInsets.all(8), children: [
              _imageFile == null
                  ? const Image(
                      image: AssetImage("assets/blank-profile-picture.png"))
                  : Image(image: FileImage(_imageFile!)),
              const SizedBox(height: 5.0),
              OutlinedButton(
                onPressed: () async {
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    if (pickedFile != null) {
                      _imageFile = File(pickedFile.path);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Loaded Image')));
                    }
                  });
                },
                child: const Text('Upload Photo'),
              ),
              const SizedBox(height: 5.0),
              TextFormField(
                autocorrect: false,
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: "Email Address",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Enter Email'),
              ),
              const SizedBox(height: 5.0),
              TextFormField(
                autocorrect: false,
                controller: _reemailController,
                validator: (value) {
                  if (value == null || value != _reemailController.text) {
                    return 'Email addresses do not match';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: "Reenter Email Address",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Re-Enter Email'),
              ),
              const SizedBox(height: 5.0),
              TextFormField(
                autocorrect: false,
                controller: _passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password cannot be empty';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: "Enter Password",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Enter Password'),
              ),
              const SizedBox(height: 5.0),
              TextFormField(
                autocorrect: false,
                controller: _repasswordController,
                validator: (value) {
                  if (value == null || value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: "Verify Password",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Verify Password'),
              ),
              const SizedBox(height: 5.0),
              TextFormField(
                autocorrect: false,
                controller: _firstnameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: "Enter Firstname",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Enter Firstname'),
              ),
              const SizedBox(height: 5.0),
              TextFormField(
                autocorrect: false,
                controller: _lastnameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lastname cannot be empty';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: "Enter Lastname",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Enter Lastname'),
              ),
              const SizedBox(height: 5.0),
              TextFormField(
                autocorrect: false,
                controller: _bioController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bio cannot be empty';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: "Enter Bio",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Enter Bio'),
              ),
              const SizedBox(height: 5.0),
              TextFormField(
                autocorrect: false,
                controller: _hometownController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Hometown cannot be empty';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: "Enter Hometown",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Enter Hometown'),
              ),
              const SizedBox(height: 5.0),
              TextFormField(
                autocorrect: false,
                controller: _yearController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Year cannot be empty';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: "Enter Year of Birth",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Enter Year of Birth'),
              ),
              const SizedBox(height: 5.0),
              OutlinedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data')));
                  }
                  setState(() {
                    register();
                  });
                },
                child: const Text('Submit'),
              )
            ])));
  }

  Future<void> register() async {
    try {
      User? user = await FireAuthClass.registerEmailPassword(
          email: _emailController.text, password: _passwordController.text);
      firebase_storage.FirebaseStorage storage =
          firebase_storage.FirebaseStorage.instance;
      String fileName = _imageFile!.path;
      String? downloadURL;
      try {
        await storage.ref('uploads/$fileName').putFile(_imageFile!);
        downloadURL = await firebase_storage.FirebaseStorage.instance
            .ref('uploads/$fileName')
            .getDownloadURL();
      } on firebase_storage.FirebaseException catch (e) {
        print(e.toString());
      }
      _db
          .collection("users")
          .doc(user!.uid)
          .set({
            "first_name": _firstnameController.text,
            "last_name": _lastnameController.text,
            "timestamp": DateTime.now(),
            "bio": _bioController.text,
            "hometown": _hometownController.text,
            "year": _yearController.text,
            "picture_url": downloadURL
          })
          .then((value) => null)
          .onError((error, stackTrace) => null);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() {});
  }
}
