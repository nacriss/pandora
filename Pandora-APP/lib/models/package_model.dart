// lib/models/package_model.dart

// Enum para o status da encomenda
enum PackageStatus {
  pending, // Aguardando chegada
  arrived, // Chegou na caixa
  delivered, // Retirada pelo destinatário
}

class Package {
  final String id;
  final String userEmail; // CHAVE ESTRANGEIRA: Identifica o usuário
  final String sender;
  final String description;
  final PackageStatus status;
  final String estimatedDelivery;
  final String trackingCode;
  final String? photo; // Caminho local da foto (opcional)

  Package({
    required this.id,
    required this.userEmail,
    required this.sender,
    required this.description,
    required this.status,
    required this.estimatedDelivery,
    required this.trackingCode,
    this.photo,
  });

  // Converte Enum para String
  String get statusString => status.toString().split('.').last;

  // Converte String para Enum
  static PackageStatus statusFromString(String status) {
    switch (status) {
      case 'arrived':
        return PackageStatus.arrived;
      case 'delivered':
        return PackageStatus.delivered;
      case 'pending':
      default:
        return PackageStatus.pending;
    }
  }

  // Converte o modelo para Map (para o SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userEmail': userEmail,
      'sender': sender,
      'description': description,
      'status': statusString,
      'estimatedDelivery': estimatedDelivery,
      'trackingCode': trackingCode,
      'photo': photo,
    };
  }

  // Cria o modelo a partir de um Map
  factory Package.fromMap(Map<String, dynamic> map) {
    return Package(
      id: map['id'] as String,
      userEmail: map['userEmail'] as String,
      sender: map['sender'] as String,
      description: map['description'] as String,
      status: statusFromString(map['status'] as String),
      estimatedDelivery: map['estimatedDelivery'] as String,
      trackingCode: map['trackingCode'] as String,
      photo: map['photo'] as String?,
    );
  }

  // Permite criar uma cópia modificando apenas alguns campos
  Package copyWith({
    String? id,
    String? userEmail,
    String? sender,
    String? description,
    PackageStatus? status,
    String? estimatedDelivery,
    String? trackingCode,
    String? photo,
  }) {
    return Package(
      id: id ?? this.id,
      userEmail: userEmail ?? this.userEmail,
      sender: sender ?? this.sender,
      description: description ?? this.description,
      status: status ?? this.status,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      trackingCode: trackingCode ?? this.trackingCode,
      photo: photo ?? this.photo,
    );
  }
}
