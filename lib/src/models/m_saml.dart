/// SAML certificate status model
class MSamlCertificateStatus {
  final bool idpCertificateFile;
  final bool publicCertificateFile;
  final bool privateKeyFile;

  MSamlCertificateStatus({
    required this.idpCertificateFile,
    required this.publicCertificateFile,
    required this.privateKeyFile,
  });

  factory MSamlCertificateStatus.fromJson(Map<String, dynamic> json) {
    return MSamlCertificateStatus(
      idpCertificateFile: json['idp_certificate_file'] ?? false,
      publicCertificateFile: json['public_certificate_file'] ?? false,
      privateKeyFile: json['private_key_file'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idp_certificate_file': idpCertificateFile,
      'public_certificate_file': publicCertificateFile,
      'private_key_file': privateKeyFile,
    };
  }
}
