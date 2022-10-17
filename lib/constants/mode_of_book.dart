enum ModeOfBook {
  normal('normal', '기본'),
  test('test', '시험'),
  timeAttack('timeAttack', '타임어택');

  final String code;
  final String displayName;
  const ModeOfBook(this.code, this.displayName);

  factory ModeOfBook.getByCode(String code) {
    return ModeOfBook.values.firstWhere((value) => value.code == code, orElse: () => ModeOfBook.normal);
  }
}
