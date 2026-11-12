import 'package:flutter/material.dart';
import 'diagnosis_screen.dart';
import '../utils/pdf_report.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> diagnosisResult;

  /// Kode gejala yang dijawab "Ya" oleh pengguna (untuk laporan PDF).
  final List<String> selectedSymptoms;

  const ResultScreen({
    super.key,
    required this.diagnosisResult,
    this.selectedSymptoms = const [],
  });

  Future<void> _cetakPdf(BuildContext context) async {
    try {
      await DiagnosisPdfReport.share(
        diagnosisResult: diagnosisResult,
        selectedSymptoms: selectedSymptoms,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal membuat PDF. Silakan coba lagi.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hasil Diagnosis Sistem Pakar"),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Hasil Analisis Berdasarkan Gejala:",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  border: Border.all(color: const Color(0xFF0D9488), width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diagnosisResult['code'],
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      diagnosisResult['name'],
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      diagnosisResult['description'] ?? '',
                      style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563), height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Saran / Penanganan Medis Awal:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  diagnosisResult['solution'],
                  style: const TextStyle(fontSize: 14, color: Color(0xFF374151), height: 1.4),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _cetakPdf(context),
                  child: const Text(
                    "Cetak Hasil (PDF)",
                    style: TextStyle(fontSize: 16, color: Color(0xFF0D9488), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const DiagnosisScreen()),
                    );
                  },
                  child: const Text("Ulangi Diagnosis", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
