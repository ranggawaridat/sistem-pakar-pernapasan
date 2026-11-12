import 'package:flutter/material.dart';
import '../data/expert_rules.dart';
import 'result_screen.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  _DiagnosisScreenState createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  bool _isStarted = false;
  int _currentIndex = 0;
  final List<String> _selectedSymptoms = [];
  final List<String> _keys = ExpertSystemEngine.symptoms.keys.toList();

  void _startDiagnosis() {
    setState(() {
      _isStarted = true;
      _currentIndex = 0;
      _selectedSymptoms.clear();
    });
  }

  void _answerQuestion(bool isYes) {
    if (isYes) {
      _selectedSymptoms.add(_keys[_currentIndex]);
    }

    setState(() {
      if (_currentIndex < _keys.length - 1) {
        _currentIndex++;
      } else {
        // Selesai kuesioner, evaluasi dengan Forward Chaining
        var result = ExpertSystemEngine.evaluateDiagnosis(_selectedSymptoms);
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              diagnosisResult: result,
              selectedSymptoms: List<String>.from(_selectedSymptoms),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isStarted) {
      // Halaman Sambutan / Beranda
      return Scaffold(
        backgroundColor: const Color(0xFFF0FDF4),
        appBar: AppBar(
          title: const Text("Sistem Pakar Pernapasan"),
          backgroundColor: const Color(0xFF0D9488),
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.air, size: 80, color: Color(0xFF0D9488)),
              const SizedBox(height: 20),
              const Text(
                "Cek Kesehatan Pernapasanmu Sekarang!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 12),
              const Text(
                "Deteksi dini penyakit pernapasan kronis seperti Asma, PPOK, FPI, Bronkiektasis, dan Sarkoidosis menggunakan metode Forward Chaining.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _startDiagnosis,
                  child: const Text("Mulai Tes Diagnosis", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Halaman Pertanyaan Kuesioner Berbasis Gejala
    String currentCode = _keys[_currentIndex];
    String currentText = ExpertSystemEngine.symptoms[currentCode]!;
    double progress = (_currentIndex + 1) / _keys.length;

    return Scaffold(
      appBar: AppBar(
        title: Text("Pertanyaan ${_currentIndex + 1} dari ${_keys.length}"),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              color: const Color(0xFF0D9488),
            ),
            const SizedBox(height: 30),
            Text(
              "Kode Gejala: $currentCode",
              style: const TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              "Apakah Anda merasakan gejala berikut: \n\n\"$currentText\"?",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _answerQuestion(false),
                    child: const Text("Tidak", style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _answerQuestion(true),
                    child: const Text("Ya", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}