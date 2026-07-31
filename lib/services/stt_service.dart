// Windows-safe stub — speech_to_text not available
class SttService {
  static final SttService _i = SttService._();
  factory SttService() => _i;
  SttService._();
  Future<bool> initialize() async => false;
  Stream<String> get onResult => const Stream.empty();
  Future<void> startListening() async {}
  Future<void> stopListening() async {}
}
