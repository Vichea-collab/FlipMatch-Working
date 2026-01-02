class CardEntity {
  final int id;
  final String symbol;
  final bool isPlaceholder;
  final bool isRevealed;
  final bool isMatched;

  const CardEntity({
    required this.id,
    required this.symbol,
    this.isPlaceholder = false,
    this.isRevealed = false,
    this.isMatched = false,
  });

  CardEntity copyWith({
    bool? isRevealed,
    bool? isMatched,
  }) {
    return CardEntity(
      id: id,
      symbol: symbol,
      isPlaceholder: isPlaceholder,
      isRevealed: isRevealed ?? this.isRevealed,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}
