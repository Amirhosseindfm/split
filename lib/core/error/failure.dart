/// دسته‌بندی خطاهای قابل نمایش به کاربر با پیام فارسی و انسانی.
/// هیچ Exception خامی نباید مستقیماً به UI برسد؛ همیشه از این کلاس عبور کن.
sealed class Failure {
  final String messageFa;
  const Failure(this.messageFa);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('اتصال اینترنت برقرار نیست. لطفاً دوباره تلاش کنید.');
}

class ServerFailure extends Failure {
  const ServerFailure() : super('خطایی در سرور رخ داد. لطفاً بعداً تلاش کنید.');
}

class AuthFailure extends Failure {
  const AuthFailure([String? custom])
      : super(custom ?? 'خطا در احراز هویت. لطفاً دوباره وارد شوید.');
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.messageFa);
}

class SyncFailure extends Failure {
  const SyncFailure() : super('همگام‌سازی اطلاعات با مشکل مواجه شد.');
}

class DatabaseFailure extends Failure {
  const DatabaseFailure() : super('خطا در ذخیره‌سازی اطلاعات.');
}

class UnknownFailure extends Failure {
  const UnknownFailure() : super('خطای غیرمنتظره‌ای رخ داد.');
}

/// تبدیل هر Exception به یک Failure قابل نمایش. جای مرکزی مدیریت خطا.
Failure mapExceptionToFailure(Object error) {
  final message = error.toString().toLowerCase();
  if (message.contains('socket') || message.contains('network')) {
    return const NetworkFailure();
  }
  if (message.contains('auth') || message.contains('unauthorized')) {
    return const AuthFailure();
  }
  if (message.contains('database') || message.contains('sqlite')) {
    return const DatabaseFailure();
  }
  if (message.contains('sync')) {
    return const SyncFailure();
  }
  return const UnknownFailure();
}
