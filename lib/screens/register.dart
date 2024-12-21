import 'dart:convert';
import 'dart:typed_data'; // Import for Uint8List
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:panganon_mobile/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  XFile? _image; // Use XFile for better compatibility

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
        });
      }
    } catch (e) {
      _showSnackbar(context, 'Failed to pick image.', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            color: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  _buildTextField(
                    controller: _usernameController,
                    label: 'Username',
                    hint: 'Enter your username',
                  ),
                  const SizedBox(height: 12.0),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 12.0),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hint: 'Confirm your password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 24.0),
                  _image != null
                      ? (kIsWeb
                          ? FutureBuilder<Uint8List>(
                              future: _image!.readAsBytes(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.done &&
                                    snapshot.hasData) {
                                  return Image.memory(
                                    snapshot.data!,
                                    height: 100,
                                    width: 100,
                                  );
                                } else if (snapshot.hasError) {
                                  return const Text(
                                    "Error loading image",
                                    style: TextStyle(color: Colors.white),
                                  );
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              },
                            )
                          : Image.file(
                              File(_image!.path),
                              height: 100,
                              width: 100,
                            ))
                      : TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image, color: Colors.white),
                          label: const Text(
                            "Upload Image",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: () async {
                      String username = _usernameController.text.trim();
                      String password1 = _passwordController.text;
                      String password2 = _confirmPasswordController.text;

                      if (username.isEmpty ||
                          password1.isEmpty ||
                          password2.isEmpty) {
                        _showSnackbar(
                            context, 'Please fill all the fields!', false);
                        return;
                      }

                      if (password1 != password2) {
                        _showSnackbar(
                            context, 'Passwords do not match!', false);
                        return;
                      }

                      String? imageBase64;
                      if (_image != null) {
                        try {
                          final bytes = await _image!.readAsBytes();
                          String mimeType = _image!.mimeType ?? 'image/jpeg'; // Default MIME type
                          
                          // Validate MIME type
                          if (!mimeType.startsWith('image/')) {
                            _showSnackbar(
                                context, 'Selected file is not an image!', false);
                            return;
                          }

                          imageBase64 =
                              "data:$mimeType;base64,${base64Encode(bytes)}";
                        } catch (e) {
                          _showSnackbar(
                              context, 'Failed to read image bytes.', false);
                          return;
                        }
                      }
                    
                      final response = await request.postJson(
                        "https://brian-altan-panganon.pbp.cs.ui.ac.id/auth/register_flutter/",
                        jsonEncode({
                          "username": username,
                          "password1": password1,
                          "password2": password2,
                          "image": imageBase64,
                        }),
                      );

                      if (context.mounted) {
                        if (response['status'] == true) {
                          _showSnackbar(
                              context,
                              response['message'] ??
                                  'Successfully registered!',
                              true);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        } else {
                          _showSnackbar(
                              context,
                              response['message'] ??
                                  'Failed to register!',
                              false);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      padding:
                          const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text('Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white),
        hintStyle: const TextStyle(color: Colors.white54),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      obscureText: obscureText,
    );
  }

  void _showSnackbar(BuildContext context, String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}
