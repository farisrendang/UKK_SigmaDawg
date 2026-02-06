class UserModel {
  final String id;
  final String username;
  final String role; // 'admin' atau 'pelanggan'
  final String namaLengkap;

  UserModel({
    required this.id,
    required this.username,
    required this.role,
    required this.namaLengkap,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Cek apakah ada objek 'profile' (Struktur Login Admin punya profile)
    var profile = json['profile'];
    
    return UserModel(
      // Ambil ID dari 'user_id' (Admin) atau 'id_user' (Pelanggan)
      id: json['user_id']?.toString() ?? json['id_user']?.toString() ?? '',
      
      // Username mungkin tidak dikembalikan API response, jadi kita isi default/kosong
      username: json['username'] ?? '',
      
      // KUNCI: Ambil role langsung dari root data (sesuai JSON kamu: "role": "admin")
      role: json['role'] ?? 'pelanggan', 
      
      // Ambil nama dari profile->nama_petugas (Admin) atau fallback ke nama pelanggan
      namaLengkap: profile != null 
          ? profile['nama_petugas'] 
          : (json['nama_lengkap'] ?? json['nama_penumpang'] ?? 'User'),
    );
  }
}