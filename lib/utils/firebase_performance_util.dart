
// Placeholder implementation that does nothing but maintains the API
class FirebasePerformanceUtil {
  static Future<void> trackScreenLoadTime(String screenName, Future<void> Function() loadFunction) async {
    // No-op implementation
    await loadFunction();
  }
  
  static Future<T> trackNetworkRequest<T>(
    String name, 
    String url, 
    Future<T> Function() networkFunction
  ) async {
    // No-op implementation
    return await networkFunction();
  }
}
