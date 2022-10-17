enum SolvingStatus {
  notYet('notYet', ''),
  solving('solving', '풀이중'),
  done('done', '풀이완료');

  final String code;
  final String displayName;
  const SolvingStatus(this.code, this.displayName);

  factory SolvingStatus.getByCode(String code) {
    return SolvingStatus.values.firstWhere((value) => value.code == code, orElse: () => SolvingStatus.notYet);
  }
}
