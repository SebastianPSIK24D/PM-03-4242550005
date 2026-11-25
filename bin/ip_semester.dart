import 'dart:io';

/// Data satu mata kuliah.
typedef MataKuliah = ({String nama, int sks, String nilai});

// Batas SKS yang diterima.
const int sksMin = 1;
const int sksMaks = 6;

// Bobot nilai dalam huruf
const Map<String, int> bobotNilai = {'A': 4, 'B': 3, 'C': 2, 'D': 1, 'E': 0};

// Mata kuliah dengan bobot di bawah ini dianggap perlu diperbaiki.
const int bobotMinimal = 2;

// Lebar kolom tabel KHS.
const int lebarNama = 24;
const int lebarSks = 5;
const int lebarNilai = 6;
const int lebarTabel = lebarNama + lebarSks + lebarNilai;

/// Mengubah nilai huruf menjadi bobot.
int bobot(String huruf) {
  final int? nilai = bobotNilai[huruf]; // null jika huruf tidak dikenal
  if (nilai == null) {
    throw FormatException('Nilai "$huruf" tidak dikenal.');
  }
  return nilai;
}

/// Periksa SKS. Melempar [FormatException] jika bukan angka 1-6.
int validasiSks(String teks) {
  final int? sks = int.tryParse(teks.trim());
  if (sks == null || sks < sksMin || sks > sksMaks) {
    throw FormatException(
      'SKS harus berupa angka $sksMin-$sksMaks, bukan "$teks".',
    );
  }
  return sks;
}

/// Periksa nilai huruf. Melempar [FormatException] jika bukan A-E.
String validasiNilai(String teks) {
  final String huruf = teks.trim().toUpperCase();
  if (!bobotNilai.containsKey(huruf)) {
    throw FormatException(
      'Nilai harus ${bobotNilai.keys.join(', ')}, bukan "$teks".',
    );
  }
  return huruf;
}

/// Menampilkan [label], lalu membaca satu baris input.
String bacaBaris(String label) {
  stdout.write(label);
  return (stdin.readLineSync() ?? '').trim(); // String? -> ganti ''
}

/// Menjumlahkan SKS semua mata kuliah.
int totalSks(List<MataKuliah> data) {
  return data.fold<int>(0, (jumlah, m) => jumlah + m.sks);
}

/// Menghitung IP = total (SKS x bobot) dibagi total SKS.
double hitungIp(List<MataKuliah> data) {
  final int sks = totalSks(data);
  if (sks == 0) return 0;
  final int mutu = data.fold<int>(
    0,
    (jumlah, m) => jumlah + m.sks * bobot(m.nilai),
  );
  return mutu / sks;
}

/// Menentukan predikat dari IP (skala contoh).
String predikat(double ip) {
  if (ip >= 3.5) return 'Sangat Memuaskan';
  if (ip >= 3.0) return 'Memuaskan';
  if (ip >= 2.0) return 'Cukup';
  return 'Kurang';
}

/// Mengambil nama mata kuliah yang bobotnya di bawah [bobotMinimal].
List<String> mkPerluDiperbaiki(List<MataKuliah> data) {
  return data
      .where((m) => bobot(m.nilai) < bobotMinimal)
      .map((m) => m.nama)
      .toList();
}

/// Mencetak KHS. Jika [urutkan] true, nilai tertinggi tampil lebih dulu.
void cetakKhs(List<MataKuliah> data, {bool urutkan = false}) {
  final List<MataKuliah> daftar = [...data]; // salinan, data asli tetap
  if (urutkan) {
    // Fungsi pembanding: bobot yang lebih besar didahulukan.
    daftar.sort((a, b) => bobot(b.nilai).compareTo(bobot(a.nilai)));
  }

  print(
    '${'Mata Kuliah'.padRight(lebarNama)}'
    '${'SKS'.padLeft(lebarSks)}'
    '${'Nilai'.padLeft(lebarNilai)}',
  );
  print('-' * lebarTabel);
  for (final m in daftar) {
    print(
      '${m.nama.padRight(lebarNama)}'
      '${m.sks.toString().padLeft(lebarSks)}'
      '${m.nilai.padLeft(lebarNilai)}',
    );
  }
  print('-' * lebarTabel);

  final double ip = hitungIp(data);
  final List<String> perbaiki = mkPerluDiperbaiki(data);
  print('Total SKS : ${totalSks(data)}');
  print('IP        : ${ip.toStringAsFixed(2)} (${predikat(ip)})');
  if (perbaiki.isNotEmpty) {
    print('Perlu diperbaiki: ${perbaiki.join(', ')}');
  }
}

void main() {
  final List<MataKuliah> data = [];

  print('Masukkan data mata kuliah. Kosongkan nama untuk selesai.');
  while (true) {
    final String nama = bacaBaris('Nama MK : ');
    if (nama.isEmpty) break;

    try {
      final int sks = validasiSks(bacaBaris('SKS     : '));
      final String nilai = validasiNilai(bacaBaris('Nilai   : '));
      data.add((nama: nama, sks: sks, nilai: nilai));
    } on FormatException catch (e) {
      // Data salah diabaikan, program tetap berjalan.
      print('Data diabaikan: ${e.message}');
    }
  }

  if (data.isEmpty) {
    print('Belum ada data.');
    return;
  }

  final double ip = hitungIp(data);
  final List<String> perbaiki = mkPerluDiperbaiki(data);
  print('Total SKS : ${totalSks(data)}');
  print('IP        : ${ip.toStringAsFixed(2)} (${predikat(ip)})');
  if (perbaiki.isNotEmpty) {
    print('Perlu diperbaiki: ${perbaiki.join(', ')}');
  }
}
