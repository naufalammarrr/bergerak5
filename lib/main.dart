import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontFamily: 'LocalFont'),
          titleMedium: TextStyle(fontFamily: 'LocalFont', fontSize: 20),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool useAlternateAssets = false;
  List<dynamic> jsonData = [];

  Future<void> loadJsonFromAssets() async {
    final String response = await rootBundle.loadString('assets/sample.json');
    setState(() {
      jsonData = json.decode(response);
    });
  }

  Future<void> loadJsonFromUrl() async {
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
      if (response.statusCode == 200) {
        setState(() {
          jsonData = json.decode(response.body);
        });
      }
    } catch (e) {
      print('Error loading JSON: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    loadJsonFromAssets(); // Default load from assets
  }

  @override
  Widget build(BuildContext context) {
    String imagePath = useAlternateAssets ? 'assets/alternate_img.jpg' : 'assets/default_img.jpeg';
    String fontFamily = useAlternateAssets ? 'AlternateFont' : 'LocalFont';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ammar Flutter App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadJsonFromUrl, // Load JSON from URL
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: OrientationBuilder(
              builder: (context, orientation) {
                return Center(
                  child: orientation == Orientation.portrait
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity),
                  )
                      : CachedNetworkImage(
                    imageUrl: 'https://via.placeholder.com/150',
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: jsonData.isNotEmpty
                ? ListView.builder(
              itemCount: jsonData.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        jsonData[index]['title'][0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      jsonData[index]['title'] ?? 'No Title',
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    subtitle: Text(jsonData[index]['body'] ?? 'No Content'),
                  ),
                );
              },
            )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            useAlternateAssets = !useAlternateAssets;
          });
        },
        child: const Icon(Icons.swap_horiz),
      ),
    );
  }
}
