import 'package:bluejobs/default_screens/view_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NearJobsPageMap extends StatefulWidget {
  @override
  _NearJobsPageMapState createState() => _NearJobsPageMapState();
}

class _NearJobsPageMapState extends State<NearJobsPageMap> {
  final List<Marker> _markers = [];
  LatLng _userLocation = LatLng(13.1339, 123.7427); // Default location
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final data = userDoc.data();
        if (data != null &&
            data.containsKey('latitude') &&
            data.containsKey('longitude')) {
          setState(() {
            _userLocation = LatLng(data['latitude'], data['longitude']);
          });
        }
      }
      await _loadPostMarkers(); 
    } catch (e) {
      print('Error loading user location: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPostMarkers() async {
    try {
      final posts = await FirebaseFirestore.instance.collection('Posts').get();
      if (posts.docs.isEmpty) {
        print('No posts found in Firestore.');
        return;
      }

      for (var doc in posts.docs) {
        final data = doc.data();
        if (data.containsKey('location')) {
          final String address = data['location'];
          final LatLng? coordinates = await _getCoordinatesFromAddress(address);
          if (coordinates != null) {
            final String title = data['description'] ?? 'Untitled Post';
            final String postId = doc.id;

            setState(() {
              _markers.add(
                Marker(
                  point: coordinates,
                  width: 80.0,
                  height: 80.0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewPostPage(postId: postId),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.redAccent,
                          size: 50.0,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
          } else {
            print('Failed to get coordinates for post: $data');
          }
        }
      }
    } catch (e) {
      print('Error loading post markers: $e');
    }
  }

  Future<LatLng?> _getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final coordinates = locations.first;
        return LatLng(coordinates.latitude, coordinates.longitude);
      }
      return null;
    } catch (e) {
      print('Error occurred while getting coordinates: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Opportunities Near You'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              setState(() {
                _loadUserLocation();
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    center: _userLocation, // Center map on user's location
                    zoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(markers: _markers),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _userLocation,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.blueAccent,
                            size: 50.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadUserLocation,
        child: const Icon(Icons.center_focus_strong),
        tooltip: 'Center Map',
      ),
    );
  }
}
