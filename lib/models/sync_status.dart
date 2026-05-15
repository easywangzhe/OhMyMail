enum SyncPhase { idle, syncing, polling, error }

class SyncStatus {
  const SyncStatus({
    required this.phase,
    this.message,
    this.accountId,
    this.updatedAt,
  });

  const SyncStatus.idle() : this(phase: SyncPhase.idle);

  final SyncPhase phase;
  final String? message;
  final String? accountId;
  final DateTime? updatedAt;
}
