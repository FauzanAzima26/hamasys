import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../education/education_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String lokasi = 'Mendeteksi lokasi...';
  String cuaca = 'Memuat cuaca...';
  String suhu = '-';
  double? lat;
  double? lon;

  final String apiKey = 'ed1aaf6c592a4f2d85141723251108';

  @override
  void initState() {
    super.initState();
    _getLokasi();
  }

  Future<void> _getLokasi() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => lokasi = 'GPS tidak aktif');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => lokasi = 'Izin lokasi ditolak');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => lokasi = 'Izin lokasi permanen ditolak');
        return;
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      lat = pos.latitude;
      lon = pos.longitude;

      await getWeather(lat!, lon!);
    } catch (e) {
      setState(() {
        lokasi = 'Gagal mendapatkan lokasi';
        cuaca = 'Error';
      });
    }
  }

  Future<void> getWeather(double lat, double lon) async {
    String url =
        'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$lat,$lon&lang=id';

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        setState(() {
          lokasi =
              "${data['location']?['name'] ?? '-'}, ${data['location']?['region'] ?? '-'}";
          cuaca = data['current']?['condition']?['text'] ?? '-';
          suhu = '${data['current']?['temp_c'] ?? '-'}°C';
        });
      } else {
        setState(() {
          cuaca = 'Gagal memuat cuaca';
        });
      }
    } catch (e) {
      setState(() {
        cuaca = 'Terjadi kesalahan';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFa8e063), Color(0xFF56ab2f)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monitoring Hama Burung',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hama Monitoring System',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 20),

                // Status Cards
                Row(
                  children: [
                    Expanded(
                      child: _statusCard(
                        Icons.cloud_done,
                        'Status',
                        'Online',
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _statusCard(
                        Icons.location_on,
                        'Lokasi',
                        lokasi,
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _statusCard(
                        Icons.thermostat,
                        'Suhu',
                        suhu,
                        const Color.fromARGB(255, 255, 175, 54),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Cuaca Card
                _infoCard(
                  Icons.wb_sunny,
                  'Cuaca',
                  cuaca,
                  iconColor: Colors.orange,
                ),

                const SizedBox(height: 20),

                // Tentang Aplikasi
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white.withOpacity(0.85),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Tentang Aplikasi",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Aplikasi ini memantau cuaca, suhu, lokasi, dan status "
                          "sistem pengusir hama burung secara real-time. Pastikan "
                          "GPS aktif agar data lokasi akurat.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EducationView(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.info_outline,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Pelajari Selengkapnya",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Tips Pencegahan Hama Burung
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white.withOpacity(0.85),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: Colors.orange,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Pasang alat pengusir di area rawan hama burung dan gunakan suara frekuensi tinggi yang tidak mengganggu manusia.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusCard(IconData icon, String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Colors.white70),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _infoCard(
    IconData icon,
    String title,
    String subtitle, {
    Color iconColor = Colors.green,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.85),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
