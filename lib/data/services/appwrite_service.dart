import 'package:appwrite/appwrite.dart';
import '../../core/constants/app_constants.dart';

class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();
  factory AppwriteService() => _instance;
  AppwriteService._internal();

  late Client _client;
  late Account _account;
  late Databases _databases;
  late Storage _storage;
  late Realtime _realtime;
  late Functions _functions;

  Client get client => _client;
  Account get account => _account;
  Databases get databases => _databases;
  Storage get storage => _storage;
  Realtime get realtime => _realtime;
  Functions get functions => _functions;

  Future<void> initialize() async {
    _client = Client()
        .setEndpoint(AppConstants.appwriteEndpoint)
        .setProject(AppConstants.appwriteProjectId);

    _account = Account(_client);
    _databases = Databases(_client);
    _storage = Storage(_client);
    _realtime = Realtime(_client);
    _functions = Functions(_client);
  }
}