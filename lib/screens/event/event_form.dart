import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EventFormPage extends StatefulWidget {
  final int? eventId;

  EventFormPage({this.eventId});

  @override
  _EventFormPageState createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String formTitle = 'Create';
  String buttonText = 'Create Event';
  Map<String, String> errors = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) {
      formTitle = 'Edit';
      buttonText = 'Update Event';
      fetchEventData(widget.eventId!);
    }
  }

  Future<void> fetchEventData(int eventId) async {
    setState(() => isLoading = true);
    final url = Uri.parse('http://127.0.0.1:8000/event/$eventId/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final event = json.decode(response.body);
      setState(() {
        _nameController.text = event['name'];
        _descriptionController.text = event['description'];
        _locationController.text = event['location'];
        _dateController.text = event['date'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to load event data.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      final request = context.read<CookieRequest>();

      final url = widget.eventId != null
          ? 'http://127.0.0.1:8000/event/update_flutter/${widget.eventId}/'
          : 'http://127.0.0.1:8000/event/create_flutter/';

      // Perform the POST request using the CookieRequest instance
      final response = await request.post(
        url,
        jsonEncode({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'location': _locationController.text,
          'date': _dateController.text,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        setState(() => isLoading = false);

        // Navigasi ke event_list.dart
        Navigator.pushReplacementNamed(context, '/event_list');
      } else {
        setState(() {
          isLoading = false;
          errors = data['errors'] ?? {};
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$formTitle Event'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white), // Back button color
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildInputField(
                          controller: _nameController,
                          label: 'Nama Acara',
                          icon: Icons.event,
                          errorText: errors['name'],
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Nama Acara harus diisi' : null,
                        ),
                        const SizedBox(height: 16),
                        buildInputField(
                          controller: _descriptionController,
                          label: 'Keterangan',
                          icon: Icons.description,
                          errorText: errors['description'],
                          isMultiline: true,
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Keterangan harus diisi' : null,
                        ),
                        const SizedBox(height: 16),
                        buildInputField(
                          controller: _locationController,
                          label: 'Lokasi Acara',
                          icon: Icons.location_on,
                          errorText: errors['location'],
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Lokasi Acara harus diisi' : null,
                        ),
                        const SizedBox(height: 16),
                        buildInputField(
                          controller: _dateController,
                          label: 'Tanggal Acara',
                          icon: Icons.date_range,
                          errorText: errors['date'],
                          readOnly: true,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                _dateController.text =
                                    "${picked.year}-${picked.month}-${picked.day} ${time.hour}:${time.minute}";
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        if (errors.isNotEmpty)
                          Column(
                            children: errors.entries.map((e) {
                              return Text(
                                '${e.key}: ${e.value}',
                                style: const TextStyle(color: Colors.red),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: isLoading ? null : submitForm,
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: Text(
                            buttonText,
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? errorText,
    bool isMultiline = false,
    bool readOnly = false,
    Function()? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        label: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        prefixIcon: Icon(icon, color: Colors.black),
        errorText: errorText,
        filled: true,
        fillColor: Colors.white,
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      maxLines: isMultiline ? 4 : 1,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
    );
  }
}
