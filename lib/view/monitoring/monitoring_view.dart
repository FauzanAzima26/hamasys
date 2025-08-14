import 'package:flutter/material.dart';

class MonitoringView extends StatefulWidget {
  const MonitoringView({super.key});

  @override
  State<MonitoringView> createState() => _MonitoringViewState();
}

class _MonitoringViewState extends State<MonitoringView> with SingleTickerProviderStateMixin {
  bool alatHidup = false;

  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _colorAnimation = ColorTween(
      begin: Colors.red.shade400,
      end: Colors.green.shade600,
    ).animate(_animationController);
  }

  void toggleAlat(bool value) {
    setState(() {
      alatHidup = value;
      if (alatHidup) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void bunyikanSuara() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Suara pengusir hama diaktifkan!')),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Alat'),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Switch untuk on/off alat
            AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _colorAnimation.value?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Alat ${alatHidup ? "Hidup" : "Mati"}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: alatHidup ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                    Switch(
                      value: alatHidup,
                      activeColor: Colors.green.shade700,
                      inactiveThumbColor: Colors.red.shade700,
                      onChanged: toggleAlat,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Tombol bunyikan suara
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: alatHidup ? bunyikanSuara : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                child: const Text(
                  'Bunyikan Suara',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
