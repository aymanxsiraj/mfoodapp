class Users{
  String name = "";
  String phone = "";

  Users(this.name, this.phone);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
    };
  }
}