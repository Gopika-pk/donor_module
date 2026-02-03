class ApiConfig {
  // IMPORTANT: Update this IP address based on your network configuration
  // 
  // For USB Debugging with Physical Device:
  // - Use your computer's local IP address (e.g., 192.168.x.x)
  // - Make sure your phone and computer are on the same WiFi network
  // - Run 'ipconfig' (Windows) or 'ifconfig' (Mac/Linux) to find your IP
  //
  // For Android Emulator:
  // - Use: http://10.0.2.2:5000
  //
  // Current network IP: 192.168.189.38
  
  static const String baseUrl = 'http://192.168.189.38:5000';
  
  // API Endpoints
  static const String adminLogin = '$baseUrl/api/admin/login';
  static const String adminCamps = '$baseUrl/api/admin/camps';
  static const String adminCreateCamp = '$baseUrl/api/admin/create-camp';
  static const String adminRegisterDisaster = '$baseUrl/api/admin/register-disaster';
  static const String adminDisasters = '$baseUrl/api/admin/disasters';
  
  static const String campManagerLogin = '$baseUrl/api/camp-manager/login';
  static const String campManagerRegister = '$baseUrl/api/camp-manager/register';
  
  static const String inventory = '$baseUrl/inventory';
  static const String campRequest = '$baseUrl/camp-request';
  static const String inmates = '$baseUrl/inmates';
  
  static const String donorDonateDirect = '$baseUrl/donor/donate-direct';
  
  // Helper method to get disaster endpoint with ID
  static String adminDisaster(String disasterId) => '$baseUrl/api/admin/disaster/$disasterId';
  
  // Helper method to get inmate endpoint with ID
  static String inmateById(String inmateId) => '$baseUrl/inmates/$inmateId';
  
  // Helper method to get donation not-receive endpoint
  static String donationNotReceive(String donationId) => '$baseUrl/camp-request/donations/$donationId/not-receive';
}
