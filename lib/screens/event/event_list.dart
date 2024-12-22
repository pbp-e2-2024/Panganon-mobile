import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:panganon_mobile/screens/event/event_form.dart';
import 'package:panganon_mobile/screens/event/event_detail.dart'; // Pastikan path ini sesuai dengan struktur folder Anda


class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List events = []; // Untuk menyimpan daftar event

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  // Fungsi untuk mengambil data event dari backend Django
  Future<void> fetchEvents() async {
    final url = Uri.parse('http://127.0.0.1:8000/event/'); // Endpoint API Django
    try {
      final response = await http.get(url, headers: {'X-Requested-With': 'XMLHttpRequest'});
      if (response.statusCode == 200) {
        setState(() {
          events = json.decode(response.body); // Konversi JSON ke List
        });
      } else {
        throw Exception('Gagal memuat data event');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteEvent(int eventId) async {
    final url = Uri.parse('http://127.0.0.1:8000/event/delete_event_flutter/');
    try {
      final response = await http.post(
        url,
        headers: {'X-Requested-With': 'XMLHttpRequest'},
        body: {'event_id': eventId.toString()},
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event deleted successfully!')),
        );
        fetchEvents();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete event')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred')),
      );
    }
  }

  

  // Widget untuk menampilkan daftar event
  Widget buildEventItem(event) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profil pengguna
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.black,
                radius: 32,
              ),
              CircleAvatar(
                backgroundImage: event['created_by_image'] != null
                    ? NetworkImage(event['created_by_image'])
                    : AssetImage('assets/images/default-profile.jpg') as ImageProvider,
                radius: 28,
              ),
            ],
          ),
          SizedBox(width: 12),
          // Detail event
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Navigasi ke halaman detail event
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailPage(eventId: event['id']),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama event
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      event['name'],
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  // Deskripsi event
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      event['description'],
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ),
                  SizedBox(height: 6),
                  // Info pembuat dan tanggal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Created by: ${event['created_by'] ?? 'Unknown'}",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        event['date'] ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Event'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Navigasi ke form tambah event
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EventFormPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header informasi
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Informasi Festival Makanan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Berikut ini adalah informasi terkait Festival Makanan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EventFormPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Create New Event'),
                  ),
                ],
              ),
            ),
            // Daftar event
            events.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: events.length,
                    itemBuilder: (context, index) => buildEventItem(events[index]),
                  ),
          ],
        ),
      ),
    );
  }
}



