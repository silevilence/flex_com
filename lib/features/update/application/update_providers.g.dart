// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the GitHub release service.

@ProviderFor(gitHubReleaseService)
const gitHubReleaseServiceProvider = GitHubReleaseServiceProvider._();

/// Provider for the GitHub release service.

final class GitHubReleaseServiceProvider
    extends
        $FunctionalProvider<
          GitHubReleaseService,
          GitHubReleaseService,
          GitHubReleaseService
        >
    with $Provider<GitHubReleaseService> {
  /// Provider for the GitHub release service.
  const GitHubReleaseServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gitHubReleaseServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gitHubReleaseServiceHash();

  @$internal
  @override
  $ProviderElement<GitHubReleaseService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GitHubReleaseService create(Ref ref) {
    return gitHubReleaseService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GitHubReleaseService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GitHubReleaseService>(value),
    );
  }
}

String _$gitHubReleaseServiceHash() =>
    r'71633cfe20756956191dd4a598b565b15dd3d671';

/// Provider for the update download service.

@ProviderFor(updateDownloadService)
const updateDownloadServiceProvider = UpdateDownloadServiceProvider._();

/// Provider for the update download service.

final class UpdateDownloadServiceProvider
    extends
        $FunctionalProvider<
          UpdateDownloadService,
          UpdateDownloadService,
          UpdateDownloadService
        >
    with $Provider<UpdateDownloadService> {
  /// Provider for the update download service.
  const UpdateDownloadServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateDownloadServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateDownloadServiceHash();

  @$internal
  @override
  $ProviderElement<UpdateDownloadService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateDownloadService create(Ref ref) {
    return updateDownloadService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateDownloadService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateDownloadService>(value),
    );
  }
}

String _$updateDownloadServiceHash() =>
    r'3bf9d8353a8ea104b241ba93cee44f2c47145690';

/// Provider for the main update service.

@ProviderFor(updateService)
const updateServiceProvider = UpdateServiceProvider._();

/// Provider for the main update service.

final class UpdateServiceProvider
    extends $FunctionalProvider<UpdateService, UpdateService, UpdateService>
    with $Provider<UpdateService> {
  /// Provider for the main update service.
  const UpdateServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateServiceHash();

  @$internal
  @override
  $ProviderElement<UpdateService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateService create(Ref ref) {
    return updateService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateService>(value),
    );
  }
}

String _$updateServiceHash() => r'f4ebba358a6cbfa334e9e3d03f580c836d46cad4';

/// Provider for the current app version string.

@ProviderFor(currentVersion)
const currentVersionProvider = CurrentVersionProvider._();

/// Provider for the current app version string.

final class CurrentVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Provider for the current app version string.
  const CurrentVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentVersionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return currentVersion(ref);
  }
}

String _$currentVersionHash() => r'638b5acacb3d470eb905bf9e08f7782c9da5a5cb';

/// Notifier for managing update check state.

@ProviderFor(UpdateChecker)
const updateCheckerProvider = UpdateCheckerProvider._();

/// Notifier for managing update check state.
final class UpdateCheckerProvider
    extends $NotifierProvider<UpdateChecker, AsyncValue<UpdateCheckResult?>> {
  /// Notifier for managing update check state.
  const UpdateCheckerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateCheckerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateCheckerHash();

  @$internal
  @override
  UpdateChecker create() => UpdateChecker();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<UpdateCheckResult?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<UpdateCheckResult?>>(
        value,
      ),
    );
  }
}

String _$updateCheckerHash() => r'df54da54c3fef89e225394b42c7a57e6221bc723';

/// Notifier for managing update check state.

abstract class _$UpdateChecker
    extends $Notifier<AsyncValue<UpdateCheckResult?>> {
  AsyncValue<UpdateCheckResult?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<UpdateCheckResult?>,
              AsyncValue<UpdateCheckResult?>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<UpdateCheckResult?>,
                AsyncValue<UpdateCheckResult?>
              >,
              AsyncValue<UpdateCheckResult?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Notifier for managing download state.

@ProviderFor(UpdateDownloader)
const updateDownloaderProvider = UpdateDownloaderProvider._();

/// Notifier for managing download state.
final class UpdateDownloaderProvider
    extends $NotifierProvider<UpdateDownloader, DownloadState> {
  /// Notifier for managing download state.
  const UpdateDownloaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateDownloaderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateDownloaderHash();

  @$internal
  @override
  UpdateDownloader create() => UpdateDownloader();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DownloadState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DownloadState>(value),
    );
  }
}

String _$updateDownloaderHash() => r'97362f0635a0c4891a43edd4557cbed813ea9d43';

/// Notifier for managing download state.

abstract class _$UpdateDownloader extends $Notifier<DownloadState> {
  DownloadState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DownloadState, DownloadState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DownloadState, DownloadState>,
              DownloadState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
