import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class EducationView extends StatefulWidget {
  const EducationView({super.key});

  @override
  State<EducationView> createState() => _EducationViewState();
}

class _EducationViewState extends State<EducationView> {
  final List<Map<String, String>> videos = [
    {
      'url': 'https://youtu.be/QgKVURkPMYA?si=2MX7HbtzbKxTRtgS',
      'title': 'Cara Mengusir Hama Burung dengan Efektif',
      'description': 'Video tutorial penggunaan alat pengusir hama burung yang aman dan efektif.'
    },
    {
      'url': 'https://youtu.be/5Rvj4H-sqco?si=Yr0c_mvmd55Dec91',
      'title': 'Tips Pencegahan Hama Burung di Ladang',
      'description': 'Berbagai tips praktis untuk mencegah gangguan hama burung di lahan pertanian.'
    },
    {
      'url': 'https://youtu.be/DowcsAkyioQ?si=6ktFal7O4hFKEJzr',
      'title': 'Teknologi Pengusir Hama Burung Modern',
      'description': 'Pembahasan teknologi terkini dalam pengusiran hama burung secara ramah lingkungan.'
    },
  ];

  late List<YoutubePlayerController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = videos.map((video) {
      final videoId = YoutubePlayer.convertUrlToId(video['url']!);
      return YoutubePlayerController(
        initialVideoId: videoId ?? '',
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edukasi Hama'),
        foregroundColor: Colors.white, 
        backgroundColor: const Color.fromARGB(255, 77, 212, 84),
        centerTitle: true,
        elevation: 4,
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            final controller = _controllers[index];

            return Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    YoutubePlayer(
                      controller: controller,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: Colors.green,
                      progressColors: const ProgressBarColors(
                        playedColor: Colors.green,
                        handleColor: Colors.greenAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      video['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      video['description'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
