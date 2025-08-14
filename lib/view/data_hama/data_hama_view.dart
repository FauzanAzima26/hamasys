import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DataHamaView extends StatefulWidget {
  const DataHamaView({super.key});

  @override
  State<DataHamaView> createState() => _DataHamaViewState();
}

class _DataHamaViewState extends State<DataHamaView> {
  final List<Map<String, dynamic>> _logMessages = [];
  late Timer _timer;

  /// Konfigurasi ThingSpeak
  static const String channelId = "3034607";
  static const String readApiKey = "83E30R03Y3UOFJK1";
  static const String writeApiKey = "F37QJQ0FRO2UQ1QM";

  String get readUrl =>
      "https://api.thingspeak.com/channels/$channelId/feeds.json?api_key=$readApiKey&results=5";

  @override
  void initState() {
    super.initState();
    // Ambil data setiap 5 detik
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchThingSpeakData();
    });
    fetchThingSpeakData();
  }

  /// Ambil data dari ThingSpeak
  Future<void> fetchThingSpeakData() async {
    try {
      final response = await http.get(Uri.parse(readUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final feeds = (data['feeds'] ?? []) as List;

        setState(() {
          _logMessages.clear();
          for (var feed in feeds.reversed) {
            String pir1 = feed['field1'] ?? '0';
            String jarak = feed['field5'] ?? '0';
            String waktu = feed['created_at'] ?? '';

            _logMessages.add({'pir': pir1, 'jarak': jarak, 'time': waktu});
          }
        });
      } else {
        debugPrint("Gagal ambil data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  /// Reset data hanya untuk PIR1 dan Jarak
  Future<void> resetThingSpeakData() async {
    const String updateUrl = "https://api.thingspeak.com/update";

    try {
      final response = await http.get(
        Uri.parse('$updateUrl?api_key=$writeApiKey&field1=0&field5=0'),
      );

      if (response.statusCode == 200) {
        if (response.body == '0') {
          print("❌ Gagal reset data: Channel tidak update");
        } else {
          print("✅ Data berhasil direset. Entry ID: ${response.body}");
          fetchThingSpeakData();
        }
      } else {
        print("❌ Gagal reset data: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("⚠ Error saat reset data: $e");
    }
  }

  /// Dialog konfirmasi sebelum reset
  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Konfirmasi Reset"),
          content: const Text(
            "Apakah Anda yakin ingin mereset data? Data terakhir akan diisi dengan nilai 0.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(ctx);
                resetThingSpeakData();
              },
              child: const Text("Reset"),
            ),
          ],
        );
      },
    );
  }

  /// Item log baru
  Widget _buildLogItem(Map<String, dynamic> log) {
    bool terdeteksi = log['pir'] == '1';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: ListTile(
        leading: Icon(
          terdeteksi ? Icons.warning_amber_rounded : Icons.check_circle,
          color: terdeteksi ? Colors.red : Colors.green,
          size: 28,
        ),
        title: Text(
          terdeteksi ? "Hama Terdeteksi!" : "Tidak Ada Hama",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: terdeteksi ? Colors.red : Colors.green,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Jarak: ${log['jarak']} cm",
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              "Waktu: ${log['time']}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Monitoring Hama Real-Time'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 3,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: "Reset Data",
            onPressed: _showResetConfirmation,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: _logMessages.isEmpty
            ? const Center(
                child: Text(
                  'Menunggu data hama...',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.separated(
                reverse: true,
                itemCount: _logMessages.length,
                separatorBuilder: (_, __) =>
                    Divider(color: Colors.green.shade200),
                itemBuilder: (context, index) =>
                    _buildLogItem(_logMessages[index]),
              ),
      ),
    );
  }
}
