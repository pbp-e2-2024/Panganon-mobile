import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:panganon_mobile/screens/event/event_form.dart';
import 'package:panganon_mobile/screens/event/event_list.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EventDetailPage extends StatefulWidget {
  final int eventId;

  EventDetailPage({required this.eventId});

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late Map<String, dynamic> event;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEventDetails();
  }

  Future<void> fetchEventDetails() async {
    final url = Uri.parse('http://127.0.0.1:8000/event/${widget.eventId}');
    final response =
        await http.get(url, headers: {'X-Requested-With': 'XMLHttpRequest'});

    if (response.statusCode == 200) {
      setState(() {
        event = json.decode(response.body);
        isLoading = false;
      });
    } else {
      _showErrorDialog('Failed to load event details.');
    }
  }

  Future<void> deleteEvent() async {
    final request = context.read<CookieRequest>();
    final url =
        'http://127.0.0.1:8000/event/${widget.eventId}/delete-flutter/';
    final response = await request.post(url, '');

    if (response['success']) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => EventListPage()));
    } else {
      _showErrorDialog('Failed to delete event.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Event'),
        content: Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['name'] ?? 'N/A',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Divider(),
                            SizedBox(height: 10),
                            _buildDetailRow(
                                icon: Icons.description,
                                label: 'Description',
                                value: event['description'] ?? 'N/A'),
                            SizedBox(height: 10),
                            _buildDetailRow(
                                icon: Icons.location_pin,
                                label: 'Location',
                                value: event['location'] ?? 'N/A'),
                            SizedBox(height: 10),
                            _buildDetailRow(
                                icon: Icons.calendar_today,
                                label: 'Date',
                                value: event['date'] ?? 'N/A'),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EventListPage()));
                          },
                          icon: Icon(Icons.arrow_back),
                          label: Text('Back'),
                        ),
                        context.read<CookieRequest>().getJsonData()['username'] == event['created_by']['username'] ?
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EventFormPage(
                                            eventId: widget.eventId,
                                          )),
                                );
                              },
                              icon: Icon(Icons.edit),
                              label: Text('Edit'),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: () async {
                                bool? confirmDelete =
                                    await _showConfirmDialog();
                                if (confirmDelete == true) {
                                  await deleteEvent();
                                }
                              },
                              icon: Icon(Icons.delete),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              label: Text('Delete'),
                            ),
                          ],
                        ) : const SizedBox.shrink(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDetailRow(
      {required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Theme.of(context).primaryColor),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
