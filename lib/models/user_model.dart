class UserModel {
  final String? id;          // User ID (from users table)
  final String? username;
  final String? role;
  final String? namaLengkap;
  final String? nik;
  final String? telp;
  final String? idPelanggan; // <-- THIS WAS MISSING

  UserModel({
    this.id,
    this.username,
    this.role,
    this.namaLengkap,
    this.nik,
    this.telp,
    this.idPelanggan,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // 1. Check if data is nested inside 'profile' (Common in your API logs)
    final profile = json['profile'] ?? {};

    return UserModel(
      // Map basic user fields
      id: json['user_id']?.toString() ?? json['id']?.toString(),
      username: json['username'],
      role: json['role'],
      
      // Map Profile fields (Handle both root and nested structure)
      namaLengkap: profile['nama_penumpang'] ?? profile['nama_petugas'] ?? json['nama_penumpang'] ?? json['nama'],
      nik: profile['nik']?.toString() ?? json['nik']?.toString(),
      telp: profile['telp'] ?? json['telp'],
      
      // --- CRITICAL FIX: Map idPelanggan ---
      // Usually 'id' inside the 'profile' object, or 'id_pelanggan' in root
      idPelanggan: profile['id']?.toString() ?? json['id_pelanggan']?.toString(), 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'username': username,
      'role': role,
      'profile': {
        'id': idPelanggan,
        'nama_penumpang': namaLengkap,
        'nik': nik,
        'telp': telp,
      }
    };
  }
}