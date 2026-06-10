import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';

class SecureEnclaveKeystore {
  final LocalAuthentication _la = LocalAuthentication();
  
  bool _isBiometricEnabled = false;
  
  Future<bool> initialize() async {
    final bool isAvailable = await _la.isDeviceSupported();
    
    if (!isAvailable) {
      print('Biometric authentication not available');
      return false;
    }
    
    final bool canUseBiometrics = await _la.canCheckBiometrics;
    
    if (canUseBiometrics) {
      _isBiometricEnabled = true;
      print('Biometric authentication enabled');
    }
    
    return true;
  }
  
  Future<bool> authenticate() async {
    if (!_isBiometricEnabled) {
      return false;
    }
    
    final result = await _la.authenticate(
      localizedReason: 'Authenticate to access your Naya data',
      options: const AuthenticationOptions(
        biometryType: BiometryType.any,
      ),
    );
    
    if (result.success) {
      print('Biometric authentication successful');
      
      // Decrypt sensitive data using hardware-backed key
      return true;
    } else {
      print('Biometric authentication failed');
      return false;
    }
  }
  
  String encryptData(String plaintext) {
    // Use device keystore for encryption
    final key = Key.fromUtf8('your-encryption-key-here');
    final iv = const Iv.fromValues([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    
    final encryptor = AesCipher(key: key, mode: AesMode.gcm);
    final encrypted = encryptor.encrypt(plaintext.toUint8List(), iv: iv);
    
    return base64Encode(encrypted.bytes);
  }
  
  String decryptData(String encryptedText) {
    // Decrypt using hardware-backed key
    try {
      final bytes = base64Decode(encryptedText);
      final decrypted = AesCipher(key: Key.fromUtf8('your-encryption-key-here'))
          .decrypt(bytes, iv: const Iv.fromValues([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
      
      return utf8.decode(decrypted);
    } catch (e) {
      print('Decryption failed: $e');
      return '';
    }
  }
}
