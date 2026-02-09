class UserModel {
  int? id;
  String? username;
  String? role;
  int? idPelanggan;
  String? nik;
  String? namaLengkap;
  String? telp;

  UserModel({
    this.id, 
    this.username, 
    this.role, 
    this.idPelanggan,
    this.nik,
    this.namaLengkap,
    this.telp,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // 1. Determine if data is inside 'profile' or at root
    // If json has 'profile', use it. Otherwise, use json itself as the source for details.
    Map<String, dynamic> details = (json['profile'] != null && json['profile'] is Map) 
        ? json['profile'] 
        : json;

    return UserModel(
      // ID handling: Check user_id, then id
      id: int.tryParse(json['user_id']?.toString() ?? json['id']?.toString() ?? '0'),
      username: json['username']?.toString() ?? '-',
      role: json['role']?.toString() ?? 'penumpang',
      
      // 2. CRITICAL: Look for data in the 'details' map we defined above
      idPelanggan: int.tryParse(details['id']?.toString() ?? json['id_pelanggan']?.toString() ?? '0'),
      
      // This handles both "nama_penumpang" (Database) and "nama" (Generic)
      namaLengkap: details['nama_penumpang'] ?? details['nama'] ?? json['nama_penumpang'] ?? "Pengguna",
      
      nik: details['nik']?.toString() ?? '-',
      telp: details['telp']?.toString() ?? '-',
    );
  }
}